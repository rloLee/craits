import 'package:craits/SignupEmail.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset('assets/logoImage.svg'),
                SizedBox(height: 20.0,),
                Text('크레이츠 시작하기', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, fontFamily: 'SpoqaHanSansNeo')),
                SizedBox(height: 200.0,),
                FractionallySizedBox(
                  widthFactor: 1, 
                  child: DefaultButton(
                    color: Colors.white,
                    fontColor: Colors.black,
                    onPressed:(){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyLogin()));
                    }, 
                    text : '로그인'
                  ),
                ),
                SizedBox(height: 10.0,),
                FractionallySizedBox(
                  widthFactor: 1, 
                  child: DefaultButton(
                    onPressed:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SignupEmail()));
                    }, 
                    text : '회원가입',
                    borderSide: BorderSide(width: 1.0, color: Colors.white),
                  ),
                ),
              ],
            ),
        ),
        ),
    );
  }
}