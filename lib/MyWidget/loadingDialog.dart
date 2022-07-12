import 'package:flutter/material.dart';

class LoadingDialog extends Dialog {

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20.0)
              )
            ),
          ),
          width:80,
          height:80,
          child: Center(
            child: CircularProgressIndicator(),
            )
        ,)),
    );
  }
}