import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../pages/customer_page.dart';
import '../pages/user_management_page.dart';
import '../pages/audit_log_page.dart';
import '../../core/utils/responsive_util.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMobile = !ResponsiveUtil.isWide(context);
    
    // Mobilde her zaman geniş olsun, çünkü drawer içinde.
    // Masaüstünde collapse durumuna göre genişlik al.
    final width = isMobile ? 280.0 : (_isCollapsed ? 80.0 : 280.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Animasyon sırasında anlık genişliğe göre içerik modunu belirle
          final showCompact = constraints.maxWidth < 200;

          return Column(
            children: [
              // Header / Logo Area
              Container(
                padding: EdgeInsets.all(isMobile ? 24 : (showCompact ? 12 : 24)),
                height: 80,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: showCompact && !isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.insights_rounded, color: AppTheme.primaryColor, size: 28),
                    ),
                    if (!(showCompact && !isMobile)) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'CRM',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              if (!isMobile)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _isCollapsed ? Icons.keyboard_double_arrow_right_rounded : Icons.keyboard_double_arrow_left_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: _toggleSidebar, // LayoutBuilder içinde olduğu için _toggleSidebar erişilebilir
                  ),
                ),

              const SizedBox(height: 8),

              // Navigation Items
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: showCompact && !isMobile ? 8 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!(showCompact && !isMobile))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                          child: Text(
                            'MENÜ',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      
                      _NavItem(
                        icon: Icons.dashboard_rounded,
                        label: 'Dashboard',
                        isActive: true,
                        isCollapsed: showCompact && !isMobile,
                        onTap: () {
                          if (isMobile && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                        },
                      ),
                      
                      if (authProvider.userRole == UserRole.admin) ...[
                        const SizedBox(height: 24),
                        if (!(showCompact && !isMobile))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'YÖNETİM',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        _NavItem(
                          icon: Icons.people_outline_rounded,
                          label: 'Kullanıcılar',
                          isActive: false,
                          isCollapsed: showCompact && !isMobile,
                          onTap: () {
                            if (isMobile && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementPage()));
                          },
                        ),
                        _NavItem(
                          icon: Icons.history_rounded,
                          label: 'Denetim Kayıtları',
                          isActive: false,
                          isCollapsed: showCompact && !isMobile,
                          onTap: () {
                            if (isMobile && Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuditLogPage()));
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // User Profile Area
              Container(
                padding: EdgeInsets.all(showCompact && !isMobile ? 12 : 20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  mainAxisAlignment: showCompact && !isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        (authProvider.userName ?? 'K')[0].toUpperCase(),
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (!(showCompact && !isMobile)) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.userName ?? 'Kullanıcı',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              authProvider.userRole.name.toUpperCase(),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor, size: 20),
                        onPressed: () {
                          authProvider.signOut().then((_) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: isCollapsed ? label : '',
        child: Material(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 10, vertical: 12),
              child: Row(
                mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isActive ? AppTheme.primaryColor : Colors.grey.shade600,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? AppTheme.primaryColor : Colors.grey.shade700,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
