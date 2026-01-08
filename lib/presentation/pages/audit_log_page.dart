import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/audit_provider.dart';
import '../../core/theme/app_theme.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({Key? key}) : super(key: key);

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().fetchLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Denetim Kayıtları'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<AuditProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.logs.isEmpty) {
            return const Center(child: Text('Kayıt bulunamadı'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final log = provider.logs[index];
              return _buildLogCard(log);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(dynamic log) {
    final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(log.timestamp);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getActionColor(log.action).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.action,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getActionColor(log.action),
                  ),
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            log.details,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                log.userEmail,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('CREATE')) return Colors.green;
    if (action.contains('DELETE')) return Colors.red;
    if (action.contains('UPDATE')) return Colors.orange;
    if (action.contains('ROLE')) return Colors.purple;
    return AppTheme.primaryColor;
  }
}
