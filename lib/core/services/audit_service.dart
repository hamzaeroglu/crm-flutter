import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/audit_log_model.dart';
import 'package:uuid/uuid.dart';

class AuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logAction({
    required String action,
    required String details,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return; // Sadece giriş yapmış kullanıcılar loglayabilir

    final log = AuditLogModel(
      id: const Uuid().v4(),
      userId: user.uid,
      userEmail: user.email ?? 'unknown',
      action: action,
      details: details,
      timestamp: DateTime.now(),
    );

    try {
      await _firestore.collection('audit_logs').doc(log.id).set(log.toJson());
      print('AuditService: Action logged successfully: $action');
    } catch (e) {
      // Loglama hatası uygulamayı durdurmamalı, sadece konsola yazalım
      print('AuditService: Audit logging failed: $e');
    }
  }
}
