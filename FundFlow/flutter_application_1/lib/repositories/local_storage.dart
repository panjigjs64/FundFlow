import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorage {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user_id';
  static const String _simulationPrefix = 'simulation_'; // per user

  // ====== USERS ======
  Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> saveAllUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(users.map((e) => e.toJson()).toList());
    await prefs.setString(_usersKey, raw);
  }

  Future<void> addUser(UserModel user) async {
    final users = await getAllUsers();
    users.add(user);
    await saveAllUsers(users);
  }

  Future<UserModel?> findUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ====== SESSION ======
  Future<void> setCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // ====== SIMULATION STATE (per user) ======
  Future<Map<String, dynamic>?> getSimulation(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_simulationPrefix$userId');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSimulation(String userId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_simulationPrefix$userId', jsonEncode(data));
  }

  Future<void> clearSimulation(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_simulationPrefix$userId');
  }
}