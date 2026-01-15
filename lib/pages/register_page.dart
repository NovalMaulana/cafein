import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Color _primaryColor = const Color(0xFF2C3E50);
  final Color _accentColor = const Color(0xFFD35400);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selamat! Akun berhasil dibuat.'),
            backgroundColor: Color(0xFF27AE60),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: const Color(0xFFC0392B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildRegisterCard(),
                    const SizedBox(height: 30),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryColor, const Color(0xFF1A252F)],
            ),
          ),
        ),
        Positioned(
          top: -50,
          right: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: _accentColor.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(Icons.coffee_rounded, size: 48, color: _accentColor),
        ),
        const SizedBox(height: 20),
        const Text(
          'Join the Club',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Temukan aroma kopi terbaik di sekitarmu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildField(
                  controller: _fullNameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline_rounded,
                  hint: 'Masukkan nama Anda',
                  validator: (v) => v!.length < 3 ? 'Minimal 3 karakter' : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.alternate_email_rounded,
                  hint: 'nama@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      !v!.contains('@') ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  hint: 'Min. 6 karakter',
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  icon: Icons.security_outlined,
                  hint: 'Ulangi password',
                  isPassword: true,
                  obscure: _obscureConfirmPassword,
                  onToggle: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  validator: (v) => v != _passwordController.text
                      ? 'Password tidak sama'
                      : null,
                ),
                const SizedBox(height: 35),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _primaryColor.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: Icon(icon, color: _primaryColor, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 18,
                    ),
                    onPressed: onToggle,
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _accentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: _primaryColor.withValues(alpha: 0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'BUAT AKUN',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah bergabung? ',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'MASUK DISINI',
            style: TextStyle(color: _accentColor, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
