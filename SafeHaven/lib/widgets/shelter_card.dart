import 'package:flutter/material.dart';

import '../models/shelter.dart';
import '../theme/app_theme.dart';

Color statusColor(Shelter s) {
  if (!s.isOpen) return AppTheme.muted;
  if (s.isFull) return AppTheme.danger;
  if (s.fill > 0.7) return AppTheme.warn;
  return AppTheme.ok;
}

String statusLabel(Shelter s) {
  if (!s.isOpen) return 'Closed';
  if (s.isFull) return 'Full';
  if (s.fill > 0.7) return 'Almost full';
  return 'Space available';
}

/// A different icon for each shelter type.
IconData typeIcon(String type) {
  switch (type) {
    case 'School':
      return Icons.school_rounded;
    case 'Community hall':
      return Icons.groups_rounded;
    case 'Mosque / Surau':
      return Icons.mosque_rounded;
    case 'Stadium':
      return Icons.stadium_rounded;
    default:
      return Icons.home_work_rounded;
  }
}

class StatusPill extends StatelessWidget {
  final Shelter shelter;
  const StatusPill(this.shelter, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(shelter);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c),
      ),
      child: Text(
        statusLabel(shelter),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

/// One row in the shelter list. InkWell gives the tap ripple + gesture.
class ShelterCard extends StatelessWidget {
  final Shelter shelter;
  final double distanceKm;
  final VoidCallback onTap;

  /// Set only for a volunteer's own shelter: shows a quick Edit button.
  final VoidCallback? onEdit;

  const ShelterCard({
    super.key,
    required this.shelter,
    required this.distanceKm,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.card(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(typeIcon(shelter.type),
                      color: AppTheme.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shelter.name,
                          style: text.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(shelter.type, style: text.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusPill(shelter),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${shelter.available} places left',
                              style: text.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    if (onEdit != null)
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Icon(Icons.edit_rounded,
                              size: 22, color: AppTheme.accent),
                        ),
                      ),
                    Text(
                      distanceKm.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary),
                    ),
                    Text('km', style: text.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
