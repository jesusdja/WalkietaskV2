import 'package:equatable/equatable.dart';

// must_be_immutable
class Tarea  extends Equatable{
  int id;
  String name;
  String description;
  // ignore: non_constant_identifier_names
  int is_priority;
  int finalized;
  String deadline;
  // ignore: non_constant_identifier_names
  int rec_type;
  // ignore: non_constant_identifier_names
  int parent_rec;
  // ignore: non_constant_identifier_names
  String start_date;
  // ignore: non_constant_identifier_names
  String end_date;
  // ignore: non_constant_identifier_names
  int is_full_day;
  int active;
  int system;
  // ignore: non_constant_identifier_names
  String url_audio;
  // ignore: non_constant_identifier_names
  String url_attachment;
  int order;
  // ignore: non_constant_identifier_names
  int reminder_type_id;
  // ignore: non_constant_identifier_names
  int user_id;
  // ignore: non_constant_identifier_names
  int user_responsability_id;
  // ignore: non_constant_identifier_names
  int company_id;
  // ignore: non_constant_identifier_names
  int project_id;
  // ignore: non_constant_identifier_names
  int status_id;
  // ignore: non_constant_identifier_names
  String created_at;
  // ignore: non_constant_identifier_names
  String updated_at;
  // ignore: non_constant_identifier_names
  String deleted_at;

  Tarea(
      {this.id,
        this.order,
        this.name,
        this.description,
        this.is_priority,
        this.finalized,
        this.deadline,
        this.rec_type,
        this.parent_rec,
        this.start_date,
        this.end_date,
        this.is_full_day,
        this.active,
        this.system,
        this.url_audio,
        this.url_attachment,
        this.reminder_type_id,
        this.user_id,
        this.user_responsability_id,
        this.company_id,
        this.project_id,
        this.status_id,
        this.created_at,
        this.updated_at,
        this.deleted_at});

  Tarea.fromJson(Map<String, dynamic> json) {
    id = isnullOrvacio(json['id']) ? 0 : json['id'];
    order = isnullOrvacio(json['order'])? 0 : json['order'];
    name = isnullOrvacio(json['name']) ? '' : json['name'];
    description = isnullOrvacio(json['description']) ? '' : json['description'];
    is_priority = isnullOrvacio(json['is_priority']) ? 0 : json['is_priority'];
    finalized = isnullOrvacio(json['finalized']) ? 0 : json['finalized'];
    deadline = isnullOrvacio(json['deadline']) ? '' : json['deadline'];
    rec_type = isnullOrvacio(json['rec_type']) ? 0 : json['rec_type'];
    parent_rec = isnullOrvacio(json['parent_rec']) ? 0 : json['parent_rec'];
    start_date = isnullOrvacio(json['start_date']) ? '' : json['start_date'];
    end_date = isnullOrvacio(json['end_date']) ? '' : json['end_date'];
    is_full_day = isnullOrvacio(json['is_full_day']) ? 0 : json['is_full_day'];
    active = isnullOrvacio(json['active']) ? 0 : json['active'];
    system = isnullOrvacio(json['system']) ? 0 : json['system'];
    url_audio = isnullOrvacio(json['url_audio']) ? '' : json['url_audio'];
    url_attachment = isnullOrvacio(json['url_attachment']) ? '' : json['url_attachment'];
    reminder_type_id = isnullOrvacio(json['reminder_type_id']) ? 0 : json['reminder_type_id'];
    user_id = isnullOrvacio(json['user_id']) ? 0 : json['user_id'];
    user_responsability_id = isnullOrvacio(json['user_responsability_id']) ? 0 : json['user_responsability_id'];
    company_id = isnullOrvacio(json['company_id']) ? 0 : json['company_id'];
    project_id = isnullOrvacio(json['project_id']) ? 0 : json['project_id'];
    status_id = isnullOrvacio(json['status_id']) ? 0 : json['status_id'];
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

  Map<String, dynamic> toJson2() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name == null ? '""' : this.name;
    data['description'] = this.description == null ? '""' : this.description;
    data['deadline'] = this.deadline == null ? '""' : this.deadline;
    data['url_audio'] = this.url_audio == null ? '""' : this.url_audio;
    data['url_attachment'] = this.url_attachment == null ? '""' : this.url_attachment;
    data['reminder_type_id'] = this.reminder_type_id == null ? '""' : this.reminder_type_id.toString();
    data['user_id'] = this.user_id == null ? '""' : this.user_id.toString();
    data['user_responsability_id'] = this.user_responsability_id == null ? '""' : this.user_responsability_id.toString();
    data['company_id'] = this.company_id == null ? '""' : this.company_id.toString();
    data['project_id'] = this.project_id == null ? '""' : this.project_id.toString();
    data['status_id'] = this.status_id == null ? '""' : this.status_id.toString();
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order'] = this.order;
    data['name'] = this.name;
    data['description'] = this.description;
    data['is_priority'] = this.is_priority;
    data['finalized'] = this.finalized;
    data['deadline'] = this.deadline;
    data['rec_type'] = this.rec_type;
    data['parent_rec'] = this.parent_rec;
    data['start_date'] = this.start_date;
    data['end_date'] = this.end_date;
    data['is_full_day'] = this.is_full_day;
    data['active'] = this.active;
    data['system'] = this.system;
    data['url_audio'] = this.url_audio;
    data['url_attachment'] = this.url_attachment;
    data['reminder_type_id'] = this.reminder_type_id;
    data['user_id'] = this.user_id;
    data['user_responsability_id'] = this.user_responsability_id;
    data['company_id'] = this.company_id;
    data['project_id'] = this.project_id;
    data['status_id'] = this.status_id;
    data['created_at'] = this.created_at;
    data['updated_at'] = this.updated_at;
    data['deleted_at'] = this.deleted_at;
    return data;
  }

