import 'dart:convert';
import 'package:craits/Etc/searchID.dart';
import 'package:craits/Etc/searchPW.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:craits/SignupSns.dart';
import 'package:craits/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kakao_flutter_sdk/all.dart' as kakao;
import 'mainHome.dart';
import 'MyWidget/defaultButton.dart';
import 'package:http/http.dart' as http;
import 'package:craits/_JClass/login.dart';
import 'package:craits/Common/com.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyLogin extends StatefulWidget {
  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  String idError;
  bool _passwordVisible = true;
  bool bLoading = true;

  @override
  void initState() {
    //비동기로 flutter secure storage 정보를 불러오는 작업.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      asyncMethod();
    });

    super.initState();
  }

  String userInfo; //user의 정보를 저장하기 위한 변수
  static final storage =
      new FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화 작업

  asyncMethod() async {
    setState(() {
      bLoading = true;
    });

    await Future.delayed(Duration(seconds: 3));

    //read 함수를 통하여 key값에 맞는 정보를 불러오게 됩니다. 이때 불러오는 결과의 타입은 String 타입임을 기억해야 합니다.
    //(데이터가 없을때는 null을 반환을 합니다.)
    userInfo = await storage.read(key: "login");
    if (userInfo != null) {
      String searchType = userInfo.split(",")[0];
      if (searchType == 'EMAIL') {
        if (FirebaseAuth.instance.currentUser == null) {
          storage.delete(key: "login");
          setState(() {
            bLoading = false;
          });
        } else {
          String key = FirebaseAuth.instance.currentUser.uid ?? '';
          login(
            searchType: searchType,
            searchSnsAuthKey: key,
          ).then((resultCode) {
            if (resultCode) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => MainHome()));
            } else {
              storage.delete(key: "login");
              setState(() {
                bLoading = false;
              });
            }
          });
        }
      } else if (searchType == 'NAVER') {
        loginNaver();
      } else if (searchType == 'GOOGLE') {
        signInWithGoogle();
      } else if (searchType == 'KAKAO') {
        loginKakao();
      }
      setState(() {
        bLoading = false;
      });
    } else {
      setState(() {
        bLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bLoading)
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
            child: Image.asset(
          'assets/splash.gif',
          fit: BoxFit.contain,
          width: 300,
        )),
      );
    else
      return Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Theme.of(context).primaryColor,
                    primaryColorDark: Color(0xFFC4C4C4),
                    inputDecorationTheme: InputDecorationTheme(
                      hintStyle: TextStyle(
                        color: Color(0xFF9F9F9F),
                        fontSize: 14.0,
                      ),
                      filled: true,
                      fillColor: Color(0xFFF3F3F3),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFEAEAEA), width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 50.0),
                          child: SvgPicture.asset(
                            'assets/logoText_black_small.svg',
                            width: 200,
                          ),
                        ),
                        TextField(
                          cursorColor: Theme.of(context).primaryColor,
                          controller: idController,
                          style: Theme.of(context).textTheme.bodyText1,
                          cursorHeight: 20.0,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(14.0),
                            hintText: '이메일 주소를 입력해 주세요.',
                            errorText: idError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.cancel_sharp,
                                color: Color(0xFFC4C4C4),
                              ),
                              onPressed: () {
                                setState(() {
                                  idController.clear();
                                });
                              },
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {
                              if (!isEmail(text)) {
                                idError = "아이디는 이메일 형식으로 입력해 주세요.";
                              } else {
                                idError = null;
                              }
                            });
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          cursorColor: Theme.of(context).primaryColor,
                          controller: pwController,
                          style: TextStyle(
                              fontSize: 14.0, color: Color(0xFF262626)),
                          cursorHeight: 20.0,
                          obscureText: _passwordVisible,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            isDense: true,
                            hintText: '비밀번호를 입력해 주세요.',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xFFC4C4C4),
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: DefaultButton(
                            onPressed: () async {
                              //로그인
                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: idController.text,
                                        password: pwController.text);
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found' ||
                                    e.code == 'wrong-password') {
                                  showDialog(
                                      context: context,
                                      builder: (context) => OkDialog(
                                          text: '아이디 혹은 비밀번호가 일치하지 않습니다.',
                                          onOk: () {}));
                                  return;
                                }
                              }

                              login(
                                      searchType: 'EMAIL',
                                      searchSnsAuthKey:
                                          FirebaseAuth.instance.currentUser.uid)
                                  .then((resultCode) {
                                if (resultCode) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainHome()));
                                } else {
                                  FirebaseAuth.instance.signOut();
                                  showDialog(
                                      context: context,
                                      builder: (context) => OkDialog(
                                          text: '아이디 혹은 비밀번호가 일치하지 않습니다.',
                                          onOk: () {}));
                                }
                              });
                            },
                            text: '로그인',
                            height: 48,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(50, 12, 50, 10),
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
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'SpoqaHanSansNeo'),
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
                          padding: EdgeInsets.symmetric(vertical: 20.0),
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
                                child: Image.asset(
                                    'assets/btn_google_light_normal.png',
                                    width: 58,
                                    fit: BoxFit.fitHeight),
                                onPressed: () {
                                  signInWithGoogle();
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchID()));
                                    },
                                    child: Text('아이디 찾기',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1)),
                                Container(
                                    height: 12,
                                    child: VerticalDivider(
                                        color: Color(0xFF9F9F9F))),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchPW()));
                                    },
                                    child: Text('비밀번호 찾기',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1)),
                                Container(
                                    height: 12,
                                    child: VerticalDivider(
                                        color: Color(0xFF9F9F9F))),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Signup()));
                                    },
                                    child: Text('회원가입',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1))
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
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
          .then((resultCode) {
        if (resultCode) {
          //로그인 조회 성공
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainHome()));
        } else {
          storage.delete(key: "login");
          //로그인 조회 실패
          //회원가입
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SignupSns(
                        initEmail: userEmail,
                        initNickname: userNickname,
                        loginType: 'KAKAO',
                        snsAuthKey: userKakao.id.toString(),
                      )));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('오류가 발생했습니다.')));
    }
  }

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        storage.delete(key: "login");
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
          .then((resultCode) {
        if (resultCode) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainHome()));
        } else {
          storage.delete(key: "login");
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
              storage.delete(key: "login");
            }
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('오류가 발생했습니다.')));
    }
  }

  Future<bool> login(
      {@required String searchType,
      String searchSnsAuthKey,
      String searchEmail,
      String searchUserPwd}) async {
    try {
      showDialog(context: context, builder: (context) => LoadingDialog());
      final uri = Uri.parse(commonUri + '/V1/Auth/Login.json');
      var params = {
        'searchType': searchType,
        'searchSnsAuthKey': searchSnsAuthKey,
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context);

      JLogin _login;
      if (response.statusCode == 200) {
        _login = JLogin.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if (_login.resultCode == 'SUCC') {
          user = _login.info;
          if (searchType == 'EMAIL') {
            user.loginType = 'EMAIL';

            await storage.write(key: "login", value: searchType);

            // await storage.write(
            //   key: "login",
            //   value: searchType + ',' + idController.text.toString() + "," + pwController.text.toString());
          } else {
            user.loginType = 'SNS';
            await storage.write(key: "login", value: searchType);
          }
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

  bool isEmail(String em) {
    String emailRegexp =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(emailRegexp);

    return regExp.hasMatch(em);
  }
}
