import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';
import '../../core/utils/responsive_util.dart';
import '../../core/theme/app_theme.dart';
import 'add_customer_page.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İşlem gerçekleştirilemedi: ${url.split(':').first}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customer = provider.findById(widget.customer.id) ?? widget.customer;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: CustomScrollView(
            slivers: [
              // Modern Flexible AppBar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Hero(
                          tag: 'avatar_${customer.id}',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    customer.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  _buildEditAction(context, customer),
                  _buildFavoriteAction(provider, customer),
                  const SizedBox(width: 12),
                ],
              ),

              // Detail Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ResponsiveUtil.isWide(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildInfoCard(context, provider, customer),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                _buildTagsSection(context, provider, customer),
                                const SizedBox(height: 24),
                                _buildNotesSection(context, provider, customer),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoCard(context, provider, customer),
                          const SizedBox(height: 24),
                          _buildTagsSection(context, provider, customer),
                          const SizedBox(height: 24),
                          _buildNotesSection(context, provider, customer),
                        ],
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditAction(BuildContext context, Customer customer) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!PermissionHelper.canUpdateCustomer(authProvider.userRole)) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddCustomerPage(customer: customer))),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteAction(CustomerProvider provider, Customer customer) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(
          customer.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          color: customer.isFavorite ? Colors.red : Colors.white,
          size: 20,
        ),
        onPressed: () => provider.toggleFavorite(customer.id),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, CustomerProvider provider, Customer customer) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _contactItem(
            context, 
            Icons.email_outlined, 
            'E-posta', 
            customer.email, 
            () => _launchUrl('mailto:${customer.email}', context)
          ),
          const Divider(height: 32),
          _contactItem(
            context, 
            Icons.phone_outlined, 
            'Telefon', 
            customer.phone, 
            () => _launchUrl('tel:${customer.phone}', context)
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Müşteri Segmenti', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 4),
                  _categoryChip(customer.category),
                ],
              ),
              DropdownButton<CustomerCategory>(
                value: customer.category,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (v) { if (v != null) provider.updateCustomerCategory(customer.id, v); },
                items: CustomerCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(_getCategoryName(c)))).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactItem(BuildContext context, IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, CustomerProvider provider, Customer customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Etiketler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...customer.tags.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close_rounded, size: 14),
                    onDeleted: () => provider.removeTag(customer.id, tag),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                  )),
                ],
              ),
              if (customer.tags.isNotEmpty) const SizedBox(height: 16),
              TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Yeni etiket ekle...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_rounded, color: AppTheme.primaryColor),
                    onPressed: () {
                      if (_tagController.text.trim().isNotEmpty) {
                        provider.addTag(customer.id, _tagController.text.trim());
                        _tagController.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, CustomerProvider provider, Customer customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notlar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...customer.notes.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: Colors.grey.shade50),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.notes_rounded, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14))),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                onPressed: () => provider.removeNote(customer.id, e.key),
              ),
            ],
          ),
        )),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Notunuzu buraya yazın...',
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primaryColor),
                  onPressed: () {
                    if (_noteController.text.trim().isNotEmpty) {
                      provider.addNote(customer.id, _noteController.text.trim());
                      _noteController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(CustomerCategory cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _getCategoryColor(cat).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        _getCategoryName(cat),
        style: TextStyle(color: _getCategoryColor(cat), fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active: return 'Aktif';
      case CustomerCategory.potential: return 'Potansiyel';
      case CustomerCategory.vip: return 'VIP';
      case CustomerCategory.inactive: return 'Pasif';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active: return Colors.green;
      case CustomerCategory.potential: return Colors.orange;
      case CustomerCategory.vip: return Colors.purple;
      case CustomerCategory.inactive: return Colors.grey;
    }
  }
}
