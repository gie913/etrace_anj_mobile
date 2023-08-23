class Farmers {
  String idFarmer;
  String fullname;
  dynamic ascendFarmerId;
  String ascendFarmerCode;
  String address;
  String subdistrict;
  String gpsLong;
  String gpsLat;
  dynamic largeAreaHa;
  String yop;
  dynamic maxTonnageYear;
  int maxBunchYear;
  dynamic sumKgYear;

  Farmers(
      {this.idFarmer,
      this.fullname,
      this.ascendFarmerId,
      this.ascendFarmerCode,
      this.address,
      this.subdistrict,
      this.gpsLong,
      this.gpsLat,
      this.largeAreaHa,
      this.yop,
      this.maxTonnageYear,
      this.maxBunchYear,
      this.sumKgYear});

  Farmers.fromJson(Map<String, dynamic> json) {
    idFarmer = json['id'];
    fullname = json['fullname'];
    ascendFarmerId = json['ascend_farmer_id'];
    ascendFarmerCode = json['ascend_farmer_code'];
    address = json['address'];
    subdistrict = json['subdistrict'];
    gpsLong = json['gps_long'];
    gpsLat = json['gps_lat'];
    largeAreaHa = json['large_area_ha'];
    yop = json['yop'];
    maxTonnageYear = json['max_tonnage_year'];
    maxBunchYear = json['max_bunch_year'];
    sumKgYear = json['sum_kg_year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.idFarmer;
    data['fullname'] = this.fullname;
    data['ascend_farmer_id'] = this.ascendFarmerId;
    data['ascend_farmer_code'] = this.ascendFarmerCode;
    data['address'] = this.address;
    data['subdistrict'] = this.subdistrict;
    data['gps_long'] = this.gpsLong;
    data['gps_lat'] = this.gpsLat;
    data['large_area_ha'] = this.largeAreaHa;
    data['yop'] = this.yop;
    data['max_tonnage_year'] = this.maxTonnageYear;
    data['max_bunch_year'] = this.maxBunchYear;
    data['sum_kg_year'] = this.sumKgYear;
    return data;
  }
}
