import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class SendOfferSheet extends StatefulWidget {
  final String wasteType;
  final String location;
  final String preferredTime;
  final Future<void> Function({
    required double pricePerUnit,
    required String priceUnit,
    required DateTime proposedPickupAt,
    String? messageToCitizen,
  })
  onSubmit;

  const SendOfferSheet({
    super.key,
    required this.wasteType,
    required this.location,
    required this.preferredTime,
    required this.onSubmit,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String wasteType,
    required String location,
    required String preferredTime,
    required Future<void> Function({
      required double pricePerUnit,
      required String priceUnit,
      required DateTime proposedPickupAt,
      String? messageToCitizen,
    })
    onSubmit,
  }) {
    return Navigator.of(context).push<bool>(
      _SendOfferRoute(
        child: SendOfferSheet(
          wasteType: wasteType,
          location: location,
          preferredTime: preferredTime,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  @override
  State<SendOfferSheet> createState() => _SendOfferSheetState();
}

class _SendOfferSheetState extends State<SendOfferSheet> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  bool _submitting = false;
  String _priceUnit = 'FIXED';
  DateTime? _proposedPickupAt;

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    _priceFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final price = double.tryParse(_priceController.text.trim());
    return !_submitting &&
        price != null &&
        price > 0 &&
        _proposedPickupAt != null;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _proposedPickupAt ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _proposedPickupAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _showSnack('Enter a valid price.', isError: true);
      return;
    }
    final pickupAt = _proposedPickupAt;
    if (pickupAt == null) {
      _showSnack('Select a pickup date and time.', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        pricePerUnit: price,
        priceUnit: _priceUnit,
        proposedPickupAt: pickupAt,
        messageToCitizen: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not send offer: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
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

  String _formatPickup(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.92;

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
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('Request Summary'),
                                const SizedBox(height: 10),
                                _buildSummaryCard(),
                                const SizedBox(height: 20),
                                _buildFieldLabel('Price'),
                                const SizedBox(height: 10),
                                _buildPriceField(),
                                const SizedBox(height: 14),
                                _buildFieldLabel('Price Unit'),
                                const SizedBox(height: 10),
                                _buildPriceUnitPicker(),
                                const SizedBox(height: 14),
                                _buildFieldLabel('Proposed Pickup Time'),
                                const SizedBox(height: 10),
                                _buildDateTimeButton(),
                                const SizedBox(height: 20),
                                _buildFieldLabel(
                                  'Message to Citizen',
                                  optional: true,
                                ),
                                const SizedBox(height: 10),
                                _buildNotesField(),
                                const SizedBox(height: 18),
                                _buildInfoBanner(),
                                const SizedBox(height: 20),
                                _buildSendButton(),
                              ],
                            ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send Collection Offer', style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(
                'Submit your price and pickup time for this request',
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTypography.titleSm.copyWith(color: AppColors.grey900),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emerald100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Waste Type', widget.wasteType),
          const SizedBox(height: 10),
          _buildSummaryRow('Location', widget.location),
          const SizedBox(height: 10),
          _buildSummaryRow('Preferred Time', widget.preferredTime),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool optional = false}) {
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
          if (optional)
            TextSpan(
              text: '  (optional)',
              style: AppTypography.labelSm.copyWith(color: AppColors.grey400),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return AnimatedBuilder(
      animation: _priceFocus,
      builder: (context, _) {
        final focused = _priceFocus.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? AppColors.green700 : AppColors.grey200,
              width: focused ? 1.4 : 1,
            ),
          ),
          child: TextField(
            controller: _priceController,
            focusNode: _priceFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: AppColors.green700,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: 'Enter amount (LKR)',
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.grey400,
              ),
              prefixText: 'LKR ',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        );
      },
    );
  }

  Widget _buildPriceUnitPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _priceUnit,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey500,
          ),
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(value: 'FIXED', child: Text('Fixed Price')),
            DropdownMenuItem(value: 'PER_KG', child: Text('Per Kilogram')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _priceUnit = v);
          },
        ),
      ),
    );
  }

  Widget _buildDateTimeButton() {
    final text = _proposedPickupAt == null
        ? 'Select pickup date and time'
        : _formatPickup(_proposedPickupAt!);
    return InkWell(
      onTap: _pickDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              color: AppColors.green700,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMd.copyWith(
                  color: _proposedPickupAt == null
                      ? AppColors.grey400
                      : AppColors.grey900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return AnimatedBuilder(
      animation: _notesFocus,
      builder: (context, _) {
        final focused = _notesFocus.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? AppColors.green700 : AppColors.grey200,
              width: focused ? 1.4 : 1,
            ),
          ),
          child: TextField(
            controller: _notesController,
            focusNode: _notesFocus,
            maxLines: 3,
            cursorColor: AppColors.green700,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: 'Any extra details for the citizen',
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.grey400,
              ),
              border: InputBorder.none,
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

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emerald100, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.emerald100,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.green800,
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Citizens can compare offers and accept one based on price and timing.',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.green800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _canSubmit
              ? [
                  BoxShadow(
                    color: AppColors.green700.withValues(alpha: 0.28),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: _canSubmit ? AppColors.green700 : AppColors.grey300,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _canSubmit ? _submit : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_submitting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  const SizedBox(width: 10),
                  Text(
                    _submitting ? 'Sending...' : 'Send Offer',
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
}

class _SendOfferRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _SendOfferRoute({required this.child})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: AppColors.scrim,
        barrierLabel: 'Dismiss',
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final motion = CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.05, 0.7, 0.1, 1.0),
            reverseCurve: const Cubic(0.3, 0.0, 0.8, 0.15),
          );
          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
            reverseCurve: const Interval(0.3, 1.0, curve: Curves.easeInCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(motion),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1.0).animate(motion),
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
      );
}
