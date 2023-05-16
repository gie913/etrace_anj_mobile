
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

Future<void> secureScreen() async {
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}

Future<void> disableSecureScreen() async {
  await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
}