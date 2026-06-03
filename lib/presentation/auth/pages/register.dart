import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _CitizenRegisterState();
}

class _CitizenRegisterState extends State<Register> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _userType = 'Citizen'; // 'Citizen' or 'Collector'
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join Garbo waste management',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Role Selector Header
              const Text(
                'I am a',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Role Cards Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _userType = 'Citizen';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _userType == 'Citizen' 
                              ? AppColors.green700.withAlpha(20)
                              : Colors.grey[50],
                          border: Border.all(
                            color: _userType == 'Citizen' 
                                ? AppColors.green700 
                                : Colors.grey[200]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              color: _userType == 'Citizen' 
                                  ? AppColors.green700 
                                  : Colors.grey[400],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Citizen',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _userType == 'Citizen' 
                                    ? AppColors.green700 
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _userType = 'Collector';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _userType == 'Collector' 
                              ? AppColors.green700.withAlpha(20)
                              : Colors.grey[50],
                          border: Border.all(
                            color: _userType == 'Collector' 
                                ? AppColors.green700 
                                : Colors.grey[200]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: _userType == 'Collector' 
                                  ? AppColors.green700 
                                  : Colors.grey[400],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Collector',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _userType == 'Collector' 
                                    ? AppColors.green700 
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Full Name field
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Username field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: Icon(Icons.account_circle_outlined, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
              const SizedBox(height: 36),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle registration logic here
                    if (_passwordController.text == _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account created successfully!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
