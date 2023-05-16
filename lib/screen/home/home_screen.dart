import 'package:e_trace_app/base/path/image_path.dart';
import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_supplier.dart';
import 'package:e_trace_app/screen/collection_point/collection_point_list.dart';
import 'package:e_trace_app/screen/data_screen/qr_code_screen.dart';
import 'package:e_trace_app/screen/delivery_order/delivery_order_list.dart';
import 'package:e_trace_app/screen/harvest_ticket/harvest_ticket_list.dart';
import 'package:e_trace_app/screen/home/counter_notifier.dart';
import 'package:e_trace_app/utils/time_utils.dart';
import 'package:e_trace_app/widget/upload_dialog.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime now = DateTime.now();
  String username = "", harvestTicket, collectionPoint, deliveryOrder, company;

  @override
  void initState() {
    onInitHomeScreen();
    DatabaseSupplier().selectSupplier();
    super.initState();
  }

  onInitHomeScreen() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    context.read<CounterNotifier>().getCountUnUploadedHarvestTicket();
    context.read<CounterNotifier>().getCountUnUploadedCollectionPoint();
    context.read<CounterNotifier>().getCountUnUploadedDeliveryOrder();
    setState(() {
      username = pref.getString('username');
      company = pref.getString('userPT');
      print("this is username : " + username);
      harvestTicket = pref.getString('harvesting_ticket');
      collectionPoint = pref.getString('collection_point');
      deliveryOrder = pref.getString('delivery_order');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterNotifier>(
      builder: (context, counterUploaded, child) {
        return Scaffold(
          appBar: AppBar(
            title: Center(child: Text(APP_NAME)),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: company == null
                    ? Container(width: 35)
                    : Text(
                        "$company",
                        style: buttonStyle16,
                      ),
              )
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Image.asset(IMAGE_ICON, height: 40),
                                ),
                              ),
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      TimeUtils.getTimeGreetings() +
                                          "$username",
                                      style: text16Bold,
                                      overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 4),
                                  Text(TimeUtils.dateFormatter(now),
                                      style: text14,
                                      overflow: TextOverflow.ellipsis),
                                ]),
                          ]),
                        ]),
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text("Kunjungi kami:",
                      style: text12Bold, textAlign: TextAlign.start),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10, bottom: 4),
                        child: InkWell(
                          onTap: () {
                            launchUrl("https://www.instagram.com/anjgroup.id/");
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(FontAwesome5.instagram,
                                      color: Colors.purple),
                                  SizedBox(width: 6),
                                  Text("ANJ Group", style: text12Bold)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 2, bottom: 4),
                        child: InkWell(
                          onTap: () {
                            launchUrl(
                                "https://www.youtube.com/channel/UCFNiwUArXp8BzfCErO-3Eyg");
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(FontAwesome5.youtube, color: Colors.red),
                                  SizedBox(width: 6),
                                  Text("ANJ Group", style: text12Bold)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 2, bottom: 4),
                        child: InkWell(
                          onTap: () {
                            launchUrl(
                                "https://www.linkedin.com/company/pt-austindo-nusantara-jaya-tbk/mycompany/");
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(FontAwesome5.linkedin,
                                      color: Colors.blue),
                                  SizedBox(width: 6),
                                  Text("ANJ Group", style: text12Bold)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 2, bottom: 4, right: 10),
                        child: InkWell(
                          onTap: () {
                            launchUrl("https://m.facebook.com/anjgroup.id/");
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(FontAwesome5.facebook,
                                      color: Colors.blueAccent),
                                  SizedBox(width: 6),
                                  Text("ANJ Group", style: text12Bold)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ListView(
                      children: [
                        harvestTicket != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, left: 8, right: 8),
                                child: Container(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HarvestTicketScreen()));
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 2,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Linecons.note,
                                                size: 50, color: Colors.orange),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(HARVEST_TICKET,
                                                  style: text18Bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        collectionPoint != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Container(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CollectionPointScreen()));
                                    },
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Linecons.inbox,
                                                size: 50, color: Colors.green),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(COLLECTION_POINT,
                                                  style: text18Bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        deliveryOrder != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Container(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DeliveryOrderScreen()));
                                    },
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Linecons.truck,
                                              size: 50,
                                              color: Colors.blue,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(DELIVERY_ORDER,
                                                  style: text18Bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        collectionPoint != null ||
                                deliveryOrder != null ||
                                harvestTicket != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Container(
                                  child: InkWell(
                                    onTap: () {
                                      showUploadDialog(context);
                                    },
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Octicons.cloud_upload,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      BUTTON_UPLOAD_DATABASE,
                                                      style: text18Bold),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            "TP: ${counterUploaded.countHarvestTicket != null ? counterUploaded.countHarvestTicket : 0}")),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Icon(
                                                            Icons.cloud_upload,
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          "TK: ${counterUploaded.countCollectionPoint != null ? counterUploaded.countCollectionPoint : 0}",
                                                        )),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Icon(
                                                            Icons.cloud_upload,
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                                deliveryOrder != null
                                                    ? Row(
                                                        children: [
                                                          Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                  "SP: ${counterUploaded.countDeliveryOrder != null ? counterUploaded.countDeliveryOrder : 0}")),
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10),
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Icon(
                                                                  Icons
                                                                      .cloud_upload,
                                                                  color: Colors
                                                                      .red)),
                                                        ],
                                                      )
                                                    : Container(width: 0),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        ExpandablePanel(
                          // ignore: deprecated_member_use
                          hasIcon: false,
                          header: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.chrome_reader_mode_outlined,
                                        size: 50,
                                        color: Colors.purple,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Pengecekan Data",
                                            style: text18Bold),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          expanded: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Container(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QRCodeScreen()));
                                    },
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.qr_code_rounded,
                                              size: 50,
                                              color: Colors.deepPurple,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(TITLE_READ_QRCODE,
                                                  style: text18Bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 8, right: 8),
                              //   child: Container(
                              //     child: InkWell(
                              //       onTap: () {
                              //         Navigator.push(
                              //             context,
                              //             MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     ReadNFCScreen()));
                              //       },
                              //       child: Card(
                              //         elevation: 2,
                              //         child: Container(
                              //           padding: EdgeInsets.all(10),
                              //           child: Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.start,
                              //             children: [
                              //               Icon(
                              //                 Icons.nfc_rounded,
                              //                 size: 50,
                              //                 color: Colors.cyan,
                              //               ),
                              //               Padding(
                              //                 padding: const EdgeInsets.all(8.0),
                              //                 child: Text(TITLE_READ_NFC,
                              //                     style: text18Bold),
                              //               )
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      Toast.show("Gagal membuka url", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}
