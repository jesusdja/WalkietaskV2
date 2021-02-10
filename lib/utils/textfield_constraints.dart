import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';

class TextFieldConstraints extends StatelessWidget {
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
  final Widget prefixIcon;
  final bool enable;
  final EdgeInsetsGeometry padding;
  final TextCapitalization textCapitalization;
  final String hintText;
  final Color colorBack;
  final bool autofocus;
  final TextInputAction textInputAction;
  final double minHeight;
  final double maxHeight;

  TextFieldConstraints({
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
    this.sizeBorder = 1.2,
    this.suffixIcon,
    this.prefixIcon,
    this.enable = true,
    this.padding = const EdgeInsets.only(left: 5),
    this.textCapitalization = TextCapitalization.sentences,
    this.hintText = '',
    this.colorBack = Colors.white,
    this.autofocus = false,
    this.textInputAction,
    this.maxHeight,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    double radius = 5.0;
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ,maxHeight: maxHeight),
      padding: padding,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: colorBack,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: new Border.all(
          width: sizeBorder,
          color: borderColor,
        ),
        boxShadow: boxShadow,
      ),
      child: TextField(
        onTap: onTap,
        style: labelStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        obscureText: obscure,
        enabled: enable,
        controller: textEditingController,
        onChanged: onChanged,
        autocorrect: autoCorrect,
        keyboardType: textInputType,
        focusNode: focusNode,
        textCapitalization: textCapitalization,
        autofocus: autofocus,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: colorBack,
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
          hintText: hintText,
          hintStyle: labelStyle,
          prefixIcon: prefixIcon,
          contentPadding:EdgeInsets.symmetric(horizontal: sizeW * 0.01, vertical: sizeH * 0.005)
        ),
      ),
    );
  }
}
