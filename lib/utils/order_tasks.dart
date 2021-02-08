import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class OrderTask {

  Future<List<Tarea>> orderListReceived(List<Tarea> listTask) async {
    List listStringIdOrder = await SharedPrefe().getValue('listOrderRecived');
    List listStringIdOrderDate = await SharedPrefe().getValue('listOrderRecivedDate');
    Map<int,int> noEstanGuardarPosicion = {};

    if(listStringIdOrder == null || listStringIdOrderDate == null){
      return listTask;
    }

    Map<int,Tarea> tasksMap = {};

    for(int x = 0; x < listTask.length; x++){
      tasksMap[listTask[x].id] = listTask[x];
      bool entre = false;
      for(int xy = 0; xy < listStringIdOrder.length; xy++){
        if(listStringIdOrder[xy] == listTask[x].id.toString()){
          if(listStringIdOrderDate[xy] == listTask[x].updated_at){
            entre = true;
          }
        }
      }
      if(!entre){
        noEstanGuardarPosicion[listTask[x].id] = x;
      }
    }

    List<Tarea> listOrder = [];
    noEstanGuardarPosicion.forEach((key, value) {
      listOrder.add(tasksMap[key]);
    });

    for(int x = 0; x < listStringIdOrder.length; x++){
      if(noEstanGuardarPosicion[int.parse(listStringIdOrder[x])] == null){
        listOrder.add(tasksMap[int.parse(listStringIdOrder[x])]);
      }
    }

    List<String> listOrderFavorite = [];
    List<String> listOrderDate = [];
    List<Tarea> listDefinitive = [];
    listOrder.forEach((element) {
      if(element != null && element.is_priority_responsability == 1){
        listDefinitive.add(element);
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    listOrder.forEach((element) {
      if(element != null && element.is_priority_responsability == 0){
        listDefinitive.add(element);
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    await SharedPrefe().setStringListValue('listOrderRecived', listOrderFavorite);
    await SharedPrefe().setStringListValue('listOrderRecivedDate', listOrderDate);

    return listDefinitive;
  }

  Future<List<Tarea>> orderListSend(List<Tarea> listTask) async {
    List listStringIdOrder = await SharedPrefe().getValue('listOrderSend');
    List listStringIdOrderDate = await SharedPrefe().getValue('listOrderSendDate');
    Map<int,int> noEstanGuardarPosicion = {};

    if(listStringIdOrder == null || listStringIdOrderDate == null){
      return listTask;
    }

    Map<int,Tarea> tasksMap = {};

    for(int x = 0; x < listTask.length; x++){
      tasksMap[listTask[x].id] = listTask[x];
      bool entre = false;
      for(int xy = 0; xy < listStringIdOrder.length; xy++){
        if(listStringIdOrder[xy] == listTask[x].id.toString()){
          if(listStringIdOrderDate[xy] == listTask[x].updated_at){
            entre = true;
          }
        }
      }
      if(!entre){
        noEstanGuardarPosicion[listTask[x].id] = x;
      }
    }

    List<Tarea> listOrder = [];
    noEstanGuardarPosicion.forEach((key, value) {
      listOrder.add(tasksMap[key]);
    });

    for(int x = 0; x < listStringIdOrder.length; x++){
      if(noEstanGuardarPosicion[int.parse(listStringIdOrder[x])] == null){
        listOrder.add(tasksMap[int.parse(listStringIdOrder[x])]);
      }
    }

    List<String> listOrderFavorite = [];
    List<String> listOrderDate = [];
    List<Tarea> listDefinitive = [];
    listOrder.forEach((element) {
      if(element != null && element.is_priority == 1){
        listDefinitive.add(element);
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    listOrder.forEach((element) {
      if(element != null && element.is_priority == 0){
        listDefinitive.add(element);
        listOrderFavorite.add(element.id.toString());
        listOrderDate.add(element.updated_at);
      }
    });
    await SharedPrefe().setStringListValue('listOrderSend', listOrderFavorite);
    await SharedPrefe().setStringListValue('listOrderSendDate', listOrderDate);
    return listDefinitive;
  }
}