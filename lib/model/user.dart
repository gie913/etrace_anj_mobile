class User {
  String? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? mRoleId;
  String? username;
  String? address;
  String? gender;
  String? rememberToken;
  String? mCompanyId;
  String? phoneNumber;
  String? lastLogin;
  int? isActive;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;
  String? photoProfile;
  int? sequenceNumber;
  String? companyName;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.mRoleId,
    this.username,
    this.address,
    this.gender,
    this.rememberToken,
    this.mCompanyId,
    this.phoneNumber,
    this.lastLogin,
    this.isActive,
    this.createdAt,
    this.createdBy,
    this.photoProfile,
    this.updatedAt,
    this.updatedBy,
    this.sequenceNumber,
    this.companyName,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    mRoleId = json['m_role_id'];
    username = json['username'];
    address = json['address'];
    gender = json['gender'];
    rememberToken = json['remember_token'];
    mCompanyId = json['m_company_id'];
    phoneNumber = json['phone_number'];
    lastLogin = json['last_login'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    sequenceNumber = json['sequence_number'];
    photoProfile = json['profile_picture'];
    companyName = json['company_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['m_role_id'] = this.mRoleId;
    data['username'] = this.username;
    data['address'] = this.address;
    data['gender'] = this.gender;
    data['m_company_id'] = this.mCompanyId;
    data['phone_number'] = this.phoneNumber;
    data['sequence_number'] = this.sequenceNumber;
    data['company_name'] = this.companyName;
    return data;
  }
}
