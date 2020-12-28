import 'package:sqflite/sqflite.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Globales.dart';

class UserDatabaseProvider{
  UserDatabaseProvider._();

  static final  UserDatabaseProvider db = UserDatabaseProvider._();
  Database _database;


  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await getDatabaseInstanace();
    return _database;
  }

//  Future<Database> getDatabaseInstanace() async {
//    Directory directory = await getApplicationDocumentsDirectory();
//    String path = join(directory.path, "unity.db");
//    return await openDatabase(path, version: 1,
//        onCreate: (Database db, int version) async {
//          await db.execute(
//              "CREATE TABLE Usuarios("
//                  "id INTEGER primary key,"
//                  "username TEXT, "
//                  "email TEXT, "
//                  "name TEXT, "
//                  "address TEXT, "
//                  "avatar TEXT, "
//                  "create_cases INT, "
//                  "active INT, "
//                  "system INT, "
//                  "level_id INT, "
//                  "company_id INT, "
//                  "createdAt TEXT, "
//                  "updatedAt TEXT, "
//                  "deletedAt TEXT, "
//                  "fijo INT"
//              ")");
//        });
//  }
  //ELIMINAR INSTANCIA
  Future deleteDatabaseInstance() async {
    final db = await database;
    db.delete('Usuarios');
  }
  //OBTENER USUARIO
  Future<Usuario> getCodeId(String codigo) async {
      try{
        final db = await database;
        var response = await db.query("Usuarios", where: "id = ?", whereArgs: [codigo]);
        return response.isNotEmpty ? Usuario.fromMap(response.first) : null;
      }catch(e){
        return null;
      }
  }
  Future<List<Usuario>> getAll() async {
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

  Future<List<Usuario>> getContacts() async {
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
    try{
      res = await dbClient.update('Usuarios', user.toMap(),where: 'id = ?', whereArgs: [user.id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }
}
