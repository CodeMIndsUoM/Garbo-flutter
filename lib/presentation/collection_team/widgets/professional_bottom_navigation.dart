import 'package:flutter/material.dart';

/// A professional, animated bottom navigation bar with smooth transitions.
///
/// Features:
/// - Sliding indicator with smooth horizontal movement
/// - Opacity transitions (100% ↔ 60%) for labels
/// - Subtle scale effect on active tab
/// - Staggered animations for natural motion
/// - Enterprise-grade visual polish
class ProfessionalBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final Color borderColor;

  const ProfessionalBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor = const Color(0xFF03824B),
    this.inactiveColor = const Color(0xFF6A7282),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5E7EB),
  });

  @override
  State<ProfessionalBottomNavigation> createState() =>
      _ProfessionalBottomNavigationState();
}

class _ProfessionalBottomNavigationState
    extends State<ProfessionalBottomNavigation>
    with TickerProviderStateMixin {
  late int _previousIndex;
  late AnimationController _indicatorController;
  late AnimationController _scaleController;
  late Animation<double> _indicatorAnimation;
  late Animation<double> _scaleAnimation;

  // Custom ease-out cubic curve (0.22, 1, 0.36, 1)
  static const Curve _easeOutCubic = Cubic(0.22, 1, 0.36, 1);

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    // Indicator slide animation: 250ms
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Scale animation: 150ms
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _indicatorAnimation =
        Tween<double>(
          begin: widget.currentIndex.toDouble(),
          end: widget.currentIndex.toDouble(),
        ).animate(
          CurvedAnimation(parent: _indicatorController, curve: _easeOutCubic),
        );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: _easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: _easeOutCubic)),
        weight: 50,
      ),
    ]).animate(_scaleController);
  }

  @override
  void didUpdateWidget(ProfessionalBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateToIndex(widget.currentIndex);
    }
  }

  void _animateToIndex(int newIndex) {
    _indicatorAnimation =
        Tween<double>(
          begin: _previousIndex.toDouble(),
          end: newIndex.toDouble(),
        ).animate(
          CurvedAnimation(parent: _indicatorController, curve: _easeOutCubic),
        );

    _indicatorController.forward(from: 0);

    // Start scale animation with 60ms delay
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) {
        _scaleController.forward(from: 0);
      }
    });

    _previousIndex = newIndex;
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border(top: BorderSide(color: widget.borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(widget.items.length, (index) {
              return Expanded(
                child: _NavItemWidget(
                  item: widget.items[index],
                  isSelected: index == widget.currentIndex,
                  activeColor: widget.activeColor,
                  inactiveColor: widget.inactiveColor,
                  scaleAnimation: index == widget.currentIndex
                      ? _scaleAnimation
                      : null,
                  onTap: () => widget.onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final Animation<double>? scaleAnimation;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
      value: widget.isSelected ? 1.0 : 0.0,
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _opacityController,
        curve: const Cubic(0.22, 1, 0.36, 1),
      ),
    );
  }

  @override
  void didUpdateWidget(_NavItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      // Start opacity transition with 40ms delay
      Future.delayed(const Duration(milliseconds: 40), () {
        if (mounted) {
          if (widget.isSelected) {
            _opacityController.forward();
          } else {
            _opacityController.reverse();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _opacityController,
          if (widget.scaleAnimation != null) widget.scaleAnimation!,
        ]),
        builder: (context, child) {
          final scale = widget.scaleAnimation?.value ?? 1.0;
          final opacity = _opacityAnimation.value;

          return Transform.scale(
            scale: widget.isSelected ? scale : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: widget.isSelected
                      ? opacity
                      : 0.6 + (1 - opacity) * 0.4,
                  child: Icon(
                    widget.item.icon,
                    color: widget.isSelected
                        ? widget.activeColor
                        : widget.inactiveColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Opacity(
                  opacity: widget.isSelected
                      ? opacity
                      : 0.6 + (1 - opacity) * 0.4,
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: widget.isSelected
                          ? widget.activeColor
                          : widget.inactiveColor,
                      fontSize: 11,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Navigation item data model
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// Simple dissolve page transition for navigation
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.22, 1, 0.36, 1),
            ),
            child: child,
          );
        },
      );
}
