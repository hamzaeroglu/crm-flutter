import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/audit_log_model.dart';

class AuditProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AuditLogModel> _logs = [];
  List<AuditLogModel> get logs => _logs;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    debugPrint('AuditProvider: Fetching logs...');
    try {
      final snapshot = await _firestore
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
          
      debugPrint('AuditProvider: Found ${snapshot.docs.length} logs');
      _logs = snapshot.docs.map((doc) => AuditLogModel.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('AuditProvider: Error fetching audit logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
