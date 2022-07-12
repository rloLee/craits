import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Etc/changePassword.dart';
import 'package:craits/Etc/notice.dart';
import 'package:craits/Etc/registerReport.dart';
import 'package:craits/Etc/userInfoEdit.dart';
import 'package:craits/Etc/withDrawal.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyPage/setPush.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

//설정
class Settings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final storage = FlutterSecureStorage();


    //로그아웃
    Future logout() async{
      try {
        final uri = Uri.parse(commonUri + '/V1/Auth/Logout.json');
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
  
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 1.0,
        title : Text('설정'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
        }),
      ),
      body: Column(
        children: [
          if(user.loginType == 'EMAIL')
            ListTile(
              title: Text('비밀번호 변경', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));
              },
            ),
          Divider(color: Color(0xFFF2F4F6)),
          ListTile(
            title: Text('회원정보 수정', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoEdit()));
            },
          ),
          Divider(color: Color(0xFFF2F4F6)),
          ListTile(
            title: Text('푸시알림 설정', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SetPush()));
            },
          ),
          Divider(color: Color(0xFFF2F4F6), height: 20, thickness: 20,),
          ListTile(
            title: Text('공지사항', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Notice()));
            },
          ),
          Divider(color: Color(0xFFF2F4F6)),
          ListTile(
            title: Text('의견 보내기', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterReport()));
            },
          ),
          Divider(color: Color(0xFFF2F4F6), height: 20, thickness: 20,),
          ListTile(
            title: Text('로그아웃', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            onTap: () async{
              await logout().then((value) async{
                  if(value == 'SUCC'){
                    user = null;
                    storage.delete(key: "login");
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>  MyLogin()), (Route<dynamic> route) => false);
                  }
                }
              );
            },
          ),
          Divider(color: Color(0xFFF2F4F6)),
          ListTile(
            title: Text('탈퇴하기', style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.normal),),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>WithDrawal()));
              // showDialog(
              //   context: context, 
              //   builder: (context) => OkCancelDialog(
              //     text: '회원 탈퇴하시겠습니까?', 
              //     onOk: (){
              //       withdrawal().then((resultCode) {
              //         if(resultCode!=null){
              //           if(resultCode == 'SUCC') {
              //             Navigator.pop(context);
              //             user = null;
              //             storage.delete(key: "login");
              //             Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>  MyLogin()), (Route<dynamic> route) => false);
              //           }
              //         }
              //       });
              //   },)
              // );
            },
          ),
          Divider(color: Color(0xFFF2F4F6), height: 20, thickness: 20,),
        ],
      )
    );
  }

}