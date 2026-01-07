import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String id;
  final String userId;
  final String userEmail;
  final String action; // e.g., 'CREATE_CUSTOMER', 'DELETE_CUSTOMER', 'CHANGE_ROLE'
  final String details;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'action': action,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory AuditLogModel.fromJson(Map<String, dynamic> json, String id) {
    return AuditLogModel(
      id: id,
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      action: json['action'] ?? '',
      details: json['details'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
