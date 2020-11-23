import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class conexionHttp{

  //String enlace = 'http://www.unitydbm.com.php73-37.phx1-1.websitetestlink.com';
  String enlace = 'http://www.unitydbm.com';


  Future<http.Response> httpListTareasRecibidas() async{
    String token  = await obtenerToken();
    var response;
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    try{
      response = http.get(
          '$enlace/api/auth/tasks/myreceivedtasks',
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

  Future<http.Response> httpCheckUser(String correo) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      };
      final msg = jsonEncode({
        'email': correo,
      });
      response = await http.post('http://www.unitydbm.com/api/auth/checkemailverified',
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

  Future<http.Response> httpConfirmUser(String code) async {

    String token  = await obtenerToken();
    String idUser = await SharedPrefe().getValue('unityIdMyUser');
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = await http.put('$enlace/api/auth/users/entercode/$idUser.',
        headers: headers,
        body: {
          'code': code,
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

  Future<http.Response> httpCreateProyect(Map jsonBody) async{
    var response;
    try{
      String token  = await obtenerToken();
      Map<String,String> headers = {
        'Content-Type':'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token'
      };
      response = await http.post('$enlace/api/auth/projects/createProjects',
        headers: headers,
        body: jsonBody,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpRegisterUser(Map<String,dynamic> body) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      };
      final msg = jsonEncode(body);
      response = await http.post('$enlace/api/auth/signup',
        headers: headers,
        body: msg,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }
}