  Tarea.fromMap(Map snapshot) :
        id = snapshot['id'],
        order = snapshot['ord'],
        name = snapshot['name'],
        description = snapshot['description'],
        is_priority = snapshot['is_priority'],
        finalized = snapshot['finalized'],
        deadline = snapshot['deadline'],
        rec_type = snapshot['rec_type'],
        parent_rec = snapshot['parent_rec'],
        start_date = snapshot['start_date'],
        end_date = snapshot['end_date'],
        is_full_day = snapshot['is_full_day'],
        active = snapshot['active'],
        system = snapshot['system'],
        url_audio = snapshot['url_audio'],
        url_attachment = snapshot['url_attachment'],
        reminder_type_id = snapshot['reminder_type_id'],
        user_id = snapshot['user_id'],
        user_responsability_id = snapshot['user_responsability_id'],
        company_id = snapshot['company_id'],
        project_id = snapshot['project_id'],
        status_id = snapshot['status_id'],
        created_at = snapshot['created_at'],
        updated_at = snapshot['updated_at'],
        deleted_at = snapshot['deleted_at']
  ;
  Tarea.map(dynamic obj) {
    this.id = obj['id'];
    this.order = obj['order'];
    this.name = obj['name'];
    this.description = obj['description'];
    this.is_priority = obj['is_priority'];
    this.finalized = obj['finalized'];
    this.deadline = obj['deadline'];
    this.rec_type = obj['rec_type'];
    this.parent_rec = obj['parent_rec'];
    this.start_date = obj['start_date'];
    this.end_date = obj['end_date'];
    this.is_full_day = obj['is_full_day'];
    this.active = obj['active'];
    this.system = obj['system'];
    this.url_audio = obj['url_audio'];
    this.url_attachment = obj['url_attachment'];
    this.reminder_type_id = obj['reminder_type_id'];
    this.user_id = obj['user_id'];
    this.user_responsability_id = obj['user_responsability_id'];
    this.company_id = obj['company_id'];
    this.project_id = obj['project_id'];
    this.status_id = obj['status_id'];
    this.created_at = obj['created_at'];
    this.updated_at = obj['updated_at'];
    this.deleted_at = obj['deleted_at'];
  }

  Map<String, dynamic> toMap2() => {
    'id' : id.toString(),
    'ord' : order,
    'name' : name,
    'description' : description,
    'is_priority' : is_priority.toString(),
    'finalized' : finalized,
    'deadline' : deadline.toString(),
    'rec_type' : rec_type.toString(),
    'parent_rec' : parent_rec,
    'start_date' : start_date,
    'end_date' : end_date.toString(),
    'is_full_day' : is_full_day.toString(),
    'active' : active.toString(),
    'system' : system.toString(),
    'url_audio' : url_audio.toString(),
    'url_attachment' : url_attachment.toString(),
    'reminder_type_id' : reminder_type_id.toString(),
    'user_id' : user_id.toString(),
    'user_responsability_id' : user_responsability_id.toString(),
    'company_id' : company_id.toString(),
    'project_id' : project_id.toString(),
    'status_id' : status_id.toString(),
    'created_at' : created_at,
    'updated_at' : updated_at,
    'deleted_at' : deleted_at,
  };

  Map<String, dynamic> toMap() => {
    'id' : id,
    'ord' : order,
    'name' : name,
    'description' : description,
    'is_priority' : is_priority,
    'finalized' : finalized,
    'deadline' : deadline,
    'rec_type' : rec_type,
    'parent_rec' : parent_rec,
    'start_date' : start_date,
    'end_date' : end_date,
    'is_full_day' : is_full_day,
    'active' : active,
    'system' : system,
    'url_audio' : url_audio,
    'url_attachment' : url_attachment,
    'reminder_type_id' : reminder_type_id,
    'user_id' : user_id,
    'user_responsability_id' : user_responsability_id,
    'company_id' : company_id,
    'project_id' : project_id,
    'status_id' : status_id,
    'created_at' : created_at,
    'updated_at' : updated_at,
    'deleted_at' : deleted_at,
  };


  @override
  List<Object> get props => [
    id,
    order,
    name,
    description,
    is_priority,
    finalized,
    deadline,
    rec_type,
    parent_rec,
    start_date,
    end_date,
    is_full_day,
    active,
    system,
    url_audio,
    url_attachment,
    reminder_type_id,
    user_id,
    user_responsability_id,
    company_id,
    project_id,
    status_id,
    created_at,
    updated_at,
    deleted_at
  ];

  @override
  bool get stringify => false;
}