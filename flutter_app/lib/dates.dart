import 'package:intl/intl.dart';

String humanizeDate(String dateStr) {
  // chatGPT written (refactored from python)
  // Define the date format
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  try {
    // Parse the date string
    DateTime dateTime = dateFormat.parse(dateStr);
    DateTime now = DateTime.now();
    String formattedDate;

    // Check if the date is today
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      formattedDate = DateFormat('h:mm a').format(dateTime);
    } else if (dateTime.year < now.year) {
      formattedDate = DateFormat('MM/dd/yy').format(dateTime);
    } else {
      formattedDate = DateFormat('MMM dd').format(dateTime);
    }

    return formattedDate;
  } catch (e) {
    print(e);
    return "Unknown Date";
  }
}
