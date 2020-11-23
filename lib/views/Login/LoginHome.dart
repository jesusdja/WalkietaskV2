import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Permisos.dart';
import 'package:walkietaskv2/services/auth.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Login/widgets/recover_password.dart';
import 'package:walkietaskv2/views/Register/register_page.dart';

class LoginHome extends StatefulWidget {
  @override
  _LoginHomeState createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {

  double alto = 0;
  double ancho = 0;
  String nombre = '';
  String pasw = '';
  bool cargando = false;
  final formKey = GlobalKey<FormState>();
  SharedPreferences prefs;

  @override
  void initState() {
    inicializar();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  inicializar() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<bool> exit() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        child: cargando ? Cargando('Verificando datos',context) :
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: alto * 0.1,),
              _logo(),
              SizedBox(height: alto * 0.2,),
              _form(),
              SizedBox(height: alto * 0.15,),
              _viewRegistre(context),
            ],
          ),
        ),
        onWillPop: exit
      ),
    );
  }

  Widget _viewRegistre(BuildContext contextLogin) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '¿No tenés cuenta?',
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
          ),
          InkWell(
            child: Text('creala aquí. Es gratis.',
              style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
            ),
            onTap: () {
              Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context2) => new RegisterPage(contextLogin: contextLogin,)));
            },
          ),
        ],
      ),
    );
  }

  TextEditingController _email = new TextEditingController();

  Widget _form(){
    return Container(
      margin: EdgeInsets.only(left: ancho * 0.05,right: alto * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: widget.key,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        child: Text('Correo:',
                          style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.027),
                        )
                    ),
                    SizedBox(height: alto * 0.04,),
                    Container(
                      child: Text('Contraseña:',
                        style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.027),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: TextFildGeneric(
                          onChanged: (text) {
                            nombre = text;
                            setState(() {});
                          },
                          labelStyle: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.025),
                          textInputType: TextInputType.emailAddress,
                          sizeH: alto,
                          sizeW: ancho,
                          borderColor: WalkieTaskColors.color_B7B7B7,
                          sizeHeight: alto * 0.045,
                          textAlign: TextAlign.left,
                          textEditingController: _email,
                          initialValue: null,
                        ),
                      ),
                      SizedBox(height: alto * 0.025,),
                      Container(
                        child: TextFildGeneric(
                          labelStyle: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.025),
                          onChanged: (text) {
                            pasw = text;
                            setState(() {});
                          },
                          obscure: true,
                          sizeH: alto,
                          sizeW: ancho,
                          borderColor: WalkieTaskColors.color_B7B7B7,
                          sizeHeight: alto * 0.045,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: alto * 0.02,),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: ancho * 0.08,
              width: ancho * 0.3,
              alignment: Alignment.centerRight,
              child: cargando
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  :
              RoundedButton(
                backgroundColor: WalkieTaskColors.primary,
                title: 'Entrar',
                onPressed: () => _save(),
                radius: 5.0,
                textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022,color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: alto * 0.01,),
          Container(
            width: ancho,
            child: InkWell(
              child: Text(
                '¿Olvidaste tu clave?',
                style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.022),
                textAlign: TextAlign.right,
              ),
              onTap: () async {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new RecoverPassword()));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _logo(){
    return Container(
      width: ancho * 0.7,
      height: alto * 0.25,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ViewImage().assetsImage("assets/image/LogoWN.png").image,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  conexionHttp conexionHispanos = new conexionHttp();
  Future<void> _save() async{
    setState(() { cargando = true; });
    if (nombre.isNotEmpty && pasw.isNotEmpty){
//          nombre = 'daniel.penya@imprevia.com';
//          nombre = 'jesus.cortez.1991@gmail.com';
//          pasw = '*Jc0473z01#';

      // nombre = 'ra@imprevia.com';
      // pasw = '*@Dmin1#';

      try{
        var response = await conexionHispanos.httpIniciarSesion(nombre,pasw);
        var value = jsonDecode(response.body);
        if(value['access_token'] != null){

          String token = value['access_token'];
          String tokenExp = value['access_token'];
          await prefs.setString('unityToken','$token');
          await prefs.setString('unityTokenExp','$tokenExp');

          UpdateData updateData = new UpdateData();
          Usuario myUser = await updateData.getMyUser();
          if(myUser != null){

            int userCheck = 1;
            var response3 = await conexionHispanos.httpCheckUser(nombre);
            var value3 = jsonDecode(response3.body);
            if(value3['status_code'] == 500){
              userCheck = 2;
            }
            if(value3['status_code'] != 500 && value3['status_code'] != 200){
              userCheck = 0;
              showAlert('Codigo vencido. Registrar nuevamente.',Colors.red[400]);
              await Future.delayed(Duration(seconds: 3));
            }
            await prefs.setInt('unityLogin',userCheck);
            await SharedPrefe().setStringValue('unityEmail',myUser.email);
            await prefs.setString('unityIdMyUser','${myUser.id}');
            await PermisoStore();
            await PermisoSonido();
            await PermisoPhotos();
            try{
              AuthService auth = Provider.of<AuthService>(context);
              auth.init();
            }catch(ex){
              print(ex);
            }
          }else{
            print('No se encontro mi usuario');
            showAlert('Error en conexión',Colors.red[400]);
            cargando = false;
            setState(() {});
          }
        }
        if(value['message'] != null){
          showAlert(value['message'],Colors.red[400]);
          cargando = false;
          setState(() {});
        }
      }catch(e){
        print(e.toString());
        showAlert('Error en conexión',Colors.red[400]);
        cargando = false;
        setState(() {});
      }
    }else{
      showAlert('Campos no pueden estar vacios.!',Colors.red[400]);
      setState(() {
        cargando = false;
      });
    }
  }
}
