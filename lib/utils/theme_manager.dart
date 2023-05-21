import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/utils/storage_manager.dart';
import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    primaryColor: Color(0xFF212121),
    brightness: Brightness.dark,
    dividerTheme: DividerThemeData(color: Colors.grey),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(primaryColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(primaryColor),
      ),
    ),
    scaffoldBackgroundColor: Colors.black,
    dividerColor: Colors.black,
    colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange, brightness: Brightness.dark)
        .copyWith(secondary: Colors.white)
        .copyWith(background: Colors.black),
  );

  final lightTheme = ThemeData(
    primaryColor: primaryColor,
    primaryColorDark: primaryColorDark,
    primaryColorLight: primaryColorLight,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      titleTextStyle: appBarStyle20,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),
    brightness: Brightness.light,
    indicatorColor: Colors.white,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(primaryColor),
      ),
    ),
    scaffoldBackgroundColor: Color(0xFFF9F9F9),
    cardColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(primaryColor),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange)
        .copyWith(secondary: primaryColorLight)
        .copyWith(background: primaryColorLight),
  );

  ThemeData? _themeData;

  bool? _status;

  bool? get status => _status;

  ThemeData? getTheme() => _themeData;

  ThemeNotifier() {
    _status = false;
    StorageManager.readData('themeMode').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        _status = false;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        _status = true;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _status = true;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _status = false;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
