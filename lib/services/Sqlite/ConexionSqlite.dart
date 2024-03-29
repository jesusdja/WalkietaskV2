import 'package:sqflite/sqflite.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/Sqlite/sqlite_instance.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class DatabaseProvider{
  DatabaseProvider._();
  static final  DatabaseProvider db = DatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if(_database != null){
      int versiondb = await SharedPrefe().getValue('unityInit');
      if(versiondb == null || versiondb != 19){
        await SharedPrefe().setIntValue('unityInit', 19);
        await deleteDatabaseInstance();
      }else{
        return _database;
      }
    }
    _database = await getDatabaseInstance();
    return _database;
  }

  //ELIMINAR INSTANCIA
  Future deleteDatabaseInstance() async {
    // final db = await database;
    // await db.close();
    //
    // // Get a location using getDatabasesPath
    // var databasesPath = await getDatabasesPath();
    // String path = join(databasesPath, 'unity.db');
    // // Delete the database
    // await deleteDatabase(path);

    // Get a location using getDatabasesPath
    // Directory directory = await getApplicationDocumentsDirectory();
    // String path = join(directory.path, 'unity.db');
    // // Delete the database
    // await deleteDatabase(path);
    // _database = null;

    try{
      final db  = await database;
      await db.rawDelete('DELETE FROM Usuarios');
      await db.rawDelete('DELETE FROM Tareas');
      await db.rawDelete('DELETE FROM Casos');
      await db.rawDelete('DELETE FROM Invitation');
    }catch(e){
      print(e.toString());
      print('ERROR AL BORRAR DB');
    }

    try{
      final db  = await database;
      await db.rawDelete('DELETE FROM Usuarios');
      await db.rawDelete('DELETE FROM Tareas');
      await db.rawDelete('DELETE FROM Casos');
      await db.rawDelete('DELETE FROM Invitation');
    }catch(e){
      print(e.toString());
      print('ERROR AL BORRAR DB');
    }

  }

  //**********************
  //**********************
  //*******USER***********
  //**********************
  //**********************

  //OBTENER USUARIO
  Future<Usuario> getCodeIdUser(String codigo) async {
      try{
        final db = await database;
        var response = await db.query("Usuarios", where: "id = ?", whereArgs: [codigo]);
        return response.isNotEmpty ? Usuario.fromMap(response.first) : null;
      }catch(e){
        return null;
      }
  }
  //OBTENER TODOS LOS USUARIOS
  Future<List<Usuario>> getAllUser() async {
    List<Usuario> listUser = new List<Usuario>();
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Usuarios WHERE fijo = 1 ORDER BY name');
      list.forEach((mapa){
        Usuario usuario = new Usuario.fromMap(mapa);
        listUser.add(usuario);
      });
      list = await db.rawQuery('SELECT * FROM Usuarios WHERE fijo = 0 ORDER BY name');
      list.forEach((mapa){
        Usuario usuario = new Usuario.fromMap(mapa);
        listUser.add(usuario);
      });
    }catch(e){
      print(e.toString());
    }
    return listUser;
  }
  //OBTENER TODOS LOS CONTACTOS
  Future<List<Usuario>> getContactsUser() async {
    List<Usuario> listUser = new List<Usuario>();
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Usuarios WHERE contact = 1 ORDER BY name');
      list.forEach((mapa){
        Usuario usuario = new Usuario.fromMap(mapa);
        listUser.add(usuario);
      });
    }catch(e){
      print(e.toString());
    }
    return listUser;
  }
  //Insert
  Future<int> saveUser(Usuario user) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient.insert("Usuarios", user.toMap());
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //MODIFICAR
  Future<int> updateUser(Usuario user) async {
    var dbClient = await  database;
    int res = 0;
    updateUserDate(user.id, 1);
    try{
      res = await dbClient.update('Usuarios', user.toMap(),where: 'id = ?', whereArgs: [user.id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //MODIFICAR SOLO PARA CONTACTO
  Future<int> updateUserContact(int idUser, int changeContact) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient.update('Usuarios', {'contact' : '$changeContact'},where: 'id = ?', whereArgs: [idUser]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //MODIFICAR FECHA UPDATE
  Future<int> updateUserDate(int idUser, int type) async {
    var dbClient = await  database;
    int res = 0;
    String date = DateTime.now().toString();
    try{
      res = await dbClient.update('Usuarios',{'updatedAt' : date},where: 'id = ?', whereArgs: [idUser]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }

//**********************
//**********************
//*******CASE***********
//**********************
//**********************

  //OBTENER TAREA
  Future<Caso> getCodeIdCase(String codigo) async {
    try{
      final db = await database;
      var response = await db.query("Casos", where: "id = ?", whereArgs: [codigo]);
      return response.isNotEmpty ? Caso.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER TODAS LAS TAREAS
  Future<List<Caso>> getAllCase() async {
    List<Caso> listCaso = new List<Caso>();
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Casos');
      list.forEach((mapa){
        Caso caso = new Caso.fromMap(mapa);
        listCaso.add(caso);
      });
    }catch(e){
      print(e.toString());
    }
    return listCaso;
  }
  //INSERTAR TAREA
  Future<int> saveCase(Caso caso) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient.insert("Casos", caso.toMap());
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //MODIFICAR TAREA
  Future<int> updateCase(Caso caso) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient.update('Casos', caso.toMap(),where: 'id = ?', whereArgs: [caso.id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }

  //MODIFICAR TAREA
  Future<int> updateDateCase(String idCase) async {
    var dbClient = await  database;
    int res = 0;
    String date = DateTime.now().toString();
    try{
      res = await dbClient.update('Casos',{'updated_at' : date},where: 'id = ?', whereArgs: [idCase]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }

  //ELIMINAR PROYECTO
  Future<int> deleteProjectCase(int id) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient.delete("Casos", where: "id = ?", whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }

    return res;
  }

  //OBTENER TODAS LAS TAREAS
  Future<List<Caso>> getMyProjects() async {
    List<Caso> listCaso = new List<Caso>();
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Casos WHERE nameCompany = "true"');
      list.forEach((mapa){
        Caso caso = new Caso.fromMap(mapa);
        listCaso.add(caso);
      });
    }catch(e){
      print(e.toString());
    }
    return listCaso;
  }

//**********************
//**********************
//*******INVITATION*****
//**********************
//**********************

  //OBTENER TAREA
  Future<InvitationModel> getCodeIdInvitation(String codigo) async {
    try{
      final db = await database;
      var response = await db.query("Invitation", where: "id = ?", whereArgs: [codigo]);
      return response.isNotEmpty ? InvitationModel.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER TODAS LAS TAREAS
  Future<List<InvitationModel>> getAllInvitation() async {
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

//**********************
//**********************
//*******TAREA**********
//**********************
//**********************

  Future<Tarea> getCodeIdTask(String codigo) async {
    try{
      final db = await database;
      var response = await db.query("Tareas", where: "id = ?", whereArgs: [codigo]);
      return response.isNotEmpty ? Tarea.fromMap(response.first) : null;
    }catch(e){
      return null;
    }
  }
  //OBTENER TODAS LAS TAREAS
  Future<List<Tarea>> getAllTask() async {
    List<Tarea> listTarea = new List<Tarea>();
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Tareas');
      list.forEach((mapa){
        Tarea usuario = new Tarea.fromMap(mapa);
        listTarea.add(usuario);
      });
    }catch(e){
      print(e.toString());
    }
    return listTarea;
  }
  //OBTENER TODAS LAS TAREAS RECIBIDAS
  Future<List<Tarea>> getAllRecevidTask() async {
    List<Tarea> listTareaFav = new List<Tarea>();
    List<Tarea> listTarea = new List<Tarea>();
    String idUser = await SharedPrefe().getValue('unityIdMyUser');
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Tareas WHERE user_responsability_id = $idUser AND is_priority_responsability = 1 ORDER BY ord DESC');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        listTareaFav.add(tarea);
      });
      list = await db.rawQuery('SELECT * FROM Tareas WHERE user_responsability_id = $idUser AND is_priority_responsability = 0 ORDER BY ord DESC');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        listTarea.add(tarea);
      });
      listTareaFav.sort((item1, item2) => DateTime.parse(item1.updated_at).compareTo(DateTime.parse(item2.updated_at)));
      listTarea.sort((item1, item2) => DateTime.parse(item1.updated_at).compareTo(DateTime.parse(item2.updated_at)));
    }catch(e){
      print(e.toString());
    }
    List<Tarea> listResult = [];
    for(int x = listTareaFav.length; x > 0; x--){
      listResult.add(listTareaFav[x - 1]);
    }
    for(int x = listTarea.length; x > 0; x--){
      listResult.add(listTarea[x - 1]);
    }
    return listResult;
  }
  //OBTENER TODAS LAS TAREAS ENVIADAS
  Future<List<Tarea>> getAllSendTask() async {
    String myId = await SharedPrefe().getValue('unityIdMyUser');
    List<Tarea> listTareaFav = new List<Tarea>();
    List<Tarea> listTarea = new List<Tarea>();
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Tareas WHERE user_id = $myId AND user_responsability_id != 0 AND is_priority = 1 ORDER BY ord DESC');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        listTareaFav.add(tarea);
      });
      list = await db.rawQuery('SELECT * FROM Tareas WHERE user_id = $myId AND user_responsability_id != 0 AND is_priority = 0 ORDER BY ord DESC');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        listTarea.add(tarea);
      });
      listTareaFav.sort((item1, item2) => DateTime.parse(item1.updated_at).compareTo(DateTime.parse(item2.updated_at)));
      listTarea.sort((item1, item2) => DateTime.parse(item1.updated_at).compareTo(DateTime.parse(item2.updated_at)));
    }catch(e){
      print(e.toString());
    }

    List<Tarea> listResult = [];
    for(int x = listTareaFav.length; x > 0; x--){
      listResult.add(listTareaFav[x - 1]);
    }
    for(int x = listTarea.length; x > 0; x--){
      listResult.add(listTarea[x - 1]);
    }
    return listResult;
  }
  //INSERTAR TAREA
  Future<int> saveTask(Tarea tarea) async {
    int res = 0;
    updateUserDate(tarea.user_id, 2);
    updateUserDate(tarea.user_responsability_id, 2);
    try{
      var dbClient = await database;
      res = await dbClient.insert("Tareas", tarea.toMap());
    }catch(e){
      print(e.toString());
    }

    return res;
  }
  //MODIFICAR TAREA
  Future<int> updateTask(Tarea tarea) async {
    var dbClient = await  database;
    int res = 0;
    updateUserDate(tarea.user_id, 3);
    updateUserDate(tarea.user_responsability_id, 3);
    if(tarea.project_id != 0){
      updateDateCase(tarea.project_id.toString());
    }
    try{
      res = await dbClient.update('Tareas', tarea.toMap(),where: 'id = ?', whereArgs: [tarea.id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //MODIFICAR FECHA DE TAREA
  Future<int> updateTaskDate(String id, String date) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient.update('Tareas', {'updated_at' : date},where: 'id = ?', whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //MODIFICAR NOMBRE DE TAREA
  Future<int> updateTaskName(int id, String name) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient.update('Tareas', {'name' : name,},where: 'id = ?', whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //ELIMINAR TAREA
  Future<int> deleteTaskId(int id) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient.rawDelete('DELETE FROM Tareas WHERE id = ?', ['$id']);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
  //OBTENER TODAS LAS TAREAS POR PROYECTO
  Future<List<Tarea>> getTaskForProjects(int idProject) async {
    List<Tarea> result = [];
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Tareas WHERE finalized = 0 AND project_id = $idProject');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        result.add(tarea);
      });
    }catch(e){
      print(e.toString());
    }
    return result;
  }

  //OBTENER TODAS LAS TAREAS CON PROYECTO
  Future<List<Tarea>> getTaskWithProjects() async {
    List<Tarea> result = [];
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Tareas WHERE finalized = 0 AND project_id != 0');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        result.add(tarea);
      });
    }catch(e){
      print(e.toString());
    }
    return result;
  }
  //OBTENER TODAS LAS TAREAS CON PROYECTO
  Future<List<Tarea>> getAssignedTaskWithProjects() async {
    List<Tarea> result = [];
    final db = await database;
    String myId = await SharedPrefe().getValue('unityIdMyUser');
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Tareas WHERE finalized = 0 AND project_id != 0 AND user_responsability_id = $myId');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        result.add(tarea);
      });
    }catch(e){
      print(e.toString());
    }
    return result;
  }
}
