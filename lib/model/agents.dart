class Agents {
  String? id;
  String? name;
  dynamic ascendAgentId;
  String? ascendAgentCode;
  String? address;
  String? phoneNumber;
  String? updatedAt;

  Agents({
    this.name,
    this.ascendAgentId,
    this.ascendAgentCode,
    this.address,
    this.phoneNumber,
  });

  Agents.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    ascendAgentId = json['ascend_agent_id'];
    ascendAgentCode = json['ascend_agent_code'];
    address = json['address'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['ascend_agent_id'] = this.ascendAgentId;
    data['ascend_agent_code'] = this.ascendAgentCode;
    data['address'] = this.address;
    data['phone_number'] = this.phoneNumber;
    return data;
  }
}
