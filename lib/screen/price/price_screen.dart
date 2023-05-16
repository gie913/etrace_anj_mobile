// import 'package:e_trace_app/base/strings/constants.dart';
// import 'package:e_trace_app/base/ui/style.dart';
// import 'package:e_trace_app/database_local/database_entity.dart';
// import 'package:e_trace_app/database_local/database_helper.dart';
// import 'package:e_trace_app/model/data_price.dart';
// import 'package:e_trace_app/model/price_response.dart';
// import 'package:e_trace_app/screen/price/price_repository.dart';
// import 'package:e_trace_app/database_local/database_price.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttericon/font_awesome_icons.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:toast/toast.dart';
//
// class PriceScreen extends StatefulWidget {
//   @override
//   _PriceScreenState createState() => _PriceScreenState();
// }
//
// class _PriceScreenState extends State<PriceScreen> {
//   List<DataPrice> listData = [];
//   DataPrice dataPrice;
//   String bigPrice, mediumPrice, smallPrice;
//   bool loading;
//   PriceResponse priceResponse;
//
//   @override
//   void initState() {
//     doGetPrice();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(child: Text(PALM_PRICE)),
//         automaticallyImplyLeading: false,
//       ),
//       body: Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             loading ?
//             Center(
//               child: SizedBox(
//                 child: new LinearProgressIndicator(
//                   value: null,
//                 ),
//               ),
//             ) :
//             listData != null
//                 ? Flexible(
//                 child: ListView.builder(
//                   itemCount: 1,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.only(top: 6, left: 6, right: 6),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Icon(FontAwesome.tags, color: Colors.green, size: 40),
//                                     Text(
//                                         "${listData.last.dayIna}, ${listData.last.date}", style: text18Bold),
//                                   ]),
//                               Divider(),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 10),
//                                 child: Row(
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(BIG_HARVEST, style: text14Bold),
//                                       Text(
//                                           "${listData[index].mainCurrency} $bigPrice")
//                                     ]),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 10),
//                                 child: Row(
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(MEDIUM_HARVEST, style: text14Bold),
//                                       Text(
//                                           "${listData[index].mainCurrency} $mediumPrice")
//                                     ]),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 10),
//                                 child: Row(
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(SMALL_HARVEST, style: text14Bold),
//                                       Text(
//                                           "${listData[index].mainCurrency} $smallPrice")
//                                     ]),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 20, bottom: 10),
//                                 child: Text("*Harga diatas hanya sebagai indikasi dan tidak mengikat", textAlign: TextAlign.center),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ))
//                 : Container(
//               height: 100,
//               child: Center(
//                 child: Text("Tidak Ada Koneksi", style: text16Bold,),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String formatDecimal(int number) {
//     int num = number;
//     if (num > -1000 && num < 1000)
//       return number.toString();
//
//     final String digits = num.abs().toString();
//     final StringBuffer result = StringBuffer(num < 0 ? '-' : '');
//     final int maxDigitIndex = digits.length - 1;
//     for (int i = 0; i <= maxDigitIndex; i += 1) {
//       result.write(digits[i]);
//       if (i < maxDigitIndex && (maxDigitIndex - i) % 3 == 0)
//         result.write(',');
//     }
//     return result.toString();
//   }
//
//   void doGetPrice() async {
//     loading = true;
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String userToken = prefs.getString('token');
//     final String userBaseUrl = prefs.getString('baseUrl');
//     PriceRepository(userBaseUrl).doGetPrice(
//         userToken, onSuccessPriceCallback, onErrorPriceCallback);
//   }
//
//   onSuccessPriceCallback(PriceResponse priceResponse) {
//     setState(() {
//       loading = false;
//       listData = List.from(priceResponse.data.reversed);
//       for(int i=0; i < listData.length; i++) {
//         bigPrice = formatDecimal(listData[i].priceLarge);
//         mediumPrice = formatDecimal(listData[i].priceMedium);
//         smallPrice = formatDecimal(listData[i].priceSmall);
//         insertPrice(listData[i]);
//       }
//     });
//   }
//
//   onErrorPriceCallback(response) {
//     DatabasePrice().getPrice(onSuccess, onError);
//     Toast.show("Tidak Ada Koneksi Internet", context,
//         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
//   }
//
//   Future<int> insertPrice(DataPrice object) async {
//     DataPrice dataPrice = DataPrice();
//     dataPrice.id = object.id;
//     dataPrice.dayIna = object.dayIna;
//     dataPrice.date = object.date;
//     dataPrice.priceSmall = object.priceSmall;
//     dataPrice.priceMedium = object.priceMedium;
//     dataPrice.priceLarge = object.priceLarge;
//     dataPrice.mainCurrency = object.mainCurrency;
//     dataPrice.mCompanyId = object.mCompanyId;
//     Database db = await DatabaseHelper().database;
//     int count = await db.update(TABLE_PRICE, dataPrice.toJson());
//     var result = await db.query(TABLE_PRICE);
//     print(result);
//     return count;
//   }
//
//   onSuccess(DataPrice response) {
//     setState(() {
//       listData.add(response);
//     });
//     print(listData.last);
//     if (listData.isNotEmpty) {
//         bigPrice = formatDecimal(int.parse(listData.last.priceLarge));
//         mediumPrice = formatDecimal(int.parse(listData.last.priceMedium));
//         smallPrice = formatDecimal(int.parse(listData.last.priceMedium));
//     }
//     loading = false;
//   }
//
//   onError() {}
// }
