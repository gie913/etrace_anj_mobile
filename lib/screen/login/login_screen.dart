import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/path/image_path.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/model/companies.dart';
import 'package:e_trace_app/screen/login/companies_notifier.dart';
import 'package:e_trace_app/screen/login/forgot_password_repository.dart';
import 'package:e_trace_app/screen/login/forgot_password_response.dart';
import 'package:e_trace_app/screen/login/login_notifier.dart';
import 'package:e_trace_app/screen/server/server_screen.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:e_trace_app/screen/profile/privacy_screen.dart';
import 'package:e_trace_app/screen/profile/term_condition_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailForgotController = TextEditingController();
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  bool _obscureText = true;
  bool autoVal = false;
  bool? checkBoxValue;
  final _formKey = GlobalKey<FormState>();
  DataCompanies? dataCompanies;

  @override
  initState() {
    setBaseUrl();
    checkBoxValue = false;
    super.initState();
  }

  setBaseUrl() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? baseUrl = preferences.getString('baseUrl');
    if (baseUrl == null) {
      preferences.setString('baseUrl', APIEndpoint.BASE_URL);
    }
    String? username = preferences.getString('username');
    if (username != null) {
      emailController.text = username;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer<CompanyViewModel>(
        builder: (context, company, child) => Scaffold(
          body: Container(
            child: Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 30, top: 40),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(IMAGE_ICON,
                                  width:
                                      MediaQuery.of(context).size.width * 0.14),
                              Text(
                                "eTIS ANJ",
                                style: TextStyle(
                                    fontFamily: "DIN Pro",
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.10),
                              )
                            ],
                          ),
                        ),
                        Text(
                          "Electronic Traceability \nInformation System",
                          style: titleTextApp,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              Text(SUBTITLE_LOGIN),
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: TextFormField(
                                  controller: emailController,
                                  autocorrect: false,
                                  textInputAction: TextInputAction.next,
                                  focusNode: _emailFocus,
                                  onTap: () {
                                    setState(() {
                                      autoVal = true;
                                    });
                                  },
                                  onEditingComplete: () {
                                    _fieldFocusChange(
                                        context, _emailFocus, _passwordFocus);
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    hintText: USERNAME,
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return ALERT_USERNAME;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              TextFormField(
                                controller: passwordController,
                                focusNode: _passwordFocus,
                                autocorrect: false,
                                textInputAction: TextInputAction.done,
                                onEditingComplete: () {
                                  _passwordFocus.unfocus();
                                  _uiInputValidation(company.myCompany);
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  suffixIcon: InkWell(
                                      onTap: _toggle,
                                      child: _obscureText
                                          ? Icon(Elusive.eye)
                                          : Icon(Elusive.eye_off)),
                                  hintText: PASSWORD,
                                  filled: true,
                                ),
                                obscureText: _obscureText,
                                validator: (value) {
                                  return validator(value);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () {
                            _uiInputValidation(company.myCompany);
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              LOGIN,
                              textAlign: TextAlign.center,
                              style: buttonStyle18,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ServerScreen()));
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Konfigurasi"),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  showForgotPasswordDialog(context);
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(FORGOT_PASSWORD),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(APP_VERSION),
                              SizedBox(
                                height: 10,
                              ),
                              Text(POWERED_BY, style: text14Bold),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? validator(dynamic value) {
    if (value.isEmpty) {
      return PASSWORD_ALERT;
    }
    return null;
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  _uiInputValidation(String companyId) async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? agreement = prefs.getString('agreement');
      if (agreement == null) {
        showDialogAgreement(context);
      } else {
        LoginVieModel().doLoginEvent(
            context, emailController.text, passwordController.text, companyId);
      }
    } else {
      setState(() {
        autoVal = true;
      });
    }
  }

  showDialogAgreement(BuildContext context) {
    agreementDialog(context);
  }

  doForgotPasswordEvent(BuildContext context, String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userBaseUrl = prefs.getString('baseUrl');
    if (userBaseUrl != null) {
      loadingDialog(context);
      ForgotPasswordRepository(userBaseUrl).doPostForgotPassword(
          context,
          username,
          _onSuccessForgotPasswordCallback,
          _onErrorForgotPasswordCallback);
    } else {
      Toast.show(SERVER_NOT_CONFIGURE, duration: 3, gravity: 2);
    }
  }

  _onSuccessForgotPasswordCallback(
      BuildContext context, ForgotPasswordResponse forgotPasswordResponse) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Berhasil Mengirim Email"),
            content: Text("${forgotPasswordResponse.message}"),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    OK,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  })
            ],
          );
        }).then((val) {
      Navigator.pop(context);
    });
  }

  _onErrorForgotPasswordCallback(BuildContext context,
      ForgotPasswordResponse forgotPasswordResponse) async {
    Toast.show(forgotPasswordResponse.message!, duration: 3, gravity: 2);
    Navigator.pop(context);
  }

  showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(FORGOT_PASSWORD_DIALOG),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(INPUT_EMAIL_ADDRESS),
                ),
                TextField(
                  controller: emailForgotController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    hintText: "username",
                    filled: true,
                  ),
                )
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                child: Text("Batal",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                child: Text("Lanjutkan",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                onTap: () {
                  if (emailForgotController.text.isNotEmpty) {
                    doForgotPasswordEvent(context, emailForgotController.text);
                  } else {
                    Toast.show("Belum Mengisi Username",
                        duration: 3, gravity: 2);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  setAgreement(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('agreement', 'agree');
  }

  checkAgreement(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? agreement = prefs.getString('agreement');
    if (agreement == null) {
      showDialogAgreement(context);
    }
  }

  agreementDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ketentuan Layanan Aplikasi"),
          content: Container(
            height: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                      "Untuk dapat mengakses aplikasi anda harus menyetujui Kebijakan Privasi dan Ketentuan Aplikasi yang telah kami buat. Klik untuk melihat:",
                      style: TextStyle(fontSize: 13)),
                ),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyScreen()));
                    },
                    child: Text("Kebijakan Privasi",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold))),
                SizedBox(height: 6),
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TermConditionScreen()));
                    },
                    child: Text("Syarat dan Ketentuan",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                child: Text("Tidak Setuju",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                child: Text("Setuju",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                onTap: () {
                  setAgreement(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
