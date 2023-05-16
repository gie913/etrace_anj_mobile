//*TABLE NAME*/
const String TABLE_HARVEST_TIKET = "HarvestTicket";
const String TABLE_COLLECTION_POINT = "CollectionPoint";
const String TABLE_DELIVERY_ORDER = "DeliveryOrder";
const String TABLE_AGENT = "TableAgent";
const String TABLE_FARMER = "TableFarmer";
const String TABLE_SUPPLIER = "TableSupplier";
const String TABLE_PRICE = "TablePrice";
const String TABLE_USER = "TableUser";
const String TABLE_COMPANY = "TableCompany";
const String TABLE_FARMER_TRANSACTION = "TableFarmerTransaction";

/*COLUMN TABLE HARVEST TICKET*/
const String ID_TICKET = "mobile_tr_ht_number";
const String ID_COLLECTION_TICKET = "mobile_tr_cp_number";
const String ID_COLLECTION_TICKET_OLD = "mobile_tr_cp_number_old";
const String ID_DELIVERY_ORDER_TICKET = "mobile_tr_do_number";
const String ID_SPLIT_TICKET = " mobile_tr_ht_number_original";
const String DATE_TICKET = "mobile_tr_ht_time";
const String LONG_LOCATION_TP = "gps_long";
const String LAT_LOCATION_TP = "gps_lat";
const String FARMER_ID = "m_farmer_id";
const String ASCEND_FARMER_ID = "ascend_farmer_id";
const String WEIGHT = "weight";
const String QUANTITY = "quantity";
const String NOTE = "note";
const String TP_TRANSFERRED = "transferred";
const String TP_RECEIVED_VIA = "received_via";
const String TP_FARMER_NAME = "farmer_name";
const String TP_UPLOADED = "uploaded";
const String NFC_NUMBER_TICKET = "nfc_number";
const String IMAGE = "image";
const String COMPANY_ID_TICKET = "m_company_id";
const String AGENT_ID_TICKET = "m_agent_id";
const String TICKET_CREATED_BY = "created_by";
const String TICKET_TRANSFER_TARGET = "user_target_id";

/*COLUMN TABLE COLLECTION POINT*/
const String ID_COLLECTION = "mobile_tr_cp_number";
const String DATE_COLLECTION = "mobile_tr_cp_time";
const String ID_DELIVERY_ORDER_CP = "mobile_tr_do_number";
const String ID_COLLECTION_POINT_ORIGINAL = "mobile_tr_cp_number_original";
const String CP_TRANSFERRED = "transferred";
const String CP_UPLOADED = "uploaded";
const String LONG_LOCATION_CP = "gps_long";
const String LAT_LOCATION_CP = "gps_lat";
const String AGENT_ID_CP = "m_agent_id";
const String ASCEND_AGENT_ID = "ascend_agent_id";
const String TOTAL_QUANTITY_CP = "total_quantity";
const String TOTAL_WEIGHT_CP = "total_weight";
const String ASCEND_AGENT_CODE = "ascend_agent_code";
const String NFC_NUMBER_CP = "nfc_number";
const String NOTE_CP = "note";
const String COMPANY_ID_CP = "m_company_id";
const String COLLECTION_CREATED_BY = "created_by";

/*COLUMN TABLE DELIVERY ORDER*/
const String ID_DO = "id_do";
const String ID_DELIVERY = "mobile_tr_do_number";
const String DATE_DELIVERY = "mobile_tr_do_time";
const String LONG_LOCATION_DO = "gps_long";
const String LAT_LOCATION_DO = "gps_lat";
const String DO_TRANSFERRED = "transferred";
const String DO_UPLOADED = "uploaded";
const String SUPPLIER_ID_DO = "m_supplier_id";
const String ASCEND_SUPPLIER_ID = "ascend_supplier_id";
const String ASCEND_SUPPLIER_CODE = "ascend_supplier_code";
const String DO_SUPPLIER_NAME = "supplier_name";
const String NFC_NUMBER_DO = "nfc_number";
const String DRIVER_NAME = "m_driver_name";
const String DRIVER_ID = "m_driver_id";
const String PLAT_NUMBER = "vehicle_reg_number";
const String TOTAL_QUANTITY_DO = "total_quantity";
const String TOTAL_WEIGHT_DO = "total_weight";
const String NOTE_DO = "note";
const String IMAGE_DO = "image";
const String COMPANY_ID_DO = "m_company_id";
const String DELIVERY_CREATED_BY = "created_by";

