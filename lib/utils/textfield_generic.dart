import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';

class TextFildGeneric extends StatelessWidget {
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
  final FocusNode focusNode;
  final void Function() onTap;
  final void Function(String) onFieldSubmitted;
  final double sizeHeight;
  final TextAlign textAlign;
  final TextStyle labelStyle;
  final List<BoxShadow> boxShadow;
  final double sizeBorder;
  final Widget suffixIcon;

  TextFildGeneric({
    this.initialValue = '',
    this.placeHolder,
    this.icon,
    this.borderColor = WalkieTaskColors.grey,
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
    this.focusNode,
    this.onTap,
    this.onFieldSubmitted,
    this.sizeHeight = 0,
    this.textAlign = TextAlign.left,
    this.labelStyle = const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
    this.boxShadow,
    this.sizeBorder = 2.0,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    double radius = 5.0;
    return Container(
      height: sizeHeight == 0 ? sizeH * 0.06 : sizeHeight,
      padding: EdgeInsets.only(left: 5),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: new Border.all(
          width: sizeBorder,
          color: borderColor,
        ),
        boxShadow: boxShadow,
      ),
      child: TextFormField(
        onFieldSubmitted: onFieldSubmitted,
        onTap: onTap,
        style: labelStyle,
        textAlign: textAlign,
        initialValue: initialValue,
        maxLines: maxLines,
        obscureText: obscure,
        enabled: true,
        controller: textEditingController,
        onChanged: onChanged,
        autocorrect: autoCorrect,
        validator: validator,
        autovalidate: autoValidate,
        keyboardType: textInputType,
        focusNode: focusNode,
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
          suffixIcon: suffixIcon,
          labelText: placeHolder,
          labelStyle: labelStyle,
          errorStyle: labelStyle,
          prefixIcon: icon != null ? Icon(
            icon,
            size: 15.0,
            color: WalkieTaskColors.black,
          ) : null,
          contentPadding:EdgeInsets.symmetric(horizontal: sizeW * 0.01, vertical: sizeH * 0.001)
        ),
      ),
    );
  }
}
