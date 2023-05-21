import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:flutter/material.dart';

import 'change_password_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(CHANGE_PASSWORD)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 40),
                ),
                Container(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 8.0),
                      Form(
                        child: TextFormField(
                          autofocus: false,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ALERT_SERVER;
                            }
                            return null;
                          },
                          controller: oldPasswordController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Kata sandi lama",
                            filled: true,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(width: 1.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Form(
                        child: TextFormField(
                          autofocus: false,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ALERT_SERVER;
                            }
                            return null;
                          },
                          controller: newPasswordController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Kata sandi baru",
                            filled: true,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(width: 1.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Form(
                        child: TextFormField(
                          autofocus: false,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ALERT_SERVER;
                            }
                            return null;
                          },
                          controller: confirmationController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Konfirmasi kata sandi baru",
                            filled: true,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(width: 1.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: OutlinedButton(
                          onPressed: () {
                            doChangePasswordLogic(
                                oldPasswordController.text,
                                newPasswordController.text,
                                confirmationController.text);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            alignment: Alignment.center,
                            child: Text(
                              "Ganti Kata Sandi",
                              style: buttonStyle16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  doChangePasswordLogic(String email, String password, String server) async {
    ChangePasswordRepository(APIEndpoint.BASE_URL).doChangePassword(
        oldPasswordController.text,
        newPasswordController.text,
        confirmationController.text,
        _onSuccessLoginCallback,
        _onLoadingCallback,
        _onErrorLoginCallback);
  }

  _onLoadingCallback() {
    loadingDialog(context);
    print("Loading Change Password");
  }

  _onSuccessLoginCallback(response) {
    print("Success Change Password");
    _openWarningDialog(response.toString());
  }

  _onErrorLoginCallback(response) {
    print("Error Change Password");
    _openWarningDialog(response.toString());
  }

  _openWarningDialog(String title) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(title, style: text14Bold),
                ),
              ],
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text(
                  OK_BUTTON,
                ),
                onPressed: () {
                  oldPasswordController.clear();
                  newPasswordController.clear();
                  confirmationController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }).then((val) {
      Navigator.pop(context);
    });
  }
}
