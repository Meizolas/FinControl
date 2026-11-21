enum UserRole { assessor, gestor, compliance, direcao }

class AppUser {
  final String id, name, email;
  final UserRole role;
  final bool mfaEnabled;
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.mfaEnabled,
  });
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'],
    name: j['name'],
    email: j['email'],
    role: UserRole.values.byName(j['role']),
    mfaEnabled: j['mfaEnabled'] ?? false,
  );
}
