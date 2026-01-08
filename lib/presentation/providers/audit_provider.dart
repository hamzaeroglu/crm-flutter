import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/audit_log_model.dart';

class AuditProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AuditLogModel> _logs = [];
  List<AuditLogModel> get logs => _logs;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchLogs() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestore
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
          
      _logs = snapshot.docs.map((doc) => AuditLogModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error fetching audit logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
