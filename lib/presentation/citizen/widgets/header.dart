import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/pages/settings.dart';
import 'package:garbo_swms/presentation/widgets/websocket_status_dot.dart';
import 'package:garbo_swms/presentation/widgets/premium/premium_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitizenHeader extends StatefulWidget {
  final String name;
  const CitizenHeader({super.key, required this.name});

  @override
  State<CitizenHeader> createState() => _CitizenHeaderState();
}

class _CitizenHeaderState extends State<CitizenHeader> {
  String _userName = 'Citizen';
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('empName') ?? 'Citizen';
      _points = prefs.getInt('rewardPoints') ?? 145; // Default for demo
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumHeader(
      title: 'Citizen Portal',
      subtitle: 'Hello, $_userName!',
      stats: [
        PremiumStatItem(
          value: '$_points',
          label: 'Eco Points',
          icon: Icons.eco_outlined,
        ),
        const PremiumStatItem(
          value: '3',
          label: 'Active Requests',
          icon: Icons.assignment_outlined,
        ),
      ],
      trailing: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CitizenSettingsPage(),
            ),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white20,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 24),
            ),
            const Positioned(
              right: -2,
              top: -2,
              child: WebSocketStatusDot(size: 11),
            ),
          ],
        ),
      ),
    );
  }
}

