enum UserRole { user, admin }

class AppUser {
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  const AppUser(this.name, this.email, this.role, {this.phone = ''});

  String get roleLabel => role == UserRole.admin ? 'Admin' : 'User';

  AppUser copyWith({String? name, String? phone}) =>
      AppUser(name ?? this.name, email, role, phone: phone ?? this.phone);
}

/// Who is logged in, and what they may do.
/// PROTOTYPE ONLY: users and admin codes live in memory / in code.
/// In Practical 2 both move into database tables (`users` and `admin_codes`),
/// and Edit profile / Change password will save to the `users` table.
class Session {
  /// Sample organisation / admin ID codes. A person can only register as a
  /// Admin if they type one of these. (Practical 2: stored in a database.)
  static const List<String> validAdminCodes = [
    'SH-ADM-2026',
    'SH-ADM-2027',
  ];

  static bool isValidAdminCode(String code) =>
      validAdminCodes.contains(code.trim().toUpperCase());

  /// Demo accounts (any password with 6+ characters):
  ///   user,      user@shelter.com       -> can only view shelters
  ///   admin, admin@shelter.com  -> can also add and edit shelters
  static final Map<String, AppUser> _users = {
    'user@shelter.com': const AppUser(
        'Demo User', 'user@shelter.com', UserRole.user,
        phone: '012-3456789'),
    'admin@shelter.com': const AppUser(
        'Demo Admin', 'admin@shelter.com', UserRole.admin,
        phone: '013-9876543'),
  };

  static AppUser? current;

  /// Only admins may add or edit shelters.
  static bool get canEdit => current?.role == UserRole.admin;

  /// An admin may edit only the shelters they added themselves.
  /// (Practical 2: compare with the `created_by` column in the database.)
  static bool canEditShelter(String createdBy) =>
      canEdit && current?.email == createdBy.trim().toLowerCase();

  static void register(String name, String email, UserRole role,
      {String phone = ''}) {
    final key = email.trim().toLowerCase();
    _users[key] = AppUser(name.trim(), key, role, phone: phone.trim());
  }

  /// No password check yet (no database). An unknown email logs in as a User,
  /// the safest role, so nobody gains edit rights without a valid admin code.
  static void login(String email) {
    final key = email.trim().toLowerCase();
    current = _users[key] ?? AppUser(key.split('@').first, key, UserRole.user);
  }

  /// Edit profile (kept in memory only for now; Practical 2: update `users` table).
  static void updateProfile({required String name, required String phone}) {
    final u = current;
    if (u == null) return;
    final updated = u.copyWith(name: name.trim(), phone: phone.trim());
    _users[u.email] = updated;
    current = updated;
  }

  static void logout() => current = null;
}
