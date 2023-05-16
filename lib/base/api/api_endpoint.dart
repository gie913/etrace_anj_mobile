class APIEndpoint {
  static const BASE_URL =
      "https://etrace-dev.anj-group.co.id/backend/public/index.php/";

  static const LOGIN_ENDPOINT = "api/v1/signin";
  static const LOGOUT_ENDPOINT = "api/v1/signout";
  static const CHANGE_PHOTO_ENDPOINT = "api/v1/profile-pic/update";
  static const PROFILE_ENDPOINT = "api/v1/my-profile";
  static const PRICE_ENDPOINT = "api/v1/cpo/palm-price";
  static const USER_TARGET_ENDPOINT = "api/v1/users";
  static const POINT_ENDPOINT = "api/v1/my-point";
  static const UPLOAD_HARVEST_TICKET = "api/v1/harvesting-ticket/create";
  static const UPLOAD_COLLECTION_POINT = "api/v1/collection-point/create";
  static const UPLOAD_DELIVERY_ORDER = "api/v1/delivery-order/create";
  static const SEND_HARVEST_TICKET = "api/v1/harvesting-ticket/send";
  static const RECEIVE_HARVEST_TICKET = "api/v1/harvesting-ticket/list";
  static const COMPANIES_ENDPOINT = "api/v1/companies";
  static const SAVE_RECEIVE_ENDPOINT = "api/v1/harvesting-ticket/receive";
  static const CHECK_VERSION = "api/v1/app-version?user_app_version=";
  static const SEND_HELP_DESK = "api/v1/feedback-message/send";
  static const FORGOT_PASSWORD = "api/v1/forgot-password";

  static const SYNC_DATA_SUPPLIER = "api/v1/suppliers";
  static const SYNC_DATA_AGENT = "api/v1/agents";
  static const SYNC_DATA_FARMER = "api/v1/farmers";
  static const SYNC_DATA_TONNAGE_FARMER = "api/v1/farmers-max-tonnage";
  static const CHANGE_PASSWORD_ENDPOINT = "api/v1/change-password";

  static const CHANGE_PROFILE = "api/v1/profile-contact/update";
  static const SET_VERSION = "api/v1/app-version";
}
