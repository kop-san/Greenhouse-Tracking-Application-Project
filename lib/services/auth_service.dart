import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import '../models/user.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = false;
  final ApiService _apiService = ApiService();
  SharedPreferences? _prefs;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null && _currentUser!.hasValidToken;

  // Initialize SharedPreferences early
  Future<void> _initPrefs() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> initializeAuth() async {
    if (_isLoading || _isInitializing) return;
    
    _isInitializing = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _initPrefs();
      final userData = await _getStoredUserData();
      if (userData != null) {
        // Parse user data in an isolate if it's large
        if (userData.length > 1000) {
          _currentUser = await compute(_parseUserData, userData);
        } else {
          _currentUser = User.fromJson(userData);
        }
        
        final shouldRefresh = _currentUser!.tokenExpiry != null &&
            _currentUser!.tokenExpiry!.difference(DateTime.now()).inMinutes <= 10;
        
        if (shouldRefresh && AppConfig.enableTokenRefresh) {
          final refreshed = await refreshToken();
          if (!refreshed) {
            developer.log('Token refresh failed during initialization', name: 'AuthService');
            await _clearStoredUserData();
            _currentUser = null;
          }
        } else if (!_currentUser!.hasValidToken) {
          developer.log('Invalid token found during initialization', name: 'AuthService');
          await _clearStoredUserData();
          _currentUser = null;
        }
      }
    } catch (e) {
      developer.log('Error initializing auth: $e', name: 'AuthService');
      await _clearStoredUserData();
      _currentUser = null;
    } finally {
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Isolate functions for parsing
  static User _parseUserData(Map<String, dynamic> userData) {
    return User.fromJson(userData);
  }

  static Map<String, dynamic> _parseJson(String jsonStr) {
    return json.decode(jsonStr) as Map<String, dynamic>;
  }

  Future<(bool, String?)> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return (false, 'Email and password are required');
    }

    if (_isLoading) {
      return (false, 'A request is already in progress');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _initPrefs();
      final response = await _apiService.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );
      
      if (response['token'] != null && response['user'] != null) {
        final token = response['token'] as String;
        final userData = <String, dynamic>{
          ...Map<String, dynamic>.from(response['user'] as Map),
          'token': token,
        };
        
        // Parse user data in an isolate if it's large
        if (userData.length > 1000) {
          _currentUser = await compute(_parseUserData, userData);
        } else {
          _currentUser = User.fromJson(userData);
        }
        
        if (_currentUser!.hasValidToken) {
          await _storeUserData(_currentUser!.toJson());
          notifyListeners();
          return (true, null);
        }
      } 
      return (false, 'Invalid server response');
    } on UnauthorizedException {
      return (false, 'Invalid email or password');
    } on ValidationException catch (e) {
      return (false, e.message);
    } on ServerException {
      return (false, 'Server error occurred. Please try again later.');
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (e) {
      developer.log('Login failed: Unexpected error - $e', name: 'AuthService');
      return (false, 'An unexpected error occurred');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _initPrefs();
      if (_currentUser?.hasValidToken ?? false) {
        try {
          await _apiService.post('/auth/logout', {});
        } on UnauthorizedException {
          developer.log('Unauthorized during logout - proceeding with local logout', name: 'AuthService');
        } catch (e) {
          developer.log('Error during logout API call: $e', name: 'AuthService');
        }
      }
    } finally {
      await _clearStoredUserData();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refreshToken() async {
    try {
      if (_currentUser?.token == null) {
        developer.log('Cannot refresh token: No token present', name: 'AuthService');
        return false;
      }

      final response = await _apiService.post('/auth/refresh', {});
      
      if (response['token'] != null) {
        final token = response['token'] as String;
        _currentUser = _currentUser!.copyWith(token: token);
        await _storeUserData(_currentUser!.toJson());
        return true;
      }
      
      return false;
    } on UnauthorizedException {
      developer.log('Token refresh failed: Unauthorized', name: 'AuthService');
      return false;
    } catch (e) {
      developer.log('Token refresh error: $e', name: 'AuthService');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _getStoredUserData() async {
    try {
      final userDataString = _prefs?.getString(AppConfig.userDataKey);
      if (userDataString == null) return null;
      
      // Parse JSON in an isolate if it's large
      if (userDataString.length > 1000) {
        return compute(_parseJson, userDataString);
      }
      return json.decode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error getting stored user data: $e', name: 'AuthService');
      return null;
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    await _initPrefs();
    await _prefs?.setString(AppConfig.userDataKey, json.encode(userData));
    // Also store token separately for ApiService
    if (userData['token'] != null) {
      await _prefs?.setString(AppConfig.authTokenKey, userData['token']);
      developer.log('Token stored in both AuthService and ApiService', name: 'AuthService');
    }
  }

  Future<void> _clearStoredUserData() async {
    await _initPrefs();
    await _prefs?.remove(AppConfig.userDataKey);
    await _prefs?.remove(AppConfig.authTokenKey);
    developer.log('User data and token cleared from storage', name: 'AuthService');
  }
}
