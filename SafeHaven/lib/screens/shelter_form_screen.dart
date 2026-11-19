import 'package:flutter/material.dart';

import '../models/shelter.dart';
import '../services/session.dart';
import '../services/shelter_store.dart';
import '../theme/app_theme.dart';

/// Screen 6 - Create / Edit shelter form.
/// Pass [existing] to edit; leave null to create a new shelter.
class ShelterFormScreen extends StatefulWidget {
  final Shelter? existing;

  /// True when opened from the details page (so we pop back past it too).
  final bool fromDetail;
  const ShelterFormScreen({super.key, this.existing, this.fromDetail = false});

  @override
  State<ShelterFormScreen> createState() => _ShelterFormScreenState();
}

class _ShelterFormScreenState extends State<ShelterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = ShelterStore.instance;

  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _capacity;
  late final TextEditingController _occupied;
  late final TextEditingController _lat;
  late final TextEditingController _lon;
  late String _type;
  late bool _isOpen;
  late Set<String> _facilities;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _capacity = TextEditingController(text: s?.capacity.toString() ?? '');
    _occupied = TextEditingController(text: s?.occupied.toString() ?? '0');
    // New shelter: start with the current (or default KL) location so Save works
    // even when GPS is blocked. Press "Use my current location" to refresh it.
    _lat = TextEditingController(
        text: s?.lat.toString() ?? _store.userLat.toStringAsFixed(5));
    _lon = TextEditingController(
        text: s?.lon.toString() ?? _store.userLon.toStringAsFixed(5));
    _type = s?.type ?? kShelterTypes.first;
    _isOpen = s?.isOpen ?? true;
    _facilities = {...?s?.facilities};
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _address,
      _phone,
      _capacity,
      _occupied,
      _lat,
      _lon
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Device feature: fill latitude/longitude from the phone's GPS.
  Future<void> _useMyLocation() async {
    await _store.refreshLocation();
    if (!mounted) return;
    if (_store.usingGps) {
      setState(() {
        _lat.text = _store.userLat.toStringAsFixed(5);
        _lon.text = _store.userLon.toStringAsFixed(5);
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_store.message)));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final shelter = Shelter(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      address: _address.text.trim(),
      type: _type,
      lat: double.parse(_lat.text),
      lon: double.parse(_lon.text),
      capacity: int.parse(_capacity.text),
      occupied: int.parse(_occupied.text),
      phone: _phone.text.trim(),
      isOpen: _isOpen,
      facilities: _facilities.toList(),
      createdBy: widget.existing?.createdBy ?? Session.current?.email ?? '',
    );
    _editing ? _store.update(shelter) : _store.add(shelter);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_editing ? 'Shelter updated' : 'Shelter added')),
    );
    // Editing came from the detail page, so pop twice to return to the list
    // (the detail page would otherwise still show the old object).
    Navigator.pop(context);
    if (_editing && widget.fromDetail) Navigator.pop(context);
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? 'Please enter $label' : null;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit shelter' : 'Add shelter')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration:
                          const InputDecoration(labelText: 'Shelter name'),
                      validator: (v) => _required(v, 'a shelter name'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _address,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (v) => _required(v, 'an address'),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: [
                        for (final t in kShelterTypes)
                          DropdownMenuItem(value: t, child: Text(t)),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'Contact phone'),
                      validator: (v) => _required(v, 'a contact number'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _capacity,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Capacity'),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n <= 0) {
                                return 'Enter a number > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _occupied,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Occupied'),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              final cap = int.tryParse(_capacity.text);
                              if (n == null || n < 0) {
                                return 'Enter 0 or more';
                              }
                              if (cap != null && n > cap) {
                                return 'More than capacity';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Location', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lat,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration:
                                const InputDecoration(labelText: 'Latitude'),
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n < -90 || n > 90) {
                                return '-90 to 90';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lon,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration:
                                const InputDecoration(labelText: 'Longitude'),
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n < -180 || n > 180) {
                                return '-180 to 180';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _useMyLocation,
                      icon: const Icon(Icons.my_location_rounded),
                      label: const Text('Use my current location'),
                    ),
                    const SizedBox(height: 18),
                    Text('Facilities', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final f in kFacilities)
                          FilterChip(
                            label: Text(f),
                            selected: _facilities.contains(f),
                            onSelected: (on) => setState(() {
                              on ? _facilities.add(f) : _facilities.remove(f);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: AppTheme.card(),
                      child: SwitchListTile(
                        title: const Text('Shelter is open'),
                        value: _isOpen,
                        onChanged: (v) => setState(() => _isOpen = v),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(_editing ? 'Save changes' : 'Add shelter'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
