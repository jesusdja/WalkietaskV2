import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/utils/Globales.dart';

class conexionHttp{

  String enlace = 'http://www.unitydbm.com.php73-37.phx1-1.websitetestlink.com';


  Future<http.Response> httpListTareasRecibidas() async{
    String token  = await obtenerToken();
    var response;
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    try{
      response = http.get(
          '$enlace/api/auth/tasks/getAllTasksReceived',
        headers: requestHeaders
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpListUsuarios() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/users/getAllUsers',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpListCasos() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/projects/getAllProjects',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpListTareasEnviadas() async{
    String token  = await obtenerToken();
    var response;
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    try{
      response = http.get('$enlace/api/auth/tasks/getAllTasksSent',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpIniciarSesion(String correo, String pasw) async{
    var response;
    try{

      //'daniel.penya@imprevia.com'
      //'*D@p3N14#'

      Map<String,String> headers = {'Content-Type':'application/json',
        'X-Requested-With': 'XMLHttpRequest'};
      final msg = jsonEncode({
        'email': correo,
        'password': pasw
      });

      response = await http.post('$enlace/api/auth/login',
        headers: headers,
        body: msg,
      );

    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpModificarTarea(Tarea tarea) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/tasks/updateTasks/${tarea.id}',
        headers: headers,
        body: {
          'name': tarea.name,
          'deadline': tarea.deadline,
          'reminder_type_id': tarea.reminder_type_id.toString(),
          'user_id': tarea.user_id.toString(),
          'status_id': tarea.status_id.toString(),
          'is_priority' : tarea.is_priority.toString(),
        },
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpMyUser() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/user',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpCrearTarea(Map jsonBody) async{
    var response;
    try{
      String token  = await obtenerToken();
      Map<String,String> headers = {
        'Content-Type':'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token'
      };
      response = await http.post('$enlace/api/auth/tasks/saveTasks',
        headers: headers,
        body: jsonBody,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }


}