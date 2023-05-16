import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/palette.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_user.dart';
import 'package:e_trace_app/model/user.dart';
import 'package:e_trace_app/screen/help/help_desk_screen.dart';
import 'package:e_trace_app/screen/help/help_screen.dart';
import 'package:e_trace_app/screen/point/point_screen.dart';
import 'package:e_trace_app/screen/profile/photo_repository.dart';
import 'package:e_trace_app/screen/profile/privacy_screen.dart';
import 'package:e_trace_app/screen/profile/profile_edit_screen.dart';
import 'package:e_trace_app/screen/profile/profile_repository.dart';
import 'package:e_trace_app/screen/profile/profile_setting_screen.dart';
import 'package:e_trace_app/screen/profile/term_condition_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  User profile = User();
  bool loading = false, loadingPhoto = false;
  PickedFile image, imageTemp;

  @override
  void initState() {
    doGetUserProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(PROFILE)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: loading
            ? Center(
                child: SizedBox(
                  child: LinearProgressIndicator(value: null),
                ),
              )
            : profile != null
                ? Center(
                    child: Column(children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  showOptionDialogUpload(context);
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: Container(
                                      padding: EdgeInsets.all(6),
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: loadingPhoto
                                                ? Container(
                                                    height:80,
                                                    width: 80,
                                                    child: Center(
                                                      child: SizedBox(
                                                        child:
                                                            CircularProgressIndicator(
                                                                value: null),
                                                      ),
                                                    ),
                                                  )
                                                : profile.photoProfile == null
                                                    ? Image.asset(
                                                        "assets/man.png",
                                                        height: 80,
                                                        width: 80,
                                                        fit: BoxFit.cover)
                                                    : Image.network(
                                                        profile.photoProfile,
                                                        height: 80,
                                                        width: 80,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Object
                                                                    exception,
                                                                StackTrace
                                                                    stackTrace) {
                                                          return Image.asset(
                                                              "assets/man.png",
                                                              height: 80,
                                                              width: 80,
                                                              fit:
                                                                  BoxFit.cover);
                                                        },
                                                      ),
                                          ),
                                          Card(
                                            child: Container(
                                              child: Icon(Icons.edit),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${profile.name.toUpperCase()}",
                                          style: text16Bold,
                                        ),
                                        Card(
                                          child: InkWell(
                                            child: Icon(Icons.edit),
                                            onTap: () async {
                                              bool changed =
                                                  await Navigator.push(context,
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                return ProfileEditScreen(
                                                    user: profile);
                                              }));
                                              if (changed == null) {
                                                doGetUserProfile();
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.email,
                                              size: 20,
                                              color: primaryColorLight),
                                          SizedBox(width: 8),
                                          Text("${profile.email ?? "-"}",
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.agriculture,
                                              size: 20,
                                              color: primaryColorLight),
                                          SizedBox(width: 8),
                                          Text("${profile.companyName}",
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.phone,
                                              size: 20,
                                              color: primaryColorLight),
                                          SizedBox(width: 8),
                                          Text("${profile.phoneNumber ?? "-"}"),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_pin,
                                              size: 20,
                                              color: primaryColorLight),
                                          SizedBox(width: 8),
                                          Container(
                                              width: 200,
                                              child:
                                                  Text("${profile.address}")),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0)),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PointScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Poin Anda",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        Icon(
                                          Linecons.wallet,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileSettingScreen()));
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(PROFILE_SETTING,
                                            style: text14Bold),
                                        Icon((Icons.settings))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HelpScreen()));
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Panduan", style: text14Bold),
                                        Icon((Icons.help))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HelpDeskScreen()));
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Layanan Pengguna",
                                            style: text14Bold),
                                        Icon((Icons.headset_mic_rounded))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PrivacyScreen()));
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Kebijakan Privasi",
                                            style: text14Bold),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TermConditionScreen()));
                                },
                                child: Container(
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Syarat dan Ketentuan",
                                            style: text14Bold),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              Container(
                                padding: EdgeInsets.only(left: 6, right: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Versi App", style: text14Bold),
                                      Text("$APP_VERSION $APP_BUILD"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]),
                  )
                : Container(
                    height: 100,
                    child: Center(
                      child: Text("Tidak Ada Koneksi", style: text16Bold),
                    ),
                  ),
      ),
    );
  }

  void doGetUserProfile() async {
    loading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    ProfileRepository(userBaseUrl).doGetProfile(
        userToken, onSuccessProfileCallback, onErrorProfileCallback);
  }

  onSuccessProfileCallback(User profile) {
    setState(() {
      loading = false;
      this.profile = profile;
      print("${profile.photoProfile}");
    });
  }

  onErrorProfileCallback(response) {
    DatabaseUser().getUser(onSuccess, onError);
  }

  showOptionDialogUpload(BuildContext context) {
    AlertDialog alert = AlertDialog(
        title: Center(child: Text("Pilih Foto Melalui")),
        content: Container(
          height: 150,
          child: Column(
            children: [
              Container(
                height: 60,
                margin: EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    getCamera();
                  },
                  child: Row(
                    children: [
                      Text(
                        "Kamera",
                        style: buttonStyle16,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60,
                margin: EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    getImage();
                  },
                  child: Row(
                    children: [
                      Text(
                        "Galeri Foto",
                        style: buttonStyle16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future getImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    var imagePick = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 25);
    imageTemp = imagePick;
    ChangeProfileRepository(userBaseUrl).doChangePhotoProfile(
        userToken, imagePick, onSuccessPhoto, onErrorPhoto);
  }

  Future getCamera() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userToken = prefs.getString('token');
    final String userBaseUrl = prefs.getString('baseUrl');
    var imagePick = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 25);
    imageTemp = imagePick;
    ChangeProfileRepository(userBaseUrl).doChangePhotoProfile(
        userToken, imagePick, onSuccessPhoto, onErrorPhoto);
  }

  onSuccessPhoto(response) {
    doGetUserProfile();
    imageCache.clear();
    setState(() {
      loadingPhoto = false;
    });
    Toast.show("Upload Foto Berhasil", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  onErrorPhoto(response) {
    setState(() {
      imageCache.clear();
      image = null;
      loadingPhoto = false;
    });
    Toast.show("Gagal Upload Foto, Maksimal 2MB", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  onSuccess(User response) {
    setState(() {
      loading = false;
      profile = response;
    });
    Toast.show("Tidak Ada Koneksi Internet", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  onError() {}
}
