import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';

class CitizenReportPage extends StatefulWidget {
  const CitizenReportPage({super.key});

  @override
  State<CitizenReportPage> createState() => CitizenReportPageState();
}

class CitizenReportPageState extends State<CitizenReportPage> {
  int currentStep = 1;
  String? selectedIssueType;
  String? selectedUrgency;
  String? selectedWasteType;
  bool showMyReports = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          CitizenHeader(name: 'Reports'),
          Expanded(
            child: SingleChildScrollView(
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
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(
        currentIndex: 1,
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
          buildFormField(
            label: "What's the issue?",
            hint: 'Select issue type',
            value: selectedIssueType,
            onChanged: (value) => setState(() => selectedIssueType = value),
          ),
          const SizedBox(height: 20),
          buildFormField(
            label: 'How urgent is this?',
            hint: 'Select urgency',
            value: selectedUrgency,
            onChanged: (value) => setState(() => selectedUrgency = value),
          ),
          const SizedBox(height: 20),
          buildFormField(
            label: 'Waste Type (Optional)',
            hint: 'Select waste type',
            value: selectedWasteType,
            onChanged: (value) => setState(() => selectedWasteType = value),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (currentStep < 3) {
                  setState(() => currentStep++);
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormField({
    required String label,
    required String hint,
    required String? value,
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
          items: const [], 
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildReportsList() {
    final reports = [
      {
        'icon': Icons.info_rounded,
        'title': 'Overflowing Bin',
        'location': 'Main Street',
        'date': '2025-11-15',
        'status': 'in-progress',
        'statusColor': AppColors.blue200,
        'statusTextColor': AppColors.blue600,
        'iconBackgroundColor': AppColors.blue50,
        'iconColor': AppColors.blue600,
      },
      {
        'icon': Icons.warning_rounded,
        'title': 'Illegal Dumping',
        'location': 'Park Avenue',
        'date': '2025-11-16',
        'status': 'pending',
        'statusColor': AppColors.orange50,
        'statusTextColor': AppColors.orange600,
        'iconBackgroundColor': AppColors.orange50,
        'iconColor': AppColors.orange600,
      },
      {
        'icon': Icons.check_circle_rounded,
        'title': 'Missed Collection',
        'location': 'Oak Road',
        'date': '2025-11-10',
        'status': 'resolved',
        'statusColor': AppColors.emerald200,
        'statusTextColor': AppColors.emerald900,
        'iconBackgroundColor': AppColors.emerald50,
        'iconColor': AppColors.emerald600,
      },
    ];

    return Column(
      children: reports.map((report) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                    color: report['iconBackgroundColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    report['icon'] as IconData,
                    color: report['iconColor'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'] as String,
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
                              report['location'] as String,
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
                        report['date'] as String,
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
                    color: report['statusColor'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report['status'] as String,
                    style: TextStyle(
                      color: report['statusTextColor'] as Color,
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
