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

  Future<http.Response> httpListContacts() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/contacts/all',
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

  Future<http.Response> httpRecoverPass(String email) async{
    var response;
    try{

      Map<String,String> headers = {'Content-Type':'application/json',
        'X-Requested-With': 'XMLHttpRequest'};

      final msg = jsonEncode({
        'email': email,
      });
      response = await http.post('$enlace/api/auth/recoverypassword',
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

  Future<http.Response> httpCheckUserRegister(String userName) async{
    var response;
    try{
      Map<String,String> headers = {
        'Content-Type':'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      };
      final msg = jsonEncode({
        'username': userName,
      });
      response = await http.post('http://www.unitydbm.com/api/auth/checkusername',
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

  Future<http.Response> httpSendInvitation(Map jsonBody) async{
    var response;
    try{
      String token  = await obtenerToken();
      Map<String,String> headers = {
        'Content-Type':'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token'
      };
      response = await http.post('$enlace/api/auth/contacts/sendinvitation',
        headers: headers,
        body: jsonBody,
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpSendInvitationNewUser(Map jsonBody) async{
    var response;
    try{
      String token  = await obtenerToken();
      Map<String,String> headers = {
        'Content-Type':'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token'
      };
      response = await http.post('$enlace/api/auth/contacts/sendinvitationtoapp',
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

  Future<http.Response> httpListInvitationSent() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/contacts/invited',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpListInvitationReceived() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/contacts/received',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpResetInvitationSent(int idInvited) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/contacts/resentinvitation/$idInvited',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpDeleteInvitationSent(int idInvited) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.delete('$enlace/api/auth/contacts/invited/delete/$idInvited',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpAcceptedInvitationReceived(int idInvited) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/contacts/acceptinvitation/$idInvited',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpDeniedInvitationReceived(int idInvited) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.delete('$enlace/api/auth/contacts/received/delete/$idInvited',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpUpdateNameTask(int id, String name) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type':'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };
    final body = {'name' : name};
    var response;
    try{
      response = await http.put('$enlace/api/auth/tasks/updatenametask/$id',
        headers: headers, body: body
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpDeleteContact(int idContact) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type':'application/json',
      'Accept': 'application/json',
    };

    var response;

    try{
      response = await http.delete('$enlace/api/auth/contacts/delete/$idContact',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpUpdateTask(Map<String,dynamic> body, int id) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type':'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = await http.put('$enlace/api/auth/tasks/updateTasks/$id',
          headers: headers, body: body
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpGetListGuestsForProjects() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/projects/myProjects',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpDeleteProject(int id) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type':'application/json',
      'Accept': 'application/json',
    };

    var response;

    try{
      response = await http.delete('$enlace/api/auth/projects/$id/delete',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpDeleteUserForProject(int idProject, int idUser) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type':'application/json',
      'Accept': 'application/json',
    };

    var response;

    try{
      response = await http.delete('$enlace/api/auth/projects/$idProject/user/$idUser',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpAddUserToProject(Map body, int id) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'X-Requested-With': 'XMLHttpRequest',
      'Content-Type':'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = await http.put('$enlace/api/auth/projects/$id/addUsers',
          headers: headers, body: body
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }
}