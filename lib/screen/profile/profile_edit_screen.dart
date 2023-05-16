import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'edit_profile_repository.dart';

class ProfileEditScreen extends StatefulWidget {
  final User user;

  ProfileEditScreen({this.user});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool loadingPhoto = false, _validate = false, changed = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    emailController.text = widget.user.email;
    numberController.text = widget.user.phoneNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => onWillPopForm(context),
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Edit Profil")),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.user.name.toUpperCase()}",
                      style: text16Bold,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Email"),
                          ),
                          Flexible(
                            child: Container(
                              width: 220,
                              child: Padding(
                                padding: const EdgeInsets.only(),
                                child: TextField(
                                  onChanged: (value) {
                                    value != null
                                        ? _validate = false
                                        : _validate = true;
                                  },
                                  controller: emailController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    errorText:
                                    _validate ? 'Belum Terisi' : null,
                                    counterText: "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)),
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Telepon"),
                          ),
                          Flexible(
                            child: Container(
                              width: 220,
                              child: Padding(
                                padding: const EdgeInsets.only(),
                                child: TextField(
                                  maxLength: 12,
                                  onChanged: (value) {
                                    value != null
                                        ? _validate = false
                                        : _validate = true;
                                  },
                                  controller: numberController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    errorText:
                                    _validate ? 'Belum Terisi' : null,
                                    counterText: "",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)),
                                      borderSide: BorderSide(width: 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        doChangeProfile();
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "Simpan",
                          textAlign: TextAlign.center,
                          style: buttonStyle18,
                        ),
                      ),
                    ),
                  ],
                ),
              )
        ),
      ),
    );
  }

  void doChangeProfile() async {
    loadingDialog(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    EditProfileRepository(userBaseUrl).doEditProfile(
        userToken,  numberController.text, emailController.text, onSuccessProfileCallback, onErrorProfileCallback);
  }

  onSuccessProfileCallback(String response) {
    Toast.show(response, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.CENTER);
    Navigator.pop(context);
    changed = true;
  }

  onErrorProfileCallback(String response) {
    Toast.show(response, context, duration: Toast.LENGTH_SHORT, gravity:  Toast.CENTER);
    Navigator.pop(context);
  }

  Future<bool> onWillPopForm(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keluar Edit Profil'),
        content: Text('Apakah yakin Anda selesai merubah? '),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
              child: Text(NO, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: Text(YES, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
