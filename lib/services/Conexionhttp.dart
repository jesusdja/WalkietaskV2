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

  Future<http.Response> httpListMyProjects() async{
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

  Future<http.Response> httpSendFavorite(Tarea tarea, int value) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/tasks/priorityTask/${tarea.id}',
        headers: headers,
        body: {
          'priority': value.toString(),
        },
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpReadTask(int idTask) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/tasks/markasread/$idTask',headers: headers,);
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpReadInvitation(int idInv) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/contacts/markasread/$idInv',headers: headers,
        body: {
          'external': 1,
        },);
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpSendFavorite2(Tarea tarea) async {

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

  Future<http.Response> httpUpdateUser(Map<String,dynamic> body) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = await http.put('$enlace/api/auth/profile/edit',
        headers: headers,
        body: body,
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
      final request = http.MultipartRequest('POST',Uri.parse('$enlace/api/auth/tasks/saveTasks'));

      request.headers.addAll(headers);

      if(jsonBody['url_audio'] != null && jsonBody['url_audio'] != ''){
        final fileAudio = await http.MultipartFile.fromPath('audio', jsonBody['url_audio'],);
        request.files.add(fileAudio);
      }

      if(jsonBody['url_attachment'] != null && jsonBody['url_attachment'] != ''){
        final fileAttachment = await http.MultipartFile.fromPath('attachment', jsonBody['url_attachment'],);
        request.files.add(fileAttachment);
      }

      jsonBody.forEach((key, value) {
        if(key != 'url_audio' && key != 'url_attachment'){
          request.fields[key] = value;
        }
      });

      print('');

      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpCrearTarea2(Map jsonBody) async{
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
      response = await http.post('$enlace/api/auth/contacts/senduserinvitation',
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
    bool _connectivity = await checkConectivity();
    if(!_connectivity){
      return null;
    }
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

  Future<http.Response> httpUpdateTokenFirebase(String tokenFb) async{
    var response;
    try{
      String token  = await obtenerToken();
      Map<String,String> headers = {
        'Content-Type':'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token'
      };
      response = await http.post('$enlace/api/auth/fcm/token',
        headers: headers,
        body: {
        'fcm_token' : tokenFb
        },
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpTaskInit(int id) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = await http.put('$enlace/api/auth/tasks/workingTask/$id',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpTaskFinalized(int id) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/tasks/finalizeTask/$id',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpSendImage(String path) async {
    String token  = await obtenerToken();
    Map<String, String> headers = {
      'Authorization': 'Bearer $token'
    };

    var response;
    try {
      final imageUp = http.MultipartRequest('POST',Uri.parse('$enlace/api/auth/users/uploadphoto'));
      imageUp.headers.addAll(headers);
      final file = await http.MultipartFile.fromPath('avatar', path,);
      imageUp.files.add(file);
      final streamedResponse = await imageUp.send();
      response = await http.Response.fromStream(streamedResponse);
    } catch (ex) {
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpUploadAudio(String path) async {
    String token  = await obtenerToken();
    Map<String, String> headers = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try {
      final imageUp = http.MultipartRequest('POST',Uri.parse('$enlace/api/auth/uploadaudiofile'));
      imageUp.headers.addAll(headers);
      final file = await http.MultipartFile.fromPath('audio', path,);
      imageUp.files.add(file);
      final streamedResponse = await imageUp.send();
      response = await http.Response.fromStream(streamedResponse);
    } catch (ex) {
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpUploadAttachment(String path) async {
    String token  = await obtenerToken();
    Map<String, String> headers = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try {
      final imageUp = http.MultipartRequest('POST',Uri.parse('$enlace/api/auth/uploadattachmentfile'));
      imageUp.headers.addAll(headers);
      final file = await http.MultipartFile.fromPath('attachment', path,);
      imageUp.files.add(file);
      final streamedResponse = await imageUp.send();
      response = await http.Response.fromStream(streamedResponse);
    } catch (ex) {
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpDeleteTask(int id) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type':'application/json',
      'Accept': 'application/json',
    };

    var response;

    try{
      response = await http.delete('$enlace/api/auth/tasks/deleteTask/$id',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }
    return response;
  }

  Future<http.Response> httpTaskRestore(int id) async {

    String token  = await obtenerToken();
    Map<String,String> headers = {
      'Content-Type':'application/x-www-form-urlencoded',
      'X-Requested-With': 'XMLHttpRequest',
      'Authorization': 'Bearer $token'
    };

    var response;

    try{
      response = await http.put('$enlace/api/auth/tasks/restoreTask/$id',
        headers: headers,
      );
    }catch(e){
      print(e.toString());
    }

    return response;
  }

  Future<http.Response> httpBinnacle() async{
    String token  = await obtenerToken();
    var response;
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    try{
      response = http.get('$enlace/api/auth/binnacle',
          headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }

  Future<http.Response> httpMyNotifications() async{
    String token  = await obtenerToken();
    Map<String, String> requestHeaders = {
      'Authorization': 'Bearer $token'
    };
    var response;
    try{
      response = http.get('$enlace/api/auth/notifications/unread',headers: requestHeaders);
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }
}