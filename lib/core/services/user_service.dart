import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Doc ID'yi dataya ekle
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Kullanıcılar yüklenirken hata oluştu: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
    } catch (e) {
      throw Exception('Rol güncellenirken hata oluştu: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Kullanıcı silinirken hata oluştu: $e');
    }
  }
}
