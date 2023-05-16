import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/screen/point/point_notifier.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:provider/provider.dart';

class PointScreen extends StatefulWidget {
  @override
  _PointScreenState createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  @override
  void initState() {
    context.read<PointNotifier>().doGetPoint();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text(TITLE_POINT)),
        ),
        body: Consumer<PointNotifier>(builder: (context, pointNotifier, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Saat ini fitur belum tersedia", style: text16, textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Linecons.wallet, size: 40, color: Colors.cyan,),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            pointNotifier.pointResponse != null
                                ? "${formatDecimal(pointNotifier.pointResponse.data.currentPoint)}"
                                : "0", style: TextStyle(fontSize: 30))),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    POINT_SUBTITLE, style: text16, textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          );
        }));
  }

  String formatDecimal(int number) {
    int num = number;
    if (num > -1000 && num < 1000)
      return number.toString();

    final String digits = num.abs().toString();
    final StringBuffer result = StringBuffer(num < 0 ? '-' : '');
    final int maxDigitIndex = digits.length - 1;
    for (int i = 0; i <= maxDigitIndex; i += 1) {
      result.write(digits[i]);
      if (i < maxDigitIndex && (maxDigitIndex - i) % 3 == 0)
        result.write(',');
    }
    return result.toString();
  }

}
