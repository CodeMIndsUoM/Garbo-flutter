import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class SendOfferSheet extends StatefulWidget {
  final String wasteType;
  final String location;
  final String preferredTime;
  final String? imageUrl;
  final double? weightKg;
  final String? notes;
  final Future<void> Function({
    double? pricePerUnit,
    String? priceUnit,
    String? exchangeItem,
    required DateTime proposedPickupAt,
    String? messageToCitizen,
  }) onSubmit;

  const SendOfferSheet({
    super.key,
    required this.wasteType,
    required this.location,
    required this.preferredTime,
    this.imageUrl,
    this.weightKg,
    this.notes,
    required this.onSubmit,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String wasteType,
    required String location,
    required String preferredTime,
    String? imageUrl,
    double? weightKg,
    String? notes,
    required Future<void> Function({
      double? pricePerUnit,
      String? priceUnit,
      String? exchangeItem,
      required DateTime proposedPickupAt,
      String? messageToCitizen,
    }) onSubmit,
  }) {
    return Navigator.of(context).push<bool>(
      _SendOfferRoute(
        child: SendOfferSheet(
          wasteType: wasteType,
          location: location,
          preferredTime: preferredTime,
          imageUrl: imageUrl,
          weightKg: weightKg,
          notes: notes,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  @override
  State<SendOfferSheet> createState() => _SendOfferSheetState();
}

class _SendOfferSheetState extends State<SendOfferSheet> {
  final _priceCtrl = TextEditingController();
  final _exchangeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _priceFocus = FocusNode();
  final _exchangeFocus = FocusNode();
  final _notesFocus = FocusNode();

  bool _submitting = false;
  String _offerType = 'PRICE';
  String _priceUnit = 'FIXED';
  DateTime? _proposedPickupAt;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _exchangeCtrl.dispose();
    _notesCtrl.dispose();
    _priceFocus.dispose();
    _exchangeFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_submitting || _proposedPickupAt == null) return false;
    if (_offerType == 'PRICE') {
      final p = double.tryParse(_priceCtrl.text.trim());
      return p != null && p > 0;
    }
    return _exchangeCtrl.text.trim().isNotEmpty;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final init = _proposedPickupAt ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
    );
    if (time == null || !mounted) return;
    setState(() {
      _proposedPickupAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    double? price;
    String? exchangeItem;
    if (_offerType == 'PRICE') {
      price = double.tryParse(_priceCtrl.text.trim());
      if (price == null || price <= 0) {
        _snack('Enter a valid price.', error: true);
        return;
      }
    } else {
      exchangeItem = _exchangeCtrl.text.trim();
      if (exchangeItem.isEmpty) {
        _snack('Enter an exchange item.', error: true);
        return;
      }
    }
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        pricePerUnit: price,
        priceUnit: _offerType == 'PRICE' ? _priceUnit : null,
        exchangeItem: exchangeItem,
        proposedPickupAt: _proposedPickupAt!,
        messageToCitizen: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _snack('Could not send offer: $e', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.redDark2 : AppColors.green700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  String _fmtPickup(DateTime dt) {
    final d = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.hour >= 12 ? 'PM' : 'AM';
    return '$d  $h:$m $s';
  }

  // ── Build ──────────────────────────────────────────────────────────────

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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(color: AppColors.shadowMd, offset: Offset(0, -6), blurRadius: 28),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Drag handle
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
                        const SizedBox(height: 16),
                        // ── Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: _header(),
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: AppColors.grey100),
                        // ── Scrollable body
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _summaryCard(),
                                const SizedBox(height: 22),
                                _offerToggle(),
                                const SizedBox(height: 18),
                                if (_offerType == 'PRICE') ...[
                                  _label('Offer Amount'),
                                  const SizedBox(height: 8),
                                  _inputField(
                                    controller: _priceCtrl,
                                    focusNode: _priceFocus,
                                    hint: '0.00',
                                    prefix: 'LKR  ',
                                    keyboard: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                  const SizedBox(height: 14),
                                  _label('Price Unit'),
                                  const SizedBox(height: 8),
                                  _unitPicker(),
                                ] else ...[
                                  _label('Exchange Item'),
                                  const SizedBox(height: 8),
                                  _inputField(
                                    controller: _exchangeCtrl,
                                    focusNode: _exchangeFocus,
                                    hint: 'e.g. 5 kg rice, fertilizer bag…',
                                    prefixIcon: Icons.swap_horiz_rounded,
                                  ),
                                ],
                                const SizedBox(height: 14),
                                _label('Pickup Date & Time'),
                                const SizedBox(height: 8),
                                _dateTimePicker(),
                                const SizedBox(height: 14),
                                _label('Message to Citizen', optional: true),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _notesCtrl,
                                  focusNode: _notesFocus,
                                  hint: 'Any extra details for the citizen…',
                                  lines: 2,
                                ),
                                const SizedBox(height: 16),
                                _infoBanner(),
                                const SizedBox(height: 18),
                                _sendBtn(),
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

  // ── Header ───────────────────────────────────────────────────────────

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
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
          child: const Icon(Icons.local_offer_rounded, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send Collection Offer', style: AppTypography.h3),
              const SizedBox(height: 2),
              Text('Submit your offer for this request', style: AppTypography.bodySm),
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
            child: const Icon(Icons.close_rounded, color: AppColors.grey600, size: 18),
          ),
        ),
      ],
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────

  Widget _summaryCard() {
    final hasImg = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.emerald50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.emerald100),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImg)
            Image.network(
              widget.imageUrl!,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 60,
                color: AppColors.emerald100,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, color: AppColors.emerald600, size: 24),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _summaryRow(Icons.delete_outline_rounded, 'Waste Type', widget.wasteType),
                const SizedBox(height: 10),
                _summaryRow(Icons.location_on_outlined, 'Location', widget.location),
                const SizedBox(height: 10),
                _summaryRow(Icons.schedule_outlined, 'Preferred', widget.preferredTime),
                if (widget.weightKg != null && widget.weightKg! > 0) ...[
                  const SizedBox(height: 10),
                  _summaryRow(Icons.scale_outlined, 'Est. Weight', '${widget.weightKg} kg'),
                ],
                if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _summaryRow(Icons.notes_rounded, 'Notes', widget.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.emerald700),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.emerald800)),
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

  // ── Offer-type toggle ────────────────────────────────────────────────

  Widget _offerToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _toggleTab('PRICE', Icons.payments_outlined, 'Give Price'),
          const SizedBox(width: 4),
          _toggleTab('EXCHANGE', Icons.swap_horiz_rounded, 'Exchange Item'),
        ],
      ),
    );
  }

  Widget _toggleTab(String type, IconData icon, String text) {
    final active = _offerType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _offerType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [const BoxShadow(color: AppColors.shadowSm, blurRadius: 6, offset: Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? AppColors.green700 : AppColors.grey400),
              const SizedBox(width: 6),
              Text(
                text,
                style: AppTypography.labelMd.copyWith(
                  color: active ? AppColors.green700 : AppColors.grey500,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared input field ───────────────────────────────────────────────

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    String? prefix,
    IconData? prefixIcon,
    int lines = 1,
    TextInputType? keyboard,
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
              width: focused ? 1.4 : 1,
            ),
            boxShadow: focused
                ? [BoxShadow(color: AppColors.green700.withValues(alpha: 0.10), blurRadius: 0, spreadRadius: 3)]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: lines,
            keyboardType: keyboard,
            cursorColor: AppColors.green700,
            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey400),
              prefixText: prefix,
              prefixStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey500, fontWeight: FontWeight.w600),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 4),
                      child: Icon(prefixIcon, size: 18, color: focused ? AppColors.green700 : AppColors.grey400),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            onChanged: (_) => setState(() {}),
          ),
        );
      },
    );
  }

  // ── Unit picker ──────────────────────────────────────────────────────

  Widget _unitPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _priceUnit,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey500),
          borderRadius: BorderRadius.circular(12),
          style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
          items: const [
            DropdownMenuItem(value: 'FIXED', child: Text('Fixed Price')),
            DropdownMenuItem(value: 'PER_KG', child: Text('Per Kilogram')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _priceUnit = v);
          },
        ),
      ),
    );
  }

  // ── Date-time picker ─────────────────────────────────────────────────

  Widget _dateTimePicker() {
    final picked = _proposedPickupAt != null;
    return InkWell(
      onTap: _pickDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: picked ? AppColors.emerald200 : AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: picked ? AppColors.emerald50 : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: picked ? AppColors.green700 : AppColors.grey400,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                picked ? _fmtPickup(_proposedPickupAt!) : 'Select pickup date and time',
                style: AppTypography.bodyMd.copyWith(
                  color: picked ? AppColors.grey900 : AppColors.grey400,
                  fontWeight: picked ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: picked ? AppColors.green700 : AppColors.grey300,
            ),
          ],
        ),
      ),
    );
  }

  // ── Field label ──────────────────────────────────────────────────────

  Widget _label(String text, {bool optional = false}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: text,
          style: AppTypography.labelMd.copyWith(color: AppColors.grey900, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        if (optional)
          TextSpan(text: '  (optional)', style: AppTypography.labelSm.copyWith(color: AppColors.grey400)),
      ]),
    );
  }

  // ── Info banner ──────────────────────────────────────────────────────

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
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
              border: Border.all(color: AppColors.grey200),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.info_outline_rounded, color: AppColors.grey500, size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Citizens can compare offers and accept one based on price and timing.',
                style: AppTypography.captionSm.copyWith(color: AppColors.grey600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Send button ──────────────────────────────────────────────────────

  Widget _sendBtn() {
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
            splashColor: AppColors.green800.withValues(alpha: 0.3),
            highlightColor: AppColors.green800.withValues(alpha: 0.15),
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
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(color: AppColors.white20, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 12),
                    ),
                  const SizedBox(width: 10),
                  Text(
                    _submitting ? 'Sending…' : 'Send Offer',
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

// ── Route (slide-up transition) ────────────────────────────────────────

class _SendOfferRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  _SendOfferRoute({required this.child})
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
          final slide = Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeOutCubic,
          ));

          // Scrim (background dim) fades in/out smoothly
          final scrimFade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeOut,
          );

          return Stack(
            children: [
              // Animated scrim overlay
              FadeTransition(
                opacity: scrimFade,
                child: const SizedBox.expand(),
              ),
              // Sheet slides up/down
              SlideTransition(
                position: slide,
                child: child,
              ),
            ],
          );
        },
      );
}
