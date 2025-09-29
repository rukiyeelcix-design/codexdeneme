import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _urlEnv = 'SUPABASE_URL';
  static const _anonKeyEnv = 'SUPABASE_ANON_KEY';

  static Future<void> ensureInitialized() async {
    final url = const String.fromEnvironment(_urlEnv);
    final anonKey = const String.fromEnvironment(_anonKeyEnv);

    if (url.isEmpty || anonKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('Supabase credentials missing; using no-op client.');
      }
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to initialise Supabase: $error');
      }
    }
  }

  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
