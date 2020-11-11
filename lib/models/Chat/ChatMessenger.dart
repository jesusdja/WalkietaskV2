class ChatMessenger{
  String texto;
  String fecha;
  String hora;
  String from;

  ChatMessenger ({
    this.texto,
    this.fecha,
    this.hora,
    this.from,
  });

  ChatMessenger.map(dynamic obj) {
    this.texto = obj["texto"];
    this.fecha = obj["fecha"];
    this.hora = obj["hora"];
    this.from = obj["from"];
  }

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  toJson(){
    return{
      "texto": texto,
      "fecha": fecha,
      "hora": hora,
      "from": from,
    };
  }
  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  ChatMessenger.fromMap(Map snapshot) :
     texto = snapshot["texto"],
     fecha = snapshot["fecha"],
     hora = snapshot["hora"],
     from = snapshot["from"]
  ;
}