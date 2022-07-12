import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class NoData extends StatelessWidget {

  final String msg;
  NoData(
    @required this.msg
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [ 
        SvgPicture.asset('assets/errorImage.svg'),
        SizedBox(height: 10,),
        Text(msg, style : Theme.of(context).textTheme.headline5, textAlign: TextAlign.center,),
      ],
    );
  }
}