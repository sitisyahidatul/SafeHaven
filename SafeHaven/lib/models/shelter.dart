class Shelter {
  final String id;
  String name;
  String address;
  String type;
  double lat;
  double lon;
  int capacity;
  int occupied;
  String phone;
  bool isOpen;
  List<String> facilities;
  String createdBy; // email of the Volunteer who added it

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.lat,
    required this.lon,
    required this.capacity,
    required this.occupied,
    required this.phone,
    required this.isOpen,
    required this.facilities,
    this.createdBy = '',
  });

  int get available => (capacity - occupied).clamp(0, capacity);
  double get fill => capacity == 0 ? 1 : occupied / capacity;
  bool get isFull => available == 0;
}

const List<String> kShelterTypes = [
  'School',
  'Community hall',
  'Mosque / Surau',
  'Stadium',
  'Other',
];

const List<String> kFacilities = [
  'Water',
  'Food',
  'Medical',
  'Toilets',
  'Power',
  'Wheelchair access',
];

/// Hard-coded SAMPLE data (no database until Practical 2).
/// Names and coordinates are illustrative only.
List<Shelter> sampleShelters() => [
      Shelter(
        createdBy: 'volunteer@shelter.com',
        id: 's1',
        name: 'SK Taman Melati Hall',
        address: 'Jalan Melati 2, Taman Melati, Kuala Lumpur',
        type: 'School',
        lat: 3.2100,
        lon: 101.7270,
        capacity: 300,
        occupied: 120,
        phone: '03-4100 1001',
        isOpen: true,
        facilities: ['Water', 'Food', 'Toilets', 'Power'],
      ),
      Shelter(
        createdBy: 'volunteer@shelter.com',
        id: 's2',
        name: 'Dewan Komuniti Setapak',
        address: 'Jalan Genting Klang, Setapak, Kuala Lumpur',
        type: 'Community hall',
        lat: 3.1990,
        lon: 101.7080,
        capacity: 150,
        occupied: 140,
        phone: '03-4022 2002',
        isOpen: true,
        facilities: ['Water', 'Toilets', 'Medical'],
      ),
      Shelter(
        createdBy: 'volunteer@shelter.com',
        id: 's3',
        name: 'Surau Al-Hidayah',
        address: 'Lorong Sentul 5, Sentul, Kuala Lumpur',
        type: 'Mosque / Surau',
        lat: 3.1830,
        lon: 101.6930,
        capacity: 80,
        occupied: 80,
        phone: '03-4041 3003',
        isOpen: true,
        facilities: ['Water', 'Toilets'],
      ),
      Shelter(
        createdBy: 'volunteer@shelter.com',
        id: 's4',
        name: 'Stadium Titiwangsa Relief Centre',
        address: 'Jalan Temerloh, Titiwangsa, Kuala Lumpur',
        type: 'Stadium',
        lat: 3.1780,
        lon: 101.7050,
        capacity: 800,
        occupied: 210,
        phone: '03-4251 4004',
        isOpen: true,
        facilities: [
          'Water',
          'Food',
          'Medical',
          'Toilets',
          'Power',
          'Wheelchair access'
        ],
      ),
      Shelter(
        createdBy: 'volunteer@shelter.com',
        id: 's5',
        name: 'SMK Bukit Bintang Hall',
        address: 'Jalan Pudu, Bukit Bintang, Kuala Lumpur',
        type: 'School',
        lat: 3.1480,
        lon: 101.7140,
        capacity: 400,
        occupied: 0,
        phone: '03-2145 5005',
        isOpen: false,
        facilities: ['Water', 'Toilets', 'Power'],
      ),
      Shelter(
        createdBy: 'volunteer@shelter.com',
        id: 's6',
        name: 'Dewan Serbaguna Cheras',
        address: 'Jalan Cheras, Cheras, Kuala Lumpur',
        type: 'Community hall',
        lat: 3.1070,
        lon: 101.7270,
        capacity: 220,
        occupied: 60,
        phone: '03-9100 6006',
        isOpen: true,
        facilities: ['Water', 'Food', 'Toilets', 'Wheelchair access'],
      ),
    ];
