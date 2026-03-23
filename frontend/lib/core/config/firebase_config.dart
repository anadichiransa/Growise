import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static Future<void> enableFirestoreOffline() async {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      print('Firestore offline settings failed: ');
    }
  }
}
