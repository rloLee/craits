import 'package:flutter/material.dart';

class OkCancelDialog extends StatelessWidget {
  final Function onOk;
  final String text;

  OkCancelDialog({
    @required this.text,
    @required this.onOk
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0.0,
      backgroundColor: Colors.white,
      actionsOverflowButtonSpacing: 20,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(20.0),
          ),
        ),
      title: Column(
        children: [
          Container(
            padding:EdgeInsets.all(5), 
            child: Text(text, style: Theme.of(context).textTheme.bodyText1)),
        ],
      ),
      actions: [
        Container(
          child: TextButton( child:Text('취소', style: Theme.of(context).textTheme.bodyText1), 
          onPressed: (){
            Navigator.pop(context);
          },)),
        Container(
        child: TextButton(
          child:Text( '확인', style: Theme.of(context).textTheme.headline6), 
          onPressed:  (){
            onOk();
          },)),
      ],
    );
  }
}