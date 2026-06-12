import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Map + current-location actions used when submitting coordinates.
class LocationSubmitActions extends StatelessWidget {
  const LocationSubmitActions({
    super.key,
    required this.onChooseOnMap,
    required this.onUseCurrentLocation,
    this.resolvingLocation = false,
    this.mapButtonLabel = 'Choose on map',
    this.currentLocationLabel = 'Current location',
  });

  final VoidCallback onChooseOnMap;
  final VoidCallback? onUseCurrentLocation;
  final bool resolvingLocation;
  final String mapButtonLabel;
  final String currentLocationLabel;

  static const _buttonStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    ),
    visualDensity: VisualDensity.compact,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static TextStyle get _labelStyle =>
      AppTypography.labelSm.copyWith(fontSize: 11, height: 1.1);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onChooseOnMap,
            style: _buttonStyle,
            child: _LocationButtonContent(
              icon: const Icon(Icons.map_outlined, size: 16),
              label: mapButtonLabel,
              labelStyle: _labelStyle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: resolvingLocation ? null : onUseCurrentLocation,
            style: _buttonStyle,
            child: _LocationButtonContent(
              icon: resolvingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 16),
              label: currentLocationLabel,
              labelStyle: _labelStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationButtonContent extends StatelessWidget {
  const _LocationButtonContent({
    required this.icon,
    required this.label,
    required this.labelStyle,
  });

  final Widget icon;
  final String label;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: labelStyle,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact single location button styling for standalone screens.
class LocationActionButton extends StatelessWidget {
  const LocationActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.loading = false,
    this.icon = Icons.my_location,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool loading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: LocationSubmitActions._buttonStyle,
      child: _LocationButtonContent(
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 16),
        label: label,
        labelStyle: LocationSubmitActions._labelStyle,
      ),
    );
  }
}
