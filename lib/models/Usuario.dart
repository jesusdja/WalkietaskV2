import 'package:equatable/equatable.dart';

class Usuario extends Equatable {


  int id;
  String username;
  String email;
  String name;
  String address;
  String avatar;
  int createCases;
  int active;
  int system;
  int levelId;
  int companyId;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int fijo;
  int contact;
  String fcmToken;

  Usuario(
      {this.id = 0,
        this.username = '',
        this.email = '',
        this.name = '',
        this.address = '',
        this.avatar = '',
        this.createCases = 0,
        this.active = 0,
        this.system = 0,
        this.levelId = 0,
        this.companyId = 0,
        this.createdAt = '',
        this.updatedAt = '',
        this.deletedAt = '',
        this.fijo = 0,
        this.contact = 0,
        this.fcmToken = '',
      });

  Usuario.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    username = json['username'] ?? '';
    email = json['email'] ?? '';
    name = json['name'] ?? '';
    address = json['address'] ?? '';
    avatar = json['avatar'] ?? '';
    createCases = json['create_cases'] ?? 0;
    active = json['active'] ?? 0;
    system = json['system'] ?? 0;
    levelId = json['level_id'] ?? 0;
    companyId = json['company_id'] ?? 0;
    createdAt = json['createdAt'] ?? '';
    updatedAt = json['updatedAt'] ?? '';
    deletedAt = json['deletedAt'] ?? '';
    fijo = json['fijo'] ?? 0;
    contact = json['contact'] ?? 0;
    fcmToken = json['fcm_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['name'] = this.name;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    data['create_cases'] = this.createCases;
    data['active'] = this.active;
    data['system'] = this.system;
    data['level_id'] = this.levelId;
    data['company_id'] = this.companyId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    data['fijo'] = this.fijo;
    data['contact'] = this.contact;
    return data;
  }
  Usuario.fromMap(Map snapshot) :
        id = snapshot['id'] ?? 0,
        username = snapshot['username'] ?? '',
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        address = snapshot['address'] ?? '',
        avatar = snapshot['avatar'] ?? '',
        createCases = snapshot['create_cases'] ?? 0,
        active = snapshot['active'] ?? 0,
        system = snapshot['system'] ?? 0,
        levelId = snapshot['level_id'] ?? 0,
        companyId = snapshot['company_id'] ?? 0,
        createdAt = snapshot['createdAt'] ?? '',
        updatedAt = snapshot['updatedAt'] ?? '',
        deletedAt = snapshot['deletedAt'] ?? '',
        fijo = snapshot['fijo'] ?? 0,
        fcmToken = snapshot['fcm_token'] ?? '',
        contact = snapshot['contact'] ?? 0
  ;

  Usuario.map(dynamic obj) {
    this.id = obj['id'];
    this.username = obj['username'];
    this.email = obj['email'];
    this.name = obj['name'];
    this.address = obj['address'];
    this.avatar = obj['avatar'];
    this.createCases = obj['create_cases'];
    this.active = obj['active'];
    this.system = obj['system'];
    this.levelId = obj['level_id'];
    this.companyId = obj['company_id'];
    this.createdAt = obj['createdAt'];
    this.updatedAt = obj['updatedAt'];
    this.deletedAt = obj['deletedAt'];
    this.fijo = obj['fijo'];
    this.contact = obj['contact'];
  }

  Map<String, dynamic> toMap() => {
    'id' :            id == null ? 0 : id,
    'username' :      username== null ? '' :username,
    'email' :         email== null ? '' :email,
    'name' :          name== null ? '' :name,
    'address' :       address== null ? '' :address,
    'avatar' :        avatar== null ? '' :avatar,
    'create_cases' :  createCases== null ? 0 :createCases,
    'active' :        active== null ? 0 :active,
    'system' :        system== null ? 0 :system,
    'level_id':       levelId== null ? 0 :levelId,
    'company_id':     companyId== null ? 0 :companyId,
    'createdAt':     createdAt== null ? '' :createdAt,
    'updatedAt':     updatedAt== null ? '' :updatedAt,
    'deletedAt':     deletedAt== null ? '' :deletedAt,
    'fijo':           fijo== null ? 0 :fijo,
    'contact':           contact== null ? 0 :contact,
  };

  @override
  List<Object> get props => [
    id,
    username ,
    email ,
    name ,
    address ,
    avatar ,
    createCases ,
    active ,
    system ,
    levelId ,
    companyId ,
    createdAt ,
    updatedAt ,
    deletedAt ,
    fijo,
    contact,
    fcmToken,
  ];

  @override
  bool get stringify => false;
}
