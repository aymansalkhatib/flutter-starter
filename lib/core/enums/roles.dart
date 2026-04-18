/// `Role` defines the different user roles in the application.
enum Role {
  // Administrator role with full access
  admin,
  // Editor role with content management privileges
  editor,
  // Viewer role with read-only access
  viewer;

  /// Returns the matching role, or `null` if not found.
  static Role? fromString(String? roleName) {
    if (roleName == null || roleName.isEmpty) {
      return null;
    }
    return Role.values.where((r) => r.name == roleName).firstOrNull;
  }

  /// Returns the matching role, or throws [ArgumentError] if not found.
  static Role fromStringOrThrow(String roleName) =>
      Role.values.byName(roleName);
}
