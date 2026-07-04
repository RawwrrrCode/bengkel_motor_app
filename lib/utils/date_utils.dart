import 'package:intl/intl.dart';

class AppDateUtils {
  static final _displayFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final _isoDateFormat = DateFormat('yyyy-MM-dd');

  static String formatDisplay(DateTime date) => _displayFormat.format(date);

  static String formatDisplayFromIso(String isoDate) =>
      _displayFormat.format(DateTime.parse(isoDate));

  static String toIsoDate(DateTime date) => _isoDateFormat.format(date);

  static String nowIso() => DateTime.now().toIso8601String();
}
