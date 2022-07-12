import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:craits/_JClass/searchId.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
//
//비밀번호 찾기  
//
class SearchPW extends StatefulWidget {
  @override
  _SearchPWState createState() => _SearchPWState();
}

class _SearchPWState extends State<SearchPW> {
  TextEditingController textController = TextEditingController();
  bool bExist = false;
  String sInputEmail;
  String sDate;
  String textErrorMsg;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          title: Text('비밀번호 찾기'),
          leading: IconButton(
            icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
          })),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child:   beforeCheck()
        )
      ),
    );
  }

  Container beforeCheck(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비밀번호 재설정을 위한 이메일을 전송합니다.', style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20,),
          TextField(
            controller: textController,
            cursorColor: Theme.of(context).primaryColor,
            style: Theme.of(context).textTheme.bodyText1,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding:EdgeInsets.all(10),
              hintText: '이메일 주소를 입력해 주세요.',
              hintStyle: Theme.of(context).textTheme.subtitle2,
              errorText: textErrorMsg,
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: const Color(0xFFEAEAEA),
                  width: 1
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: const Color(0xFFEAEAEA),
                    width: 1
                    ),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: const Color(0xFFFC1F2D),
                  width: 1
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: const Color(0xFFFC1F2D),
                  width: 1
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
            ),
          ), 
          SizedBox(height: 20),
          DefaultButton(
            text: '비밀번호 재설정 이메일 전송',
            onPressed: ()async{
              FirebaseAuth.instance.setLanguageCode("ko");
              FirebaseAuth.instance.sendPasswordResetEmail(email: textController.text).then((value){
                showDialog(context: context, builder: (context)=>OkDialog(text: '비밀번호 재설정 이메일을 전송했습니다.\n다소 시간이 소요될 수 있습니다.', onOk: (){
                  Navigator.pop(context);
                }));
              });
            },
          ),
        ],
      ),
    );
  }
} 