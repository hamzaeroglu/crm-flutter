import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_management_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_util.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserManagementProvider>();
      if (provider.users.isEmpty) {
        provider.fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Kullanıcı Yönetimi'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Kullanıcı bulunamadı', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => await provider.fetchUsers(),
            child: ResponsiveUtil.isWide(context)
                ? GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtil.isDesktop(context) ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) => _userCardBuilder(context, provider, index),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) => _userCardBuilder(context, provider, index),
                  ),
          );
        },
      ),
    );
  }

  Widget _userCardBuilder(BuildContext context, UserManagementProvider provider, int index) {
    final user = provider.users[index];
    final email = user['email'] ?? 'E-posta yok';
    final currentRole = user['role'] ?? 'viewer';
    final uid = user['uid'] ?? '';
    final name = user['name'] ?? 'Kullanıcı';

    return Container(
      margin: ResponsiveUtil.isWide(context) ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildRolePicker(context, provider, uid, email, currentRole),
          ],
        ),
      ),
    );
  }

  Widget _buildRolePicker(
    BuildContext context, 
    UserManagementProvider provider, 
    String uid, 
    String email, 
    String currentRole
  ) {
    return PopupMenuButton<String>(
      onSelected: (newRole) async {
        if (newRole != currentRole) {
          try {
            await provider.updateUserRole(uid, email, currentRole, newRole);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rol $newRole olarak güncellendi'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
              );
            }
          }
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _buildPopupItem('viewer', 'Viewer', Icons.visibility_outlined),
        _buildPopupItem('agent', 'Agent', Icons.support_agent_rounded),
        _buildPopupItem('admin', 'Admin', Icons.admin_panel_settings_rounded),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getRoleColor(currentRole).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentRole.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getRoleColor(currentRole),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _getRoleColor(currentRole)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return AppTheme.errorColor;
      case 'agent': return AppTheme.secondaryColor;
      default: return Colors.grey.shade600;
    }
  }
}
