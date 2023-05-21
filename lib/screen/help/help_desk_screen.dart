import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/model/send_help_desk.dart';
import 'package:e_trace_app/screen/help/help_desk_repository.dart';
import 'package:e_trace_app/widget/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class HelpDeskScreen extends StatefulWidget {
  @override
  _HelpDeskScreenState createState() => _HelpDeskScreenState();
}

class _HelpDeskScreenState extends State<HelpDeskScreen> {
  var subjectController = TextEditingController();
  var messageController = TextEditingController();
  var _validateSubject = false;
  var _validateMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Layanan Pengguna"),
      ),
      body: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text("Judul:", style: text14Bold),
                  ),
                  Flexible(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(),
                        child: TextField(
                          onChanged: (value) {
                            value.isNotEmpty
                                ? _validateSubject = false
                                : _validateSubject = true;
                          },
                          controller: subjectController,
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            errorText: _validateSubject ? 'Belum Terisi' : null,
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text("Pesan/Saran:", style: text14Bold),
                    ),
                    Flexible(
                      child: Container(
                        child: TextField(
                          onChanged: (value) {
                            value.isNotEmpty
                                ? _validateMessage = false
                                : _validateMessage = true;
                          },
                          controller: messageController,
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          maxLines: 6,
                          decoration: InputDecoration(
                            errorText: _validateMessage ? 'Belum Terisi' : null,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton(
                  onPressed: () {
                    if (subjectController.text.isEmpty) {
                      setState(() {
                        _validateSubject = true;
                      });
                    } else if (messageController.text.isEmpty) {
                      setState(() {
                        _validateMessage = true;
                      });
                    } else {
                      doSendHelpDesk(
                          subjectController.text, messageController.text);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    child: Text("Kirim", style: buttonStyle18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void doSendHelpDesk(String subject, String message) async {
    loadingDialog(this.context);
    HelpDeskRepository(APIEndpoint.BASE_URL)
        .doSendHelpDesk(subject, message, onSuccess, onError);
  }

  onSuccess(SendHelpDesk sendHelpDesk) {
    subjectController.clear();
    messageController.clear();
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Berhasil Terkirim'),
        content: Text(
            'Terima kasih atas pesan/saran yang diberikan, kami akan menghubungi melalui email'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                YES,
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onError() {
    Toast.show("Gagal Mengirimkan", duration: 1, gravity: 0);
  }
}
