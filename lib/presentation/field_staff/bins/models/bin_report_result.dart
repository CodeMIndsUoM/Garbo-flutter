class BinReportResult {
  final bool success;
  final String? status;
  final int? fillLevel;
  final bool discrepancy;
  final String? previousStatus;

  const BinReportResult({
    required this.success,
    this.status,
    this.fillLevel,
    this.discrepancy = false,
    this.previousStatus,
  });

  factory BinReportResult.fromJson(Map<String, dynamic> body) {
    final data = body['data'];
    if (body['success'] != true || data is! Map<String, dynamic>) {
      return const BinReportResult(success: false);
    }

    return BinReportResult(
      success: true,
      status: data['status']?.toString(),
      fillLevel: _parseInt(data['fillLevel']),
      discrepancy: data['discrepancy'] == true,
      previousStatus: data['previousStatus']?.toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
