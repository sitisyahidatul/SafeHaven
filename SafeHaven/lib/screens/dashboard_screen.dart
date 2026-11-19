import 'package:flutter/material.dart';

import '../services/session.dart';
import '../services/shelter_store.dart';
import '../theme/app_theme.dart';
import '../widgets/shelter_card.dart';
import 'shelter_detail_screen.dart';
import 'shelter_form_screen.dart';
import 'shelter_list_screen.dart';

/// Screen 3 - Dashboard: summary + BottomNavigationBar (Home / Shelters / Profile).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // Ask for the device location as soon as the dashboard opens.
    ShelterStore.instance.refreshLocation();
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['SafeHaven', 'Nearby shelters', 'Profile'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab])),
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(onSeeAll: () => setState(() => _tab = 1)),
          const ShelterListScreen(),
          _ProfileTab(onChanged: () => setState(() {})),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_city_rounded), label: 'Shelters'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _HomeTab({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final store = ShelterStore.instance;
    final text = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final nearest = store.nearestOpenWithSpace;
        final mine = store.nearestFirst
            .where((s) => Session.canEditShelter(s.createdBy))
            .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Hello, ${Session.current?.name ?? 'there'}!',
                style: text.headlineMedium),
            const SizedBox(height: 4),
            Text('Find the nearest open shelter with space.',
                style: text.bodySmall),
            const SizedBox(height: 16),

            // ---- Location status card (device feature) ----
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.card(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (store.usingGps ? AppTheme.ok : AppTheme.warn)
                          .withValues(alpha: 0.15),
                    ),
                    child: store.status == LocationStatus.loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5))
                        : Icon(
                            store.usingGps
                                ? Icons.my_location_rounded
                                : Icons.location_off_rounded,
                            color:
                                store.usingGps ? AppTheme.ok : AppTheme.warn),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your location', style: text.titleMedium),
                        Text(store.message, style: text.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh location',
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppTheme.primary),
                    onPressed: store.refreshLocation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Summary stats (Row + Expanded) ----
            Row(
              children: [
                Expanded(
                    child: _Stat('${store.totalCount}', 'Shelters',
                        Icons.home_work_rounded, AppTheme.primary)),
                const SizedBox(width: 10),
                Expanded(
                    child: _Stat('${store.openCount}', 'Open now',
                        Icons.check_circle_rounded, AppTheme.ok)),
                const SizedBox(width: 10),
                Expanded(
                    child: _Stat('${store.freeBeds}', 'Free places',
                        Icons.hotel_rounded, AppTheme.info)),
              ],
            ),
            const SizedBox(height: 24),

            if (Session.canEdit) ...[
              // Admin: show the shelters they added, with a quick Edit icon.
              Text('My shelters (${mine.length})', style: text.titleLarge),
              const SizedBox(height: 10),
              if (mine.isEmpty)
                Text('You have not added any shelter yet. Tap "Add shelter".',
                    style: text.bodyMedium)
              else
                for (final s in mine.take(3))
                  ShelterCard(
                    shelter: s,
                    distanceKm: store.distanceKm(s),
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ShelterFormScreen(existing: s)),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ShelterDetailScreen(shelter: s)),
                    ),
                  ),
            ] else ...[
              Text('Nearest open shelter', style: text.titleLarge),
              const SizedBox(height: 10),
              if (nearest == null)
                Text('No open shelter with space right now.',
                    style: text.bodyMedium)
              else
                ShelterCard(
                  shelter: nearest,
                  distanceKm: store.distanceKm(nearest),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ShelterDetailScreen(shelter: nearest)),
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSeeAll,
                    icon: const Icon(Icons.list_rounded),
                    label: const Text('All shelters'),
                  ),
                ),
                // Only admins may add shelters.
                if (Session.canEdit) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ShelterFormScreen()),
                      ),
                      icon: const Icon(Icons.add_location_alt_rounded),
                      label: const Text('Add shelter'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _Stat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: AppTheme.card(),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final VoidCallback onChanged;
  const _ProfileTab({required this.onChanged});

  void _info(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.card(),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(Session.current?.name ?? 'Guest', style: text.titleLarge),
              Text(Session.current?.email ?? '', style: text.bodySmall),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  Session.current?.roleLabel ?? 'User',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppTheme.card(),
          child: Column(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.edit_outlined, color: AppTheme.primary),
                title: const Text('Edit profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Edit profile: coming in a later practical (needs the database)'))),
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.lock_outline, color: AppTheme.primary),
                title: const Text('Change password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Change password: coming in a later practical (needs the database)'))),
              ),
              const Divider(height: 1),
              if (Session.canEdit)
                ListenableBuilder(
                  listenable: ShelterStore.instance,
                  builder: (context, _) {
                    final n = ShelterStore.instance.nearestFirst
                        .where((s) => Session.canEditShelter(s.createdBy))
                        .length;
                    return ListTile(
                      leading: const Icon(Icons.home_work_outlined,
                          color: AppTheme.primary),
                      title: const Text('Shelters added'),
                      trailing: Text('$n',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary)),
                    );
                  },
                )
              else
                ListTile(
                  leading:
                      const Icon(Icons.call_outlined, color: AppTheme.primary),
                  title: const Text('Emergency numbers'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _info(context, 'Emergency numbers',
                      'Police / Ambulance: 999\nFire and Rescue: 994\nMobile emergency: 112'),
                ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.info_outline, color: AppTheme.primary),
                title: const Text('About SafeHaven'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _info(context, 'About SafeHaven',
                    'SafeHaven helps people find the nearest open disaster shelter, with distance, address and places left.\n\nIt supports SDG 11: Sustainable Cities and Communities, by making communities safer and more resilient during disasters.'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.danger),
                title: const Text('Log out'),
                onTap: () {
                  Session.logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
