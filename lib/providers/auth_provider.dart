import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserModel?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initializeAuth();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize core firebase wrapper
      await _firebaseService.initialize();
    } catch (e) {
      print("⚠️ Auth initialization failed: $e");
    }

    // Listen to real-time session changes for persistence
    _authSubscription = _firebaseService.authStateChanges.listen((UserModel? user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });

    // Release the loading lock if Firebase is not initialized (so offline mock mode is active)
    // or if a timeout is reached to prevent permanent UI lockups
    if (!_firebaseService.isFirebaseInitialized) {
      _isLoading = false;
      notifyListeners();
    } else {
      Timer(const Duration(milliseconds: 1500), () {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      });
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all credential fields.');
      }
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address.');
      }

      _currentUser = await _firebaseService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all registration fields.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address.');
      }

      _currentUser = await _firebaseService.signUp(
        name: name,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final uid = _currentUser?.uid;
    _currentUser = null;
    notifyListeners();
    
    try {
      await _firebaseService.logout(uid);
    } catch (e) {
      print('⚠️ Error during logout: $e');
    }
  }

  Future<void> updateProfile({required String name, required String status}) async {
    if (_currentUser == null) return;
    
    try {
      final updatedData = {
        'name': name,
        'status': status,
      };

      await _firebaseService.updateProfileData(_currentUser!.uid, updatedData);
      
      _currentUser = _currentUser!.copyWith(
        name: name,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      print('⚠️ Error updating profile data: $e');
    }
  }
}
