import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';
import '../../core/theme/app_theme.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';
import 'user_management_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomerProvider>();
      if (provider.customers.isEmpty) {
        provider.fetchCustomers();
      }
    });
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active: return 'Aktif';
      case CustomerCategory.potential: return 'Potansiyel';
      case CustomerCategory.vip: return 'VIP';
      case CustomerCategory.inactive: return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Premium Animated AppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                'CRM Dashboard',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              _buildActionMenu(context, authProvider),
              const SizedBox(width: 12),
            ],
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Highlights
                  _buildStatsSection(customerProvider),
                  const SizedBox(height: 32),
                  
                  // Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Müşteri Listesi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (PermissionHelper.canCreateCustomer(authProvider.userRole))
                        _buildAddButton(context),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Modern Search Bar
                  _buildSearchBar(customerProvider),
                  const SizedBox(height: 16),

                  // Horizontal Category Filter
                  _buildCategoryFilter(customerProvider),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // List Content
          _buildCustomerList(customerProvider, authProvider),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.menu_rounded, color: AppTheme.primaryColor, size: 20),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) {
        final isAdmin = authProvider.userRole == UserRole.admin;
        return [
          if (isAdmin)
            PopupMenuItem(
              value: 'users',
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Kullanıcı Yönetimi'),
                ],
              ),
              onTap: () => Future.delayed(
                const Duration(milliseconds: 100),
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementPage())),
              ),
            ),
          PopupMenuItem(
            value: 'logout',
            child: const Row(
              children: [
                Icon(Icons.logout_rounded, size: 20, color: AppTheme.errorColor),
                SizedBox(width: 12),
                Text('Çıkış Yap', style: TextStyle(color: AppTheme.errorColor)),
              ],
            ),
            onTap: () => authProvider.signOut().then((_) => Navigator.of(context).pushReplacementNamed('/login')),
          ),
        ];
      },
    );
  }

  Widget _buildStatsSection(CustomerProvider provider) {
    return Row(
      children: [
        _statCard(
          context,
          'Toplam',
          '${provider.customers.length}',
          Icons.people_alt_rounded,
          AppTheme.primaryColor,
        ),
        const SizedBox(width: 16),
        _statCard(
          context,
          'Favori',
          '${provider.customers.where((c) => c.isFavorite).length}',
          Icons.favorite_rounded,
          AppTheme.secondaryColor,
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddCustomerPage())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text('Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(CustomerProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => provider.searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Müşteri, e-posta veya telefon ara...',
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () { _searchController.clear(); provider.searchQuery = ''; setState(() {}); },
              )
            : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(CustomerProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterChip(
            'Hepsi', 
            provider.selectedCategory == null, 
            () => provider.selectedCategory = null
          ),
          ...CustomerCategory.values.map((c) => _filterChip(
            _getCategoryName(c), 
            provider.selectedCategory == c, 
            () => provider.selectedCategory = c
          )),
          const SizedBox(width: 8),
          VerticalDivider(color: Colors.grey.shade300, indent: 8, endIndent: 8),
          const SizedBox(width: 8),
          _filterChip(
            'Sadece Favoriler', 
            provider.showOnlyFavorites, 
            () => provider.showOnlyFavorites = !provider.showOnlyFavorites,
            icon: provider.showOnlyFavorites ? Icons.favorite_rounded : Icons.favorite_outline_rounded
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: icon != null ? Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.primaryColor) : null,
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.primaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildCustomerList(CustomerProvider provider, AuthProvider authProvider) {
    if (provider.isLoading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    }

    if (provider.filteredCustomers.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Sonuç Bulunamadı', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            Text('Filtreleri veya aramayı değiştirmeyi deneyin.', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final customer = provider.filteredCustomers[index];
            return CustomerListTile(
              customer: customer,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CustomerDetailPage(customer: customer))),
              onToggleFavorite: () => provider.toggleFavorite(customer.id),
              onEdit: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddCustomerPage(customer: customer))),
              onDelete: () => _confirmDelete(context, provider, customer),
            );
          },
          childCount: provider.filteredCustomers.length,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CustomerProvider provider, Customer customer) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 48),
            const SizedBox(height: 16),
            const Text('Müşteriyi Sil?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${customer.name} isimli müşteriyi silmek istediğinize emin misiniz?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirm == true) await provider.deleteCustomer(customer.id);
  }
}
 