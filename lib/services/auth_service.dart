import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _auth = Supabase.instance.client.auth;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Stream untuk listen perubahan auth state
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // Register dengan email dan password
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Trim dan lowercase email untuk menghindari masalah whitespace
      final normalizedEmail = email.trim().toLowerCase();

      print('Attempting to register with email: $normalizedEmail'); // Debug

      final response = await _auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {'full_name': fullName.trim()},
      );

      print('SignUp response: ${response.user?.id}'); // Debug

      // Jika registrasi berhasil, simpan data user ke tabel profiles
      if (response.user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': response.user!.id,
          'email': normalizedEmail,
          'full_name': fullName.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } on AuthException catch (e) {
      // Handle specific auth errors
      print('Auth error: ${e.message}, code: ${e.statusCode}');

      if (e.message.contains('email_address_invalid')) {
        throw Exception('Format email tidak valid. Gunakan email yang benar.');
      } else if (e.message.contains('User already registered')) {
        throw Exception('Email sudah terdaftar. Silakan login.');
      } else {
        throw Exception('Registrasi gagal: ${e.message}');
      }
    } catch (e) {
      print('General error: $e');
      rethrow;
    }
  }

  // Login dengan email dan password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // Trim dan lowercase email untuk konsistensi
      final normalizedEmail = email.trim().toLowerCase();

      final response = await _auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({required String fullName}) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      await Supabase.instance.client
          .from('profiles')
          .update({
            'full_name': fullName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser!.id);
    } catch (e) {
      rethrow;
    }
  }
}
