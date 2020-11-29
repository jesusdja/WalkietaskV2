import 'package:equatable/equatable.dart';

class InvitationModel extends Equatable {

  int id;
  int userId;
  int userIdInvited;
  int sent;
  int resent;
  int accepted;
  String createdAt;
  String updateAt;
  int inv;

  InvitationModel(
      {
        this.id,
        this.userId,
        this.userIdInvited,
        this.sent,
        this.resent,
        this.accepted,
        this.createdAt,
        this.updateAt,
        this.inv,
      });

  InvitationModel.fromJson(Map<String, dynamic> json) {
    id = json['id']== null ? 0 : json['id'];
    userId = json['user_id']== null ? 0 :json['user_id'];
    userIdInvited = json['user_id_invited']== null ? 0 :json['user_id_invited'];
    sent = json['sent']== null ? 0 :json['sent'];
    resent = json['resent']== null ? 0 :json['resent'];
    accepted = json['accepted']== null ? 0 : json['accepted'];
    createdAt = json['created_at']== null ? '' : json['created_at'];
    updateAt = json['update_at']== null ? '' : json['update_at'];
    inv = json['inv']== null ? 0 : json['inv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_id_invited'] = this.userIdInvited;
    data['sent'] = this.sent;
    data['resent'] = this.resent;
    data['accepted'] = this.accepted;
    data['created_at'] = this.createdAt;
    data['update_at'] = this.updateAt;
    data['inv'] = this.inv;
    return data;
  }
  InvitationModel.fromMap(Map snapshot) :
        id = snapshot['id']== null ? 0 :snapshot['id'],
        userId = snapshot['user_id']== null ? 0 :snapshot['user_id'],
        userIdInvited = snapshot['user_id_invited']== null ? 0 :snapshot['user_id_invited'],
        sent = snapshot['sent']== null ? 0 :snapshot['sent'],
        resent = snapshot['resent']== null ? 0 :snapshot['resent'],
        accepted = snapshot['accepted']== null ? 0 :snapshot['accepted'],
        createdAt = snapshot['created_at']== null ? '' :snapshot['created_at'],
        updateAt = snapshot['update_at']== null ? '' :snapshot['update_at'],
        inv = snapshot['inv']== null ? 0 :snapshot['inv']
  ;

  Map<String, dynamic> toMap() => {
    'id' : id,
    'user_id' : userId,
    'user_id_invited' : userIdInvited,
    'sent' : sent,
    'resent' : resent,
    'accepted' : accepted,
    'created_at' : createdAt,
    'update_at' : updateAt,
    'inv' : inv,
  };

  InvitationModel.map(dynamic obj) {
    this.id = obj['id'];
    this.userId = obj['user_id'];
    this.userIdInvited = obj['user_id_invited'];
    this.sent = obj['sent'];
    this.resent = obj['resent'];
    this.accepted = obj['accepted'];
    this.createdAt = obj['created_at'];
    this.updateAt = obj['update_at'];
    this.inv = obj['active'];
  }

  @override
  List<Object> get props => [
    id,
    userId ,
    userIdInvited ,
    sent ,
    resent ,
    accepted ,
    createdAt ,
    updateAt ,
    inv
  ];

  @override
  bool get stringify => false;
}
