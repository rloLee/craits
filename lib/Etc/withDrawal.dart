import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
//
//탈퇴하기 
//
class TextFieldInfo extends StatelessWidget {
  final String title;
  final String initText;
  final TextEditingController controller;
  final String hintText; 
  final TextInputType inputType;

  TextFieldInfo({
    @required this.title,
    @required this.controller,
    @required this.hintText,
    this.initText,
    this.inputType = TextInputType.text,
  });

  final String passwordReqexp = r'^(?=.*[0-9])(?=.*[A-Za-z])(?=.*[!@#$%^&*+=.])[A-Za-z0-9~!@#$%^&*+=.]{8,15}$';

  @override
  Widget build(BuildContext context) {
    if(initText != null)
      controller.text = initText;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headline5,),
          SizedBox(height: 5,),
          TextField(
            controller: controller,
            keyboardType: inputType,
            cursorColor: Theme.of(context).primaryColor,
            style: Theme.of(context).textTheme.bodyText1,
            obscureText: true,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.subtitle2,
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1
                  ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFFEAEAEA),
                  width: 1
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFFEAEAEA),
                  width: 1
                  ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
        ],
      ),
    );
  }
}


class WithDrawal extends StatefulWidget {
  @override
  _WithDrawalState createState() => _WithDrawalState();
}

class _WithDrawalState extends State<WithDrawal> {
  static final storage = new FlutterSecureStorage();
  TextEditingController textPasswordController = TextEditingController();
  TextEditingController textPasswordCheckController = TextEditingController();
  TextFieldInfo textPassword;
  TextFieldInfo textPasswordCheck;
  bool bAgree = false; 

  @override
  void initState() {
     textPassword = TextFieldInfo(
      title: '비밀번호',
      hintText: '비밀번호를 입력해 주세요.',
      controller: textPasswordController,
    );
     textPasswordCheck = TextFieldInfo(
      title: '비밀번호 재확인',
      hintText: '비밀번호를 입력해 주세요.',
      controller: textPasswordCheckController,
    );
    super.initState();
  }
  
    //탈퇴
    Future withdrawal() async{
      try {
        final uri = Uri.parse(commonUri + '/V1/Auth/Withdrawal.json');
        showDialog(context: context,barrierDismissible: false,  builder: (_)  => LoadingDialog());

        var params = {
          'user_auth_id' : user.userAuthId,
        };

        final newUri = uri.replace(queryParameters: params);
        http.Response response = await http.get(newUri).timeout(Duration(seconds: 10));

        Navigator.pop(context); //로딩끝
        
        JResponse _response;
        if(response.statusCode == 200){
          _response =JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
          return _response.resultCode;
        }
        else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
        }
      } on TimeoutException catch(_) {
          Navigator.pop(context); //로딩끝
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('네트워크 오류가 발생했습니다.'))
          );
        } 
        catch(_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('네트워크 오류가 발생했습니다.'))
          );
        }
      return null;
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text('회원탈퇴'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
          }
        )),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text('탈퇴 유의사항', style: Theme.of(context).textTheme.headline5,),
              SizedBox(height: 5,),
              Text('• 회원 탈퇴와 함께 어플리케이션을 삭제할 경우, 기존에 업로드한 사진 데이터 및 진료기록 데이터는 즉시 삭제되므로 복구가 불가합니다.', style: TextStyle(height: 1.5, fontSize: 14.0),),
              Text('• 데이터 처리에 시간이 소요되므로, 즉시 재가입이 불가능할 경우가 있습니다.', style: TextStyle(height: 1.5, fontSize: 14.0),),
              Text('• 회원 정보 및 그외의 기입한 데이터의 경우 지체없이 파기 절차가 진행되어 복구가 불가합니다.', style: TextStyle(height: 1.5, fontSize: 14.0),),
              SizedBox(height: 20),
              InkWell(
                onTap: (){
                  setState(() {
                    bAgree = !bAgree;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      child: 
                        (bAgree)?
                          Icon(Icons.check_circle, color: Theme.of(context).primaryColor,)
                        :
                          Icon(Icons.circle_outlined, color: Color(0xFFC4C4C4), ),
                    ),
                    SizedBox(width: 10),
                    Text('안내 사항을 모두 확인하였으며, 이에 동의합니다.', style: TextStyle(fontSize: 14.0),),
                  ],
                ),
              ),
              SizedBox(height: 20),
              DefaultButton(
                color: Colors.red,
                text: '회원탈퇴',
                onPressed: (){
                  if(!bAgree){
                    showDialog(context: context, builder: (context) => OkDialog(text: '탈퇴 유의사항을 확인 후 동의해 주세요.', onOk: (){}));
                  }
                  else {
                    showDialog(context: context, builder: (context) => OkCancelDialog(text: '정말로 탈퇴하시겠습니까?', onOk: (){
                      withdrawal().then((resultCode) {
                      if(resultCode!=null){
                        if(resultCode == 'SUCC') {
                          Navigator.pop(context);
                          user = null;
                          storage.delete(key: "login");
                          FirebaseAuth.instance.currentUser.delete();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>  MyLogin()), (Route<dynamic> route) => false);
                        }
                        else {
                          showDialog(context: context, builder: (context) => OkDialog(text: '오류가 발생했습니다.', onOk: (){}));
                          Navigator.pop(context);
                        }
                      }
                    });
                    }));
                  
                  }
                },
              ),
            ],
          ),
        )
    );
  }
}