import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String zipCode;
  final String profileImagePath;
  final DateTime dateOfBirth;
  final String gender;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.address = '',
    this.city = '',
    this.zipCode = '',
    this.profileImagePath = '',
    DateTime? dateOfBirth,
    this.gender = '',
  }) : dateOfBirth = dateOfBirth ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'profileImagePath': profileImagePath,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : DateTime.now(),
      gender: json['gender'] ?? '',
    );
  }

  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? zipCode,
    String? profileImagePath,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return ProfileModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

class ProfileService {
  // In-memory storage for the current session
  static ProfileModel? _currentProfile;
  static final List<Function(ProfileModel?)> _listeners = [];

  // Default profile data
  static ProfileModel get defaultProfile => ProfileModel(
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@example.com',
    phone: '+1 234 567 8900',
    address: '123 Main Street',
    city: 'New York',
    zipCode: '10001',
    gender: 'Male',
    dateOfBirth: DateTime(1990, 1, 1),
  );

  /// Initialize with default profile if none exists
  static Future<void> initialize() async {
    if (_currentProfile == null) {
      _currentProfile = defaultProfile;
      _notifyListeners();
    }
  }

  /// Get current profile
  static Future<ProfileModel?> getProfile() async {
    await initialize();
    return _currentProfile;
  }

  /// Update profile
  static Future<bool> updateProfile(ProfileModel profile) async {
    try {
      _currentProfile = profile;
      _notifyListeners();
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Update specific profile field
  static Future<bool> updateProfileField(String field, dynamic value) async {
    try {
      if (_currentProfile == null) await initialize();

      switch (field) {
        case 'firstName':
          _currentProfile = _currentProfile!.copyWith(firstName: value);
          break;
        case 'lastName':
          _currentProfile = _currentProfile!.copyWith(lastName: value);
          break;
        case 'email':
          _currentProfile = _currentProfile!.copyWith(email: value);
          break;
        case 'phone':
          _currentProfile = _currentProfile!.copyWith(phone: value);
          break;
        case 'address':
          _currentProfile = _currentProfile!.copyWith(address: value);
          break;
        case 'city':
          _currentProfile = _currentProfile!.copyWith(city: value);
          break;
        case 'zipCode':
          _currentProfile = _currentProfile!.copyWith(zipCode: value);
          break;
        case 'gender':
          _currentProfile = _currentProfile!.copyWith(gender: value);
          break;
        case 'dateOfBirth':
          _currentProfile = _currentProfile!.copyWith(dateOfBirth: value);
          break;
        case 'profileImagePath':
          _currentProfile = _currentProfile!.copyWith(profileImagePath: value);
          break;
        default:
          return false;
      }

      _notifyListeners();
      return true;
    } catch (e) {
      print('Error updating profile field: $e');
      return false;
    }
  }

  /// Clear profile (logout)
  static Future<void> clearProfile() async {
    _currentProfile = null;
    _notifyListeners();
  }

  /// Reset to default profile
  static Future<void> resetToDefault() async {
    _currentProfile = defaultProfile;
    _notifyListeners();
  }

  /// Add listener for profile changes
  static void addListener(Function(ProfileModel?) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  static void removeListener(Function(ProfileModel?) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of profile changes
  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_currentProfile);
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone format
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  /// Validate required fields
  static String? validateProfile(ProfileModel profile) {
    if (profile.firstName.trim().isEmpty) {
      return 'First name is required';
    }
    if (profile.lastName.trim().isEmpty) {
      return 'Last name is required';
    }
    if (profile.email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(profile.email)) {
      return 'Please enter a valid email address';
    }
    if (profile.phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhone(profile.phone)) {
      return 'Please enter a valid phone number';
    }
    return null; // Valid
  }

  /// Export profile as JSON string
  static String exportProfile() {
    if (_currentProfile == null) return '{}';
    return jsonEncode(_currentProfile!.toJson());
  }

  /// Import profile from JSON string
  static Future<bool> importProfile(String jsonString) async {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final profile = ProfileModel.fromJson(json);
      return await updateProfile(profile);
    } catch (e) {
      print('Error importing profile: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear saved user data (optional)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // or selectively remove keys

      print("User logged out successfully.");
    } catch (e) {
      print("Logout failed: $e");
      rethrow;
    }
  }
}
