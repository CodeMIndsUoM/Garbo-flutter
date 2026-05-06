import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/pages/suggest_event.dart';
import 'package:garbo_swms/data/sources/citizen_api.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'dart:convert';

class CitizenPublicEventsPage extends StatefulWidget {
  const CitizenPublicEventsPage({super.key});

  @override
  State<CitizenPublicEventsPage> createState() =>
      CitizenPublicEventsPageState();
}

class CitizenPublicEventsPageState extends State<CitizenPublicEventsPage> {
  List<dynamic> _approvedEvents = [];
  bool _isLoading = true;
  bool _showSuggestForm = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
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
      final events = await api.getVisibleEvents();
      if (mounted) {
        setState(() {
          _approvedEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('Error fetching events: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuggestForm) {
      return WillPopScope(
        onWillPop: () async {
          setState(() => _showSuggestForm = false);
          return false;
        },
        child: SuggestEventPage(
          onSuccess: () {
            setState(() => _showSuggestForm = false);
            _fetchEvents();
          },
          onCancel: () {
            setState(() => _showSuggestForm = false);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _approvedEvents.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: AppColors.grey400),
                      const SizedBox(height: 16),
                      const Text('No upcoming events found', style: TextStyle(color: AppColors.grey600)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchEvents,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: _approvedEvents.length,
                itemBuilder: (context, index) {
                  final event = _approvedEvents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: buildEventCard(event),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => _showSuggestForm = true);
        },
        backgroundColor: AppColors.emerald600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Suggest Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildEventCard(dynamic event) {
    final category = (event['category'] ?? 'Event').toString().toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  child: event['imageUrl'] != null && event['imageUrl'].toString().isNotEmpty
                      ? Image.network(event['imageUrl'], fit: BoxFit.cover)
                      : const Icon(Icons.image_outlined, size: 48, color: AppColors.grey500),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.emerald600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
                  event['title'] ?? 'Untitled Event',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.grey900),
                ),
                const SizedBox(height: 8),
                Text(
                  event['description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 14, color: AppColors.grey600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                buildEventInfo(Icons.calendar_today, event['eventDate'] ?? 'Date TBD'),
                const SizedBox(height: 8),
                buildEventInfo(Icons.location_on, event['location'] ?? 'Location TBD'),
                const SizedBox(height: 8),
                buildEventInfo(
                  Icons.people, 
                  'Enrolled: ${event['enrolledCount'] ?? 0}${event['maxParticipants'] != null ? ' / ${event['maxParticipants']}' : ''}'
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
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
                        final success = await api.enrollEvent(event['id']);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Successfully enrolled in event!')),
                          );
                          _fetchEvents();
                        }
                      } catch (e) {
                        if (mounted) {
                          print('ERROR ENROLLING: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to enroll: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Enroll Now', style: TextStyle(fontWeight: FontWeight.bold)),
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
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.grey700)),
      ],
    );
  }
}