import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ======================= MODEL =======================
// Đề chỉ cho đúng 4 trường: email, matkhau, hoten, hinhanh.
class UserModel {
  final String? id; // id document (= uid của Authentication)
  final String email;
  final String matkhau;
  final String hoten;
  final String hinhanh; // chuỗi base64

  const UserModel({
    this.id,
    required this.email,
    required this.matkhau,
    required this.hoten,
    this.hinhanh = '',
  });

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final m = (doc.data() as Map<String, dynamic>?) ?? {};
    return UserModel(
      id: doc.id,
      email: m['email'] ?? '',
      matkhau: m['matkhau'] ?? '',
      hoten: m['hoten'] ?? '',
      hinhanh: m['hinhanh'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'matkhau': matkhau,
    'hoten': hoten,
    'hinhanh': hinhanh,
  };

  bool matches(String keyword) {
    final k = keyword.toLowerCase();
    return hoten.toLowerCase().contains(k) || email.toLowerCase().contains(k);
  }
}

// ======================= SERVICE (Auth + Firestore) =======================
class UserService {
  final CollectionReference _col =
  FirebaseFirestore.instance.collection('users');

  Stream<List<UserModel>> watchUsers() =>
      _col.snapshots().map((s) => s.docs.map(UserModel.fromDoc).toList());

  Future<UserModel?> getProfile(String uid) async {
    final d = await _col.doc(uid).get();
    return d.exists ? UserModel.fromDoc(d) : null;
  }

  Future<void> update(UserModel u) => _col.doc(u.id).update(u.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();

  // ---------- Authentication ----------
  Future<UserCredential> signIn(String email, String pass) =>
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

  Future<void> logout() => FirebaseAuth.instance.signOut();

  /// Tạo tài khoản Auth + document Firestore (id = uid).
  /// Dùng app Firebase phụ để không làm đăng xuất người đang đăng nhập
  /// (ví dụ admin đang thêm người dùng).
  Future<void> createAccount(UserModel u) async {
    const name = 'secondary';
    FirebaseApp app;
    try {
      app = Firebase.app(name);
    } catch (_) {
      app = await Firebase.initializeApp(
        name: name,
        options: Firebase.app().options,
      );
    }
    final auth = FirebaseAuth.instanceFor(app: app);
    final cred = await auth.createUserWithEmailAndPassword(
      email: u.email,
      password: u.matkhau,
    );
    try {
      await FirebaseFirestore.instanceFor(app: app)
          .collection('users')
          .doc(cred.user!.uid)
          .set(u.toMap());
    } finally {
      await auth.signOut();
    }
  }
}

/// Đổi mã lỗi Firebase thành thông báo tiếng Việt.
String authErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Sai email hoặc mật khẩu';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'email-already-in-use':
        return 'Email đã được đăng ký';
      case 'weak-password':
        return 'Mật khẩu tối thiểu 6 ký tự';
      case 'operation-not-allowed':
        return 'Chưa bật Email/Password trong Firebase Authentication';
      case 'too-many-requests':
        return 'Thử quá nhiều lần, vui lòng đợi một lúc';
      default:
        return 'Lỗi xác thực: ${e.code}';
    }
  }
  return 'Lỗi: $e';
}

// ======================= ẢNH (base64) =======================
class ImageHelper {
  /// Chọn ảnh từ thư viện, nén nhỏ, trả về base64 (null nếu hủy).
  static Future<String?> pickAsBase64() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 60,
    );
    if (file == null) return null;
    return base64Encode(await file.readAsBytes());
  }

  static ImageProvider? toProvider(String b64) =>
      b64.isEmpty ? null : MemoryImage(base64Decode(b64));
}