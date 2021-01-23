import 'package:sqflite/sqflite.dart';
import 'package:walkietaskv2/utils/Globales.dart';

class CaseDatabaseProvider{
  CaseDatabaseProvider._();

  static final  CaseDatabaseProvider db = CaseDatabaseProvider._();
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

}
