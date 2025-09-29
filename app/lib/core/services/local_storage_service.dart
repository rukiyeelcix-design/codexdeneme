import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static Future<void> ensureInitialized() async {
    if (!Hive.isAdapterRegistered(0)) {
      // Reserved for future Hive adapters.
    }
  }
}
