
import 'harvesting_ticket.dart';

class CollectionPoint {
  String idCollection;
  String dateCollection;
  String deliveryCollection;
  String idCollectionOriginal;
  String gpsLong;
  String gpsLat;
  String agentID;
  String transferred;
  String uploaded;
  int totalQuantity;
  double totalWeight;
  String ascendAgentID;
  String ascendAgentCode;
  String cardNumber;
  String note;
  String companyID;
  String createdBy;
  List<HarvestingTicket> harvestingTicket;

  CollectionPoint(
      {this.idCollection,
      this.dateCollection,
        this.deliveryCollection,
        this.idCollectionOriginal,
      this.gpsLong,
      this.gpsLat,
      this.transferred,
      this.uploaded,
        this.totalQuantity,
        this.totalWeight,
        this.note,
      this.agentID,
      this.ascendAgentID,
      this.ascendAgentCode,
      this.cardNumber,
      this.companyID,
      this.createdBy,
      this.harvestingTicket});

  CollectionPoint.fromJson(Map<String, dynamic> map) {
    this.idCollection = map['mobile_tr_cp_number'];
    this.dateCollection = map['mobile_tr_cp_time'];
    this.deliveryCollection = map['mobile_tr_do_number'];
    this.idCollectionOriginal = map['mobile_tr_cp_number_original'];
    this.gpsLong = map['gps_long'];
    this.gpsLat = map['gps_lat'];
    this.transferred = map['transferred'];
    this.totalQuantity = map['total_quantity'];
    this.totalWeight = map['total_weight'];
    this.uploaded = map['uploaded'];
    this.agentID = map['m_agent_id'];
    this.note = map['note'];
    this.ascendAgentID = map['ascend_agent_id'];
    this.ascendAgentCode = map['ascend_agent_code'];
    this.cardNumber = map['nfc_number'];
    this.companyID = map['m_company_id'];
    this.createdBy = map['created_by'];
    if (map['harvesting_ticket'] != null) {
      harvestingTicket = [];
      map['harvesting_ticket'].forEach((v) {
        harvestingTicket.add(new HarvestingTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['mobile_tr_cp_number'] = this.idCollection;
    map['mobile_tr_cp_time'] = this.dateCollection;
    map['mobile_tr_do_number'] = this.deliveryCollection;
    map['mobile_tr_cp_number_original'] = this.idCollectionOriginal;
    map['gps_long'] = this.gpsLong;
    map['gps_lat'] = this.gpsLat;
    map['transferred'] = this.transferred;
    map['uploaded'] = this.uploaded;
    map['note'] = this.note;
    map['total_quantity'] = this.totalQuantity;
    map['total_weight'] = this.totalWeight;
    map['m_agent_id'] = this.agentID;
    map['ascend_agent_id'] = this.ascendAgentID;
    map['ascend_agent_code'] = this.ascendAgentCode;
    map['nfc_number'] = this.cardNumber;
    map['m_company_id'] = this.companyID;
    map['created_by'] = this.createdBy;
    if (this.harvestingTicket != null) {
      map['harvesting_ticket'] =
          this.harvestingTicket.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
