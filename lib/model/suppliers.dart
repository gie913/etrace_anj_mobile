class Suppliers {
  String? idSupplier;
  String? name;
  dynamic ascendSupplierId;
  String? ascendSupplierCode;
  String? address;
  String? phoneNumber;

  Suppliers({
    this.idSupplier,
    this.name,
    this.ascendSupplierId,
    this.ascendSupplierCode,
    this.address,
    this.phoneNumber,
  });

  Suppliers.fromJson(Map<String, dynamic> json) {
    idSupplier = json['id'];
    name = json['name'];
    ascendSupplierId = json['ascend_supplier_id'];
    ascendSupplierCode = json['ascend_supplier_code'];
    address = json['address'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.idSupplier;
    data['name'] = this.name;
    data['ascend_supplier_id'] = this.ascendSupplierId;
    data['ascend_supplier_code'] = this.ascendSupplierCode;
    data['address'] = this.address;
    data['phone_number'] = this.phoneNumber;
    return data;
  }
}
