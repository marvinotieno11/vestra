import 'package:shared_preferences/shared_preferences.dart';

class UserAccountStore {
  static String? fullName;
  static String? email;
  static String? password;

  static bool isLoggedIn = false;

  static const String _nameKey = 'user_full_name';
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';

  static Future<void> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();

    fullName = prefs.getString(_nameKey);
    email = prefs.getString(_emailKey);
    password = prefs.getString(_passwordKey);

    isLoggedIn = false;
  }

  static Future<void> createAccount({
    required String name,
    required String userEmail,
    required String userPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    fullName = name.trim();
    email = userEmail.trim().toLowerCase();
    password = userPassword;

    await prefs.setString(_nameKey, fullName!);
    await prefs.setString(_emailKey, email!);
    await prefs.setString(_passwordKey, password!);

    isLoggedIn = true;
  }

  static Future<bool> login({
    required String userEmail,
    required String userPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    email ??= prefs.getString(_emailKey);
    password ??= prefs.getString(_passwordKey);
    fullName ??= prefs.getString(_nameKey);

    final enteredEmail = userEmail.trim().toLowerCase();

    if (email == null || password == null) {
      return false;
    }

    if (email == enteredEmail && password == userPassword) {
      isLoggedIn = true;
      return true;
    }

    return false;
  }

  static Future<bool> accountExists(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();

    email ??= prefs.getString(_emailKey);

    final enteredEmail = userEmail.trim().toLowerCase();

    return email != null && email == enteredEmail;
  }

  static Future<bool> isCorrectPassword(String userPassword) async {
    final prefs = await SharedPreferences.getInstance();

    password ??= prefs.getString(_passwordKey);

    return password != null && password == userPassword;
  }

  static void signOut() {
    isLoggedIn = false;
  }

  static Future<void> clearAccount() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);

    fullName = null;
    email = null;
    password = null;
    isLoggedIn = false;
  }
}
