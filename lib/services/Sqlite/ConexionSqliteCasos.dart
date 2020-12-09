import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/utils/Globales.dart';

class CasosDatabaseProvider{
  CasosDatabaseProvider._();

  static final  CasosDatabaseProvider db = CasosDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await getDatabaseInstanace();
    return _database;
  }
  //ELIMINAR INSTANCIA
  Future deleteDatabaseInstance() async {
    final db = await database;
    db.delete('Casos');
  }
  //OBTENER TAREA
  Future<Caso> getCodeId(String codigo) async {
      try{
        final db = await database;
        var response = await db.query("Casos", where: "id = ?", whereArgs: [codigo]);
        return response.isNotEmpty ? Caso.fromMap(response.first) : null;
      }catch(e){
        return null;
      }
  }
  //OBTENER TODAS LAS TAREAS
  Future<List<Caso>> getAll() async {
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
  Future<int> saveCaso(Caso caso) async {
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
  Future<int> updateCaso(Caso caso) async {
    var dbClient = await  database;
    int res = 0;
    try{
      res = await dbClient.update('Casos', caso.toMap(),where: 'id = ?', whereArgs: [caso.id]);
    }catch(e){
      print(e.toString());
    }
    return res;
  }

  //ELIMINAR PROYECTO
  Future<int> deleteProject(int id) async {
    int res = 0;
    try{
      var dbClient = await database;
      res = await dbClient.delete("Casos", where: "id = ?", whereArgs: [id]);
    }catch(e){
      print(e.toString());
    }

    return res;
  }
}
