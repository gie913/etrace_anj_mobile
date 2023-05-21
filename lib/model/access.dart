class Access {
  String? id;
  String? mModuleId;
  String? mRoleId;
  int? canCreate;
  int? canUpdate;
  int? canDelete;
  int? isActive;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;

  Access({
    this.id,
    this.mModuleId,
    this.mRoleId,
    this.canCreate,
    this.canUpdate,
    this.canDelete,
    this.isActive,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  Access.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mModuleId = json['m_module_id'];
    mRoleId = json['m_role_id'];
    canCreate = json['can_create'];
    canUpdate = json['can_update'];
    canDelete = json['can_delete'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['m_module_id'] = this.mModuleId;
    data['m_role_id'] = this.mRoleId;
    data['can_create'] = this.canCreate;
    data['can_update'] = this.canUpdate;
    data['can_delete'] = this.canDelete;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
