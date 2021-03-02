import 'package:equatable/equatable.dart';

class Usuario extends Equatable {


  int id;
  String username;
  String email;
  String name;
  String surname;
  String address;
  String avatar;
  String avatar_100;
  String avatar_500;
  String avatar_800;
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
        this.surname = '',
        this.address = '',
        this.avatar = '',
        this.avatar_100 = '',
        this.avatar_500 = '',
        this.avatar_800 = '',
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
    surname = json['surname'] ?? '';
    address = json['address'] ?? '';
    avatar = json['avatar'] ?? '';
    avatar_100 = json['avatar_100'] ?? '';
    avatar_500 = json['avatar_500'] ?? '';
    avatar_800 = json['avatar_800'] ?? '';
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
    data['surname'] = this.surname;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    data['avatar_100'] = this.avatar_100;
    data['avatar_500'] = this.avatar_500;
    data['avatar_800'] = this.avatar_800;
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
    data['fcmToken'] = this.fcmToken;
    return data;
  }
  Usuario.fromMap(Map snapshot) :
        id = snapshot['id'] ?? 0,
        username = snapshot['username'] ?? '',
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        surname = snapshot['surname'] ?? '',
        address = snapshot['address'] ?? '',
        avatar = snapshot['avatar'] ?? '',
        avatar_100 = snapshot['avatar_100'] ?? '',
        avatar_500 = snapshot['avatar_500'] ?? '',
        avatar_800 = snapshot['avatar_800'] ?? '',
        createCases = snapshot['create_cases'] ?? 0,
        active = snapshot['active'] ?? 0,
        system = snapshot['system'] ?? 0,
        levelId = snapshot['level_id'] ?? 0,
        companyId = snapshot['company_id'] ?? 0,
        createdAt = snapshot['createdAt'] ?? '',
        updatedAt = snapshot['updatedAt'] ?? '',
        deletedAt = snapshot['deletedAt'] ?? '',
        fijo = snapshot['fijo'] ?? 0,
        fcmToken = snapshot['fcmToken'] ?? '',
        contact = snapshot['contact'] ?? 0
  ;

  Usuario.map(dynamic obj) {
    this.id = obj['id'];
    this.username = obj['username'];
    this.email = obj['email'];
    this.name = obj['name'];
    this.surname = obj['surname'];
    this.address = obj['address'];
    this.avatar = obj['avatar'];
    this.avatar_100 = obj['avatar_100'];
    this.avatar_500 = obj['avatar_500'];
    this.avatar_800 = obj['avatar_800'];
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
    this.fcmToken = obj['fcmToken'];
  }

  Map<String, dynamic> toMap() => {
    'id' :            id == null ? 0 : id,
    'username' :      username== null ? '' :username,
    'email' :         email== null ? '' :email,
    'name' :          name== null ? '' :name,
    'surname' :       surname == null ? '' : surname,
    'address' :       address== null ? '' :address,
    'avatar' :        avatar== null ? '' :avatar,
    'avatar_100' :        avatar_100== null ? '' :avatar_100,
    'avatar_500' :        avatar_500== null ? '' :avatar_500,
    'avatar_800' :        avatar_800== null ? '' :avatar_800,
    'create_cases' :  createCases== null ? 0 :createCases,
    'active' :        active== null ? 0 :active,
    'system' :        system== null ? 0 :system,
    'level_id':       levelId== null ? 0 :levelId,
    'company_id':     companyId== null ? 0 :companyId,
    'createdAt':     createdAt== null ? '' :createdAt,
    'updatedAt':     updatedAt== null ? '' :updatedAt,
    'deletedAt':     deletedAt== null ? '' :deletedAt,
    'contact':       contact== null ? 0 : contact,
    'fcmToken':      fcmToken == null ? '' : fcmToken,
    'fijo':          fijo== null ? 0 : fijo,
  };

  @override
  List<Object> get props => [
    id,
    username ,
    email ,
    name ,
    surname,
    address ,
    avatar ,
    avatar_100 ,
    avatar_500 ,
    avatar_800 ,
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
