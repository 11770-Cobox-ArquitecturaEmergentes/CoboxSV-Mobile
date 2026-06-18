enum UserRole {
  driver('Conductor', 'driver'),
  admin('Administrador', 'admin'),
  supervisor('Supervisor', 'supervisor');

  const UserRole(this.label, this.value);

  final String label;
  final String value;

  int get priority {
    switch (this) {
      case UserRole.admin:
        return 1;
      case UserRole.supervisor:
        return 2;
      case UserRole.driver:
        return 3;
    }
  }

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.driver,
    );
  }
}
