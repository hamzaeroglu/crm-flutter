import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../domain/entities/customer.dart';
import '../providers/customer_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/permission_helper.dart';

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
      // Hata durumunda kullanıcıya bilgi ver
      if (url.startsWith('mailto:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması bulunamadı')),
        );
      } else if (url.startsWith('tel:')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı')),
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
          appBar: AppBar(
            title: const Text('Müşteri Detayı'),
            actions: [
              IconButton(
                tooltip: customer.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
                icon: Icon(customer.isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => provider.toggleFavorite(customer.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Müşteri Bilgileri
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl('mailto:${customer.email}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.email, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.email, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _launchUrl('tel:${customer.phone}', context),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 20),
                                  const SizedBox(width: 8),
                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(
                                    _getCategoryName(customer.category),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getCategoryColor(customer.category),
                                ),
                                DropdownButton<CustomerCategory>(
                                  value: customer.category,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateCustomerCategory(customer.id, value);
                                    }
                                  },
                                  items: CustomerCategory.values
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(_getCategoryName(cat)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Etiketler (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Etiketler (${customer.tags.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canManageTags = PermissionHelper.canManageTags(authProvider.userRole);
                              return Column(
                                children: [
                                  if (customer.tags.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: customer.tags.map((tag) {
                                        return Chip(
                                          label: Text(tag),
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                          deleteIcon: canManageTags ? const Icon(Icons.close, size: 16) : null,
                                          onDeleted: canManageTags
                                              ? () {
                                                  provider.removeTag(customer.id, tag);
                                                }
                                              : null,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (canManageTags) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _tagController,
                                            decoration: const InputDecoration(
                                              hintText: 'Etiket adı',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_tagController.text.trim().isNotEmpty) {
                                              provider.addTag(
                                                customer.id,
                                                _tagController.text.trim(),
                                              );
                                              _tagController.clear();
                                            }
                                          },
                                          child: const Text('Ekle'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Notlar (açılır kart)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          'Notlar (${customer.notes.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        childrenPadding: const EdgeInsets.all(16.0),
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final canManageNotes = PermissionHelper.canManageNotes(authProvider.userRole);
                              return Column(
                                children: [
                                  if (customer.notes.isNotEmpty) ...[
                                    ...customer.notes.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final note = entry.value;
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          title: Text(note),
                                          trailing: canManageNotes
                                              ? IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  onPressed: () {
                                                    provider.removeNote(customer.id, index);
                                                  },
                                                )
                                              : null,
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 12),
                                  ],
                                  if (canManageNotes) ...[
                                    TextField(
                                      controller: _noteController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText: 'Notunuzu buraya yazın...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_noteController.text.trim().isNotEmpty) {
                                            provider.addNote(
                                              customer.id,
                                              _noteController.text.trim(),
                                            );
                                            _noteController.clear();
                                          }
                                        },
                                        child: const Text('Not Ekle'),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getCategoryColor(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active:
        return Colors.green;
      case CustomerCategory.potential:
        return Colors.orange;
      case CustomerCategory.vip:
        return Colors.purple;
      case CustomerCategory.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}