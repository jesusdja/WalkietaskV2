import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpPushNotifications{

  Future<http.Response> httpSendMessagero(String to, String idDoc,{String description : ''}) async{
    var url = "https://fcm.googleapis.com/fcm/send";

    Map<String, String> requestHeaders = {
      'Content-Type' : 'application/json',
      'Authorization': 'key=AAAAchi7p6U:APA91bHYqqePapeybZ089xYX45qbm1qWbNP0zF7FGOBpjGNqsaNz1a7mvADEBWSn1PA9ikdav2wxGr_3MtTw4ruCapHKeUrD4__BY89_sPBWlXJfcTnzD94e-mL506Pt15BpwLV-vAKL'
    };

    String sms = 'Nuevo mensaje: $description';
    if(description.length > 20){
      sms = 'Nuevo mensaje: ${description.substring(0,19)}...';
    }

    // final msg = jsonEncode({
    //   "title": "Este es el titulo",
    //   "body": "Este es el body",
    //   "color": "#4EA0F0",
    //   "sound": "default",
    //   "tag": "noti1",
    //   "click_action": "FLUTTER_NOTIFICATION_CLICK",
    //   "channel_id": "1",
    //   "local_only": true,
    //   "notification_priority": "PRIORITY_MAX",
    //   "default_sound": true,
    //   "default_vibrate_timings": true,
    //   "default_light_settings": true,
    //   "notification_count": 1,
    // });

    final msg = jsonEncode({
      "notification": {
        "body" : sms,
        "sound":"default",
        "channel_id" : "CHAT_MESSAGES",
      },
      "priority":"high",
      "data" : {
        "click_action" : "FLUTTER_NOTIFICATION_CLICK",
        "table" : "sms",
        "description": description,
        "idDoc": idDoc,
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