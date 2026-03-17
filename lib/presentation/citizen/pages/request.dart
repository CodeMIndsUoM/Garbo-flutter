import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';

class CitizenRequestPage extends StatefulWidget {
  const CitizenRequestPage({super.key});

  @override
  State<CitizenRequestPage> createState() => CitizenRequestPageState();
}

class CitizenRequestPageState extends State<CitizenRequestPage> {
  int currentStep = 1;
  String? selectedWasteType;
  String? selectedQuantity;
  DateTime? selectedPickupDate;
  String? selectedTimeSlot;
  String? selectedPickupLocation;
  String? contactPhone;
  String? additionalNotes;
  bool showMyRequests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          CitizenHeader(name: 'Requests',),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  buildActionButtons(),
                  const SizedBox(height: 20),
                  showMyRequests ? buildRequestsList() : buildRequestForm(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(
        currentIndex: 3,
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => showMyRequests = false);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'New Request',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: !showMyRequests ? AppColors.emerald600 : Colors.white,
              foregroundColor: !showMyRequests ? Colors.white : AppColors.emerald600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: showMyRequests ? const BorderSide(color: AppColors.emerald600, width: 1.5) : BorderSide.none,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() => showMyRequests = true);
            },
            icon: const Icon(Icons.list_alt_rounded, size: 18),
            label: const Text(
              'My Requests',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: showMyRequests ? AppColors.emerald600 : Colors.white,
              foregroundColor: showMyRequests ? Colors.white : AppColors.emerald600,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: !showMyRequests ? const BorderSide(color: AppColors.emerald600, width: 1.5) : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRequestsList() {
    final requests = [
      {
        'image': Icons.electrical_services_rounded,
        'title': 'Electronic Waste',
        'collector': 'GreenTech Recyclers',
        'date': '2025-11-18',
        'status': 'accepted',
        'statusColor': AppColors.blue200,
        'statusTextColor': AppColors.blue600,
        'hasOffers': false,
      },
      {
        'image': Icons.chair_rounded,
        'title': 'Furniture',
        'collector': 'Looking for collector...',
        'date': '2025-11-20',
        'status': 'pending',
        'statusColor': AppColors.orange200,
        'statusTextColor': AppColors.orange600,
        'hasOffers': true,
      },
      {
        'image': Icons.construction_rounded,
        'title': 'Construction Debris',
        'collector': 'BuildWaste Co.',
        'date': '2025-11-12',
        'status': 'completed',
        'statusColor': AppColors.emerald200,
        'statusTextColor': AppColors.emerald900,
        'hasOffers': false,
      },
    ];

    return Column(
      children: [
        ...requests.map((request) {
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      request['image'] as IconData,
                      color: AppColors.grey700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                request['title'] as String,
                                style: const TextStyle(
                                  color: AppColors.citizenGrey900,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: request['statusColor'] as Color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                request['status'] as String,
                                style: TextStyle(
                                  color: request['statusTextColor'] as Color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 14, color: AppColors.citizenGrey600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                request['collector'] as String,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              request['date'] as String,
                              style: const TextStyle(
                                color: AppColors.citizenGrey500,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (request['hasOffers'] == true)
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('View offers feature coming soon'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View available offers',
                                  style: TextStyle(
                                    color: AppColors.emerald600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.emerald50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.emerald200, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.emerald600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tap on pending requests',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'to view and accept collection offers from nearby collectors',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.emerald700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRequestForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Text(
                currentStep == 1 ? 'Request Collection' : currentStep == 2 ? 'Pickup Schedule' : 'Contact & Photos',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey900,
                ),
              ),
              TextButton(
                onPressed: () {
                },
                child: Text(
                  currentStep == 1 ? 'Waste Details' : currentStep == 2 ? 'Pickup Details' : 'Contact & Photos',
                  style: const TextStyle(
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
          if (currentStep == 1) ..._buildStep1Content(),
          if (currentStep == 2) ..._buildStep2Content(),
          if (currentStep == 3) ..._buildStep3Content(),
          if (currentStep == 1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => currentStep++);
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
          if (currentStep > 1)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (currentStep > 1) {
                        setState(() => currentStep--);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey900,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.grey300, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentStep < 3) {
                        setState(() => currentStep++);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request submitted successfully!'),
                            backgroundColor: AppColors.emerald600,
                          ),
                        );
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentStep == 3)
                          const Icon(Icons.check_circle_outline, size: 18),
                        if (currentStep == 3) const SizedBox(width: 8),
                        Text(
                          currentStep == 3 ? 'Submit Request' : 'Next',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (currentStep < 3) const SizedBox(width: 8),
                        if (currentStep < 3)
                          const Icon(Icons.arrow_forward, size: 18),
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

  List<Widget> _buildStep1Content() {
    return [
      buildFormField(
        label: 'What needs to be collected?',
        hint: 'Select waste type',
        value: selectedWasteType,
        onChanged: (value) => setState(() => selectedWasteType = value),
      ),
      const SizedBox(height: 20),
      buildFormField(
        label: 'Estimated quantity',
        hint: 'Select approximate amount',
        value: selectedQuantity,
        onChanged: (value) => setState(() => selectedQuantity = value),
      ),
      const SizedBox(height: 36),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.emerald50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.emerald200, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.emerald600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Collection Info',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Third-party collectors will see your request and contact you directly.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.emerald700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildStep2Content() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferred pickup date *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedPickupDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => selectedPickupDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: AppColors.grey400),
                  const SizedBox(width: 12),
                  Text(
                    selectedPickupDate != null
                        ? '${selectedPickupDate!.year}-${selectedPickupDate!.month.toString().padLeft(2, '0')}-${selectedPickupDate!.day.toString().padLeft(2, '0')}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedPickupDate != null ? AppColors.grey900 : AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      buildFormField(
        label: 'Preferred time slot *',
        hint: 'Select time slot',
        value: selectedTimeSlot,
        onChanged: (value) => setState(() => selectedTimeSlot = value),
      ),
      const SizedBox(height: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pickup location *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => selectedPickupLocation = value),
            decoration: InputDecoration(
              hintText: 'Enter pickup address',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.grey400,
              ),
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.grey400),
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
                borderSide: const BorderSide(
                  color: AppColors.emerald700,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'GPS: Automatically detected',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildStep3Content() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact phone *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => contactPhone = value),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Your phone number',
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.grey400,
              ),
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.grey400),
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
                borderSide: const BorderSide(
                  color: AppColors.emerald700,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Collectors will contact you on this number',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload photos of items *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Help collectors assess the items',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Take photo functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera feature coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  label: const Text(
                    'Take Photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey500,
                    backgroundColor: AppColors.grey50,
                    side: const BorderSide(color: AppColors.grey400, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Upload feature coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_outlined, size: 20),
                  label: const Text(
                    'Upload',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey500,
                    backgroundColor: AppColors.grey50,
                    side: const BorderSide(color: AppColors.grey400, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional notes (Optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => setState(() => additionalNotes = value),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Any special instructions or details...',
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
                borderSide: const BorderSide(
                  color: AppColors.emerald700,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget buildFormField({
    required String label,
    required String hint,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    List<String> items = [];
    if (label == 'What needs to be collected?') {
      items = ['E-Waste', 'Furniture', 'Geaden Waste', 'Other'];
    } else if (label == 'Estimated quantity') {
      items = [
        'Small(1-2 bags/items)',
        'Medium(3-5 bags/items)',
        'Large(6-10 bags/items)',
        'Extra Large(10+ bags/items)'
      ];
    } else if (label == 'Preferred time slot *') {
      items = [
        'Morning(8AM-12PM)',
        'Afternoon(12 PM- 4 PM)',
        'Evening(4PM-7PM)'
      ];
    }

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
              borderSide: const BorderSide(
                color: AppColors.emerald700,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}