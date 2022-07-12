import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

//
//설정 – 비밀번호 변경 (이메일 로그인만)
//
class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController textOldPasswordController = TextEditingController();
  TextEditingController textPasswordController = TextEditingController();
  TextEditingController textPasswordCheckController = TextEditingController();
  TextFieldInfo textOldPassword;
  TextFieldInfo textPassword;
  TextFieldInfo textPasswordCheck;
  @override
  void initState() {
     textOldPassword = TextFieldInfo(
      title: '현재 비밀번호',
      hintText: '8~15자 영문, 숫자, 특수문자로 입력해 주세요.',
      controller: textOldPasswordController,
    );
     textPassword = TextFieldInfo(
      title: '새 비밀번호',
      hintText: '8~15자 영문, 숫자, 특수문자로 입력해 주세요.',
      controller: textPasswordController,
    );
     textPasswordCheck = TextFieldInfo(
      title: '새 비밀번호 재확인',
      hintText: '8~15자 영문, 숫자, 특수문자로 입력해 주세요.',
      controller: textPasswordCheckController,
    );
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          title: Text('비밀번호 변경'),
          leading: IconButton(
            icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
          })),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textOldPassword,
              textPassword,
              textPasswordCheck,
              SizedBox(height: 20),
              DefaultButton(
                text: '확인',
                onPressed: () async {
                  if(textPasswordController.text != textPasswordCheckController.text){
                    showDialog(context: context, builder: (context) => OkDialog(text: '비밀번호가 일치하지 않습니다.', onOk: (){}));
                  }
                  else if (!isCorrect(textPasswordController.text) || !isCorrect(textPasswordCheckController.text) ){
                    showDialog(context: context, builder: (context) => OkDialog(text: '비밀번호는 8~15자 영문, 숫자, 특수문자로 입력해 주세요.', onOk: (){}));
                  }
                  else{
                    try{
                      await FirebaseAuth.instance.signInWithEmailAndPassword(email: FirebaseAuth.instance.currentUser.email, password: textOldPasswordController.text).then((value) async{
                        if(value != null)
                          await FirebaseAuth.instance.currentUser.updatePassword(textPasswordController.text).then((value){
                            showDialog(context: context, builder: (context) => OkDialog(text: '비밀번호가 변경되었습니다.', onOk: (){
                              Navigator.pop(context);
                            }));
                        });
                      });
                    } on FirebaseAuthException catch (e){
                        if(e.code == 'user-not-found' || e.code == 'wrong-password'){
                          showDialog(
                            context: context,
                            builder: (context) => OkDialog(
                                text: '현재 비밀번호가 일치하지 않습니다.',
                                onOk: () {}));
                          return;
                        }
                      }
                      catch (e){
                        print(e);
                      }

                  }
                },
              ),
            ],
          ),
        )
      ),
    );
  }


  Future changePw() async{
    final uri = Uri.parse(commonUri + '/V1/Auth/ModifyPwd.json');
    try{	
      var params = {
        'user_auth_id' : user.userAuthId,
        'old_pwd' : textOldPasswordController.text,
        'new_pwd' : textPasswordController.text,
      };

      Uri newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JResponse _response;
      if(response.statusCode == 200){
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_response.resultCode == 'SUCC')
          showDialog(context: context, builder: (context) => OkDialog(text: '비밀번호가 변경되었습니다.', onOk: (){
            Navigator.pop(context);
          }));
        else{
          showDialog(context: context, builder: (context) => OkDialog(text: _response.resultMsg?? '오류가 발생했습니다.', onOk: (){
          }));
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
  
  bool isCorrect(String password) {
    String reqex = r'^(?=.*[0-9])(?=.*[A-Za-z])(?=.*[!@#$%^&*+=.])[A-Za-z0-9~!@#$%^&*+=.]{8,15}$';
    RegExp regExp = RegExp(reqex);
    return regExp.hasMatch(password);
  }

}

class TextFieldInfo extends StatefulWidget {
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

  @override
  _TextFieldInfoState createState() => _TextFieldInfoState();
}

class _TextFieldInfoState extends State<TextFieldInfo> {
  String passwordReqexp = r'^(?=.*[0-9])(?=.*[A-Za-z])(?=.*[!@#$%^&*+=.])[A-Za-z0-9~!@#$%^&*+=.]{8,15}$';
  String errorText; 
  String helperText;
  bool isChecked = false;

  @override
  void initState() {
    helperText = widget.hintText;
    if(widget.initText != null)
      widget.controller.text = widget.initText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.headline5,),
          SizedBox(height: 5,),
          TextField(
            onChanged: (text){
              if(isCorrect(passwordReqexp, text))
                setState(() {
                  errorText = null;
                });
              else
                setState(() {
                  errorText = widget.hintText;
                });
            },
            controller: widget.controller,
            keyboardType: widget.inputType,
            cursorColor: Theme.of(context).primaryColor,
            style: Theme.of(context).textTheme.bodyText1,
            obscureText: true,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.subtitle2,
              errorText: errorText,
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
                  color: (isChecked)
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFEAEAEA),
                  width: 1
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: (isChecked)
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFEAEAEA),
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
  
  bool isCorrect(String reqex, String em) {
    RegExp regExp = RegExp(reqex);
    return regExp.hasMatch(em);
  }

}