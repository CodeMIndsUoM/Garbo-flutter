import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:image_picker/image_picker.dart';

class CompleteCollectionSheet extends StatefulWidget {
  final String title;
  final String address;
  final String person;
  final bool weightRequired;

  const CompleteCollectionSheet({
    super.key,
    required this.title,
    required this.address,
    required this.person,
    required this.weightRequired,
  });

  static Future<CompleteCollectionInput?> show(
    BuildContext context, {
    required String title,
    required String address,
    required String person,
    required bool weightRequired,
  }) {
    return Navigator.of(context).push<CompleteCollectionInput>(
      _CompleteCollectionRoute(
        child: CompleteCollectionSheet(
          title: title,
          address: address,
          person: person,
          weightRequired: weightRequired,
        ),
      ),
    );
  }

  @override
  State<CompleteCollectionSheet> createState() =>
      _CompleteCollectionSheetState();
}

class _CompleteCollectionSheetState extends State<CompleteCollectionSheet> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();

  String? _photoPath;
  String? _weightError;

  @override
  void initState() {
    super.initState();
    _weight.addListener(_clearWeightErrorOnEdit);
  }

  @override
  void dispose() {
    _weight.removeListener(_clearWeightErrorOnEdit);
    _weight.dispose();
    _notes.dispose();
    _weightFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  void _clearWeightErrorOnEdit() {
    if (_weightError != null) {
      setState(() => _weightError = null);
    }
  }

  String _shortName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last.substring(0, 1)}.';
  }

  void _submit() {
    final sanitizedWeight = _weight.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsedWeight = sanitizedWeight.isEmpty
        ? null
        : double.tryParse(sanitizedWeight);
    final weightText = sanitizedWeight;
    if (widget.weightRequired && (parsedWeight == null || parsedWeight <= 0)) {
      setState(() => _weightError = 'Weight is required for this waste type.');
      _weightFocus.requestFocus();
      return;
    }
    if (weightText.isNotEmpty && (parsedWeight == null || parsedWeight <= 0)) {
      setState(() => _weightError = 'Weight must be a positive number.');
      _weightFocus.requestFocus();
      return;
    }
    if (_weightError != null) {
      setState(() => _weightError = null);
    }

    Navigator.of(context).pop(
      CompleteCollectionInput(
        weightKg: parsedWeight,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        photoPath: _photoPath,
      ),
    );
  }

  Future<void> _pickCompletionPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.green700,
              ),
              title: Text('Take a photo', style: AppTypography.titleMd),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.green700,
              ),
              title: Text('Choose from gallery', style: AppTypography.titleMd),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null || !mounted) return;
      setState(() => _photoPath = picked.path);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not open $source. Please try again.', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.redDark2 : AppColors.green700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.only(bottom: inset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowMd,
                      offset: Offset(0, -6),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.grey300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 18),
                        Container(height: 1, color: AppColors.grey100),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                          child: _buildJobCard(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(
                                'Collected Weight',
                                isRequired: widget.weightRequired,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _weight,
                                focusNode: _weightFocus,
                                hint: 'e.g. 2.5',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                suffixText: 'kg',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _weightError ??
                                    'Estimate the total weight collected',
                                style: AppTypography.captionSm.copyWith(
                                  color: _weightError != null
                                      ? AppColors.redDark2
                                      : null,
                                  fontWeight: _weightError != null
                                      ? FontWeight.w600
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildFieldLabel(
                                'Collection Notes',
                                isRequired: false,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _notes,
                                focusNode: _notesFocus,
                                hint:
                                    'Add any observations, conditions, or special notes about the collection',
                                maxLines: 4,
                              ),
                              const SizedBox(height: 20),
                              _buildFieldLabel(
                                'Completion Photo',
                                isRequired: false,
                              ),
                              const SizedBox(height: 10),
                              _buildPhotoPicker(),
                              const SizedBox(height: 18),
                              _buildDisclaimer(),
                              const SizedBox(height: 20),
                              _buildCompleteButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.green700,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.green700.withValues(alpha: 0.25),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complete Collection', style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(
                'Confirm the collection details before completing',
                style: AppTypography.bodySm,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.grey600,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.emerald100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.green800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTypography.titleMd),
                const SizedBox(height: 4),
                Text(
                  widget.address,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySm,
                    children: [
                      const TextSpan(text: 'Citizen: '),
                      TextSpan(
                        text: _shortName(widget.person),
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.grey900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: isRequired ? '  (required)' : '  (optional)',
            style: AppTypography.labelSm.copyWith(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? AppColors.green700 : AppColors.grey200,
              width: focused ? 1.4 : 1.2,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: AppColors.green700.withValues(alpha: 0.10),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            cursorColor: AppColors.green700,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.grey400,
              ),
              suffixText: suffixText,
              suffixStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.grey500,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey200, width: 1.2),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.grey500,
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'By completing, you confirm the waste has been collected as agreed',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.green700.withValues(alpha: 0.28),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Material(
          color: AppColors.green700,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _submit,
            borderRadius: BorderRadius.circular(14),
            splashColor: AppColors.green800.withValues(alpha: 0.3),
            highlightColor: AppColors.green800.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.white20,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Complete Collection',
                    style: AppTypography.buttonLg.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return InkWell(
      onTap: _pickCompletionPhoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_photoPath == null)
              Row(
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to capture photo',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_photoPath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheHeight: 480,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CompleteCollectionInput {
  final double? weightKg;
  final String? notes;
  final String? photoPath;

  const CompleteCollectionInput({
    required this.weightKg,
    required this.notes,
    required this.photoPath,
  });
}

class _CompleteCollectionRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _CompleteCollectionRoute({required this.child})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.scrim,
        barrierLabel: 'Dismiss',
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 850),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth slide — same feel for open and close
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeOutCubic,
                ),
              );

          // Scrim (background dim) fades in/out smoothly
          final scrimFade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeOut,
          );

          return Stack(
            children: [
              FadeTransition(
                opacity: scrimFade,
                child: const SizedBox.expand(),
              ),
              SlideTransition(position: slide, child: child),
            ],
          );
        },
      );
}
