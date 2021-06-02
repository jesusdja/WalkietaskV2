import 'package:equatable/equatable.dart';

class Caso extends Equatable{
  int id;
  int serial;
  int imei;
  int boleta;
  String name;
  int is_priority;
  int active;
  int system;
  int company_id;
  int status_id;
  int customer_id;
  int user_id;
  String created_at;
  String updated_at;
  String deleted_at;
  String nameCompany;

  Caso(
      {this.id,
        this.serial,
        this.imei,
        this.boleta,
        this.name,
        this.is_priority,
        this.active,
        this.system,
        this.company_id,
        this.status_id,
        this.customer_id,
        this.user_id,
        this.created_at,
        this.updated_at,
        this.deleted_at,
        this.nameCompany
      });

  Caso.fromJson(Map<String, dynamic> json) {
    id = isnullOrvacio(json['id']) ? 0 : json['id'];
    serial = isnullOrvacio(json['serial']) ? 0 : json['serial'];
    imei = isnullOrvacio(json['imei']) ? 0 : json['imei'];
    boleta = isnullOrvacio(json['boleta']) ? 0 : json['boleta'];
    name = isnullOrvacio(json['name']) ? '' : json['name'];
    is_priority = isnullOrvacio(json['is_priority']) ? 0 : json['is_priority'];
    active = isnullOrvacio(json['active']) ? 0 : json['active'];
    system = isnullOrvacio(json['system']) ? 0 : json['system'];
    company_id = isnullOrvacio(json['company_id']) ? 0 : json['company_id'];
    status_id = isnullOrvacio(json['status_id']) ? 0 : json['status_id'];
    customer_id = isnullOrvacio(json['customer_id']) ? 0 : json['customer_id'];
    user_id = isnullOrvacio(json['user_id']) ? 0 : json['user_id'];
    created_at = isnullOrvacio(json['created_at']) ? '' : json['created_at'];
    updated_at = isnullOrvacio(json['updated_at']) ? '' : json['updated_at'];
    deleted_at = isnullOrvacio(json['deleted_at']) ? '' : json['deleted_at'];
  }

  bool isnullOrvacio(dynamic object){
    if(object == null || object == ''){
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['serial'] = this.serial;
    data['imei'] = this.imei;
    data['boleta'] = this.boleta;
    data['name'] = this.name;
    data['is_priority'] = this.is_priority;
    data['active'] = this.active;
    data['system'] = this.system;
    data['company_id'] = this.company_id;
    data['status_id'] = this.status_id;
    data['customer_id'] = this.customer_id;
    data['user_id'] = this.user_id;
    data['created_at'] = this.created_at;
    data['updated_at'] = this.updated_at;
    data['deleted_at'] = this.deleted_at;
    return data;
  }

  Caso.fromMap(Map snapshot) :
        id = snapshot['id'],
        serial = snapshot['serial'],
        imei = snapshot['imei'],
        boleta = snapshot['boleta'],
        name = snapshot['name'],
        is_priority = snapshot['is_priority'],
        active = snapshot['active'],
        system = snapshot['system'],
        company_id = snapshot['company_id'],
        status_id = snapshot['status_id'],
        customer_id = snapshot['customer_id'],
        user_id = snapshot['user_id'],
        created_at = snapshot['created_at'],
        updated_at = snapshot['updated_at'],
        deleted_at = snapshot['deleted_at'],
        nameCompany = snapshot['nameCompany']
  ;

  Caso.map(dynamic obj) {
    this.id = obj['id'];
    this.serial = obj['serial'];
    this.imei = obj['imei'];
    this.boleta = obj['boleta'];
    this.name = obj['name'];
    this.is_priority = obj['is_priority'];
    this.active = obj['active'];
    this.system = obj['system'];
    this.company_id = obj['company_id'];
    this.status_id = obj['status_id'];
    this.customer_id = obj['customer_id'];
    this.user_id = obj['user_id'];
    this.created_at = obj['created_at'];
    this.updated_at = obj['updated_at'];
    this.deleted_at = obj['deleted_at'];
  }

  Map<String, dynamic> toMap() => {
    'id' : id,
    'serial' : serial,
    'imei' : imei,
    'boleta' : boleta,
    'name' : name,
    'is_priority' : is_priority,
    'active' : active,
    'system' : system,
    'company_id' : company_id,
    'status_id' : status_id,
    'customer_id' : customer_id,
    'user_id' : user_id,
    'created_at' : created_at,
    'updated_at' : updated_at,
    'deleted_at' : deleted_at,
    'nameCompany' : nameCompany,
  };

  @override
  List<Object> get props => [
  id,
  serial,
  imei,
  boleta,
  name,
  is_priority,
  active,
  system,
  company_id,
  status_id,
  customer_id,
  user_id,
  created_at,
  updated_at,
  deleted_at,
  nameCompany
  ];

  @override
  bool get stringify => false;
}