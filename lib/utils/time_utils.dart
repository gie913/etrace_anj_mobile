import 'dart:convert';

import 'package:intl/intl.dart';

class TimeUtils {
  static DateTime now = DateTime.now();

  static String getIDOnTime(DateTime now) {
    String iDTime = now.year.toString().substring(2) +
        DateFormat('MM').format(now) +
        DateFormat('dd').format(now) +
        DateFormat('HH').format(now) +
        DateFormat('mm').format(now) +
        DateFormat('ss').format(now);
    return iDTime;
  }

  static String getTime(DateTime now) {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
    return formattedDate;
  }

  static String getTimeGreetings() {
    DateTime morningStartTime = DateTime(now.year, now.month, now.day, 00, 00);
    DateTime morningEndTime = DateTime(now.year, now.month, now.day, 11, 59);
    DateTime afternoonStartTime =
        DateTime(now.year, now.month, now.day, 12, 00);
    DateTime afternoonEndTime = DateTime(now.year, now.month, now.day, 17, 59);
    DateTime eveningStartTime = DateTime(now.year, now.month, now.day, 18, 00);
    DateTime eveningEndTime = DateTime(now.year, now.month, now.day, 23, 59);

    String morning = "Selamat pagi, ";
    String afternoon = "Selamat siang, ";
    String evening = "Selamat malam, ";
    String value;

    if (now.isAfter(morningStartTime) && now.isBefore(morningEndTime)) {
      value = morning;
    } else if (now.isAfter(afternoonStartTime) &&
        now.isBefore(afternoonEndTime)) {
      value = afternoon;
    } else if (now.isAfter(eveningStartTime) && now.isBefore(eveningEndTime)) {
      value = evening;
    } else {
      value = "";
    }
    return value;
  }

  static String dateFormatter(DateTime date) {
    dynamic dayData =
        '{ "1" : "Senin", "2" : "Selasa", "3" : "Rabu", "4" : "Kamis", "5" : "Jumat", "6" : "Sabtu", "7" : "Minggu" }';

    dynamic monthData =
        '{ "1" : "Januari", "2" : "Februari", "3" : "Maret", "4" : "April", "5" : "Mei", "6" : "Juni", "7" : "Juli", "8" : "Agustus", "9" : "September", "10" : "Oktober", "11" : "November", "12" : "Desember" }';

    return json.decode(dayData)['${date.weekday}'] +
        ", " +
        date.day.toString() +
        " " +
        json.decode(monthData)['${date.month}'] +
        " " +
        date.year.toString();
  }
}
