import 'package:flutter/material.dart';

import 'common_widgets.dart';
import 'profile_page.dart';
import 'register_page.dart';
import 'user_data.dart';
import 'user_list_page.dart';

// Email của tài khoản admin (tạo trong Authentication)
const adminEmail = 'admin@gmail.com';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _service = UserService();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (email.isEmpty || pass.isEmpty) {
      showMsg(context, 'Nhập email và mật khẩu');
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await _service.signIn(email, pass);
      if (!mounted) return;

      // Admin -> trang quản lý
      if (email.toLowerCase() == adminEmail) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserListPage()),
        );
        return;
      }

      // Người dùng thường -> trang thông tin cá nhân
      final user = await _service.getProfile(cred.user!.uid);
      if (!mounted) return;
      if (user == null) {
        await _service.logout();
        if (mounted) showMsg(context, 'Tài khoản không còn tồn tại trong hệ thống');
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
      );
    } catch (e) {
      if (mounted) showMsg(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      icon: Icons.lock_outline,
      title: 'Chào mừng trở lại',
      subtitle: 'Đăng nhập để tiếp tục',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          PasswordField(controller: _pass, onSubmitted: (_) => _login()),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Đăng nhập'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
            child: const Text('Chưa có tài khoản? Đăng ký'),
          ),
        ],
      ),
    );
  }
}