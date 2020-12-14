import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';

class TextFildGenericVerific extends StatelessWidget {
  final String placeHolder;
  final IconData icon;
  final bool obscure;
  final int maxLines;
  final Color borderColor;
  final TextEditingController textEditingController;
  final bool autoCorrect;
  final void Function(String) onChanged;
  final String Function(String) validator;
  final TextInputType textInputType;
  final bool autoValidate;
  final String initialValue;
  final double sizeH;
  final double sizeW;
  final int check;
  final double sizeHeight;
  final FocusNode focusNode;

  TextFildGenericVerific({
    this.initialValue = '',
    this.placeHolder,
    this.icon,
    this.borderColor,
    this.textEditingController,
    this.onChanged,
    this.validator,
    this.textInputType,
    this.autoCorrect = false,
    this.obscure = false,
    this.autoValidate = false,
    this.maxLines = 1,
    @required this.sizeH,
    @required this.sizeW,
    @required this.check,
    this.focusNode,
    this.sizeHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    double radius = 5.0;

    Widget widgetIcons = Container();
    if(check == 1){
      widgetIcons = Icon(Icons.check,color: Colors.green,);
    }
    if(check == 2){
      widgetIcons = Icon(Icons.clear,color: Colors.red,);
    }
    if(check == 3){
      widgetIcons = Container(
        width: sizeH * 0.03,
        height: sizeH * 0.03,
        child: Center(child: CircularProgressIndicator(),),
      );
    }

    return Container(
      width: sizeW,
      height: sizeHeight == 0 ? sizeH * 0.045 : sizeHeight,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: new Border.all(
          width: 2.0,
          color: WalkieTaskColors.grey,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              focusNode: focusNode,
              style: TextStyle(height: 1.5),
              initialValue: initialValue,
              maxLines: maxLines,
              obscureText: obscure,
              enabled: true,
              controller: textEditingController,
              onChanged: onChanged,
              autocorrect: autoCorrect,
              validator: validator,
              keyboardType: textInputType,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  borderSide: BorderSide(
                    width: 0.0,
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  borderSide: BorderSide(
                    width: 0.0,
                    color: Colors.transparent,
                  ),
                ),
                labelText: placeHolder,
                labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                errorStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                prefixIcon: icon != null ? Icon(
                  icon,
                  size: 15.0,
                  color: WalkieTaskColors.black,
                ) : null,
                  contentPadding:EdgeInsets.symmetric(horizontal: sizeW * 0.01, vertical: sizeH * 0.001)
              ),
            ),
          ),
          widgetIcons
        ],
      ),
    );
  }
}
