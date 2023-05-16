import 'package:e_trace_app/base/strings/constants.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/screen/data_screen/read_data_notifier.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:provider/provider.dart';

class QRCodeScreen extends StatefulWidget {
  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  @override
  initState() {
    context.read<ReadDataNotifier>().onInitScan();
    context.read<ReadDataNotifier>().scan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Baca Kode QR")),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ReadDataNotifier>().scan();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    child: Text(
                      "Pindai Kode QR",
                      style: buttonStyle18,
                    ),
                  ),
                ),
              ),
              Flexible(child: listViewHarvestTicket()),
            ],
          ),
        ),
      ),
    );
  }

  Widget listViewHarvestTicket() {
    return Consumer<ReadDataNotifier>(builder: (context, nfcNotifier, child) {
      return nfcNotifier.listHarvestTicket.length != 0
          ? ListView.builder(
          itemCount: nfcNotifier.listHarvestTicket.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20.0),
                  ),
                ),
                margin: EdgeInsets.only(left: 4, top: 4),
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  Column(children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 20),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child:
                                nfcNotifier.listHarvestTicket.isNotEmpty
                                    ? Icon(
                                  Linecons.note,
                                  color: Colors.orange,
                                  size: 40,
                                )
                                    : Icon(
                                  Linecons.truck,
                                  color: Colors.blue,
                                  size: 40,
                                )),
                            Container(
                                child:
                                nfcNotifier.listHarvestTicket.isNotEmpty
                                    ? Text(
                                  HARVEST_TICKET,
                                  style: text16Bold,
                                )
                                    : Text(
                                  DELIVERY_ORDER,
                                  style: text16Bold,
                                )),
                          ],
                        )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        nfcNotifier.listHarvestTicket.isNotEmpty
                            ? Text(
                          ID_HARVEST_TICKET_FORM,
                          style: text20Bold,
                        )
                            : Text(
                          ID_DELIVERY_ORDER_FORM,
                          style: text20Bold,
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 6.0, bottom: 10.0),
                          child: nfcNotifier.listHarvestTicket.isNotEmpty
                              ? Text(
                            "${nfcNotifier.listHarvestTicket[index].idTicket}",
                            style: text16Bold,
                          )
                              : Text(
                            "${nfcNotifier.listHarvestTicketDO[index].idTicket}",
                            style: text16Bold,
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Container(
                      child: Column(
                        children: [
                          nfcNotifier.listHarvestTicket.isNotEmpty
                              ? Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Kode Areal"),
                              SelectableText(
                                  "${nfcNotifier.listHarvestTicket[index].ascendFarmerCode}"),
                            ],
                          )
                              : Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Kode Areal"),
                              SelectableText(
                                  "${nfcNotifier.listHarvestTicketDO[index].ascendFarmerCode}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    nfcNotifier.listHarvestTicket.isNotEmpty
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Jumlah Janjang"),
                        SelectableText(
                            "${nfcNotifier.listHarvestTicket[index].quantity}"),
                      ],
                    )
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Jumlah Janjang"),
                        SelectableText(
                            "${nfcNotifier.listHarvestTicketDO[index].quantity}"),
                      ],
                    ),
                    Divider(),
                    nfcNotifier.listHarvestTicket.isNotEmpty
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(WEIGHT),
                        SelectableText(
                            "${nfcNotifier.listHarvestTicket[index].weight}"),
                      ],
                    )
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Berat Janjang"),
                        SelectableText(
                            "${nfcNotifier.listHarvestTicketDO[index].weight}"),
                      ],
                    ),
                    Divider(),
                    nfcNotifier.listHarvestTicket.isNotEmpty
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ID_COLLECTION_POINT_FORM),
                        SelectableText(
                            "${nfcNotifier.listHarvestTicket[index].idCollectionTicket ?? "-"}")
                      ],
                    )
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ID Supplier"),
                        SelectableText(
                            "${nfcNotifier.listHarvestTicketDO[index].idCollectionTicket ?? "-"}")
                      ],
                    ),
                    Divider(),
                    nfcNotifier.listHarvestTicket.isNotEmpty
                        ? Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ID_DELIVERY_ORDER_FORM),
                          SelectableText(
                              "${nfcNotifier.listHarvestTicket[index].idDeliveryOrderTicket ?? "-"}"),
                        ])
                        : Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DRIVER),
                          SelectableText(
                              "${nfcNotifier.listHarvestTicketDO[index].idDeliveryOrderTicket ?? "-"}"),
                        ]),
                    Divider(),
                    nfcNotifier.listHarvestTicketDO.isNotEmpty
                        ? Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Plat Nomor"),
                          SelectableText(
                              "${nfcNotifier.listHarvestTicketDO[index].dateTicket}"),
                        ])
                        : Container(),
                  ]),
                ]),
              ),
            );
          })
          : nfcNotifier.listHarvestTicketDO.length != 0
          ? Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
            ),
          ),
          margin: EdgeInsets.only(left: 4, top: 4),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Linecons.truck,
                          size: 35,
                          color: Colors.blue,
                        )),
                    Container(
                        child: Text(
                          DELIVERY_ORDER,
                          style: text16Bold,
                        )),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ID_DELIVERY_ORDER_FORM,
                    style: text18Bold,
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 6.0, bottom: 10.0),
                    child: Text(
                      "${nfcNotifier.listHarvestTicketDO[0].idTicket}",
                      style: text16Bold,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ID Supplier"),
                  SelectableText(
                      "${nfcNotifier.listHarvestTicketDO[0].idCollectionTicket}")
                ],
              ),
              Divider(),
              nfcNotifier.suppliersObject == null
                  ? Container()
                  : Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text("Nama Supplier"),
                  SelectableText(
                      "${nfcNotifier.suppliersObject.name}")
                ],
              ),
              Divider(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Supir"),
                    SelectableText(
                        "${nfcNotifier.listHarvestTicketDO[0].idDeliveryOrderTicket}"),
                  ]),
              Divider(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Plat Nomor"),
                    SelectableText(
                        "${nfcNotifier.listHarvestTicketDO[0].dateTicket}"),
                  ]),
              Divider(),
              Flexible(
                  child: ListView.builder(
                      itemCount:
                      nfcNotifier.listHarvestTicketDO.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20.0),
                              ),
                            ),
                            margin: EdgeInsets.only(left: 4, top: 4),
                            padding: EdgeInsets.all(20),
                            child: Column(children: [
                              Column(children: [
                                nfcNotifier.farmerObject == null
                                    ? Container()
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text("Nama Petani"),
                                    SelectableText(
                                        "${nfcNotifier.listFarmerObject[index].fullname}")
                                  ],
                                ),
                                Divider(),
                                Container(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Text("Kode Areal"),
                                          SelectableText(
                                              "${nfcNotifier.listHarvestTicketDO[index].ascendFarmerCode}"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Jumlah Janjang"),
                                    SelectableText(
                                        "${nfcNotifier.listHarvestTicketDO[index].quantity}"),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Berat Janjang"),
                                    SelectableText(
                                        "${formatThousandSeparator(nfcNotifier.listHarvestTicketDO[index].weight.round())}"),
                                  ],
                                ),
                              ]),
                            ]),
                          ),
                        );
                      }))
            ],
          ),
        ),
      )
          : Container();
    });
  }
}
