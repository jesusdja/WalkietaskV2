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
  String userprojects;

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
        this.nameCompany,
        this.userprojects
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
        nameCompany = snapshot['nameCompany'],
        userprojects = snapshot['userprojects']
  ;

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
    'userprojects' : userprojects,
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
  nameCompany,
  userprojects
  ];

  @override
  bool get stringify => false;
}