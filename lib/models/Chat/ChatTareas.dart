class ChatTareas{
  String id;
  String idTarea;
  String idUser;
  String idFromUser;
  Map<dynamic,dynamic> mensajes;
  Map userFrom;
  Map task;

  ChatTareas ({
    this.id,
    this.idTarea,
    this.idUser,
    this.idFromUser,
    this.mensajes,
    this.userFrom,
    this.task,
  });

  ChatTareas.maps(dynamic obj) {
    this.id = obj["id"];
    this.idTarea = obj["idTarea"];
    this.idUser = obj["idUser"];
    this.idFromUser = obj["idFromUser"];
    this.mensajes = obj["mensajes"];
  }

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  toJson(){
    return{
      "id": id,
      "idTarea": idTarea,
      "idUser": idUser,
      "idFromUser": idFromUser,
      "mensajes": mensajes,
      "userFrom" : userFrom,
      "task" : task
    };
  }
  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  ChatTareas.fromMap(Map snapshot) :
        id = snapshot["id"],
        idTarea = snapshot["idTarea"],
        idUser = snapshot["idUser"],
        idFromUser = snapshot["idFromUser"],
        mensajes = snapshot["mensajes"],
        task = snapshot["task"],
        userFrom = snapshot["userFrom"]
  ;
}