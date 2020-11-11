import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Register/widgets/form_register.dart';

class RegisterCode extends StatefulWidget {
  @override
  _RegisterCodeState createState() => _RegisterCodeState();
}

class _RegisterCodeState extends State<RegisterCode> {

  double sizeH = 0;
  double sizeW = 0;

  bool isLoad = false;
  bool isAccepted = false;

  FocusNode focusNode_1 = FocusNode();
  FocusNode focusNode_2 = FocusNode();
  FocusNode focusNode_3 = FocusNode();
  FocusNode focusNode_4 = FocusNode();

  TextEditingController controller_1 = TextEditingController();
  TextEditingController controller_2 = TextEditingController();
  TextEditingController controller_3 = TextEditingController();
  TextEditingController controller_4 = TextEditingController();

  Map<int,bool> mapCode = {
    1: false, 2: false, 3: false, 4: false,
  };
  Map<int,String> mapCodeStrg = {
    1: '', 2: '', 3: '', 4: '',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller_1 = TextEditingController(text: '');
    controller_2 = TextEditingController(text: '');
    controller_3 = TextEditingController(text: '');
    controller_4 = TextEditingController(text: '');
  }

  @override
  void dispose() {
    super.dispose();
    focusNode_1.dispose();
    focusNode_2.dispose();
    focusNode_3.dispose();
    focusNode_4.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sizeH = MediaQuery.of(context).size.height;
    sizeW = MediaQuery.of(context).size.width;

    TextStyle textStyle1 = WalkieTaskStyles().styleNunitoRegular(size: sizeH * 0.02);

    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      appBar: appBarWidget( sizeH,()=>Navigator.of(context).pop(),'Activa tu cuenta'),
      body: Container(
        margin: EdgeInsets.only(left: 24,right: 24),
        height: sizeH,
        width: sizeW,
        child: isLoad
            ? Center(
          child: CircularProgressIndicator(),
        )
            : GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            margin: EdgeInsets.only(left: 3, right: 3),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Container(
                    width: sizeW,
                    child: Text(
                      'Para activar tu cuenta hemos enviado un correo a usuario@email.com con un número de activación.\nDigitalo aquí:',
                      style: textStyle1,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: sizeH * 0.06,),
                  _insertCode(),
                  SizedBox(height: sizeH * 0.08,),
                  _buttonPressSaveUser(),
                  SizedBox(height: sizeH * 0.04,),
                  Container(
                    width: sizeW,
                    child: Text(
                      '¿No recibiste el email?\nRevisa tu carpeta de SPAM',
                      style: textStyle1,
                      textAlign: TextAlign.center,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonPressSaveUser(){
    return Container(
      width: sizeW,
      child: Center(
        child: isAccepted ?
        CircularProgressIndicator()
            :
        RoundedButton(
          borderColor: WalkieTaskColors.primary,
          width: sizeW * 0.2,
          height: sizeH * 0.05,
          radius: 5.0,
          title: 'Aceptar',
          textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: sizeH * 0.02, color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
          backgroundColor: WalkieTaskColors.primary,
          onPressed: () async{
            setState(() {
              isAccepted = true;
            });
            await Future.delayed(Duration(seconds: 3));
            setState(() {
              isAccepted = false;
            });
            // Navigator.push(context, new MaterialPageRoute(
            //     builder: (BuildContext context) => new RegisterCode()));
          },
        ),
      ),
    );
  }

  Widget _insertCode(){
    return Container(
      width: sizeW,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _containerNumber(1, focusNode_1, controller_1),
          _containerNumber(2, focusNode_2, controller_2),
          _containerNumber(3, focusNode_3, controller_3),
          _containerNumber(4, focusNode_4, controller_4),
        ],
      ),
    );
  }

  Widget _containerNumber(int index, FocusNode focusNode, TextEditingController controller){
    TextStyle textStyle2 = WalkieTaskStyles().styleNunitoRegular(size: sizeH * 0.065,color: WalkieTaskColors.primary);
    return Container(
      width: sizeW * 0.12,
      height: sizeH * 0.09,
      margin: EdgeInsets.only(left: sizeW * 0.02, right: sizeW * 0.02),
      child: TextFildGeneric(
        labelStyle: textStyle2,
        focusNode: focusNode,
        initialValue: null,
        textEditingController: controller,
        onTap: () => onTapCode(index),
        onChanged: (String value) => onChange(index, value),
        sizeW: sizeW,
        sizeH: sizeH,
        sizeHeight: sizeH * 0.045,
        borderColor: mapCode[index] ? WalkieTaskColors.primary : WalkieTaskColors.color_B7B7B7 ,
        boxShadow: mapCode[index] ? <BoxShadow>[
          BoxShadow(
              color: WalkieTaskColors.primary,
              blurRadius: 3.0,
              offset: Offset(0.0, 0.0)
          )
        ] : null,
        sizeBorder: 1.0
      ),
    );
  }

  void onChange(int index, String value){
    if(value.length > 1){
      FocusScope.of(context).requestFocus(new FocusNode());
      if(index == 1){ controller_1.text = value.substring(0,1); }
      if(index == 2){ controller_2.text = value.substring(0,1); }
      if(index == 3){ controller_3.text = value.substring(0,1); }
      if(index == 4){ controller_4.text = value.substring(0,1); }

    }else{
      if(value.isEmpty){
        mapCode[index] = false;
        if(index == 1){
          FocusScope.of(context).requestFocus(new FocusNode());
        }
        if(index == 2){
          focusNode_1.requestFocus();
        }
        if(index == 3){
          focusNode_2.requestFocus();
        }
        if(index == 4){
          focusNode_3.requestFocus();
        }
      }else{
        mapCode[index] = true;
        if(index == 1){
          focusNode_2.requestFocus();
        }
        if(index == 2){
          focusNode_3.requestFocus();
        }
        if(index == 3){
          focusNode_4.requestFocus();
        }
        if(index == 4){
          FocusScope.of(context).requestFocus(new FocusNode());
        }
      }
    }
    setState(() {});
  }

  void onTapCode(int index){
    if(index == 1){
      if(mapCode[2] ||mapCode[3] ||mapCode[4] ){
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    }
    if(index == 2){
      if(mapCode[3] || mapCode[4] || !mapCode[1]){
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    }
    if(index == 3){
      if(mapCode[4] || !mapCode[1] || !mapCode[2]){
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    }
    if(index == 4){
      if(!mapCode[3]){
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    }
  }

  Widget appBarWidget(double sizeH,Function() onTap,String title){
    return AppBar(
      leading: InkWell(
        child: Icon(Icons.arrow_left,size: sizeH * 0.07,color: WalkieTaskColors.white,),
        onTap: onTap,
      ),
      title: Text(title,style: WalkieTaskStyles().styleNunitoBold()),
    );
  }
}
