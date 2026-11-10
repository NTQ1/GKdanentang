import 'package:flutter/material.dart';

import 'user_data.dart';

const appGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
);

void showMsg(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
}

// ======================= AVATAR =======================
class UserAvatar extends StatelessWidget {
  final String base64Image;
  final double radius;
  final Widget? placeholder;

  const UserAvatar({
    super.key,
    required this.base64Image,
    this.radius = 20,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final image = ImageHelper.toProvider(base64Image);
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE0E7FF),
      backgroundImage: image,
      child: image == null
          ? (placeholder ??
          Icon(Icons.person, size: radius, color: const Color(0xFF4F46E5)))
          : null,
    );
  }
}

/// Avatar có biểu tượng máy ảnh, bấm để chọn ảnh.
class AvatarPicker extends StatelessWidget {
  final String base64Image;
  final double radius;
  final VoidCallback onTap;

  const AvatarPicker({
    super.key,
    required this.base64Image,
    required this.onTap,
    this.radius = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        UserAvatar(base64Image: base64Image, radius: radius),
        Positioned(
          right: 0,
          bottom: 0,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}

// ======================= Ô MẬT KHẨU =======================
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Mật khẩu',
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _hide,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _hide = !_hide),
        ),
      ),
    );
  }
}

// ======================= KHUNG ĐĂNG NHẬP / ĐĂNG KÝ =======================
class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool showBack;
  final Widget child;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: showBack
          ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      )
          : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: appGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(icon,
                        size: 36, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: child,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}