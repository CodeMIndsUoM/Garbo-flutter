import 'dart:io';
import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/sources/citizen_api.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class SuggestEventPage extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  
  const SuggestEventPage({super.key, this.onSuccess, this.onCancel});

  @override
  State<SuggestEventPage> createState() => _SuggestEventPageState();
}

class _SuggestEventPageState extends State<SuggestEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  
  DateTime? _selectedDate;
  File? _image;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all mandatory fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.token;
      
      final api = CitizenApi(
        client: http.Client(),
        authHeadersProvider: () async => {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        tokenProvider: () async => token ?? '',
      );

      String? imageUrl;
      if (_image != null) {
        imageUrl = await api.uploadEventPhoto(_image!.path);
      }

      final payload = {
        'title': _titleController.text,
        'description': _purposeController.text,
        'location': _placeController.text,
        'latitude': double.tryParse(_latController.text) ?? 0.0,
        'longitude': double.tryParse(_lngController.text) ?? 0.0,
        'eventDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'imageUrl': imageUrl,
        'category': 'Citizen Suggestion',
      };

      final success = await api.suggestEvent(payload);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event suggested successfully! Waiting for admin approval.')),
          );
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            Navigator.pop(context, true);
          }
        }
      } else {
        throw Exception('Failed to submit suggestion');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _isSubmitting 
        ? const Center(child: CircularProgressIndicator(color: AppColors.emerald600))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onCancel ?? () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text(
                        'Suggest New Event',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.grey900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Event Details'),
                  _buildTextField(_titleController, 'Event Title', 'e.g. Community Garden Cleanup'),
                  const SizedBox(height: 16),
                  _buildTextField(_purposeController, 'Purpose / Description', 'What is the goal of this event?', maxLines: 3),
                  const SizedBox(height: 16),
                  
                  _buildSectionTitle('Date'),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: AppColors.emerald600),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null 
                              ? 'Select Event Date' 
                              : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null ? AppColors.grey500 : AppColors.grey900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Location'),
                  _buildTextField(_placeController, 'Place Name', 'e.g. Victoria Park'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_latController, 'Latitude', '6.9271', keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(_lngController, 'Longitude', '79.8612', keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Photo (Optional)'),
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _image != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.grey400),
                              const SizedBox(height: 8),
                              Text('Add a photo of the location', style: TextStyle(color: AppColors.grey500)),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald600,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Submit Suggestion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    String hint, 
    {int maxLines = 1, TextInputType keyboardType = TextInputType.text}
  ) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.grey700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.grey300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.grey300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.emerald600, width: 2)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
