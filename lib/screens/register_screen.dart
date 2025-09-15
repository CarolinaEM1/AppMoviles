import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _obscure = true;
  File? _avatar;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  // ---------- UI helpers ----------
  void _hideBanners() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
  }

  void _showErrorBanner(String msg) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFFFEF2F2), // rosita claro
        contentTextStyle: const TextStyle(color: Color(0xFF991B1B)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _hideBanners,
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF991B1B))),
          )
        ],
      ),
    );
  }

  void _showSuccessSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Usuario registrado correctamente'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10B981), // verde
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---------- Image picking ----------
  Future<void> _pick(ImageSource src) async {
    final f = await _picker.pickImage(source: src, imageQuality: 85);
    if (f != null) setState(() => _avatar = File(f.path));
  }

  void _showPickSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF06B6D4)),
              title: const Text('Galería', style: TextStyle(color: Colors.black)),
              onTap: () { Navigator.pop(context); _pick(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF06B6D4)),
              title: const Text('Cámara', style: TextStyle(color: Colors.black)),
              onTap: () { Navigator.pop(context); _pick(ImageSource.camera); },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  // ---------- Validators ----------
  String? _req(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label es obligatorio';
    return null;
  }

  String? _email(String? v) {
    final r = _req(v, 'Email');
    if (r != null) return r;
    final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!re.hasMatch(v!.trim())) return 'Introduce un email válido';
    return null;
  }

  String? _pwd(String? v) {
    final r = _req(v, 'Password');
    if (r != null) return r;
    if (v!.trim().length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  void _submit() {
    _hideBanners();
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      // mostrar el primer error de la forma como banner
      String firstError = 'Revisa los campos marcados.';
      if ((_nameCtrl.text).trim().isEmpty) {
        firstError = 'El nombre no puede ir vacío.';
      } else if (!_emailCtrl.text.contains('@') || _email(_emailCtrl.text) != null) {
        firstError = 'El email no tiene un formato válido.';
      } else if (_pwdCtrl.text.trim().length < 6) {
        firstError = 'La contraseña debe tener al menos 6 caracteres.';
      }
      _showErrorBanner(firstError);
      return;
    }
    _showSuccessSnack();
    Navigator.pop(context);
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Header morado/indigo
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D28D9), Color(0xFF312E81)], // morado -> indigo
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar simple
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Crear cuenta',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa tus datos para registrarte',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Formulario en tarjeta flotante
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: const Color(0xFFEDE9FE), // morado muy claro
                              backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                              child: _avatar == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                            GestureDetector(
                              onTap: _showPickSheet,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4), // turquesa
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Nombre
                        _pillTextField(
                          controller: _nameCtrl,
                          label: 'Nombre completo',
                          icon: Icons.badge,
                          validator: (v) => _req(v, 'Nombre completo'),
                        ),
                        const SizedBox(height: 14),

                        // Email
                        _pillTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: _email,
                        ),
                        const SizedBox(height: 14),

                        // Password
                        _pillTextField(
                          controller: _pwdCtrl,
                          label: 'Password',
                          icon: Icons.lock,
                          obscureText: _obscure,
                          validator: _pwd,
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF06B6D4)),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Botón registrar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF06B6D4),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            child: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Custom input style (pill) ----------
  Widget _pillTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon: Icon(icon, color: const Color(0xFF06B6D4)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF6F7FB), // gris muy claro
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFF6D28D9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
      ),
    );
  }
}
