class CloudinaryConstants {
  // Use --dart-define to provide real values per environment.
  // Example:
  // flutter run --dart-define=CLOUDINARY_CLOUD_NAME=xxx --dart-define=CLOUDINARY_UPLOAD_PRESET=yyy
  static const String cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: '',
  );

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}
