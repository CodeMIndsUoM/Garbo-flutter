import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_surface_card.dart';
import 'package:garbo_swms/presentation/shared/widgets/option_select_chips.dart';

enum _EventsView { browse, suggest, mySuggestions }

class CitizenPublicEventsPage extends StatefulWidget {
  const CitizenPublicEventsPage({super.key});

  @override
  State<CitizenPublicEventsPage> createState() =>
      CitizenPublicEventsPageState();
}

class CitizenPublicEventsPageState extends State<CitizenPublicEventsPage> {
  final ApiService _apiService = ApiService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _myEvents = [];
  bool _loading = true;
  bool _submitting = false;
  _EventsView _view = _EventsView.browse;
  String? _selectedCategory;
  DateTime? _selectedDate;
  final Set<int> _enrollingIds = {};

  static const _categories = [
    'Cleanup',
    'Recycling',
    'Education',
    'Community',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _apiService.getEvents(),
        _apiService.getMyEvents(),
      ]);
      if (mounted) {
        setState(() {
          _events = results[0];
          _myEvents = results[1];
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load events')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _enroll(int eventId) async {
    setState(() => _enrollingIds.add(eventId));
    try {
      await _apiService.enrollInEvent(eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrolled successfully')),
        );
        await _loadEvents();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enroll')),
        );
      }
    } finally {
      if (mounted) setState(() => _enrollingIds.remove(eventId));
    }
  }

  Future<void> _submitSuggestion() async {
    if (_titleController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _selectedDate == null ||
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _apiService.suggestEvent({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'eventDate': _selectedDate!.toIso8601String().split('T').first,
        'location': _locationController.text.trim(),
        'category': _selectedCategory,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event suggestion submitted for approval')),
      );
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedDate = null;
        _view = _EventsView.mySuggestions;
      });
      await _loadEvents();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit suggestion')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CitizenHeader(name: 'Events'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildViewToggle(theme),
                          const SizedBox(height: 20),
                          if (_view == _EventsView.browse) ..._buildBrowseView(theme),
                          if (_view == _EventsView.suggest) _buildSuggestForm(theme),
                          if (_view == _EventsView.mySuggestions)
                            _buildMySuggestions(theme),
                          const SizedBox(height: 140),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildViewToggle(ThemeData theme) {
    return SegmentedButton<_EventsView>(
      segments: const [
        ButtonSegment(
          value: _EventsView.browse,
          label: Text('Events'),
          icon: Icon(Icons.event_outlined, size: 18),
        ),
        ButtonSegment(
          value: _EventsView.suggest,
          label: Text('Suggest'),
          icon: Icon(Icons.add_circle_outline, size: 18),
        ),
        ButtonSegment(
          value: _EventsView.mySuggestions,
          label: Text('My Events'),
          icon: Icon(Icons.list_alt_rounded, size: 18),
        ),
      ],
      selected: {_view},
      onSelectionChanged: (selection) {
        setState(() => _view = selection.first);
      },
    );
  }

  List<Widget> _buildBrowseView(ThemeData theme) {
    if (_events.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No upcoming events in your council')),
        ),
      ];
    }
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Upcoming Events', style: theme.textTheme.titleMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_events.length} events',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ..._events.map((e) => buildEventCardFromData(e, theme)),
    ];
  }

  Widget _buildSuggestForm(ThemeData theme) {
    return CitizenSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suggest an Event', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Your council admin will review and approve your suggestion.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Event title *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          OptionSelectChips(
            label: 'Category',
            options: _categories,
            selected: _selectedCategory,
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 16),
          Text('Event date *', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedDate != null
                    ? _selectedDate!.toIso8601String().split('T').first
                    : 'Select date',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location *'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _submitSuggestion,
              child: Text(_submitting ? 'Submitting...' : 'Submit Suggestion'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySuggestions(ThemeData theme) {
    if (_myEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No event suggestions yet')),
      );
    }

    return Column(
      children: _myEvents.map((event) {
        final title = (event['title'] ?? 'Event').toString();
        final status = (event['status'] ?? 'PENDING').toString();
        final date = (event['eventDate'] ?? '').toString();
        final reason = (event['rejectionReason'] ?? '').toString();

        return CitizenSurfaceCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleSmall),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (date.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(date.split('T').first, style: theme.textTheme.bodySmall),
              ],
              if (reason.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Reason: $reason', style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildEventCardFromData(Map<String, dynamic> event, ThemeData theme) {
    final id = (event['id'] as num?)?.toInt() ?? 0;
    final title = (event['title'] ?? 'Event').toString();
    final description = (event['description'] ?? '').toString();
    final date = (event['eventDate'] ?? '').toString();
    final startTime = (event['startTime'] ?? '').toString();
    final endTime = (event['endTime'] ?? '').toString();
    final location = (event['location'] ?? '-').toString();
    final category = (event['category'] ?? 'Event').toString();
    final enrolled = (event['enrolledCount'] as num?)?.toInt() ?? 0;
    final max = (event['maxParticipants'] as num?)?.toInt();
    final participants =
        max != null ? '$enrolled / $max participants' : '$enrolled enrolled';
    final timeLabel = startTime.isNotEmpty
        ? (endTime.isNotEmpty ? '$startTime - $endTime' : startTime)
        : 'Time TBA';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: buildEventCard(
        theme: theme,
        eventId: id,
        badge: category,
        title: title,
        description: description,
        date: date.split('T').first,
        time: timeLabel,
        location: location,
        participants: participants,
      ),
    );
  }

  Widget buildEventCard({
    required ThemeData theme,
    required int eventId,
    required String badge,
    required String title,
    required String description,
    required String date,
    required String time,
    required String location,
    required String participants,
  }) {
    final enrolling = _enrollingIds.contains(eventId);

    return CitizenSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.event,
                    size: 40,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
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
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(description, style: theme.textTheme.bodySmall),
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
                  child: FilledButton(
                    onPressed: enrolling ? null : () => _enroll(eventId),
                    child: Text(enrolling ? 'Enrolling...' : 'Enroll Now'),
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
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
