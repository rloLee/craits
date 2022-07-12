import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class NetworkErr extends StatelessWidget {

  final Function onRetry;
  NetworkErr({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [ 
        SvgPicture.asset('assets/errorImage.svg'),
        Text('인터넷 접속이 원활하지 않습니다.', style : Theme.of(context).textTheme.headline5),
        SizedBox(height: 30,),
        if(onRetry != null)
          DefaultButton(width: 200, onPressed: onRetry, text: '다시 시도하기', fontColor: Theme.of(context).primaryColor, color: Colors.white, borderSide: BorderSide(color: Theme.of(context).primaryColor),),
      ],
    );
  }
}