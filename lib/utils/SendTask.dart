import 'dart:convert';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';

Future<bool> sendTask(Tarea tarea) async {
  conexionHttp conexionHispanos = new conexionHttp();
  try{

    var response = await conexionHispanos.httpCrearTarea({});
    var value = jsonDecode(response.body);

    if(value['status_code'] == 201){
      return true;
    }else{
      return false;
    }
  }catch(e){
    print(e.toString());
  }
  return false;
}