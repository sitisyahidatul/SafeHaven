import 'package:flutter/material.dart';

import '../services/session.dart';
import '../services/shelter_store.dart';
import '../theme/app_theme.dart';
import '../widgets/shelter_card.dart';
import 'shelter_detail_screen.dart';
import 'shelter_form_screen.dart';

/// Screen 4 - Main feature: scrolling list of shelters, nearest first,
/// with search and filter chips.
class ShelterListScreen extends StatefulWidget {
  const ShelterListScreen({super.key});

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  final _store = ShelterStore.instance;
  String _query = '';
  String _filter = 'All'; // All | Open | Has space | My shelters

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final items = _store.nearestFirst.where((s) {
          final matchText =
              s.name.toLowerCase().contains(_query.toLowerCase()) ||
                  s.address.toLowerCase().contains(_query.toLowerCase());
          final matchFilter = switch (_filter) {
            'Open' => s.isOpen,
            'Has space' => s.isOpen && !s.isFull,
            'My shelters' => Session.canEditShelter(s.createdBy),
            _ => true,
          };
          return matchText && matchFilter;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          // Only volunteers may add shelters.
          floatingActionButton: Session.canEdit
              ? FloatingActionButton.extended(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ShelterFormScreen()),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                )
              : null,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name or area',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final f in [
                      'All',
                      'Open',
                      'Has space',
                      if (Session.canEdit) 'My shelters',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${items.length} shelter(s) - sorted by distance'
                    '${_store.usingGps ? '' : ' (from central KL)'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(_filter == 'My shelters'
                            ? 'You have not added any shelter yet.'
                            : 'No shelters match your search.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final s = items[i];
                          return ShelterCard(
                            shelter: s,
                            distanceKm: _store.distanceKm(s),
                            onEdit: Session.canEditShelter(s.createdBy)
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ShelterFormScreen(existing: s)),
                                    )
                                : null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ShelterDetailScreen(shelter: s)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
