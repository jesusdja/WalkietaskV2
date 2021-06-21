import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as pathServide;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/upload_background_documents.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/gallery_camera_dialog.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/proyects/add_proyects.dart';

class EditProject extends StatefulWidget {

  EditProject({
    @required this.project,
    @required this.widgetHome,
    @required this.blocCasos,
    @required this.myUser,
  });

  final Caso project;
  final Map<String,dynamic> widgetHome;
  final BlocCasos blocCasos;
  final Usuario myUser;

  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {

  final controllerPage = PageController(initialPage: 0,);

  double alto = 0;
  double ancho = 0;
  String idMyUser = '0';
  Caso project;
  Map<String,dynamic> widgetHome;
  List<Usuario> listUser = [];
  List<Usuario> usersForProject = [];
  bool loadData = true;
  bool isCreateProject = false;
  String photoProjectAvatar;
  StreamSubscription streamSubscriptionCasos;
  Map<int,bool> mapDeleteLoad = {};
  bool deleteProjectLoad = false;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    widgetHome = widget.widgetHome;
    initialUser();
    _inicializarPatronBlocCasos();
  }

  @override
  void dispose() {
    super.dispose();
    controllerPage.dispose();
    streamSubscriptionCasos?.cancel();
  }

  initialUser() async {
    if(project != null){
      idMyUser = await SharedPrefe().getValue('unityIdMyUser');
      isCreateProject = project.user_id.toString() == idMyUser;
      listUser = await DatabaseProvider.db.getAllUser();
      usersForProject = [];
      String usersProjects = project.userprojects ?? '';
      List<String> data = usersProjects.split('|');
      data.forEach((idUserProject) {
        if(idUserProject != idMyUser){
          listUser.forEach((element) {
            if(element.id.toString() == idUserProject && mapDeleteLoad[element.id] == null){
              usersForProject.add(element);
              mapDeleteLoad[element.id] = false;
            }
          });
        }
      });

      photoProjectAvatar = await SharedPrefe().getValue('${project.id}Photo');

      loadData = false;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: _appBarH(),
        body: project == null ? Container() : body(),
      )
    );
  }

  Widget _appBarH(){
    String nombreUser = project == null ? '' : project.name ?? '';
    return AppBar(
      leading: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
        },
        child: Container(
          child: Center(
            child: Container(
              width: ancho * 0.1,
              height: alto * 0.06,
              child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Container(
          width: ancho,
          child: Row(
            children: <Widget>[
              Container( width: ancho * 0.1, ),
              Expanded(
                child: Text('$nombreUser',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_3C3C3C),textAlign: TextAlign.center,),
              ),
              Center(
                child: InkWell(
                  child: Container(
                    margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.02),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
      elevation: 0,
      backgroundColor: colorFondoChat,
    );
  }

  Widget body(){
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        width: ancho,
        child: Column(
          children: [
            photoProject(),
            Container(
              width: ancho,
              margin: EdgeInsets.only(left: ancho * 0.05),
              child: Text('${translate(context: context,text: 'members')}:',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02),),
            ),
            !isCreateProject ? Container(
            width: ancho,
             height: alto * 0.02,
            ) : InkWell(
              child: Container(
                width: ancho,
                margin: EdgeInsets.only(right: ancho * 0.05, left: ancho * 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.add_circle_outline,size: alto * 0.03,color: WalkieTaskColors.primary,),
                    Text('${translate(context: context,text: 'add')}',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.024,color: WalkieTaskColors.primary),)
                  ],
                ),
              ),
              onTap: () => addUserProject(),
            ),
            loadData ?
            Container(
              width: ancho,
              height: alto * 0.5,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ) :
            listUsersView(),
            !isCreateProject ? Container() :
            deleteProjectLoad ?
            Container(
              width: ancho,
              margin: EdgeInsets.symmetric(horizontal: ancho * 0.3,vertical: alto * 0.04),
              child: Center(
                child: Container(
                  width: ancho * 0.06,
                  height: alto * 0.03,
                  child: Center(child: CircularProgressIndicator(),),
                ),
              ),
            ) :
            Container(
              width: ancho,
              margin: EdgeInsets.symmetric(horizontal: ancho * 0.3,vertical: alto * 0.04),
              child: RoundedButton(
                backgroundColor: WalkieTaskColors.color_E07676,
                title: '${translate(context: context,text: 'delete')} ${translate(context: context,text: 'projects').replaceAll('s','')}',
                onPressed: () => deleteProject(),
                radius: 5.0,
                height: alto * 0.04,
                textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget photoProject(){

    Widget avatar = avatarWidgetProject(alto: alto, radius: 0.13, text: '${project.name.isEmpty ? '' : project.name.substring(0,1).toUpperCase()}',);
    if(project.image_500 != null && project.image_500.isNotEmpty){
      avatar = avatarWidgetImage(alto: alto, radius: 0.13, pathImage: project.image_500);
    }
    if(photoProjectAvatar !=null && photoProjectAvatar.isNotEmpty){
      avatar = avatarWidgetImageLocal(alto: alto, radius: 0.13,pathImage: photoProjectAvatar);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: alto * 0.05,horizontal: ancho * 0.1),
      child: InkWell(
        radius: alto * 0.035,
        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                decoration: new BoxDecoration(
                  color: bordeCirculeAvatar, // border color
                  shape: BoxShape.circle,
                ),
                child: avatar,
              ),
            ),
            !isCreateProject ? Container() : Container(
              width: ancho,
              height: alto * 0.25,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(right: ancho * 0.15),
                  child: CircleAvatar(
                    backgroundColor: WalkieTaskColors.primary,
                    radius: alto * 0.035,
                    child: Padding(
                      padding: EdgeInsets.all(alto * 0.003),
                      child: CircleAvatar(
                        backgroundColor: WalkieTaskColors.color_E8F4FA,
                        radius: alto * 0.033,
                        child: Center(child: Icon(Icons.camera_alt_outlined,color: WalkieTaskColors.primary,size: alto * 0.035,)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: isCreateProject ? () => _onTapPhoto() : null,
      ),
    );
  }

  void _onTapPhoto(){
    final callback = Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => GalleryCameraDialog(
          isVideo: false,
        ))
    );
    callback.then((media) async {
      if(media != null) {
        PickedFile _imageFile = media as PickedFile;
        File croppedImage = await ViewImage().croppedImageView(_imageFile.path, cropStyle: CropStyle.circle);
        if(croppedImage != null){
          try{
            File fileSave = File(croppedImage.path);
            Directory directory = await getApplicationDocumentsDirectory();
            String _fileNameAdjunto = croppedImage.path.split('/').last;
            File fileNew = await fileSave.copy('${directory.path}/$_fileNameAdjunto');

            await SharedPrefe().setStringValue('${project.id}Photo', fileNew.path);
            photoProjectAvatar = croppedImage.path;
            setState(() {});
            widget.blocCasos.inList.add(true);

            List listA = await SharedPrefe().getValue('WalListPhotosProjects') ?? [];
            List<String> listB = [];
            listA.forEach((element) {listB.add(element);});
            listB.add('${project.id}|${croppedImage.path}|');
            await SharedPrefe().setStringListValue('WalListPhotosProjects',listB);
            uploadBackPhotoProjects();
          }catch(e){
            print('_onTapPhoto: ${e.toString()}');
          }
        }
      }
    },
    );
  }

  Widget listUsersView(){
    List<Widget> listW = [];
    usersForProject.forEach((user) {

      String userName = user != null ? user.name ?? '' : '';
      Widget avatarUserWidget = avatarWidget(alto: alto,text: userName.isEmpty ? '' : userName.substring(0,1).toUpperCase(),radius: 0.035);
      if(user != null){
        if(user != null && user.avatar_100 != ''){
          avatarUserWidget = avatarWidgetImage(alto: alto,pathImage: user.avatar_100,radius: 0.035);
        }
      }

      listW.add(
          Container(
            width: ancho,
            margin: EdgeInsets.only(top: alto * 0.015),
            child: Row(
              children: [
                avatarUserWidget,
                SizedBox(width: ancho * 0.03,),
                Expanded(
                  child: Text(userName,style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.024),textAlign: TextAlign.left,),
                ),
                !isCreateProject ? Container() :
                mapDeleteLoad[user.id] ?
                Container(
                  margin: EdgeInsets.only(right: ancho * 0.1),
                  child: Center(
                    child: Container(
                      height: alto * 0.03,
                      width: alto * 0.03,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ) :
                Container(
                  margin: EdgeInsets.only(right: ancho * 0.1),
                  child: InkWell(
                    radius: alto * 0.03,
                    child: Container(
                      padding: EdgeInsets.all(alto * 0.02),
                      child: Icon(Icons.delete_outline,size: alto * 0.04,color: WalkieTaskColors.color_E07676,),
                    ),
                    onTap: () => deleteUserProject(user.id),
                  ),
                ),
              ],
            ),
          )
      );

      listW.add(
          Container(
            width: ancho,
            height: alto * 0.002,
            margin: EdgeInsets.only(left: ancho * 0.13,top: alto * 0.02),
            color: WalkieTaskColors.grey,
          )
      );
    });


    return Container(
      width: ancho,
      constraints: BoxConstraints(minHeight: alto * 0.3 ),
      margin: EdgeInsets.only(left: ancho * 0.08),
      child: Column(
        children: listW,
      ),
    );
  }

  Future<void> addUserProject() async{
    List listU = [];
    usersForProject.forEach((element) {
      listU.add({'users' : element.toMap()});
    });
    listU.add({'users' : widget.myUser.toMap()});

    bool res = await Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) =>
        new AddProyects(
          myUserRes: widget.myUser,
          listUserRes: listUser,
          blocPage: null,
          proyect: project,
          listUsersExist: listU,
        )));
    if(res){
      updateDateProject(project.id);
    }
  }

  Future<void> deleteUserProject(int idUser) async{

    mapDeleteLoad[idUser] = true;
    setState(() {});

    //await Future.delayed(Duration(seconds: 3));

    try{
      var response = await conexionHttp().httpDeleteUserForProject(project.id,idUser);
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        updateDateProject(project.id);
      }else{
        showAlert(translate(context: context, text: 'connectionError'),WalkieTaskColors.color_E07676);
      }
    }catch(e){
      print(e.toString());
      showAlert(translate(context: context, text: 'connectionError'),WalkieTaskColors.color_E07676);
    }

    await Future.delayed(Duration(seconds: 2));

    mapDeleteLoad[idUser] = false;
    setState(() {});
  }

  Future<void> deleteProject() async{
    deleteProjectLoad = true;
    setState(() {});

    bool res = false;
    res = await alertDeleteElement(context, '¿${translate(context: context, text: 'sureDeleteProject')} "${project.name}"?');
    if(res != null && res){
      try{
        var response = await conexionHttp().httpDeleteProject(project.id);
        var value = jsonDecode(response.body);
        if(value['status_code'] == 200){
          int res = await DatabaseProvider.db.deleteProjectCase(project.id);
          if(res != 0){
            widget.blocCasos.inList.add(true);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        }else{
          showAlert(translate(context: context, text: 'connectionError'),WalkieTaskColors.color_E07676);
        }
      }catch(e){
        print(e.toString());
        showAlert(translate(context: context, text: 'connectionError'),WalkieTaskColors.color_E07676);
      }
    }
    deleteProjectLoad = false;
    if(mounted){
      setState(() {});
    }
  }

  Future<void> updateDateProject(int idPRojects) async{
    try{
      var response = await conexionHttp().httpUpdateDateProject(idPRojects);
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        UpdateData().actualizarCasos(widget.blocCasos);
      }
    }catch(e){
      print(e.toString());
    }
  }

  _inicializarPatronBlocCasos(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionCasos = widget.blocCasos.outList.listen((newVal) {
        if(newVal){
          updateProject();
        }
      });
    } catch (e) {}
  }

  updateProject() async {
    project = await  DatabaseProvider.db.getCodeIdCase(project.id.toString());
    setState(() {});
    initialUser();
  }
}

