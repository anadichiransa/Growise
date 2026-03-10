import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {

  
  /// Enable Firestore offline persistence
  /// 
  /// This allows the app to work without internet.
  /// Data is cached locally and synced when online.
  static Future<void> enableFirestoreOffline() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,  // Enable offline cache
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,  // Unlimited cache
    );
  }
}