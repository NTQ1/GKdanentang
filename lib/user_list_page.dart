import 'package:flutter/material.dart';

import 'common_widgets.dart';
import 'login_page.dart';
import 'user_data.dart';

// ======================= DANH SÁCH =======================
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _service = UserService();
  final _search = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _service.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _openForm([UserModel? user]) {
    showDialog(
      context: context,
      builder: (_) => UserFormDialog(user: user, service: _service),
    );
  }

  Future<void> _confirmDelete(UserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 36),
        title: const Text('Xóa người dùng?'),
        content: Text('Bạn có chắc muốn xóa "${user.hoten}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true && user.id != null) {
      await _service.delete(user.id!);
      if (mounted) showMsg(context, 'Đã xóa ${user.hoten}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appGradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm người dùng'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Tìm theo họ tên / email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _keyword.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _search.clear();
                      setState(() => _keyword = '');
                    },
                  ),
                ),
                onChanged: (v) => setState(() => _keyword = v),
              ),
            ),
            Expanded(child: _buildList()),
          ]),
        ),
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<UserModel>>(
      stream: _service.watchUsers(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Lỗi: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snap.data!.where((u) => u.matches(_keyword)).toList();

        if (users.isEmpty) {
          return const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 8),
              Text('Chưa có người dùng', style: TextStyle(color: Colors.grey)),
            ]),
          );
        }

        return Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${users.length} người dùng',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
              itemCount: users.length,
              itemBuilder: (_, i) => _buildItem(users[i]),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildItem(UserModel user) {
    final isAdmin = user.email.toLowerCase() == adminEmail;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: UserAvatar(base64Image: user.hinhanh, radius: 24),
        title: Row(children: [
          Flexible(
            child: Text(
              user.hoten,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(fontSize: 11, color: Color(0xFF4F46E5)),
              ),
            ),
          ],
        ]),
        subtitle: Text(user.email, overflow: TextOverflow.ellipsis),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            tooltip: 'Sửa',
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4F46E5)),
            onPressed: () => _openForm(user),
          ),
          if (!isAdmin)
            IconButton(
              tooltip: 'Xóa',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(user),
            ),
        ]),
      ),
    );
  }
}

// ======================= FORM THÊM / SỬA =======================
class UserFormDialog extends StatefulWidget {
  final UserModel? user; // null = thêm mới
  final UserService service;

  const UserFormDialog({super.key, this.user, required this.service});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  late final _email = TextEditingController(text: widget.user?.email ?? '');
  late final _matkhau = TextEditingController(text: widget.user?.matkhau ?? '');
  late final _hoten = TextEditingController(text: widget.user?.hoten ?? '');
  late String _hinhanh = widget.user?.hinhanh ?? '';
  bool _saving = false;

  bool get _isEdit => widget.user != null;

  @override
  void dispose() {
    _email.dispose();
    _matkhau.dispose();
    _hoten.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final b64 = await ImageHelper.pickAsBase64();
    if (b64 != null) setState(() => _hinhanh = b64);
  }

  Future<void> _save() async {
    if (_email.text.trim().isEmpty ||
        _matkhau.text.isEmpty ||
        _hoten.text.trim().isEmpty) {
      showMsg(context, 'Nhập đủ thông tin');
      return;
    }
    if (!_isEdit && _matkhau.text.length < 6) {
      showMsg(context, 'Mật khẩu tối thiểu 6 ký tự');
      return;
    }

    final user = UserModel(
      id: widget.user?.id,
      email: _email.text.trim(),
      matkhau: _matkhau.text,
      hoten: _hoten.text.trim(),
      hinhanh: _hinhanh,
    );

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await widget.service.update(user);
      } else {
        await widget.service.createAccount(user);
      }
      if (!mounted) return;
      Navigator.pop(context);
      showMsg(context, _isEdit ? 'Đã cập nhật' : 'Đã thêm người dùng');
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMsg(context, authErrorMessage(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(_isEdit ? 'Sửa người dùng' : 'Thêm người dùng'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AvatarPicker(base64Image: _hinhanh, radius: 44, onTap: _pickImage),
            const SizedBox(height: 20),
            TextField(
              controller: _hoten,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              enabled: !_isEdit,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            PasswordField(controller: _matkhau, enabled: !_isEdit),
            if (_isEdit)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Email và mật khẩu gắn với tài khoản đăng nhập nên không sửa tại đây.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(90, 44)),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}