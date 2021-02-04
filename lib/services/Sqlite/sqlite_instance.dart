import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';


String versionApp = '1.2.6';

Future<Database> getDatabaseInstance() async {
  Directory directory = await getApplicationDocumentsDirectory();
  String path = join(directory.path, "unity13.db");
  print(path);
  return await openDatabase(path, version: 13,
      onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE Usuarios("
                "id INTEGER primary key,"
                "username TEXT, "
                "email TEXT, "
                "name TEXT, "
                "address TEXT, "
                "avatar TEXT, "
                "create_cases INT, "
                "active INT, "
                "system INT, "
                "level_id INT, "
                "company_id INT, "
                "createdAt TEXT, "
                "updatedAt TEXT, "
                "deletedAt TEXT, "
                "fijo INT, "
                "fcmToken TEXT, "
                "contact INT"
                ")");
        await db.execute(
            "CREATE TABLE Tareas("
                "id INTEGER primary key, "
                "name TEXT, "
                "description TEXT, "
                "ord INT,"
                "read INT,"
                "is_priority INT, "
                "is_priority_responsability INT, "
                "working INT, "
                "finalized INT, "
                "deadline TEXT, "
                "rec_type INT, "
                "parent_rec INT, "
                "start_date TEXT, "
                "end_date TEXT, "
                "is_full_day INT, "
                "active INT, "
                "system INT, "
                "url_audio TEXT, "
                "url_attachment TEXT, "
                "reminder_type_id INT, "
                "user_id INT, "
                "user_responsability_id INT, "
                "company_id INT, "
                "project_id INT, "
                "status_id INT, "
                "created_at TEXT, "
                "updated_at TEXT, "
                "deleted_at TEXT"
                ")");
        await db.execute(
            "CREATE TABLE Casos("
                "id INTEGER primary key, "
                "serial INT, "
                "imei INT, "
                "boleta INT, "
                "name TEXT, "
                "is_priority INT, "
                "active INT, "
                "system INT, "
                "company_id INT, "
                "status_id INT, "
                "customer_id INT, "
                "user_id INT, "
                "created_at TEXT, "
                "updated_at TEXT, "
                "deleted_at TEXT, "
                "nameCompany TEXT"
                ")");
        await db.execute(
            "CREATE TABLE Invitation("
                "id INTEGER primary key, "
                "user_id INT, "
                "user_id_invited INT, "
                "sent INT, "
                "resent INT, "
                "accepted INT, "
                "read INT,"
                "created_at TEXT, "
                "updated_at TEXT, "
                "inv INT, "
                "external INT, "
                "contact TEXT"
                ")");
      });
}