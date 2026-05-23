class ProfileBadge {
  final int stars;
  final String label;
  final double fontSize;
  final String iconUrl;

  const ProfileBadge({
    required this.stars,
    required this.label,
    this.fontSize = 14,
    this.iconUrl = '',
  });
}
