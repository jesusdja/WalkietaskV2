import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class ChatProject extends StatefulWidget {
  @override
  _ChatProjectState createState() => _ChatProjectState();
}

class _ChatProjectState extends State<ChatProject> {

  double alto = 0;
  double ancho = 0;
  TextEditingController _controllerChatSms = TextEditingController();

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorChat,
      body: Stack(
        children: [
          messages(),
          Positioned.fill(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: _textFieldSend(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFieldSend(){

    var styleBorder = const OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: const BorderRadius.all(const Radius.circular(15.0),),
    );

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ancho * 0.1,
            height: alto * 0.1,
            color: Colors.red,
          ),
          Container(
            color: colorFondoSend,
            constraints: BoxConstraints(minHeight: alto * 0.07,maxHeight: alto * 0.15),
            child: Row(
              children: <Widget>[
                Container(
                  child: IconButton(
                    icon: Icon(Icons.add_circle_outline,color: WalkieTaskColors.color_4D9DFA,),
                    onPressed: (){},
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: ancho * 0.02,right: ancho * 0.02,top: alto * 0.01, bottom: alto * 0.01),
                    child: TextField(
                      controller: _controllerChatSms,
                      maxLines: null,
                      onTap: (){},
                      style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D,spacing: 1,fontWeight: FontWeight.bold),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: new InputDecoration(
                          focusedBorder: styleBorder,
                          enabledBorder: styleBorder,
                          border: styleBorder,
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding:EdgeInsets.symmetric(horizontal: ancho * 0.05, vertical: alto * 0.013)
                      ),
                    ),
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: Icon(Icons.send,color: WalkieTaskColors.color_4D9DFA,),
                    onPressed: (){},
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget messages(){
    return Container(
      width: ancho,
      height: alto * 0.9,
      margin: EdgeInsets.only(bottom: alto * 0.06),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(width: ancho,height: alto * 0.1,color: Colors.teal,),
            Container(width: ancho,height: alto * 0.1,color: Colors.white,),
            Container(width: ancho,height: alto * 0.1,color: Colors.teal,),
            Container(width: ancho,height: alto * 0.1,color: Colors.white,),
            Container(width: ancho,height: alto * 0.1,color: Colors.teal,),
            Container(width: ancho,height: alto * 0.1,color: Colors.white,),
            Container(width: ancho,height: alto * 0.1,color: Colors.teal,),
            Container(width: ancho,height: alto * 0.1,color: Colors.white,),
            Container(width: ancho,height: alto * 0.1,color: Colors.teal,),
            Container(width: ancho,height: alto * 0.1,color: Colors.white,),
          ],
        ),
      ),
    );
  }


}
