import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  // ===== AUTO LOGIN =====
  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _service.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  // ===== REGISTER =====
  Future<AuthResult> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    final res = await _service.register(
      nama: nama,
      email: email,
      password: password,
    );
    if (res.success) _currentUser = res.user;
    _isLoading = false;
    notifyListeners();
    return res;
  }

  // ===== LOGIN =====
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    final res = await _service.login(email: email, password: password);
    if (res.success) _currentUser = res.user;
    _isLoading = false;
    notifyListeners();
    return res;
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    await _service.logout();
    _currentUser = null;
    notifyListeners();
  }

  // ===== UPDATE PROFIL =====
  Future<void> updateProfile({
    String? institusi,
    String? tingkat,
    String? tahunLulus,
    String? nomorTelepon,
  }) async {
    if (_currentUser == null) return;
    final updated = await _service.updateProfile(
      userId: _currentUser!.id,
      institusi: institusi,
      tingkat: tingkat,
      tahunLulus: tahunLulus,
      nomorTelepon: nomorTelepon,
    );
    if (updated != null) {
      _currentUser = updated;
      notifyListeners();
    }
  }
}