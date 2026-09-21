/// Lightweight, dependency-free date helpers.
class AppDate {
  const AppDate._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// e.g. "12 Aug 2025"
  static String format(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// e.g. "just now", "5m ago", "3h ago", "2d ago", or a date for older.
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return format(date);
  }
}
