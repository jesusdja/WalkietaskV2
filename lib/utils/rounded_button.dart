import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class RoundedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double height;
  final double width;
  final double textSize;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool bold;
  final EdgeInsets margin;
  final EdgeInsets titlePadding;
  final IconData icon;
  final double radius;
  final TextStyle textStyle;

  RoundedButton({
    @required this.title,
    @required this.onPressed,
    this.bold = false,
    this.icon,
    this.height,
    this.width,
    this.textSize = 16.0,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.black,
    this.margin = const EdgeInsets.all(0.0),
    this.titlePadding = const EdgeInsets.all(0.0),
    @required this.radius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {

    TextStyle textStyleLocal = textStyle ?? WalkieTaskStyles().styleHelveticaneueRegular();

    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: WalkieTaskColors.primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: titlePadding,
              child: icon != null
                  ? Icon(
                      icon,
                      color: textColor,
                    )
                  : Text(
                      title,
                      style: textStyleLocal,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
