import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyPage/settings.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:craits/_JClass/response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
//
//설정 – 회원정보수정 
//
class UserInfoEdit extends StatefulWidget {
  @override
  _UserInfoEditState createState() => _UserInfoEditState();
}

class _UserInfoEditState extends State<UserInfoEdit> {
  TextEditingController textEmailController = TextEditingController();
  TextEditingController textHpController = TextEditingController();
  TextEditingController textPasswordController = TextEditingController();

  @override
  void initState() {
    textEmailController.text = user.email ?? '';
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
            title: Text('회원정보 수정'),
            leading: IconButton(
              icon: SvgPicture.asset('assets/arrowLeft.svg'), 
            onPressed: (){
              Navigator.pop(context);
            })),
          body: 
          (profile != null)?
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이메일', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                  SizedBox(height: 5,),
                  TextField(
                    controller: textEmailController,
                    cursorColor: Theme.of(context).primaryColor,
                    style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: const Color(0xFFEAEAEA),
                          width: 1
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFEAEAEA),
                          width: 1
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text('휴대폰 번호', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                  SizedBox(height: 5,),
                  TextField(
                    inputFormatters: [MultiMaskedTextInputFormatter(masks: ['xxx-xxx-xxxx', 'xxx-xxxx-xxxx'], separator: '-', )],
                    cursorColor: Theme.of(context).primaryColor,
                    style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: const Color(0xFFEAEAEA),
                          width: 1
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFEAEAEA),
                          width: 1
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  DefaultButton(
                    text: '회원정보 수정',
                    onPressed: (){
                      if(user.loginType == 'EMAIL'){
                        //이메일 로그인인 경우, 비밀번호 체크
                        showDialog(context: context, builder: (context)=> Dialog(
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            width: 350,
                            height: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('비밀번호를 입력해 주세요.', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                                TextField(
                                  controller: textPasswordController,
                                  cursorColor: Theme.of(context).primaryColor,
                                  style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(10),
                                    isDense: true,
                                    filled: true,
                                    fillColor: const Color(0xFFF3F3F3),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: const Color(0xFFEAEAEA),
                                        width: 1
                                      ),
                                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFEAEAEA),
                                        width: 1
                                      ),
                                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                    ),
                                  ),
                                ),
                                DefaultButton(
                                  text: '확인',
                                  height: 45,
                                  onPressed: ()async{
                                    if(textPasswordController.text.isEmpty){ 
                                      showDialog(context: context, builder: (context)=> OkDialog(text: '비밀번호를 바르게 입력해 주세요.', onOk: (){
                                        Navigator.pop(context);
                                      })); 
                                      return;
                                    }
                                    try{
                                      await FirebaseAuth.instance.signInWithEmailAndPassword(email: FirebaseAuth.instance.currentUser.email, password: textPasswordController.text).then((value) async{
                                        if(value != null)
                                          await FirebaseAuth.instance.currentUser.updateEmail(textEmailController.text).then((value){
                                            showDialog(context: context, builder: (context) => OkDialog(text: '이메일이 변경되었습니다.', onOk: (){
                                              Navigator.pop(context); 
                                              Navigator.pop(context); 
                                            }));
                                        });
                                      });
                                    } on FirebaseAuthException catch (e){
                                        if(e.code == 'user-not-found' || e.code == 'wrong-password'){
                                          showDialog(
                                            context: context,
                                            builder: (context) => OkDialog(
                                              text: '아이디 혹은 비밀번호가 일치하지 않습니다.',
                                              onOk: () {}));
                                          return;
                                        }
                                      }
                                  },
                                )
                              ],
                            ),
                          ),
                        ));
                      }
                      else { //이메일 로그인 아닌경우. 비밀번호 인증 없이 업데이트

                      }
                  },
                )
              ],),
            )
          : Center( child: NoData('오류가 발생했습니다.\n잠시 후 다시 시도해 주세요.'),)
        )
      );
  }

  
  Future updateProfile() async{
    final uri = Uri.parse(commonUri + '/V1/Auth/UpdateProfile.json');
    try{	
      var params = {
        'user_auth_id' : user.userAuthId,
        'email' : textEmailController.text,
        'hp_no' : textPasswordController.text,
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
}
