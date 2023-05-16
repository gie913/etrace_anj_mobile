import 'package:e_trace_app/model/harvesting_ticket.dart';

class UploadHarvestTicket {
  List<HarvestingTicket> harvestingTicket;

  UploadHarvestTicket({this.harvestingTicket});

  UploadHarvestTicket.fromJson(Map<String, dynamic> json) {
    if (json['harvesting_ticket'] != null) {
      harvestingTicket = [];
      json['harvesting_ticket'].forEach((v) {
        harvestingTicket.add(HarvestingTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.harvestingTicket != null) {
      data['harvesting_ticket'] =
          this.harvestingTicket.map((v) => v.toJson()).toList();
    }
    return data;
  }
}