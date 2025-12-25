import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/customer_list_tile.dart';
import '../providers/customer_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';
import '../domain/entities/customer.dart';
import 'add_customer_page.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return 'Aktif';
      case CustomerCategory.potential:
        return 'Potansiyel';
      case CustomerCategory.vip:
        return 'VIP';
      case CustomerCategory.inactive:
        return 'Pasif';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'logout') {
                    try {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) {
                  final themeMode = Provider.of<ThemeProvider>(context, listen: false).themeMode;
                  return [
                    PopupMenuItem(
                      value: 'theme',
                      child: PopupMenuButton<ThemeMode>(
                        child: Row(
                          children: [
                            const Icon(Icons.brightness_6),
                            const SizedBox(width: 8),
                            const Text('Tema'),
                            const Spacer(),
                            Text(themeMode == ThemeMode.system
                                ? 'Sistem'
                                : themeMode == ThemeMode.light
                                    ? 'Açık'
                                    : 'Koyu'),
                          ],
                        ),
                        onSelected: (mode) => context.read<ThemeProvider>().setTheme(mode),
                        itemBuilder: (context) => [
                          CheckedPopupMenuItem(
                            value: ThemeMode.system,
                            checked: themeMode == ThemeMode.system,
                            child: const Text('Sistem'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.light,
                            checked: themeMode == ThemeMode.light,
                            child: const Text('Açık'),
                          ),
                          CheckedPopupMenuItem(
                            value: ThemeMode.dark,
                            checked: themeMode == ThemeMode.dark,
                            child: const Text('Koyu'),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Çıkış Yap'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Müşteri',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${provider.customers.length}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canCreate = PermissionHelper.canCreateCustomer(authProvider.userRole);
                              if (!canCreate) return const SizedBox.shrink();
                              return Expanded(
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const AddCustomerPage()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            size: 32,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Yeni Müşteri',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category/Favorite Filters (collapsible)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ExpansionTile(
                          title: const Text('Durum & Favori Filtreleri'),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıralama',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                DropdownButton<SortOption>(
                                  value: provider.sortOption,
                                  onChanged: (value) {
                                    if (value != null) provider.sortOption = value;
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      value: SortOption.nameAsc,
                                      child: Text('İsim A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: SortOption.nameDesc,
                                      child: Text('İsim Z-A'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('Tümü'),
                                          selected: provider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) provider.selectedCategory = null;
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...CustomerCategory.values.map((category) {
                                          final isSelected = provider.selectedCategory == category;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: FilterChip(
                                              label: Text(_getCategoryName(category)),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                provider.selectedCategory = selected ? category : null;
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                FilterChip(
                                  label: const Text('Favoriler'),
                                  selected: provider.showOnlyFavorites,
                                  onSelected: (selected) {
                                    provider.showOnlyFavorites = selected;
                                  },
                                  avatar: Icon(
                                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Filtreleri temizle'),
                                onPressed: () {
                                  provider.resetFilters();
                                  _searchController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag Filters (collapsible)
                  if (provider.allTags.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: const Text('Etiket Filtreleri'),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('Tüm Etiketler'),
                                      selected: provider.selectedTag.isEmpty,
                                      onSelected: (selected) {
                                        if (selected) provider.selectedTag = '';
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...provider.allTags.map((tag) {
                                      final isSelected = provider.selectedTag == tag;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: FilterChip(
                                          label: Text(tag),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            provider.selectedTag = selected ? tag : '';
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Müşteri ara (isim, email, telefon)',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.searchQuery = '';
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          onChanged: (value) {
                            provider.searchQuery = value;
                            setState(() {}); // suffixIcon'u güncellemek için
                          },
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Customer List
                  provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : provider.filteredCustomers.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Card(
                                  margin: const EdgeInsets.all(32.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hiç müşteri yok',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sağ üstten yeni müşteri ekleyebilirsiniz',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                    child: Consumer<AuthProvider>(
                                      builder: (context, authProvider, _) {
                                        final canUpdate = PermissionHelper.canUpdateCustomer(authProvider.userRole);
                                        final canDelete = PermissionHelper.canDeleteCustomer(authProvider.userRole);
                                        return Card(
                                          child: CustomerListTile(
                                            customer: provider.filteredCustomers[index],
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => CustomerDetailPage(
                                                    customer: provider.filteredCustomers[index],
                                                  ),
                                                ),
                                              );
                                            },
                                            onToggleFavorite: () async {
                                              try {
                                                await provider.toggleFavorite(provider.filteredCustomers[index].id);
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(e.toString())),
                                                  );
                                                }
                                              }
                                            },
                                            onEdit: canUpdate
                                                ? () {
                                                    final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => AddCustomerPage(
                                                          customer: provider.customers[originalIndex],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                : null,
                                            onDelete: canDelete
                                                ? () async {
                                                    final originalIndex = provider.customers.indexWhere((m) => m.id == provider.filteredCustomers[index].id);
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Müşteri Sil'),
                                                        content: const Text('Bu müşteriyi silmek istediğinize emin misiniz?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(false),
                                                            child: const Text('İptal'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(true),
                                                            child: const Text('Sil'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      try {
                                                        await provider.deleteCustomer(provider.customers[originalIndex].id);
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Müşteri silindi')),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text(e.toString())),
                                                          );
                                                        }
                                                      }
                                                    }
                                                  }
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                childCount: provider.filteredCustomers.length,
                              ),
                            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 