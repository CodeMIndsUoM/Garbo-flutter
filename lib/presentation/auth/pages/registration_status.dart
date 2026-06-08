import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/sources/api_service.dart';

/// Registration Status Screen
/// Displays the third-party collector registration status
/// Users can check if their application is PENDING, APPROVED, or REJECTED
class RegistrationStatus extends StatefulWidget {
  final int empId;
  final String email;

  const RegistrationStatus({
    super.key,
    required this.empId,
    required this.email,
  });

  @override
  State<RegistrationStatus> createState() => _RegistrationStatusState();
}

class _RegistrationStatusState extends State<RegistrationStatus> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _statusData;
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final status = await _apiService.checkThirdPartyRegistrationStatus(widget.empId);
      if (mounted) {
        setState(() {
          _statusData = status;
          _loading = false;
          _refreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
        _showSnackBar('Failed to check status: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.redDark2 : AppColors.green700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Registration Status', style: AppTypography.titleLg),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _loading
                ? const CircularProgressIndicator()
                : _buildStatusContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContent() {
    if (_statusData == null) {
      return const Text('No status data available');
    }

    final status = _statusData!['registrationStatus'] as String? ?? 'UNKNOWN';
    final empId = _statusData!['empId'];
    final email = _statusData!['email'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusIcon(status),
        const SizedBox(height: 32),
        _buildStatusCard(status, empId, email),
        const SizedBox(height: 32),
        _buildActionButton(status),
        const SizedBox(height: 16),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status.toUpperCase()) {
      case 'PENDING':
        icon = Icons.hourglass_empty;
        color = AppColors.amber600;
        break;
      case 'APPROVED':
        icon = Icons.check_circle;
        color = AppColors.green700;
        break;
      case 'REJECTED':
        icon = Icons.cancel;
        color = AppColors.redDark2;
        break;
      default:
        icon = Icons.help_outline;
        color = AppColors.grey600;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 64,
        color: color,
      ),
    );
  }

  Widget _buildStatusCard(String status, int empId, String email) {
    String title;
    String message;
    Color cardColor;

    switch (status.toUpperCase()) {
      case 'PENDING':
        title = 'Application Pending';
        message = 'Your registration is under review. We will notify you once it is approved.';
        cardColor = AppColors.amber600;
        break;
      case 'APPROVED':
        title = 'Application Approved';
        message =
            'Your registration has been approved. Check your email for your login credentials. '
            'Sign in with the temporary password — you will be asked to change it on first login.';
        cardColor = AppColors.green700;
        break;
      case 'REJECTED':
        title = 'Application Rejected';
        message = 'Your registration was rejected. Please contact support for more information.';
        cardColor = AppColors.redDark2;
        break;
      default:
        title = 'Status Unknown';
        message = 'Unable to determine your application status.';
        cardColor = AppColors.grey600;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.card().copyWith(
        border: Border.all(color: cardColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.titleLg.copyWith(color: cardColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Application ID', empId.toString()),
          const SizedBox(height: 12),
          _buildInfoRow('Email', email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String status) {
    if (status.toUpperCase() == 'APPROVED') {
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.login,
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green700,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Go to Login',
          style: AppTypography.buttonLg.copyWith(color: Colors.white),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRefreshButton() {
    return TextButton.icon(
      onPressed: _refreshing ? null : _checkStatus,
      icon: _refreshing
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.grey400),
              ),
            )
          : Icon(Icons.refresh, color: AppColors.grey600),
      label: Text(
        _refreshing ? 'Refreshing...' : 'Refresh Status',
        style: AppTypography.bodySm.copyWith(
          color: AppColors.grey600,
        ),
      ),
    );
  }
}
