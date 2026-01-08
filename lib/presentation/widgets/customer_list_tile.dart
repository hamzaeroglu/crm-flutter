import 'package:flutter/material.dart';
import '../domain/entities/customer.dart';
import '../../core/theme/app_theme.dart';

class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const CustomerListTile({
    Key? key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Profile Identity with Modern Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Hero(
                    tag: 'avatar_${customer.id}',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(customer.category),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              
              // Info Segment
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _infoBadge(
                          context, 
                          _getCategoryName(customer.category), 
                          _getCategoryColor(customer.category).withOpacity(0.1),
                          _getCategoryColor(customer.category),
                        ),
                        if (customer.tags.isNotEmpty)
                          _infoBadge(
                            context,
                            customer.tags.first,
                            AppTheme.accentColor.withOpacity(0.1),
                            AppTheme.accentColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      customer.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: customer.isFavorite ? Colors.red : Colors.grey.shade300,
                      size: 24,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                  _buildMoreButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400, size: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18, color: AppTheme.textPrimary),
              const SizedBox(width: 12),
              const Text('Düzenle'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 18, color: AppTheme.errorColor),
              const SizedBox(width: 12),
              const Text('Sil', style: TextStyle(color: AppTheme.errorColor)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
    );
  }

  Widget _infoBadge(BuildContext context, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
 