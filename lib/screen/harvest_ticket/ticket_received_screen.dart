import 'package:e_trace_app/base/api/api_endpoint.dart';
import 'package:e_trace_app/base/ui/style.dart';
import 'package:e_trace_app/model/harvesting_ticket.dart';
import 'package:e_trace_app/screen/harvest_ticket/ticket_receive_repository.dart';
import 'package:e_trace_app/utils/separator_thousand.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linecons_icons.dart';

class TicketReceivedScreen extends StatefulWidget {
  @override
  _TicketReceivedScreenState createState() => _TicketReceivedScreenState();
}

class _TicketReceivedScreenState extends State<TicketReceivedScreen> {
  TextEditingController typeFarmerController = TextEditingController();
  String? valFarmer;
  ScrollController? scrollController;
  List<HarvestingTicket> harvestTicketListChecked = [];
  List<HarvestingTicket> _ticketReceived = [];
  List<bool> _isChecked = [false];
  bool? isLoading;

  @override
  void initState() {
    getTicketReceived();
    super.initState();
  }

  getTicketReceived() async {
    isLoading = true;
    ReceiveTicketRepository(APIEndpoint.BASE_URL)
        .doReceiveTicket(onSuccess, onError);
  }

  void onSuccess(List<HarvestingTicket> listHarvestTicket) {
    setState(() {
      isLoading = false;
      _ticketReceived = listHarvestTicket;
      _isChecked = List<bool>.filled(_ticketReceived.length, false);
    });
  }

  void onError(response) {
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Daftar Tiket Diterima")),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context, harvestTicketListChecked);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.add_box_rounded),
            ),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: Container(
                child: _ticketReceived.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _ticketReceived.length,
                        itemBuilder: (context, index) => Container(
                              margin: EdgeInsets.only(bottom: 4),
                              child: Card(
                                child: Container(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: CheckboxListTile(
                                    value: _isChecked[index],
                                    onChanged: (val) {
                                      setState(
                                        () {
                                          _isChecked[index] = val!;
                                          if (_isChecked[index]) {
                                            harvestTicketListChecked
                                                .add(_ticketReceived[index]);
                                          } else {
                                            harvestTicketListChecked
                                                .remove(_ticketReceived[index]);
                                          }
                                        },
                                      );
                                    },
                                    secondary: Icon(Linecons.note,
                                        size: 35, color: Colors.orange),
                                    title: Text(
                                      _ticketReceived[index].idTicket!,
                                      style: text16Bold,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Janjang/Berat(KG): ${_ticketReceived[index].quantity}/${formatThousandSeparator(_ticketReceived[index].weight.round())}"),
                                          Text(
                                              "Kode Areal: ${_ticketReceived[index].ascendFarmerCode}"),
                                          Text(
                                            "Pengirim: ${_ticketReceived[index].sender}",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ))
                    : isLoading!
                        ? Center(
                            child: SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: new CircularProgressIndicator(
                                value: null,
                                strokeWidth: 3.0,
                              ),
                            ),
                          )
                        : Center(
                            child: SizedBox(
                              height: 30.0,
                              child: new Text(
                                "Belum Ada Tiket Masuk",
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
