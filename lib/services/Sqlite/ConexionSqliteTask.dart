import 'package:sqflite/sqflite.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class TaskDatabaseProvider{
  TaskDatabaseProvider._();

  static final  TaskDatabaseProvider db = TaskDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await getDatabaseInstanace();
    return _database;
  }

//  Future<Database> getDatabaseInstanace() async {
//    Directory directory = await getApplicationDocumentsDirectory();
//    String path = join(directory.path, "unity2.db");
//
//    var res = await openDatabase(path, version: 1,
//        onCreate: (Database db, int version) async {
//          await db.execute(
//              "CREATE TABLE Tareas("
//                  "id INTEGER primary key, "
//                  "name TEXT, "
//                  "ord INT,"
//                  "is_priority INT, "
//                  "finalized INT, "
//                  "deadline TEXT, "
//                  "rec_type INT, "
//                  "parent_rec INT, "
//                  "start_date TEXT, "
//                  "end_date TEXT, "
//                  "is_full_day INT, "
//                  "active INT, "
//                  "system INT, "
//                  "reminder_type_id INT, "
//                  "user_id INT, "
//                  "user_responsability_id INT, "
//                  "company_id INT, "
//                  "project_id INT, "
//                  "status_id INT, "
//                  "created_at TEXT, "
//                  "updated_at TEXT, "
//                  "deleted_at TEXT"
//                  ")");
//        });
//    return res;
//  }
  //ELIMINAR INSTANCIA
  Future deleteDatabaseInstance() async {
    final db = await database;
    db.delete('Tareas');
  }
  //OBTENER TAREA
  Future<Tarea> getCodeId(String codigo) async {
      try{
        final db = await database;
        var response = await db.query("Tareas", where: "id = ?", whereArgs: [codigo]);
        return response.isNotEmpty ? Tarea.fromMap(response.first) : null;
      }catch(e){
        return null;
      }
  }
  //OBTENER TODAS LAS TAREAS
  Future<List<Tarea>> getAll() async {
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
  Future<List<Tarea>> getAllRecevid() async {
    List<Tarea> listTareaFav = new List<Tarea>();
    List<Tarea> listTarea = new List<Tarea>();
    String idUser = await SharedPrefe().getValue('unityIdMyUser');
    final db = await database;
    try{
      List<Map> list = await db.rawQuery('SELECT * FROM Tareas WHERE user_responsability_id = $idUser AND is_priority = 1 ORDER BY ord DESC');
      list.forEach((mapa){
        Tarea tarea = new Tarea.fromMap(mapa);
        listTareaFav.add(tarea);
      });
      list = await db.rawQuery('SELECT * FROM Tareas WHERE user_responsability_id = $idUser AND is_priority = 0 ORDER BY ord DESC');
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
  Future<List<Tarea>> getAllSend() async {
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

  // //OBTENER TODAS LAS TAREAS ENVIADAS
  // Future<Map<int,List<Tarea>>> getAllSend(String myId) async {
  //   print(myId);
  //   Map<int,List<Tarea>> mapTarea = new Map<int,List<Tarea>>();
  //   final db = await database;
  //   try{
  //     List<Map> list = await db.rawQuery('SELECT * FROM Tareas WHERE user_id = $myId AND user_responsability_id != 0 AND is_priority = 1 ORDER BY ord');
  //     list.forEach((mapa){
  //       Tarea tarea = new Tarea.fromMap(mapa);
  //       if(mapTarea[0] == null){mapTarea[0] = new List<Tarea>();}
  //       mapTarea[0].add(tarea);
  //     });
  //     list = await db.rawQuery('SELECT * FROM Tareas WHERE user_id = $myId AND user_responsability_id != 0 AND is_priority = 0 ORDER BY ord');
  //     list.forEach((mapa){
  //       Tarea tarea = new Tarea.fromMap(mapa);
  //       if(mapTarea[tarea.user_responsability_id] == null){mapTarea[tarea.user_responsability_id] = new List<Tarea>();}
  //       mapTarea[tarea.user_responsability_id].add(tarea);
  //     });
  //   }catch(e){
  //     print(e.toString());
  //   }
  //   return mapTarea;
  // }

  //INSERTAR TAREA
  Future<int> saveTask(Tarea tarea) async {
    int res = 0;
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
}
