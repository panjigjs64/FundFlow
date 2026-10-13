import '../models/user_model.dart';
import '../repositories/local_storage.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({required this.success, required this.message, this.user});
}

class AuthService {
  final LocalStorage _storage = LocalStorage();

  // ====== REGISTER ======
  Future<AuthResult> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    // Validasi
    if (nama.trim().isEmpty) {
      return AuthResult(success: false, message: 'Nama tidak boleh kosong');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      return AuthResult(success: false, message: 'Email tidak valid');
    }
    if (password.length < 6) {
      return AuthResult(
          success: false, message: 'Kata sandi minimal 6 karakter');
    }

    // Cek duplikat
    final existing = await _storage.findUserByEmail(email);
    if (existing != null) {
      return AuthResult(
          success: false, message: 'Email sudah terdaftar');
    }

    // Simpan user
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: nama.trim(),
      email: email.trim(),
      password: password,
    );
    await _storage.addUser(user);
    await _storage.setCurrentUser(user.id);

    return AuthResult(
        success: true, message: 'Registrasi berhasil', user: user);
  }

  // ====== LOGIN ======
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final user = await _storage.findUserByEmail(email);
    if (user == null) {
      return AuthResult(
          success: false, message: 'Akun tidak ditemukan');
    }
    if (user.password != password) {
      return AuthResult(success: false, message: 'Kata sandi salah');
    }
    await _storage.setCurrentUser(user.id);
    return AuthResult(
        success: true, message: 'Login berhasil', user: user);
  }

  // ====== LOGOUT ======
  Future<void> logout() async {
    await _storage.clearSession();
  }

  // ====== CEK SESSION ======
  Future<UserModel?> getCurrentUser() async {
    final id = await _storage.getCurrentUserId();
    if (id == null) return null;
    final users = await _storage.getAllUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // ====== UPDATE PROFIL ======
  Future<UserModel?> updateProfile({
    required String userId,
    String? institusi,
    String? tingkat,
    String? tahunLulus,
    String? nomorTelepon,
  }) async {
    final users = await _storage.getAllUsers();
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx == -1) return null;

    final old = users[idx];
    final updated = UserModel(
      id: old.id,
      nama: old.nama,
      email: old.email,
      password: old.password,
      institusi: institusi ?? old.institusi,
      tingkat: tingkat ?? old.tingkat,
      tahunLulus: tahunLulus ?? old.tahunLulus,
      nomorTelepon: nomorTelepon ?? old.nomorTelepon,
    );
    users[idx] = updated;
    await _storage.saveAllUsers(users);
    return updated;
  }
}