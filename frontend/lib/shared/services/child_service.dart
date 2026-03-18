import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  static Future<Map<String, dynamic>?> getFirstChild() async {
    if (_uid == null) return null;
    try {
      final snap = await _db
          .collection('children')
          .where('parentId', isEqualTo: _uid)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return {'id': snap.docs.first.id, ...snap.docs.first.data()};
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllChildren() async {
    if (_uid == null) return [];
    try {
      final snap = await _db
          .collection('children')
          .where('parentId', isEqualTo: _uid)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateChild({
    required String childId,
    required String name,
    required DateTime birthDate,
    required String gender,
  }) async {
    try {
      await _db.collection('children').doc(childId).update({
        'name': name,
        'birthDate': Timestamp.fromDate(birthDate),
        'gender': gender,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
