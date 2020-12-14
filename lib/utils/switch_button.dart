import 'package:flutter/material.dart';

class CustomSwitchLocal extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double sizeW;
  final double sizeH;
  final double sizeCircule;
  final Color colorBgOn;
  final Color colorBgOff;

  CustomSwitchLocal({
    Key key,
    this.value,
    this.onChanged,
    this.sizeH : 28.0,
    this.sizeW : 45.0,
    this.sizeCircule : 20.0,
    this.colorBgOn : Colors.blue,
    this.colorBgOff : Colors.grey,
  }): super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitchLocal>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    AlignmentTween(
        begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        end: widget.value ? Alignment.centerLeft :Alignment.centerRight).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false
                ? widget.onChanged(true)
                : widget.onChanged(false);
          },
          child: Container(
            width: widget.sizeW,
            height: widget.sizeH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              color: widget.value ? widget.colorBgOn : widget.colorBgOff,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 2.0, right: 2.0, left: 2.0),
              child:  Container(
                alignment: widget.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: widget.sizeCircule,
                  height: widget.sizeCircule,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
