import 'package:flutter/material.dart';

import 'common_widgets.dart';
import 'login_page.dart';
import 'user_data.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    await UserService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          // ---------- Phần đầu gradient ----------
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(children: [
                  Row(children: [
                    const Expanded(
                      child: Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đăng xuất',
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _logout(context),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 62,
                    backgroundColor: Colors.white,
                    child: UserAvatar(base64Image: user.hinhanh, radius: 58),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.hoten,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: Colors.white70)),
                ]),
              ),
            ),
          ),

          // ---------- Thông tin chi tiết ----------
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _infoTile(Icons.badge_outlined, 'Họ tên', user.hoten),
                  _infoTile(Icons.email_outlined, 'Email', user.email),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4F46E5)),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}