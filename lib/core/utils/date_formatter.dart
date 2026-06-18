import 'package:intl/intl.dart';

String formatDate(String? date){
  if (date == null) return '-';

  final dateTime= DateTime.tryParse(date);
  final localDateTime= dateTime?.toLocal();
  return DateFormat('yyyy-MM-dd').format(localDateTime!);
}