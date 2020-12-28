import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpPushNotifications{

  Future<http.Response> httpSendMessagero(String to,{String description : ''}) async{
    var url = "https://fcm.googleapis.com/fcm/send";

    Map<String, String> requestHeaders = {
      'Content-Type' : 'application/json',
      'Authorization': 'key=AAAAchi7p6U:APA91bHYqqePapeybZ089xYX45qbm1qWbNP0zF7FGOBpjGNqsaNz1a7mvADEBWSn1PA9ikdav2wxGr_3MtTw4ruCapHKeUrD4__BY89_sPBWlXJfcTnzD94e-mL506Pt15BpwLV-vAKL'
    };

    final msg = jsonEncode({
      'notification': {
        'body' : 'Nuevo mensaje Walkietask',
      },
      "priority" : "high",
      "data" : {
        "click_action" : "FLUTTER_NOTIFICATION_CLICK",
        "table" : "sms",
        "description": description,
      },
      "to" : "$to"
    });
    var response;
    try{
      response = await http.post(
          url,
          headers: requestHeaders,
          body: msg
      );
    }catch(ex){
      print(ex.toString());
    }
    return response;
  }
}