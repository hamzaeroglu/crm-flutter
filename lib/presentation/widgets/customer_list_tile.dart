import 'package:flutter/material.dart';
import '../domain/entities/customer.dart';

class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onCategoryChanged;

  const CustomerListTile({
    Key? key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
    this.onCategoryChanged,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              customer.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onToggleFavorite != null)
            IconButton(
              icon: Icon(
                customer.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: customer.isFavorite ? Colors.red : null,
                size: 20,
              ),
              onPressed: onToggleFavorite,
              tooltip: customer.isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  customer.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                customer.phone,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              _getCategoryName(customer.category),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            backgroundColor: _getCategoryColor(customer.category),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          if (customer.tags != null && customer.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: customer.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onEdit,
            tooltip: 'Düzenle',
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: onDelete,
            tooltip: 'Sil',
          ),
        ],
      ),
      onTap: onTap,
    );
  }
} 