class HarvestingTicket {
  String? idTicket;
  String? dateTicket;
  String? idCollectionTicket;
  String? idCollectionTicketOld;
  String? idTicketOriginal;
  String? gpsLong;
  String? gpsLat;
  String? transferred;
  String? uploaded;
  String? receivedVia;
  String? mFarmerID;
  String? ascendFarmerID;
  String? ascendFarmerCode;
  String? farmerName;
  int? quantity;
  dynamic weight;
  String? note;
  String? nfcNumber;
  String? image;
  String? companyID;
  String? idDeliveryOrderTicket;
  String? createdBy;
  String? userTargetId;
  String? sender;

  HarvestingTicket({
    this.idTicket,
    this.dateTicket,
    this.idCollectionTicket,
    this.idCollectionTicketOld,
    this.idTicketOriginal,
    this.receivedVia,
    this.gpsLong,
    this.gpsLat,
    this.transferred,
    this.uploaded,
    this.mFarmerID,
    this.ascendFarmerID,
    this.ascendFarmerCode,
    this.farmerName,
    this.quantity,
    this.weight,
    this.note,
    this.nfcNumber,
    this.image,
    this.companyID,
    this.idDeliveryOrderTicket,
    this.createdBy,
    this.userTargetId,
    this.sender,
  });

  HarvestingTicket.fromJson(Map<String, dynamic> map) {
    this.idTicket = map['mobile_tr_ht_number'];
    this.dateTicket = map['mobile_tr_ht_time'];
    this.idCollectionTicket = map["mobile_tr_cp_number"];
    this.idCollectionTicketOld = map["mobile_tr_cp_number_old"];
    this.idDeliveryOrderTicket = map['mobile_tr_do_number'];
    this.idTicketOriginal = map["mobile_tr_ht_number_original"];
    this.receivedVia = map["received_via"];
    this.mFarmerID = map['m_farmer_id'];
    this.gpsLong = map['gps_long'];
    this.gpsLat = map['gps_lat'];
    this.transferred = map['transferred'];
    this.uploaded = map['uploaded'];
    this.ascendFarmerID = map['ascend_farmer_id'];
    this.ascendFarmerCode = map['ascend_farmer_code'];
    this.farmerName = map["farmer_name"];
    this.quantity = map['quantity'];
    this.weight = map['weight'];
    this.note = map['note'];
    this.nfcNumber = map['nfc_number'];
    this.image = map['image'];
    this.companyID = map['m_company_id'];
    this.createdBy = map['created_by'];
    this.userTargetId = map['user_target_id'];
    this.sender = map["user_source"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['mobile_tr_ht_number'] = idTicket;
    map['mobile_tr_ht_time'] = dateTicket;
    map['mobile_tr_cp_number'] = idCollectionTicket;
    map['mobile_tr_cp_number_old'] = idCollectionTicketOld;
    map['mobile_tr_do_number'] = idDeliveryOrderTicket;
    map["mobile_tr_ht_number_original"] = idTicketOriginal;
    map["received_via"] = receivedVia;
    map['gps_long'] = gpsLong;
    map['gps_lat'] = gpsLat;
    map['m_farmer_id'] = mFarmerID;
    map['transferred'] = transferred;
    map['uploaded'] = uploaded;
    map['ascend_farmer_id'] = ascendFarmerID;
    map['ascend_farmer_code'] = ascendFarmerCode;
    map['farmer_name'] = farmerName;
    map['quantity'] = quantity;
    map['weight'] = weight;
    map['note'] = note;
    map['nfc_number'] = nfcNumber;
    map['image'] = image;
    map['m_company_id'] = companyID;
    map['created_by'] = createdBy;
    map['user_target_id'] = userTargetId;
    return map;
  }
}
