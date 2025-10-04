import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      clearError();

      // TODO: Implement actual authentication with Supabase
      // For now, simulate authentication
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful authentication
      _currentUser = User(
        id: 'user_123',
        email: email,
        name: 'Grandmother Rose',
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      clearError();

      // TODO: Implement actual registration with Supabase
      // For now, simulate registration
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful registration
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      clearError();

      // TODO: Implement actual sign out with Supabase
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(String name, String? avatarUrl) async {
    try {
      if (_currentUser == null) return false;

      _setLoading(true);
      clearError();

      // TODO: Implement actual profile update with Supabase
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        name: name,
        avatarUrl: avatarUrl,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);

      // TODO: Check actual authentication status with Supabase
      // For now, simulate checking stored session
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock: Check if user should be logged in (simulate persistent session)
      // For demo purposes, we'll start with no user
      _currentUser = null;

      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }
}