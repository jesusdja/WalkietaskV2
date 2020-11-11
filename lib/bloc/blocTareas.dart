import 'dart:async';

class BlocTask {

  var _PatronController = StreamController<bool>.broadcast();
  Stream<bool> get outList => _PatronController.stream;
  Sink<bool> get inList => _PatronController.sink;

//  Future getList() async{
//    conexionHttp conexionHispanos = new conexionHttp();
//    List<Tarea> listRelacion = new List<Tarea>();
//
//    //await Future.delayed(Duration(seconds: 50));
//
//    var response = await conexionHispanos.httpListTareasRecibidas();
//    var value = jsonDecode(response.body);
//    List<dynamic> tareas = value["tasks"];
//    for(int x = 0; x < tareas.length; x++){
//      Tarea tarea = Tarea.fromJson(tareas[x]);
//      listRelacion.add(tarea);
//    }
//    inList.add(listRelacion);
//  }

  BlocTask(){
    //getList();
  }

  @override
  void dispose() {
    _PatronController.close();
  }
}