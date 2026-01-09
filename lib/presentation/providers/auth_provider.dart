import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, agent, viewer }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _userName;
  UserRole _userRole = UserRole.viewer;
  bool _isLoading = false;

  User? get user => _user;
  String? get userName => _userName;
  UserRole get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userName = null;
        _userRole = UserRole.viewer;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _userName = data?['name'] as String?;
        final roleString = data?['role'] as String? ?? 'viewer';
        _userRole = _roleFromString(roleString);
      } else {
        // İlk girişte varsayılan rol viewer
        _userName = _user?.displayName;
        _userRole = UserRole.viewer;
        await _firestore.collection('users').doc(uid).set({
          'role': 'viewer',
          'email': _user?.email,
          'name': _userName,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      notifyListeners();
    } catch (e) {
      _userRole = UserRole.viewer;
      notifyListeners();
    }
  }

  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'agent':
        return UserRole.agent;
      default:
        return UserRole.viewer;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null && !credential.user!.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'E-posta adresi doğrulanmamış. Lütfen e-postanızı kontrol edin.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Giriş yapılırken bir hata oluştu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    await _user?.sendEmailVerification();
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Doğrulama maili gönder
        await credential.user!.sendEmailVerification();

        // Kullanıcı bilgilerini Firestore'a kaydet
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'name': name,
          'role': 'viewer', // Varsayılan rol
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Kullanıcıyı hemen giriş yapmış sayma, doğrulama beklenecek
        // UI tarafında dialog gösterilecek ve orada polling yapılacak
        // await _auth.signOut(); // Polling için oturum açık kalmalı
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Kayıt olurken bir hata oluştu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Geçici giriş yap
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        if (credential.user!.emailVerified) {
          // Zaten doğrulanmışsa çıkış yap ve bilgi ver
          await _auth.signOut();
          throw Exception('E-posta adresi zaten doğrulanmış. Giriş yapabilirsiniz.');
        }
        
        await credential.user!.sendEmailVerification();
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Doğrulama maili gönderilemedi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _userRole = UserRole.viewer;
      notifyListeners();
    } catch (e) {
      throw Exception('Çıkış yapılırken bir hata oluştu: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış';
      case 'email-not-verified':
        return 'E-posta adresi henüz doğrulanmamış';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}

