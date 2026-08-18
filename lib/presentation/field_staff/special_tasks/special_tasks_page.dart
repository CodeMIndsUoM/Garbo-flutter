import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/complaint_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/task_status_theme.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/widgets/task_card.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/widgets/task_filter_chips.dart';

/// Special Tasks page shown when the "Tasks" tab is selected.
///
/// Features:
/// - Search bar for quick lookup by ID, title, location, or issue type
/// - Filter chips with real-time count badges
/// - Anti-aliased card list matching the Bins page design language
/// - Status indicating top colored bar on every task card
/// - Approve and Reject modal bottom sheets with image picker and notes
/// - Pull-to-refresh
class SpecialTasksPage extends StatefulWidget {
  const SpecialTasksPage({super.key});

  @override
  State<SpecialTasksPage> createState() => _SpecialTasksPageState();
}

class _SpecialTasksPageState extends State<SpecialTasksPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<ComplaintModel> _tasks = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';

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

  List<ComplaintModel> get _filteredTasks {
    var tasks = List<ComplaintModel>.from(_tasks);

    // Apply status filter dynamically
    if (_selectedFilter != 'All') {
      tasks = tasks
          .where((t) => TaskStatusTheme.formatStatus(t.status) == _selectedFilter)
          .toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      tasks = tasks.where((t) {
        final title = (t.title ?? '').toLowerCase();
        final issueType = (t.issueType ?? '').toLowerCase();
        final location = (t.location ?? '').toLowerCase();
        final wasteType = (t.wasteType ?? '').toLowerCase();
        final idStr = (t.id?.toString() ?? '').toLowerCase();
        final desc = (t.description ?? '').toLowerCase();

        return title.contains(q) ||
            issueType.contains(q) ||
            location.contains(q) ||
            wasteType.contains(q) ||
            idStr.contains(q) ||
            desc.contains(q);
      }).toList();
    }

    // Sort so actionable 'IN_PROGRESS' tasks appear first
    tasks.sort((a, b) {
      final aIsActionable = a.status == 'IN_PROGRESS';
      final bIsActionable = b.status == 'IN_PROGRESS';

      if (aIsActionable && !bIsActionable) return -1;
      if (!aIsActionable && bIsActionable) return 1;

      // Newer first
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return tasks;
  }

  List<TaskFilterItem> get _filterItems {
    final Map<String, int> counts = {'All': _tasks.length};
    for (final task in _tasks) {
      final label = TaskStatusTheme.formatStatus(task.status);
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => TaskFilterItem(label: e.key, count: e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red500),
              const SizedBox(height: 12),
              Text(
                'Error loading tasks: $_errorMessage',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(color: AppColors.red500),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Retry', style: AppTypography.buttonMd),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Static header containing Search Bar & Filter Chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: _buildSearchBar(),
              ),
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TaskFilterChips(
                  filters: _filterItems,
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchTasks,
              child: CustomScrollView(
                slivers: [
                  _filteredTasks.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final task = _filteredTasks[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TaskCard(
                                    task: task,
                                    onApprove: () => _showDecisionSheet(task, true),
                                    onReject: () => _showDecisionSheet(task, false),
                                  ),
                                );
                              },
                              childCount: _filteredTasks.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: AppColors.grey500, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
              decoration: AppDecorations.searchInput(
                hintText: 'Search tasks by title, location or type...',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey500),
                contentPadding: const EdgeInsets.only(bottom: 6),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() => _searchQuery = '');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.clear, color: AppColors.grey500, size: 18),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              'No special tasks found',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'All'
                  ? 'Try changing your search query or selecting a different status filter.'
                  : 'You do not have any special tasks assigned currently.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  void _showDecisionSheet(ComplaintModel task, bool isApprove) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _DecisionSheet(
          task: task,
          isApprove: isApprove,
          onSubmit: (note, imageFile) async {
            try {
              String? photoUrl;
              if (imageFile != null) {
                photoUrl = await _apiService.uploadComplaintImage(imageFile);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A verification photo is required.'),
                      backgroundColor: AppColors.red500,
                    ),
                  );
                }
                return;
              }

              await _apiService.confirmComplaint(task.id!, {
                'isTrue': isApprove,
                'note': note,
                'photoUrl': photoUrl,
              });

              if (sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
              if (mounted) {
                _fetchTasks();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Task ${isApprove ? 'approved' : 'rejected'} successfully.',
                    ),
                    backgroundColor: isApprove ? AppColors.green700 : AppColors.red500,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.red500,
                  ),
                );
              }
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
  final Future<void> Function(String, File?) onSubmit;

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
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset > 0 ? bottomInset + 16 : 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.isApprove ? AppColors.greenSurface2 : AppColors.red50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
                            color: widget.isApprove ? AppColors.green700 : AppColors.red500,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.isApprove ? 'Approve Task' : 'Reject Task',
                          style: AppTypography.h3,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.cancel_outlined, color: AppColors.grey900, size: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.task.displayId} • ${widget.task.displayTitle}',
                  style: AppTypography.caption.copyWith(color: AppColors.grey600),
                ),
                const SizedBox(height: 18),

                // Note Field
                Text('Verification Note (Optional)', style: AppTypography.titleSm),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
                  decoration: InputDecoration(
                    hintText: widget.isApprove
                        ? 'Add any observations or confirmation details...'
                        : 'Explain why this task was rejected...',
                    hintStyle: AppTypography.bodySm.copyWith(color: AppColors.grey500),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.isApprove ? AppColors.green700 : AppColors.red500,
                        width: 1.2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 18),

                // Photo Picker Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Verification Photo', style: AppTypography.titleSm),
                    Text(
                      'Required',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.red500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_imageFile != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _imageFile!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageFile = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 20, color: AppColors.grey700),
                                const SizedBox(width: 8),
                                Text(
                                  'Camera',
                                  style: AppTypography.buttonMd.copyWith(color: AppColors.grey700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library_outlined, size: 20, color: AppColors.grey700),
                                const SizedBox(width: 8),
                                Text(
                                  'Gallery',
                                  style: AppTypography.buttonMd.copyWith(color: AppColors.grey700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Submit Button
                GestureDetector(
                  onTap: _isSubmitting
                      ? null
                      : () async {
                          if (_imageFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('A verification photo is required.'),
                                backgroundColor: AppColors.red500,
                              ),
                            );
                            return;
                          }
                          setState(() => _isSubmitting = true);
                          await widget.onSubmit(_noteController.text, _imageFile);
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.isApprove ? AppColors.green700 : AppColors.red500,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowSm,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            widget.isApprove ? 'Confirm Approval' : 'Confirm Rejection',
                            style: AppTypography.buttonLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
