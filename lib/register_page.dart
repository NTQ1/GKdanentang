import 'package:flutter/material.dart';

import 'common_widgets.dart';
import 'user_data.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _service = UserService();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _hoten = TextEditingController();
  String _hinhanh = '';
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _hoten.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final b64 = await ImageHelper.pickAsBase64();
    if (b64 != null) setState(() => _hinhanh = b64);
  }

  Future<void> _register() async {
    final email = _email.text.trim();
    final hoten = _hoten.text.trim();

    if (email.isEmpty || _pass.text.isEmpty || hoten.isEmpty) {
      showMsg(context, 'Nhập đủ thông tin');
      return;
    }
    if (_pass.text.length < 6) {
      showMsg(context, 'Mật khẩu tối thiểu 6 ký tự');
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.createAccount(UserModel(
        email: email,
        matkhau: _pass.text,
        hoten: hoten,
        hinhanh: _hinhanh,
      ));
      if (!mounted) return;
      showMsg(context, 'Đăng ký thành công, hãy đăng nhập');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showMsg(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      icon: Icons.person_add_alt_1,
      title: 'Tạo tài khoản',
      subtitle: 'Điền thông tin để đăng ký',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: AvatarPicker(base64Image: _hinhanh, onTap: _pickImage)),
          const SizedBox(height: 20),
          TextField(
            controller: _hoten,
            decoration: const InputDecoration(
              labelText: 'Họ tên',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          PasswordField(controller: _pass, onSubmitted: (_) => _register()),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }
}