/*COLUMN TABLE FARMER*/
const String FARMER_NAME = "fullname";
const String FARMER_ID_OBJECT = "id";
const String FARMER_ASCEND_ID = "ascend_farmer_id";
const String FARMER_ASCEND_CODE = "ascend_farmer_code";
const String FARMER_ADDRESS = "address";
const String FARMER_LAT = "gps_lat";
const String FARMER_LONG = "gps_long";
const String FARMER_LARGE_AREA = "large_area_ha";
const String FARMER_YOP = "yop";
const String FARMER_LAND_STATUS = "land_status";
const String FARMER_PHONE = "phone_number";
const String FARMER_COMPANY = "m_company_id";
const String FARMER_SUPPLIER = "m_supplier_id";
const String FARMER_AGENT = "m_agent_id";
const String FARMER_MAX_TONNAGE_YEAR = "max_tonnage_year";
const String FARMER_MAX_BUNCH_YEAR = "max_bunch_year";
const String FARMER_MAX_KG_YEAR = "sum_kg_year";

/*COLUMN TABLE AGENT*/
const String AGENT_NAME = "name";
const String AGENT_ASCEND_ID = "ascend_agent_id";
const String AGENT_ASCEND_CODE = "ascend_agent_code";
const String AGENT_ADDRESS = "address";
const String AGENT_OTHER_ADDRESS = "other_address";
const String AGENT_LAT = "gps_lat";
const String AGENT_LONG = "gps_long";
const String AGENT_PHONE = "phone_number";
const String AGENT_COMPANY = "m_company_id";

/*COLUMN TABLE SUPPLIER*/
const String SUPPLIER_NAME = "name";
const String SUPPLIER_ID = "id";
const String SUPPLIER_ASCEND_ID = "ascend_supplier_id";
const String SUPPLIER_ASCEND_CODE = "ascend_supplier_code";
const String SUPPLIER_ADDRESS = "address";
const String SUPPLIER_OTHER_ADDRESS = "other_address";
const String SUPPLIER_LAT = "gps_lat";
const String SUPPLIER_LONG = "gps_long";
const String SUPPLIER_PHONE = "phone_number";
const String SUPPLIER_COMPANY = "m_company_id";

/*COLUMN TABLE PRICE*/
const String DAY_PRICE = "day_ina";
const String DATE_PRICE = "date";
const String ID_PRICE = "id";
const String PRICE_MEDIUM = "price_medium";
const String PRICE_SMALL = "price_small";
const String PRICE_LARGE = "price_large";
const String MAIN_CURRENCY = "main_currency";
const String COMPANY_ID = "m_company_id";

/*COLUMN TABLE COMPANY*/
const String CODE_COMPANY = "code";
const String ALIAS_COMPANY = "alias";
const String ID_COMPANY = "id";
const String NAME_COMPANY = "name";

/*COLUMN TABLE USER*/
const String ID_USER = "id";
const String NAME_USER = "name";
const String EMAIL_USER = "email";
const String ROLE_USER = "m_role_id";
const String USERNAME_USER = "username";
const String PASSWORD_USER = "password";
const String ADDRESS = "address";
const String GENDER = "gender";
const String TOKEN = "token";
const String COMPANY_NAME = "company_name";
const String COMPANY_ID_USER = "m_company_id";
const String SEQUENCE_NUMBER = "sequence_number";
const String PHONE_NUMBER = "phone_number";

/* COLUMN TABLE FARMER TRANSACTIONS */
const String TRYEAR = 'tr_year';
const String TRMONTH = 'tr_month';
const String ASCENDFARMERNAME = "ascend_farmer_name";
const String MAXTONNAGEYEAR = 'max_tonnage_year';
const String GROUPINGMONTHINYEAR = 'grouping_month_in_year';
