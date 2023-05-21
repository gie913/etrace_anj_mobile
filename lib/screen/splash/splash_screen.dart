import 'dart:async';

import 'package:e_trace_app/base/path/image_path.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/screen/login/login_screen.dart';
import 'package:e_trace_app/screen/main/database_local_update.dart';
import 'package:e_trace_app/screen/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    autoLogIn();
    DatabaseLocalUpdate().addNewColumnOnVersion();
    super.initState();
  }

  void autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? session = prefs.getString('session');
    String? tokenExpired = prefs.getString('tokenExpired');
    var duration = const Duration(seconds: 3);
    Timer(duration, () {
      if (session != null) {
        if (tokenExpired != null) {
          DateTime expiredDate = DateTime.parse(tokenExpired);
          DateTime expiredDate14 = new DateTime(
              expiredDate.year, expiredDate.month, expiredDate.day - 14);
          DateTime now = DateTime.now();
          bool valDate = now.isAfter(expiredDate14);
          if (!valDate) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          }
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
        }
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Flexible(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(IMAGE_ICON,
                              width: MediaQuery.of(context).size.width * 0.2),
                          Text(
                            "eTIS",
                            style: TextStyle(
                                fontFamily: "DIN Pro",
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.12),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    Text(POWERED_BY, textAlign: TextAlign.center),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
