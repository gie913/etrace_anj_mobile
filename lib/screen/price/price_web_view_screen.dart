import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/model/price_response.dart';
import 'package:e_trace_app/screen/price/price_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PriceWebViewScreen extends StatefulWidget {
  const PriceWebViewScreen({key}) : super(key: key);

  @override
  _PriceWebViewScreenState createState() => _PriceWebViewScreenState();
}

class _PriceWebViewScreenState extends State<PriceWebViewScreen> {
  String url = "";

  PDFDocument? document;
  String dataPriceLess = "", datePrice = "";
  bool _isLoading = true;

  final controller = WebViewController();

  @override
  void initState() {
    doGetPrice();
    super.initState();
  }

  void doGetPrice() async {
    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('token');
    final String? userBaseUrl = prefs.getString('baseUrl');
    PriceRepository(userBaseUrl!)
        .doGetPrice(userToken!, onSuccessPriceCallback, onErrorPriceCallback);
  }

  onSuccessPriceCallback(PriceResponse priceResponse) async {
    print(priceResponse.dataPrice!.file);
    if (priceResponse.dataPrice!.infoType == "file") {
      setState(() {
        dataPriceLess = "file";
        url = priceResponse.dataPrice!.file!;
        datePrice = priceResponse.dataPrice!.date!;
      });
      document = await PDFDocument.fromURL(priceResponse.dataPrice!.file!);
      print(priceResponse.dataPrice!.file!);
    } else if (priceResponse.dataPrice!.infoType == "website") {
      setState(() {
        dataPriceLess = "website";
        url = priceResponse.dataPrice!.infoSource!;
        datePrice = priceResponse.dataPrice!.date!;
      });
    } else {
      setState(() {
        url = priceResponse.dataPrice!.infoSource!;
        datePrice = priceResponse.dataPrice!.date!;
      });
    }
    setState(() => _isLoading = false);
    setState(() {
      _isLoading = false;
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(url));
    });
  }

  onErrorPriceCallback(response) async {
    Toast.show("Tidak Ada Koneksi Internet", duration: 3, gravity: 0);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(PALM_PRICE)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.white,
                child: dataPriceLess == "file"
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Tanggal Pembaruan: $datePrice",
                                  style: text14BoldBlack,
                                )),
                          ),
                          Flexible(
                            child: PDFViewer(
                              document: document!,
                              zoomSteps: 1,
                              showPicker: false,
                              showNavigation: true,
                            ),
                          ),
                        ],
                      )
                    : dataPriceLess == "website"
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Tanggal Pembaruan: $datePrice",
                                      style: text14BoldBlack,
                                    )),
                              ),
                              Flexible(
                                child: WebViewWidget(controller: controller),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Tanggal Pembaruan: $datePrice",
                                      style: text14BoldBlack,
                                    )),
                              ),
                              Flexible(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 20.0, right: 20.0),
                                  child: Html(data: """$url"""),
                                ),
                              ),
                            ],
                          ),
              ),
      ),
    );
  }
}
