import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbo_swms/data/models/complaint_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';

class SpecialTasksPage extends StatefulWidget {
  const SpecialTasksPage({super.key});

  @override
  State<SpecialTasksPage> createState() => _SpecialTasksPageState();
}

class _SpecialTasksPageState extends State<SpecialTasksPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<ComplaintModel> _tasks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _apiService.getAssignedComplaints();
      setState(() {
        _tasks = data.map((json) => ComplaintModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('No special tasks assigned.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title ?? 'No title',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Chip(
                        label: Text(
                          task.status ?? 'UNKNOWN',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Type: ${task.issueType ?? 'N/A'} - ${task.wasteType ?? 'N/A'}'),
                  Text('Location: ${task.location ?? 'N/A'}'),
                  Text('Urgency: ${task.urgency ?? 'N/A'}'),
                  if (task.status == 'IN_PROGRESS') ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showDecisionSheet(task, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showDecisionSheet(task, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDecisionSheet(ComplaintModel task, bool isApprove) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _DecisionSheet(
          task: task,
          isApprove: isApprove,
          onSubmit: (note, imageFile) async {
            try {
              String? photoUrl;
              if (imageFile != null) {
                photoUrl = await _apiService.uploadComplaintImage(imageFile);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo is required.')),
                );
                return;
              }
              
              await _apiService.confirmComplaint(task.id!, {
                'isTrue': isApprove,
                'note': note,
                'photoUrl': photoUrl,
              });
              
              Navigator.pop(context);
              _fetchTasks();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task ${isApprove ? 'approved' : 'rejected'} successfully.')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        );
      },
    );
  }
}

class _DecisionSheet extends StatefulWidget {
  final ComplaintModel task;
  final bool isApprove;
  final Function(String, File?) onSubmit;

  const _DecisionSheet({
    required this.task,
    required this.isApprove,
    required this.onSubmit,
  });

  @override
  State<_DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends State<_DecisionSheet> {
  final TextEditingController _noteController = TextEditingController();
  File? _imageFile;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isApprove ? 'Approve Task' : 'Reject Task',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Optional Note',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          if (_imageFile != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  color: Colors.black54,
                  onPressed: () => setState(() => _imageFile = null),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    if (_imageFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('A photo is required.')),
                      );
                      return;
                    }
                    setState(() => _isSubmitting = true);
                    await widget.onSubmit(_noteController.text, _imageFile);
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  },
            child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
