import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  return NumberFormat('#,##0', 'ar').format(amount);
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy', 'ar').format(date);
}

String formatTimeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
  if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
  if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
  return 'الآن';
}
