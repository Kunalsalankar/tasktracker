import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isAuthenticated = false;
  String? _username;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get userId => _userId;

  // ✅ Add this to fix 'email' error
  String? get email => _username;

  // Check if user is already logged in
  Future<void> checkCurrentUser() async {
    final User? user = _supabase.auth.currentUser;
    if (user != null) {
      _isAuthenticated = true;
      _username = user.email;
      _userId = user.id;
      await _fetchUserProfile();
      notifyListeners();
    }
  }

  // Login with email & password
  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        _username = response.user!.email;
        _userId = response.user!.id;

        await _fetchUserProfile();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return false;
  }

  // Signup with optional full name
  Future<bool> signup(String email, String password, {String? fullName}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        _username = response.user!.email;
        _userId = response.user!.id;

        await _storeUserProfile(
          response.user!.id,
          email,
          fullName ?? '',
        );

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      rethrow;
    }
    return false;
  }

  // Store user profile in Supabase 'profiles' table
  Future<void> _storeUserProfile(String userId, String email, String fullName) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      } as Map<String, Object>);
    } catch (e) {
      debugPrint('Error storing user profile: $e');
    }
  }

  // Fetch user profile data from Supabase
  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    if (_userId != null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select()
            .eq('id', _userId!)
            .maybeSingle();

        if (data != null) {
          debugPrint('User profile fetched: $data');
          return data;
        }
      } catch (e) {
        debugPrint('Error fetching user profile: $e');
      }
    }
    return null;
  }

  // Update user profile
  Future<bool> updateProfile({String? fullName, String? bio}) async {
    if (_userId == null) return false;

    try {
      final Map<String, Object> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (bio != null) updateData['bio'] = bio;

      await _supabase.from('profiles')
          .update(updateData)
          .eq('id', _userId!);

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Logout
  void logout() async {
    await _supabase.auth.signOut();
    _isAuthenticated = false;
    _username = null;
    _userId = null;
    notifyListeners();
  }
}
