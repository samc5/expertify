import 'package:intl/intl.dart';
import 'package:universal_html/html.dart';

String humanizeDate(String dateStr) {
  // chatGPT written (refactored from python)
  // Define the date format
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  try {
    // Parse the date string
    DateTime dateTime = dateFormat.parse(dateStr, true);
    DateTime dateLocal = dateTime.toLocal();
    DateTime now = DateTime.now();
    String formattedDate;
    // Check if the date is today
    if (dateLocal.year == now.year &&
        dateLocal.month == now.month &&
        dateLocal.day == now.day) {
      formattedDate = DateFormat('h:mm a').format(dateLocal);
    } else if (dateLocal.year < now.year) {
      formattedDate = DateFormat('MM/dd/yy').format(dateLocal);
    } else {
      formattedDate = DateFormat('MMM dd').format(dateLocal);
    }

    return formattedDate;
  } catch (e) {
    print(e);
    return "Unknown Date";
  }
}
