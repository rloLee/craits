import 'package:craits/MyAlarm/myPushLog.dart';
import 'package:craits/search/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyAppBar extends StatelessWidget {
  @override
  AppBar build(BuildContext context) {
    return AppBar(
      title: SvgPicture.asset('assets/logoText_black_small.svg', height: 25,),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
        icon: SvgPicture.asset('assets/search.svg'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> Search()));
        }),
        IconButton(
          icon: SvgPicture.asset('assets/alarm.svg'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> PushLogList()));
          }), 
      ],
      iconTheme:IconThemeData(color:Colors.black),
      backgroundColor: Colors.white,
    );
  }
}