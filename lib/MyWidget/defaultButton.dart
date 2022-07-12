import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {

  DefaultButton({this.color = const Color(0xFF469BA7 ), this.fontColor = Colors.white, this.onPressed, 
  this.text = '', this.radius = 5.0, this.height = 48, this.width = double.infinity, this.borderSide = BorderSide.none, this.fontsize = 18.0, this.fontWeight = FontWeight.w500});

  final Color color;
  final Color fontColor;
  final String text;
  final VoidCallback onPressed;
  final double radius;
  final double height;
  final double width;
  final BorderSide borderSide;
  final double fontsize;
  final FontWeight fontWeight;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration:  ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          side: borderSide,
          borderRadius: BorderRadius.circular(radius))),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(text, 
          style: TextStyle(
            color: fontColor,
            fontSize: fontsize, 
            fontWeight: fontWeight, 
            fontFamily: 'SpoqaHanSansNeo',
          ),
        ),
      ),
    );
  }
}