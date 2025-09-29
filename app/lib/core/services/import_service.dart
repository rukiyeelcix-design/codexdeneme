import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/finance_provider.dart';
import 'supabase_service.dart';

class ImportCandidate {
  ImportCandidate({
    required this.kind,
    required this.date,
    required this.description,
    required this.amount,
    required this.currency,
    this.installments = 1,
    this.paid = false,
    this.mainCategory,
    this.subCategory,
    this.note,
  });

  final TransactionKind kind;
  final DateTime date;
  final String description;
  final double amount;
  final String currency;
  final int installments;
  final bool paid;
  final String? mainCategory;
  final String? subCategory;
  final String? note;
}

class OcrImportService {
  static const List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'csv',
    'xlsx',
    'xls',
    'txt',
  ];

  static Future<List<ImportCandidate>> pickCandidates(TransactionKind kind) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );
    if (result == null || result.files.isEmpty) {
      return [];
    }

    final picked = result.files.first;
    Uint8List bytes;
    if (picked.bytes != null) {
      bytes = picked.bytes!;
    } else if (picked.path != null) {
      bytes = await File(picked.path!).readAsBytes();
    } else {
      return [];
    }

    final fromSupabase = await _parseWithSupabase(bytes, picked.name, kind);
    if (fromSupabase != null && fromSupabase.isNotEmpty) {
      return fromSupabase;
    }

    return _parseLocally(bytes, picked.name, kind);
  }

  static Future<List<ImportCandidate>?> _parseWithSupabase(
    Uint8List data,
    String fileName,
    TransactionKind kind,
  ) async {
    final client = SupabaseService.client;
    if (client == null) return null;
    try {
      final response = await client.functions.invoke(
        'ocr-import',
        body: {
          'file_name': fileName,
          'file_content': base64Encode(data),
          'kind': kind.name,
        },
      );
      final payload = response.data;
      if (payload is Map && payload['transactions'] is List) {
        final List<dynamic> list = payload['transactions'] as List<dynamic>;
        return list.map((dynamic row) {
          final map = row as Map<String, dynamic>;
          return ImportCandidate(
            kind: kind,
            date: DateTime.parse(map['date'] as String),
            description: map['description'] as String? ?? '',
            amount: (map['amount'] as num?)?.toDouble() ?? 0,
            currency: map['currency'] as String? ?? 'TRY',
            installments: map['installments'] as int? ?? 1,
            paid: map['paid'] as bool? ?? false,
            mainCategory: map['main_category'] as String?,
            subCategory: map['sub_category'] as String?,
            note: map['note'] as String?,
          );
        }).toList();
      }
    } catch (error) {
      debugPrint('Supabase OCR import failed: $error');
    }
    return null;
  }

  static List<ImportCandidate> _parseLocally(
    Uint8List data,
    String fileName,
    TransactionKind kind,
  ) {
    final text = utf8.decode(data, allowMalformed: true);
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.length <= 1) {
      return [];
    }

    final delimiter = lines.first.contains(';')
        ? ';'
        : (lines.first.contains('\t') ? '\t' : ',');
    final headers = lines.first.split(delimiter).map((e) => e.trim().toLowerCase()).toList();
    final dateIndex = _matchHeader(headers, const ['tarih', 'date']);
    final descriptionIndex = _matchHeader(headers, const ['açıklama', 'description', 'ürün']);
    final amountIndex = _matchHeader(headers, const ['tutar', 'amount', 'fiyat']);
    final currencyIndex = _matchHeader(headers, const ['para birimi', 'currency']);
    final installmentsIndex = _matchHeader(headers, const ['taksit', 'installments']);

    if (dateIndex == null || descriptionIndex == null || amountIndex == null) {
      return [];
    }

    final List<ImportCandidate> candidates = [];
    for (final line in lines.skip(1)) {
      final parts = line.split(delimiter);
      if (parts.length < headers.length) continue;
      final date = _parseDate(parts[dateIndex].trim());
      if (date == null) continue;
      final description = parts[descriptionIndex].trim();
      final amount = double.tryParse(parts[amountIndex].replaceAll(',', '.').trim());
      if (amount == null) continue;
      final currency = currencyIndex != null
          ? parts[currencyIndex].trim().isNotEmpty
              ? parts[currencyIndex].trim().toUpperCase()
              : 'TRY'
          : 'TRY';
      final installments = installmentsIndex != null
          ? int.tryParse(parts[installmentsIndex].trim()) ?? 1
          : 1;
      candidates.add(
        ImportCandidate(
          kind: kind,
          date: date,
          description: description,
          amount: amount,
          currency: currency,
          installments: installments,
        ),
      );
    }
    return candidates;
  }

  static int? _matchHeader(List<String> headers, List<String> candidates) {
    for (var i = 0; i < headers.length; i++) {
      final value = headers[i];
      for (final candidate in candidates) {
        if (value.contains(candidate.toLowerCase())) {
          return i;
        }
      }
    }
    return null;
  }

  static DateTime? _parseDate(String input) {
    final normalized = input.replaceAll('.', '-').replaceAll('/', '-');
    final patterns = [
      'yyyy-MM-dd',
      'dd-MM-yyyy',
      'MM-dd-yyyy',
    ];
    for (final pattern in patterns) {
      try {
        return DateFormat(pattern).parseStrict(normalized);
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
