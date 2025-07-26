import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
///HH
class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  ProfileModel? _currentProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  String _selectedGender = 'Male';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _currentProfile = profile;
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone;
        _addressController.text = profile.address;
        _cityController.text = profile.city;
        _zipCodeController.text = profile.zipCode;
        _selectedGender = profile.gender.isNotEmpty ? profile.gender : 'Male';
        _selectedDate = profile.dateOfBirth;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = ProfileModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDate,
      profileImagePath: _currentProfile?.profileImagePath ?? '',
    );

    final validationError = ProfileService.validateProfile(updatedProfile);
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    final success = await ProfileService.updateProfile(updatedProfile);
    if (success) {
      setState(() {
        _currentProfile = updatedProfile;
        _isEditing = false;
      });
      _showSnackBar('Profile updated successfully!');
    } else {
      _showSnackBar('Failed to update profile', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.brown.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.brown.shade800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                }
              },
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: TextStyle(
                  color: Colors.brown.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              _buildProfilePicture(),
              const SizedBox(height: 32),

              // Personal Information
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 16),
              _buildPersonalInfoSection(),

              const SizedBox(height: 32),

              // Contact Information
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: 16),
              _buildContactInfoSection(),

              const SizedBox(height: 32),

              // Address Information
              _buildSectionTitle('Address Information'),
              const SizedBox(height: 16),
              _buildAddressInfoSection(),

              const SizedBox(height: 32),

              // Profile Actions
              if (!_isEditing) _buildProfileActions(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.brown.shade100,
            child: _currentProfile?.profileImagePath.isNotEmpty == true
                ? ClipOval(
              child: Image.network(
                _currentProfile!.profileImagePath,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              ),
            )
                : _buildDefaultAvatar(),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // In a real app, you'd implement image picker here
                  _showSnackBar('Image picker would open here');
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().scale(duration: 600.ms);
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 60,
      color: Colors.brown.shade300,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.brown.shade700,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildGenderDropdown(),
        const SizedBox(height: 16),
        _buildDateOfBirthField(),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Email is required';
            }
            if (!ProfileService.isValidEmail(value!)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return 'Phone number is required';
            }
            if (!ProfileService.isValidPhone(value!)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressInfoSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _zipCodeController,
                label: 'ZIP Code',
                icon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: Colors.brown.shade800,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.brown.shade600),
        prefixIcon: Icon(icon, color: Colors.brown.shade600),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.brown.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade600, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade200),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: ['Male', 'Female', 'Other']
          .map((gender) => DropdownMenuItem(
        value: gender,
        child: Text(gender),
      ))
          .toList(),
      onChanged: _isEditing ? (value) {
        if (value != null) {
          setState(() {
            _selectedGender = value;
          });
        }
      } : null,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc, color: Colors.brown.shade600),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.brown.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade300),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return GestureDetector(
      onTap: _isEditing ? _selectDate : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isEditing ? Colors.white : Colors.brown.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.brown.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth',
                    style: TextStyle(
                      color: Colors.brown.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(
                      color: Colors.brown.shade800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (_isEditing)
              Icon(Icons.arrow_drop_down, color: Colors.brown.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await ProfileService.resetToDefault();
              _loadProfile();
              _showSnackBar('Profile reset to default');
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to Default'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade100,
              foregroundColor: Colors.brown.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final profileJson = ProfileService.exportProfile();
              _showSnackBar('Profile exported: ${profileJson.length} characters');
              // In a real app, you could save this to a file or share it
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}