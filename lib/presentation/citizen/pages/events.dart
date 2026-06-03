import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';

class CitizenPublicEventsPage extends StatefulWidget {
  const CitizenPublicEventsPage({super.key});

  @override
  State<CitizenPublicEventsPage> createState() =>
      CitizenPublicEventsPageState();
}

class CitizenPublicEventsPageState extends State<CitizenPublicEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          CitizenHeader(name: 'Events'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  buildSectionHeader(),
                  const SizedBox(height: 16),
                  buildEventCard(
                    badge: 'Cleanup',
                    badgeColor: AppColors.emerald600,
                    imageUrl: 'assets/cleanup_event.jpg',
                    title: 'Community Cleanup Drive',
                    description:
                        'Join us for a community clean up event. Gloves and bags will be provided.',
                    date: '2025-11-25',
                    time: '9:00 AM - 12:00 PM',
                    location: 'Central Park',
                    participants: '45 / 100 participants',
                  ),
                  const SizedBox(height: 16),
                  buildEventCard(
                    badge: 'Workshop',
                    badgeColor: AppColors.purple600,
                    imageUrl: 'assets/workshop_event.jpg',
                    title: 'Recycling Workshop',
                    description:
                        'Learn how to properly sort and recycle different materials.',
                    date: '2025-12-02',
                    time: '2:00 PM - 4:00 PM',
                    location: 'Community Center',
                    participants: '23 / 50 participants',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(
        currentIndex: 2,
      ),
    );
  }

  Widget buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.emerald100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '2 events',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.emerald700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEventCard({
    required String badge,
    required Color badgeColor,
    required String imageUrl,
    required String title,
    required String description,
    required String date,
    required String time,
    required String location,
    required String participants,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  color: AppColors.grey300,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: AppColors.grey500,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                buildEventInfo(Icons.calendar_today_rounded, date),
                const SizedBox(height: 8),
                buildEventInfo(Icons.access_time_rounded, time),
                const SizedBox(height: 8),
                buildEventInfo(Icons.location_on_outlined, location),
                const SizedBox(height: 8),
                buildEventInfo(Icons.group_outlined, participants),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Enroll Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEventInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey600),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }
}