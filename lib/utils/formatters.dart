import 'package:intl/intl.dart';

class AppFormatters {
  static final _numberFmt = NumberFormat.decimalPattern('id_ID');
  static final _dateFmt = DateFormat('d MMM yyyy', 'id_ID');

  static String fmtNumber(int n) => _numberFmt.format(n);

  static String fmtRp(int n) => 'Rp ${_numberFmt.format(n)}';

  static String fmtKm(int n) => '${_numberFmt.format(n)} km';

  static String fmtDate(DateTime date) => _dateFmt.format(date);

  static String fmtRating(double rating) => rating.toStringAsFixed(1).replaceAll('.', ',');
}
