class ChatTareas{
  String id;
  String idTarea;
  Map<dynamic,dynamic> mensajes;

  ChatTareas ({
    this.id,
    this.idTarea,
    this.mensajes,
  });

  ChatTareas.map(dynamic obj) {
    this.id = obj["id"];
    this.idTarea = obj["idTarea"];
    this.mensajes = obj["mensajes"];
  }

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  toJson(){
    return{
      "id": id,
      "idTarea": idTarea,
      "mensajes": mensajes,
    };
  }
  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  ChatTareas.fromMap(Map snapshot) :
        id = snapshot["id"],
        idTarea = snapshot["idTarea"],
        mensajes = snapshot["mensajes"]
  ;
}