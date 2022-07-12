import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/SignupEmailFirebase.dart';
import 'package:craits/_JClass/login.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/SignupEmail.dart';
import 'package:craits/SignupSns.dart';
import 'package:craits/mainHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/all.dart' as kakao;

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  static final storage =
      new FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화 작업

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 1.0,
          title: Text('회원가입'),
          leading: IconButton(
              icon: SvgPicture.asset('assets/arrowLeft.svg'),
              onPressed: () {
                Navigator.pop(context);
              })),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'SNS 계정으로 간편하게 가입',
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //카카오 로그인
                MaterialButton(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: Color(0xFFFEE500),
                      ),
                      child: Image.asset(
                        'assets/kakaologo.png',
                        scale: 2.2,
                      )),
                  onPressed: () {
                    loginKakao();
                  },
                ),
                //네이버 로그인
                MaterialButton(
                  child: Image.asset('assets/btnG_naver.png',
                      width: 50, fit: BoxFit.fitHeight),
                  onPressed: () {
                    loginNaver();
                  },
                ),
                //구글 로그인
                MaterialButton(
                  child: Image.asset('assets/btn_google_light_normal.png',
                      width: 58, fit: BoxFit.fitHeight),
                  onPressed: () {
                    signInWithGoogle();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 25),
            child: Row(children: <Widget>[
              Expanded(
                  child: Divider(
                color: Color(0xFFE3E3E3),
                thickness: 1,
              )),
              SizedBox(
                width: 20.0,
              ),
              Text(
                "또는",
                style: TextStyle(
                    color: Color(0xFF9F9F9F),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                  child: Divider(
                color: Color(0xFFE3E3E3),
                thickness: 1,
              )),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: DefaultButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignupEmailFirebase()));
              },
              color: Colors.white,
              text: '이메일로 가입하기',
              fontsize: 15.0,
              fontWeight: FontWeight.w500,
              fontColor: const Color(0xFF262626),
              borderSide:
                  const BorderSide(width: 1.0, color: Color(0xFFE3E3E3)),
            ),
          ),
        ],
      ),
    );
  }

  Future loginKakao() async {
    try {
      final installed = await kakao.isKakaoTalkInstalled();
      installed
          ? await kakao.UserApi.instance.loginWithKakaoTalk()
          : await kakao.UserApi.instance.loginWithKakaoAccount();
      kakao.User userKakao = await kakao.UserApi.instance.me();

      String userEmail;
      String userNickname;
      if (userKakao.kakaoAccount.emailNeedsAgreement != null &&
          userKakao.kakaoAccount.emailNeedsAgreement)
        userEmail = userKakao.kakaoAccount.email;
      if (userKakao.kakaoAccount.profileNicknameNeedsAgreement)
        userNickname = userKakao.kakaoAccount.profile.nickname;

      login(searchType: 'KAKAO', searchSnsAuthKey: userKakao.id.toString())
          .then((resultCode) => {
                if (resultCode)
                  {
                    //로그인 조회 성공
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MainHome())),
                  }
                else
                  {
                    //로그인 조회 실패 //회원가입'
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignupSns(
                                  initEmail: userEmail,
                                  initNickname: userNickname,
                                  loginType: 'KAKAO',
                                  snsAuthKey: userKakao.id.toString(),
                                ))),
                  }
              });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('오류가 발생했습니다.')));
    }
  }

  Future loginNaver() async {
    NaverLoginResult res = await FlutterNaverLogin.logIn();
    if (res.status == NaverLoginStatus.loggedIn) {
      setState(() {
        login(searchType: 'NAVER', searchSnsAuthKey: res.account.id)
            .then((resultCode) => {
                  if (resultCode)
                    {
                      //로그인 조회 성공
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => MainHome())),
                    }
                  else
                    {
                      //로그인 조회 실패 //회원가입'
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupSns(
                                    initEmail: res.account.email,
                                    initNickname: res.account.nickname,
                                    loginType: 'NAVER',
                                    snsAuthKey: res.account.id,
                                  ))).then((value) {
                        if (value != null && value == true) {
                          login(
                                  searchType: 'NAVER',
                                  searchSnsAuthKey: res.account.id)
                              .then((resultCode) => {
                                    if (resultCode)
                                      {
                                        //로그인 조회 성공
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MainHome())),
                                      }
                                  });
                        } else {
                          FlutterNaverLogin.logOut();
                        }
                      }),
                    }
                });
      });
    }
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential res =
        await FirebaseAuth.instance.signInWithCredential(credential);

    login(searchType: 'GOOGLE', searchSnsAuthKey: res.user.uid.toString())
        .then((resultCode) => {
              if (resultCode)
                {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainHome())),
                }
              else
                {
                  //로그인 조회 실패 //회원가입'
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignupSns(
                                initEmail: googleUser.email,
                                initNickname: googleUser.displayName,
                                loginType: 'GOOGLE',
                                snsAuthKey: res.user.uid.toString(),
                              ))).then((value) {
                    if (value != null && value == true) {
                      login(
                              searchType: 'GOOGLE',
                              searchSnsAuthKey: res.user.uid.toString())
                          .then((resultCode) => {
                                if (resultCode)
                                  {
                                    //로그인 조회 성공
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MainHome())),
                                  }
                              });
                    } else {
                      GoogleSignIn().signOut();
                    }
                  }),
                }
            });
  }

  Future<bool> login(
      {@required String searchType,
      String searchSnsAuthKey,
      String searchEmail,
      String searchUserPwd}) async {
    try {
      final uri = Uri.parse(commonUri + '/V1/Auth/Login.json');
      var params = {
        'searchType': searchType,
        'searchSnsAuthKey': searchSnsAuthKey,
        'searchEmail': searchEmail,
        'searchUserPwd': searchUserPwd,
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JLogin _login;
      if (response.statusCode == 200) {
        _login = JLogin.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if (_login.resultCode == 'SUCC') {
          user = _login.info;
          await storage.write(key: "login", value: searchType);
          return true;
        } else {
          storage.delete(key: "login");
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.')));
        return false;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.')));
      return false;
    }
  }
}
