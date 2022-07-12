import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Etc/searchPW.dart';
import 'package:craits/_JClass/searchId.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
//
//아이디찾기 
//
class SearchID extends StatefulWidget {
  @override
  _SearchIDState createState() => _SearchIDState();
}

class _SearchIDState extends State<SearchID> {
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
          title: Text('아이디 찾기'),
          leading: IconButton(
            icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
          })),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: 
            bExist ?
              afterCheck()
              : beforeCheck()
        )
      ),
    );
  }

  Container beforeCheck(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('크레이츠는 이메일 주소로 로그인 할 수 있습니다.', style: Theme.of(context).textTheme.bodyText1),
          Text('이메일 주소를 입력하시면 가입 유/무를 알려드립니다.', style: Theme.of(context).textTheme.bodyText1),
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
            text: '확인',
            onPressed: (){
              sInputEmail = textController.text;
              getData();
            },
          ),
        ],
      ),
    );
  }

  Future getData() async{
    final uri = Uri.parse(commonUri + '/V1/Auth/SearchId.json');
    try{
      var params = {
        'searchEmail' : sInputEmail,  
      };

      Uri newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JSearchId _searchId;
      if(response.statusCode == 200){
        _searchId =JSearchId.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_searchId.resultCode == 'SUCC')
          setState(() {
            bExist = true;
            sInputEmail = _searchId.info.email;
            sDate = _searchId.info.regDt;
          });
        else{
          setState(() {
            textErrorMsg = '입력하신 이메일 주소로 등록된 회원이 없습니다.';
          });
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    } on TimeoutException catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    } catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }
  
  Container afterCheck(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('회원으로 등록된 이메일 주소입니다.', style: Theme.of(context).textTheme.bodyText1),
          Text('해당 이메일로 로그인 하고 크레이츠를 이용해보세요.', style: Theme.of(context).textTheme.bodyText1),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sInputEmail??'', style: Theme.of(context).textTheme.bodyText1,),
                Text(sDate??'', style: Theme.of(context).textTheme.bodyText1,),
              ],
            ),
            width: double.infinity,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),  
              color: const Color(0xFFF3F3F3),
              border: Border.all(
                color: const Color(0xFFEAEAEA)
              )
            ),
          ),
          SizedBox(height: 20),
          DefaultButton(
            text: '로그인 하기',
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 15),
          DefaultButton(
            color: Colors.white,
            fontColor: Theme.of(context).primaryColor,
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
            text: '비밀번호 찾기',
            onPressed: (){
            },
          ),
        ],
      ),
    );
  }
} 