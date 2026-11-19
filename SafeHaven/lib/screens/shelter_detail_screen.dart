import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/shelter.dart';
import '../services/session.dart';
import '../services/shelter_store.dart';
import '../theme/app_theme.dart';
import '../widgets/shelter_card.dart';
import 'shelter_form_screen.dart';

/// Screen 5 - Shelter details (opened with Navigator.push, closed with pop).
class ShelterDetailScreen extends StatelessWidget {
  final Shelter shelter;
  const ShelterDetailScreen({super.key, required this.shelter});

  Future<void> _openDirections(BuildContext context) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${shelter.lat},${shelter.lon}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) throw Exception('cannot open');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the map.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ShelterStore.instance;
    final text = Theme.of(context).textTheme;

    // Rebuild when the shelter is edited.
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final color = statusColor(shelter);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shelter details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // An admin may edit only the shelters they added.
              if (Session.canEditShelter(shelter.createdBy))
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ShelterFormScreen(
                            existing: shelter, fromDetail: true)),
                  ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(typeIcon(shelter.type),
                              color: AppTheme.primary, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(shelter.name, style: text.titleLarge),
                              Text(shelter.type, style: text.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StatusPill(shelter),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 20, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                            child:
                                Text(shelter.address, style: text.bodyMedium)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk_rounded,
                            size: 20, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                            '${store.distanceKm(shelter).toStringAsFixed(1)} km from you',
                            style: text.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 20, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(shelter.phone, style: text.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Capacity', style: text.titleMedium),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: shelter.fill.clamp(0.0, 1.0),
                        minHeight: 12,
                        color: color,
                        backgroundColor: const Color(0xFFE2E8F0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${shelter.occupied} / ${shelter.capacity} occupied',
                            style: text.bodyMedium),
                        Text('${shelter.available} left',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: color)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppTheme.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Facilities', style: text.titleMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final f in shelter.facilities)
                          Chip(
                            label: Text(f),
                            backgroundColor:
                                AppTheme.primary.withValues(alpha: 0.08),
                            side: BorderSide.none,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _openDirections(context),
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Get directions'),
              ),
            ],
          ),
        );
      },
    );
  }
}
