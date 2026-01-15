import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _auth = Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      print('Attempting to register with email: $normalizedEmail');

      final response = await _auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {'full_name': fullName.trim()},
      );

      print('SignUp response: ${response.user?.id}'); 

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

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
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

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

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
