import 'dart:io';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/auth/pages/registration_status.dart';
import 'package:image_picker/image_picker.dart';

/// Third Party Collector Registration Screen
/// Collectors fill their details and submit for admin approval
/// After approval, they can create password and login
class CollectorRegister extends StatefulWidget {
  const CollectorRegister({super.key});

  @override
  State<CollectorRegister> createState() => _CollectorRegisterState();
}

class _CollectorRegisterState extends State<CollectorRegister> {
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _contractIdController = TextEditingController();
  final TextEditingController _contractStartController = TextEditingController();
  final TextEditingController _contractEndController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State
  File? _idPhotoFrontFile;
  String? _idPhotoFrontUrl;
  File? _idPhotoBackFile;
  String? _idPhotoBackUrl;
  bool _uploadingFrontPhoto = false;
  bool _uploadingBackPhoto = false;
  bool _submitting = false;
  List<String> _councils = [];
  String? _selectedCouncil;
  bool _loadingCouncils = true;
  int _currentStep = 1;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _loadCouncils();
  }

  Future<void> _loadCouncils() async {
    try {
      final councils = await _apiService.fetchThirdPartyCouncils();
      if (mounted) {
        setState(() {
          _councils = councils;
          _loadingCouncils = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCouncils = false);
        _showSnackBar('Failed to load councils: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nicController.dispose();
    _dobController.dispose();
    _companyController.dispose();
    _contractIdController.dispose();
    _contractStartController.dispose();
    _contractEndController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickIdPhotoFront() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _idPhotoFrontFile = File(image.path);
          _uploadingFrontPhoto = true;
        });

        // Upload photo
        final photoUrl = await _apiService.uploadThirdPartyNicPhoto(_idPhotoFrontFile!);

        if (mounted) {
          setState(() {
            _idPhotoFrontUrl = photoUrl;
            _uploadingFrontPhoto = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingFrontPhoto = false);
        _showSnackBar('Failed to upload front photo: $e', isError: true);
      }
    }
  }

  Future<void> _pickIdPhotoBack() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _idPhotoBackFile = File(image.path);
          _uploadingBackPhoto = true;
        });

        // Upload photo
        final photoUrl = await _apiService.uploadThirdPartyNicPhoto(_idPhotoBackFile!);

        if (mounted) {
          setState(() {
            _idPhotoBackUrl = photoUrl;
            _uploadingBackPhoto = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingBackPhoto = false);
        _showSnackBar('Failed to upload back photo: $e', isError: true);
      }
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submitRegistration() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email', isError: true);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter your phone number', isError: true);
      return;
    }
    if (_nicController.text.trim().isEmpty) {
      _showSnackBar('Please enter your NIC', isError: true);
      return;
    }
    if (_dobController.text.trim().isEmpty) {
      _showSnackBar('Please enter your date of birth', isError: true);
      return;
    }
    if (_companyController.text.trim().isEmpty) {
      _showSnackBar('Please enter your company name', isError: true);
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      _showSnackBar('Please enter your address', isError: true);
      return;
    }
    if (_selectedCouncil == null || _selectedCouncil!.isEmpty) {
      _showSnackBar('Please select a council', isError: true);
      return;
    }
    if (_idPhotoFrontUrl == null || _idPhotoFrontUrl!.isEmpty) {
      _showSnackBar('Please upload your ID front photo', isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await _apiService.registerThirdPartyCollector(
        empName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        NIC: _nicController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        company: _companyController.text.trim(),
        contractId: _contractIdController.text.trim().isEmpty
            ? null
            : _contractIdController.text.trim(),
        contractStart: _contractStartController.text.trim().isEmpty
            ? null
            : _contractStartController.text.trim(),
        contractEnd: _contractEndController.text.trim().isEmpty
            ? null
            : _contractEndController.text.trim(),
        defaultAddress: _addressController.text.trim(),
        idPhotoUrl: _idPhotoFrontUrl!,
        idPhotoBackUrl: _idPhotoBackUrl,
        assignedCouncil: _selectedCouncil!,
      );

      if (mounted) {
        // Navigate to registration status screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationStatus(
              empId: result['empId'],
              email: result['email'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Registration failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showRegistrationSuccess(dynamic empId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.emerald100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.green700,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Registration Submitted',
              style: AppTypography.titleMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your registration has been submitted for admin review. You will be notified once approved.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green700,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.redDark2 : AppColors.green700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Collector Registration',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.green700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fill in your details below. Admin will review and approve your registration.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.green800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Step Indicator
                _buildStepIndicator(),
                const SizedBox(height: 24),

                // Step Content
                _buildStepContent(),
                const SizedBox(height: 24),

                // Navigation Buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleSm.copyWith(
        color: AppColors.grey700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final stepNumber = index + 1;
          final isCompleted = stepNumber < _currentStep;
          final isCurrent = stepNumber == _currentStep;
          final isFuture = stepNumber > _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.green700
                              : isCurrent
                                  ? AppColors.green700
                                  : AppColors.grey300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : Text(
                                  '$stepNumber',
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.white
                                        : AppColors.grey600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepTitle(stepNumber),
                        style: AppTypography.bodySm.copyWith(
                          color: isCurrent
                              ? AppColors.green700
                              : AppColors.grey500,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted ? AppColors.green700 : AppColors.grey300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Personal';
      case 2:
        return 'Company';
      case 3:
        return 'ID & Address';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Content();
      case 2:
        return _buildStep2Content();
      case 3:
        return _buildStep3Content();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Personal Information'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nicController,
          label: 'NIC Number',
          hint: 'Enter your NIC',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        _buildDateField(
          controller: _dobController,
          label: 'Date of Birth',
          hint: 'Select your date of birth',
          icon: Icons.cake_outlined,
        ),
      ],
    );
  }

  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Company Information'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _companyController,
          label: 'Company Name',
          hint: 'Enter company name',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _contractIdController,
          label: 'Contract ID (Optional)',
          hint: 'Enter contract ID if applicable',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                controller: _contractStartController,
                label: 'Contract Start (Optional)',
                hint: 'Select start date',
                icon: Icons.calendar_today_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                controller: _contractEndController,
                label: 'Contract End (Optional)',
                hint: 'Select end date',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Council'),
        const SizedBox(height: 12),
        _buildCouncilDropdown(),
      ],
    );
  }

  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('Address'),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter your address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _buildIdPhotoSection(),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey200,
                foregroundColor: AppColors.grey700,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Previous',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_currentStep > 1) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _currentStep == _totalSteps
                ? (_submitting ? null : _submitRegistration)
                : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green700,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _currentStep == _totalSteps && _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    _currentStep == _totalSteps ? 'Submit Registration' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (_currentStep == 1) {
      if (_nameController.text.trim().isEmpty) {
        _showSnackBar('Please enter your name', isError: true);
        return;
      }
      if (_emailController.text.trim().isEmpty) {
        _showSnackBar('Please enter your email', isError: true);
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        _showSnackBar('Please enter your phone number', isError: true);
        return;
      }
      if (_nicController.text.trim().isEmpty) {
        _showSnackBar('Please enter your NIC', isError: true);
        return;
      }
      if (_dobController.text.trim().isEmpty) {
        _showSnackBar('Please enter your date of birth', isError: true);
        return;
      }
    }
    if (_currentStep == 2) {
      if (_companyController.text.trim().isEmpty) {
        _showSnackBar('Please enter your company name', isError: true);
        return;
      }
      if (_selectedCouncil == null || _selectedCouncil!.isEmpty) {
        _showSnackBar('Please select a council', isError: true);
        return;
      }
    }
    
    setState(() {
      _currentStep++;
    });
  }

  Widget _buildCouncilDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Council',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _loadingCouncils
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCouncil,
                    isExpanded: true,
                    hint: Row(
                      children: [
                        Icon(Icons.location_city_outlined, color: AppColors.grey400),
                        const SizedBox(width: 12),
                        Text(
                          'Select your council',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                    items: _councils.map((council) {
                      return DropdownMenuItem<String>(
                        value: council,
                        child: Row(
                          children: [
                            Icon(Icons.location_city_outlined,
                                color: AppColors.grey400),
                            const SizedBox(width: 12),
                            Text(council),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCouncil = value);
                    },
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildIdPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ID Photos',
          style: AppTypography.titleSm.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Front ID Photo
        _buildPhotoUploadCard(
          title: 'Front ID Photo',
          file: _idPhotoFrontFile,
          url: _idPhotoFrontUrl,
          uploading: _uploadingFrontPhoto,
          onTap: _pickIdPhotoFront,
        ),
        const SizedBox(height: 16),
        // Back ID Photo
        _buildPhotoUploadCard(
          title: 'Back ID Photo',
          file: _idPhotoBackFile,
          url: _idPhotoBackUrl,
          uploading: _uploadingBackPhoto,
          onTap: _pickIdPhotoBack,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildPhotoUploadCard({
    required String title,
    required File? file,
    required String? url,
    required bool uploading,
    required VoidCallback onTap,
    bool isOptional = false,
  }) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: file != null ? AppColors.emerald50 : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppColors.green700 : AppColors.grey300,
            width: 2,
          ),
        ),
        child: uploading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : file != null
                ? Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload $title',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      if (isOptional)
                        Text(
                          '(Optional)',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySm.copyWith(
              color: AppColors.grey400,
            ),
            prefixIcon: Icon(icon, color: AppColors.grey400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.green700),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(controller),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySm.copyWith(
              color: AppColors.grey400,
            ),
            prefixIcon: Icon(icon, color: AppColors.grey400),
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.grey400,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.green700),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
