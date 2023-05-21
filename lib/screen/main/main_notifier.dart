import 'package:e_trace_app/screen/home/home_screen.dart';
import 'package:e_trace_app/screen/price/price_web_view_screen.dart';
import 'package:e_trace_app/screen/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class MainNotifier extends ChangeNotifier {
  int _selectedIndex = 0;
  String? _token;
  List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PriceWebViewScreen(),
    ProfileScreen()
  ];

  int get selectIndex => _selectedIndex;

  String? get token => _token;

  List<Widget> get widgetOption => _widgetOptions;

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
