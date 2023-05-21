import 'package:e_trace_app/model/point_response.dart';
import 'package:e_trace_app/screen/point/point_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class PointNotifier extends ChangeNotifier {
  List<Data>? _listData;
  PointResponse? _pointResponse;

  List<Data>? get listData => _listData;

  PointResponse? get pointResponse => _pointResponse;

  void doGetPoint() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('token');
    final String? userBaseUrl = prefs.getString('baseUrl');
    PointRepository(userBaseUrl!)
        .doGetPrice(userToken!, onSuccessPointCallback, onErrorPointCallback);
  }

  onSuccessPointCallback(PointResponse pointResponse) {
    pointResponse = pointResponse;
    notifyListeners();
  }

  onErrorPointCallback(response, BuildContext context) {
    Toast.show(response.toString(), duration: 1, gravity: 0);
  }
}
