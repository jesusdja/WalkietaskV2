import 'package:sqflite/sqflite.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/utils/Globales.dart';

class InvitationDatabaseProvider{
  InvitationDatabaseProvider._();

  static final  InvitationDatabaseProvider db = InvitationDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await getDatabaseInstanace();
    return _database;
  }
  //ELIMINAR INSTANCIA
  Future deleteDatabaseInstance() async {
    final db = await database;
    db.delete('Invitation');
  }
  //OBTENER TAREA
  Future<InvitationModel> getCodeId(String codigo) async {
      try{
        final db = await database;
        var response = await db.query("Invitation", where: "id = ?", whereArgs: [codigo]);
        return response.isNotEmpty ? InvitationModel.fromMap(response.first) : null;
      }catch(e){
        return null;
      }
  }
  //OBTENER TODAS LAS TAREAS
  Future<List<InvitationModel>> getAll() async {
    List<InvitationModel> listinvitation = new List<InvitationModel>();
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Invitation');
      list.forEach((mapa){
        InvitationModel invitation = new InvitationModel.fromMap(mapa);
        listinvitation.add(invitation);
      });
    }catch(e){
      print(e.toString());
    }
    return listinvitation;
  }

  //INSERTAR TAREA
  Future<int> saveInvitation(InvitationModel invitation) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient.insert("Invitation", invitation.toMap());
    }catch(e){
      print(e.toString());
    }

    return res;
  }

  //ELIMINAR INVITACION
  Future<int> deleteInvitation(int id) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient.delete("Invitation", where: "id = ?", whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //MODIFICAR TAREA
  Future<int> updateInvitation(InvitationModel invitation) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient.update('Invitation', invitation.toMap(),where: 'id = ?', whereArgs: [invitation.id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
}
