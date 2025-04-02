library globals;

Map<String, dynamic>? user;
String? role;

void setUser(Map<String, dynamic>? newUser, String? newRole) {
  user = newUser;
  role = newRole;
}

void clearUser() {
  user = null;
  role = null;
}
