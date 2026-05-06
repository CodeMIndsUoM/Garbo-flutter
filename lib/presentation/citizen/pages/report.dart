import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:intl/intl.dart';

class CitizenReportPage extends StatefulWidget {
  const CitizenReportPage({super.key});

  @override
  State<CitizenReportPage> createState() => CitizenReportPageState();
}

class CitizenReportPageState extends State<CitizenReportPage> {
  int currentStep = 1;
  String? selectedIssueType;
  String? selectedUrgency = 'Low';
  String? selectedWasteType;
  String? otherIssueDetail;
  String? detailedMessage;
  String? latitude;
  String? longitude;
  bool showMyReports = false;
  bool isLoading = false;
  List<Map<String, dynamic>> myReports = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final reports = await _apiService.getMyComplaints();
      if (mounted) {
        setState(() {
          myReports = reports;
        });
      }
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    }
  }

  Future<void> submitReport() async {
    if (selectedIssueType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue type')),
      );
      return;
    }

    try {
      final payload = {
        'issueType': selectedIssueType == 'Other' ? otherIssueDetail : selectedIssueType,
        'urgency': selectedUrgency,
        'wasteType': selectedWasteType,
        'otherIssueDetail': otherIssueDetail,
        'description': detailedMessage ?? 'Reported via mobile app',
        'latitude': double.tryParse(latitude ?? ''),
        'longitude': double.tryParse(longitude ?? ''),
        'location': '$latitude, $longitude',
        'status': 'new',
      };

      final success = await _apiService.createComplaint(payload);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully')),
          );
          setState(() {
            currentStep = 1;
            selectedIssueType = null;
            otherIssueDetail = null;
            detailedMessage = null;
            latitude = null;
            longitude = null;
            selectedUrgency = 'Low';
            selectedWasteType = null;
            showMyReports = true;
          });
          fetchReports();
        }
      } else {
        throw Exception('Failed to submit report');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            buildActionButtons(),
            const SizedBox(height: 20),
            showMyReports ? buildReportsList() : buildReportForm(),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => showMyReports = false);
            },
            icon: const Icon(Icons.note_add_outlined, size: 18),
            label: const Text(
              'New Report',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: !showMyReports ? AppColors.emerald600 : Colors.white,
              foregroundColor: !showMyReports ? Colors.white : AppColors.emerald600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: showMyReports ? const BorderSide(color: AppColors.emerald600, width: 1.5) : BorderSide.none,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => showMyReports = true);
            },
            icon: const Icon(Icons.list_alt_rounded, size: 18),
            label: const Text(
              'My Reports',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: showMyReports ? AppColors.emerald600 : Colors.white,
              foregroundColor: showMyReports ? Colors.white : AppColors.emerald600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: !showMyReports ? const BorderSide(color: AppColors.emerald600, width: 1.5) : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildReportForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Waste Issue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              TextButton(
                onPressed: () {
                },
                child: const Text(
                  'Issue Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emerald600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Step $currentStep of 3',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentStep / 3,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.emerald600,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 28),
          if (currentStep == 1) ...[
            buildDropdownField(
              label: "What's the issue?",
              hint: 'Select issue type',
              value: selectedIssueType,
              items: [
                'Overflow bin',
                'Broken or damaged bin',
                'Bad smell from waste',
                'Illegal rubbish dumping',
                'Other'
              ],
              onChanged: (value) => setState(() => selectedIssueType = value),
            ),
            if (selectedIssueType == 'Other') ...[
              const SizedBox(height: 20),
              buildTextField(
                label: 'What is your issue? (Mandatory)',
                hint: 'Please describe the issue',
                value: otherIssueDetail,
                onChanged: (value) => setState(() => otherIssueDetail = value),
              ),
            ],
            const SizedBox(height: 20),
            buildUrgencyField(),
            const SizedBox(height: 20),
            buildDropdownField(
              label: 'Waste Type (Optional)',
              hint: 'Select waste type',
              value: selectedWasteType,
              items: ['General', 'Recyclable', 'Organic', 'Mix'],
              onChanged: (value) => setState(() => selectedWasteType = value),
            ),
          ] else if (currentStep == 2) ...[
            buildTextField(
              label: 'Latitude (Mandatory)',
              hint: 'e.g. 6.9271',
              value: latitude,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => latitude = value),
            ),
            const SizedBox(height: 20),
            buildTextField(
              label: 'Longitude (Mandatory)',
              hint: 'e.g. 79.8612',
              value: longitude,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => longitude = value),
            ),
            const SizedBox(height: 20),
            buildTextField(
              label: 'Additional Details (Optional)',
              hint: 'Add more details about the problem...',
              value: detailedMessage,
              maxLines: 3,
              onChanged: (value) => setState(() => detailedMessage = value),
            ),
            const SizedBox(height: 20),
            buildPhotoPicker(),
          ] else ...[
            buildSummaryStep(),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              if (currentStep > 1) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => currentStep--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    if (currentStep < 3) {
                      // Validation
                      if (currentStep == 1) {
                        if (selectedIssueType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select issue type')));
                          return;
                        }
                        if (selectedIssueType == 'Other' && (otherIssueDetail == null || otherIssueDetail!.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please specify your issue')));
                          return;
                        }
                      } else if (currentStep == 2) {
                        if (latitude == null || latitude!.isEmpty || longitude == null || longitude!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Latitude and Longitude are mandatory')));
                          return;
                        }
                      }
                      setState(() => currentStep++);
                    } else {
                      submitReport();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentStep < 3 ? 'Next' : 'Submit Report',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(currentStep < 3 ? Icons.arrow_forward : Icons.check_circle_outline, size: 18),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.grey400,
            ),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.emerald700, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          items: items.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildUrgencyField() {
    final urgencyLevels = ['Low', 'Medium', 'High'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How urgent is this?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: urgencyLevels.map((level) {
            final isSelected = selectedUrgency == level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level != 'High' ? 8.0 : 0,
                ),
                child: InkWell(
                  onTap: () => setState(() => selectedUrgency = level),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.emerald600 : AppColors.grey50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.emerald600 : AppColors.grey300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        level,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.grey700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required String? value,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.emerald700, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach Photos (Optional)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.grey700),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Icon(Icons.camera_alt_outlined, color: AppColors.grey400, size: 32),
              const SizedBox(height: 8),
              const Text('Tap to upload photos', style: TextStyle(color: AppColors.grey600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.grey900),
        ),
        const SizedBox(height: 20),
        buildSummaryRow('Issue Type', selectedIssueType == 'Other' ? otherIssueDetail ?? 'Other' : selectedIssueType ?? 'N/A'),
        buildSummaryRow('Urgency', selectedUrgency ?? 'N/A'),
        buildSummaryRow('Waste Type', selectedWasteType ?? 'Not specified'),
        buildSummaryRow('Location', '$latitude, $longitude'),
        if (detailedMessage != null && detailedMessage!.isNotEmpty)
          buildSummaryRow('Details', detailedMessage!),
        const SizedBox(height: 10),
        const Text(
          'Please verify the details before submitting.',
          style: TextStyle(fontSize: 12, color: AppColors.grey500, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, color: AppColors.grey900, fontWeight: FontWeight.w600)),
          const Divider(height: 20, color: AppColors.grey100),
        ],
      ),
    );
  }

  Widget buildReportsList() {
    if (myReports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: AppColors.grey300),
            const SizedBox(height: 16),
            const Text(
              'No reports yet',
              style: TextStyle(color: AppColors.grey500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: myReports.map((report) {
        final status = (report['status'] ?? 'new').toString().toLowerCase();
        final issueType = report['issueType'] ?? 'Unknown Issue';
        final createdAtStr = report['createdAt'] != null 
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(report['createdAt']))
            : 'Unknown Date';
        
        Color statusColor;
        Color statusTextColor;
        String statusLabel = status.toUpperCase();

        if (status == 'accepted' || status == 'completed' || status == 'resolved') {
          statusColor = AppColors.emerald200;
          statusTextColor = AppColors.emerald900;
          statusLabel = 'ACCEPTED';
        } else if (status == 'rejected') {
          statusColor = Colors.red.shade100;
          statusTextColor = Colors.red.shade900;
          statusLabel = 'REJECTED';
        } else if (status == 'inprogress' || status == 'in_progress') {
          statusColor = AppColors.blue200;
          statusTextColor = AppColors.blue600;
          statusLabel = 'IN PROGRESS';
        } else {
          statusColor = AppColors.orange50;
          statusTextColor = AppColors.orange600;
          statusLabel = status == 'new' ? 'PENDING' : status.toUpperCase();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_rounded,
                    color: statusTextColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issueType,
                        style: const TextStyle(
                          color: AppColors.citizenGrey900,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppColors.citizenGrey600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report['location'] ?? 'N/A',
                              style: const TextStyle(
                                color: AppColors.citizenGrey600,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAtStr,
                        style: const TextStyle(
                          color: AppColors.citizenGrey500,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
