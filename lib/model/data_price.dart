class DataPrice {
  String id;
  String date;
  String dayIna;
  String dayEng;
  double priceMedium;
  double priceSmall;
  double priceLarge;
  String mainCurrency;
  String source;
  int isActive;
  String createdAt;
  String mCompanyId;
  String createdBy;
  String updatedAt;
  String updatedBy;
  int priceAll;
  String infoType;
  String file;
  String infoSource;

  DataPrice(
      {this.id,
        this.date,
        this.dayIna,
        this.dayEng,
        this.priceMedium,
        this.priceSmall,
        this.priceLarge,
        this.mainCurrency,
        this.source,
        this.isActive,
        this.createdAt,
        this.mCompanyId,
        this.createdBy,
        this.updatedAt,
        this.updatedBy,
        this.priceAll,
        this.infoType,
        this.file,
        this.infoSource});

  DataPrice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    dayIna = json['day_ina'];
    dayEng = json['day_eng'];
    priceMedium = json['price_medium'];
    priceSmall = json['price_small'];
    priceLarge = json['price_large'];
    mainCurrency = json['main_currency'];
    source = json['source'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    mCompanyId = json['m_company_id'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    priceAll = json['price_all'];
    infoType = json['info_type'];
    file = json['file'];
    infoSource = json['info_source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['day_ina'] = this.dayIna;
    data['day_eng'] = this.dayEng;
    data['price_medium'] = this.priceMedium;
    data['price_small'] = this.priceSmall;
    data['price_large'] = this.priceLarge;
    data['main_currency'] = this.mainCurrency;
    data['source'] = this.source;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['m_company_id'] = this.mCompanyId;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    data['price_all'] = this.priceAll;
    data['info_type'] = this.infoType;
    data['file'] = this.file;
    data['info_source'] = this.infoSource;
    return data;
  }
}