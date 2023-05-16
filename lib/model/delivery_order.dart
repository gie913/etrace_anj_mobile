import 'package:e_trace_app/model/harvesting_ticket.dart';

class DeliveryOrder {
  String idDelivery;
  String dateDelivery;
  String gpsLong;
  String gpsLat;
  String transferred;
  String uploaded;
  int totalQuantity;
  double totalWeight;
  String supplierID;
  String ascentSupplierID;
  String ascentSupplierCode;
  String supplierName;
  String driverName;
  String mDriverID;
  String platNumber;
  String cardNumber;
  String note;
  String image;
  String companyID;
  String createdBy;
  List<HarvestingTicket> harvestingTicket;

  DeliveryOrder(
      {this.idDelivery,
      this.dateDelivery,
      this.gpsLong,
      this.gpsLat,
      this.transferred,
      this.uploaded,
      this.totalQuantity,
      this.totalWeight,
      this.mDriverID,
      this.supplierID,
      this.ascentSupplierID,
      this.ascentSupplierCode,
        this.supplierName,
      this.driverName,
      this.platNumber,
      this.cardNumber,
      this.note,
      this.image,
      this.companyID,
      this.createdBy,
      this.harvestingTicket});

  DeliveryOrder.fromJson(Map<String, dynamic> map) {
    this.idDelivery = map['mobile_tr_do_number'];
    this.dateDelivery = map['mobile_tr_do_time'];
    this.gpsLong = map["gps_long"];
    this.gpsLat = map["gps_lat"];
    this.transferred = map['transferred'];
    this.uploaded = map['uploaded'];
    this.mDriverID = map['m_driver_id'];
    this.totalQuantity = map['total_quantity'];
    this.totalWeight = map['total_weight'];
    this.supplierID = map["m_supplier_id"];
    this.ascentSupplierID = map["ascend_supplier_id"];
    this.ascentSupplierCode = map["ascend_supplier_code"];
    this.supplierName = map["supplier_name"];
    this.cardNumber = map["nfc_number"];
    this.driverName = map['m_driver_name'];
    this.platNumber = map['vehicle_reg_number'];
    this.note = map["note"];
    this.image = map["image"];
    this.companyID = map["m_company_id"];
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
    map['mobile_tr_do_number'] = this.idDelivery;
    map['mobile_tr_do_time'] = this.dateDelivery;
    map["gps_long"] = this.gpsLong;
    map["gps_lat"] = this.gpsLat;
    map['transferred'] = this.transferred;
    map['uploaded'] = this.uploaded;
    map['m_driver_id'] = this.mDriverID;
    map['total_quantity'] = this.totalQuantity;
    map['total_weight'] = this.totalWeight;
    map["m_supplier_id"] = this.supplierID;
    map["ascend_supplier_id"] = this.ascentSupplierID;
    map["ascend_supplier_code"] = this.ascentSupplierCode;
    map["supplier_name"] = this.supplierName;
    map["nfc_number"] = this.cardNumber;
    map['m_driver_name'] = this.driverName;
    map['vehicle_reg_number'] = this.platNumber;
    map["note"] = this.note;
    map["image"] = this.image;
    map["m_company_id"] = this.companyID;
    map['created_by'] = this.createdBy;
    if (this.harvestingTicket != null) {
      map['harvesting_ticket'] =
          this.harvestingTicket.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
