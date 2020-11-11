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
        this.fijo = 0
      });

  Usuario.fromJson(Map<String, dynamic> json) {
    id = json['id']== null ? 0 : json['id'];
    username = json['username']== null ? '' :json['username'];
    email = json['email']== null ? '' :json['email'];
    name = json['name']== null ? '' :json['name'];
    address = json['address']== null ? '' :json['address'];
    avatar = json['avatar']== null ? '' : json['avatar'];
    createCases = json['create_cases']== null ? 0 : json['create_cases'];
    active = json['active']== null ? 0 : json['active'];
    system = json['system']== null ? 0 : json['system'];
    levelId = json['level_id']== null ? 0 : json['level_id'];
    companyId = json['company_id']== null ? 0 : json['company_id'];
    createdAt = json['createdAt']== null ? '' :json['createdAt'];
    updatedAt = json['updatedAt']== null ? '' :json['updatedAt'];
    deletedAt = json['deletedAt']== null ? '' :json['deletedAt'];
    fijo = json['fijo']== null ? 0 : json['fijo'];
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
    return data;
  }
  Usuario.fromMap(Map snapshot) :
        id = snapshot['id']== null ? 0 :snapshot['id'],
        username = snapshot['username']== null ? '' :snapshot['username'],
        email = snapshot['email']== null ? '' :snapshot['email'],
        name = snapshot['name']== null ? '' :snapshot['name'],
        address = snapshot['address']== null ? '' :snapshot['address'],
        avatar = snapshot['avatar']== null ? '' :snapshot['avatar'],
        createCases = snapshot['create_cases']== null ? 0 :snapshot['create_cases'],
        active = snapshot['active']== null ? 0 :snapshot['active'],
        system = snapshot['system']== null ? 0 :snapshot['system'],
        levelId = snapshot['level_id']== null ? 0 :snapshot['level_id'],
        companyId = snapshot['company_id']== null ? 0 :snapshot['company_id'],
        createdAt = snapshot['createdAt']== null ? '' :snapshot['createdAt'],
        updatedAt = snapshot['updatedAt']== null ? '' :snapshot['updatedAt'],
        deletedAt = snapshot['deletedAt']== null ? '' :snapshot['deletedAt'],
        fijo = snapshot['fijo']== null ? 0 :snapshot['fijo']
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
    fijo
  ];

  @override
  bool get stringify => false;
}
