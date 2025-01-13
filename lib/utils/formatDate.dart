import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  // Get the day with the ordinal suffix
  String day = _getOrdinalSuffix(date.day);

  // Format the date
  String formattedDate = DateFormat("d MMMM, yyyy").format(date);

  // Replace the day part with the ordinal formatted day
  return formattedDate.replaceFirst(date.day.toString(), day);
}

String _getOrdinalSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return '${day}th'; // Special case for 11th, 12th, 13th
  }
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}
