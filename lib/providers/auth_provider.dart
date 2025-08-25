import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserModel? _userData;
  String _userRole = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  UserModel? get userData => _userData;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isStudent => _userRole == 'student';
  bool get isTeacher => _userRole == 'teacher';
  bool get isAdmin => _userRole == 'admin';

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userData = null;
        _userRole = '';
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get user role and data
      _userRole = await _authService.getUserRole(uid);
      _userData = await _authService.getUserData(uid);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createUserAccount({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.createUserAccount(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.changePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user has permission to access certain features
  bool hasPermission(String requiredRole) {
    if (_userRole == 'admin') return true;
    return _userRole == requiredRole;
  }

  // Check if user can access student data
  bool canAccessStudentData(String studentId) {
    if (_userRole == 'admin') return true;
    if (_userRole == 'teacher') {
      // Teachers can only access their assigned students
      // This would need to be implemented based on class assignments
      return true; // Simplified for now
    }
    if (_userRole == 'student') {
      return _currentUser?.uid == studentId;
    }
    return false;
  }

  // Check if user can access teacher data
  bool canAccessTeacherData(String teacherId) {
    if (_userRole == 'admin') return true;
    if (_userRole == 'teacher') {
      return _currentUser?.uid == teacherId;
    }
    return false;
  }
}
