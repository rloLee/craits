import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Etc/term.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'MyWidget/okDialog.dart';


class SignupSns extends StatefulWidget {
  final String initEmail;
  final String initNickname;
  final String loginType;
  final String snsAuthKey;

  SignupSns({
    @required this.loginType,
    @required this.snsAuthKey,
    this.initEmail,
    this.initNickname,
  });

  @override
  _SignupSnsState createState() => _SignupSnsState();
}

class _SignupSnsState extends State<SignupSns> {
  TextEditingController textEmailController = TextEditingController();
  TextEditingController textNicknameController = TextEditingController();

  bool valueAll = false;
  bool value1 = false; //서비스 이용약관
  bool value2 = false; //개인정보 취급 방침
  bool value3 = false; //마케팅 정보 수신
  bool valuePush = false;
  bool valueSms = false;
  bool valueEmail = false;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    TextFieldDuplicationInfo textEmail = TextFieldDuplicationInfo(
      title: '이메일', 
      hintText: '이메일 주소를 입력해 주세요.', 
      initText: widget.initEmail, 
      controller: textEmailController,
      searchType: 'EMAIL',
    );
    TextFieldDuplicationInfo textNickName = TextFieldDuplicationInfo(
      title: '닉네임', 
      hintText: '2~15자 한글, 영문, 숫자로 입력해 주세요.', 
      initText: widget.initNickname,
      controller: textNicknameController,
      searchType: 'NAME',
    );
    
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          title: Text('SNS계정으로 가입하기', ),
          leading: IconButton(
            icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.of(context).pop(false);
          })),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              textEmail,
              textNickName,
              terms(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: DefaultButton(
                  text: '회원가입', 
                  onPressed: () async {
                    String strEmail = textEmailController.text;
                    String strNickname = textNicknameController.text;
                    if(strEmail.length == 0 || strNickname.length == 0) {
                      showDialog(context: context, builder: (context) => OkDialog(text: '정확히 입력해 주세요.', onOk: (){}));
                    }
                    else if(await checkDuplication('EMAIL', strEmail) == false){
                      showDialog(context: context, builder: (context) => OkDialog(text: '중복확인을 다시 해주세요.', onOk: (){}));
                    }
                    else if (await checkDuplication('NAME', strNickname) == false){
                      showDialog(context: context, builder: (context) => OkDialog(text: '중복확인을 다시 해주세요.', onOk: (){}));
                    }
                    else if(value1 == false || value2 == false){
                      showDialog(context: context, builder: (context) => OkDialog(text: '필수 약관에 동의해주세요.', onOk: (){}));
                    }
                    else{
                      //회원가입처리
                      signupSns().then((resultCode) {
                        if(resultCode){
                          showDialog(context: context, builder: (context)=> OkDialog(
                            text: '회원가입이 완료되었습니다.\n로그인 해주세요.', 
                            onOk: (){
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>  MyLogin()), (Route<dynamic> route) => false);
                            }));
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget terms(){
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          title: Text('모든 약관에 동의합니다.', style: Theme.of(context).textTheme.headline3),
          value: valueAll,
          onChanged: (value){
          setState(() {
            valueAll = value;
            if(valueAll)
              setState(() {
                value1 = true;
                value2 = true;
                value3 = true;
                valueEmail = true;
                valuePush = true;
                valueSms = true;
              });
            else 
              setState(() {
                value1 = false;
                value2 = false;
                value3 = false;
              });
          });
        }),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          tileColor: Color(0xFFF3F3F3),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          secondary: IconButton(
            icon : SvgPicture.asset('assets/arrowRight.svg'),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>TermView(searchType: 'TERMS_SERVICE'))); 
            },
          ),
          title: Text('서비스 이용약관 (필수)', style: Theme.of(context).textTheme.headline5),
          value: value1, onChanged: (value){
          setState(() {
            value1 = value;
            if(value == false)
              valueAll = false;
          });
        }),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          tileColor: Color(0xFFF3F3F3),
          controlAffinity: ListTileControlAffinity.leading,
          secondary: IconButton(
            icon : SvgPicture.asset('assets/arrowRight.svg'), 
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>TermView(searchType: 'TERMS_PRIVACY'))); 
            },
          ),
          title: Text('개인정보 취급 방침 (필수)', style: Theme.of(context).textTheme.headline5 ),
          value: value2, onChanged: (value){
          setState(() {
            value2 = value;
            if(value == false)
              valueAll = false;
          });
        }),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          tileColor: const Color(0xFFF3F3F3),
          controlAffinity: ListTileControlAffinity.leading,
          secondary: IconButton(
            icon : SvgPicture.asset('assets/arrowRight.svg'), 
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>TermView(searchType: 'TERMS_MARKETING'))); 
            },
          ),
          title: Text('마케팅 정보 수신 (선택)', style: Theme.of(context).textTheme.headline5 ),
          value: value3,
          onChanged: (value){
            setState(() {
              value3 = value;
              if(!value){
                valueAll = false;
                valuePush = false;
                valueSms = false;
                valueEmail = false;
              }
              else{
                valuePush = true;
                valueSms = true;
                valueEmail = true;
              }
            });
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: valuePush,
                onChanged: 
                  (value){
                    setState(() {
                      valuePush = value;
                      if(value)
                        value3 = true;
                      if(!valuePush && !valueSms && !valueEmail)
                        value3 = false;
                    });
                  }
              ),
              Text('앱 Push', style: Theme.of(context).textTheme.bodyText1,),
              SizedBox(width: 10,),
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: valueSms,
                onChanged: 
                  (value){
                    setState(() {
                      valueSms = value;
                      if(value)
                        value3 = true;
                      if(!valuePush && !valueSms && !valueEmail)
                        value3 = false;
                    });
                  }
              ),
              Text('SMS', style: Theme.of(context).textTheme.bodyText1,),
              SizedBox(width: 10,),
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: valueEmail,
                onChanged: 
                  (value){
                    setState(() {
                      valueEmail = value;
                      if(value)
                        value3 = true;
                      if(!valuePush && !valueSms && !valueEmail)
                        value3 = false;
                    });
                  }
              ),
              Text('이메일', style: Theme.of(context).textTheme.bodyText1,)
            ],
          )
      ],
    );
  }

  Future<bool> checkDuplication(String searchType, String value) async{
    try{
      final uri = Uri.parse(commonUri+'/V1/Auth/DuplCheck.json');
      var params = {
        'searchType' : searchType,
        'searchValue' : value,
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JResponse _response;
      if(response.statusCode == 200){
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_response.resultCode == 'SUCC')
          return true;
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 1500),
              content: Text('네트워크 오류가 발생했습니다.'))
          );
          return false;
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        return false;
      }
    } 
    catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
        return false;
    }
  }

  Future signupSns() async{
    try{
      showDialog(context: context, builder: (context)=> LoadingDialog());
      final uri = Uri.parse(commonUri+'/V1/Auth/Signup.json');
      var params = {
        // 'key' : 'e9b41f70',
        'login_type': widget.loginType,
        'sns_auth_key': widget.snsAuthKey,
        'email': textEmailController.text.trim(),
        'name': textNicknameController.text.trim(),
      };
      
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      Navigator.pop(context);

      JResponse _response;
      if(response.statusCode == 200){
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_response.resultCode == 'SUCC')
          return true;
        else
          return false;
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
        return false;
      }
    } 
    catch(_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
  }
} 

class TextFieldDuplicationInfo extends StatefulWidget {
  final String title;
  final String initText;
  final TextEditingController controller;
  final String searchType;
  final String hintText; 
  final TextInputType inputType;

  TextFieldDuplicationInfo({
    @required this.title,
    @required this.controller,
    @required this.searchType,
    @required this.hintText,
    this.initText,
    this.inputType = TextInputType.text,
  });

  @override
  _TextFieldDuplicationInfoState createState() => _TextFieldDuplicationInfoState();
}

class _TextFieldDuplicationInfoState extends State<TextFieldDuplicationInfo> {
  String nicknameRegexp = r'^([a-zA-Z가-힣0-9]{2,15})';
  String emailRegexp = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  String errorText; 
  String helperText;
  bool isChecked = false;
  bool isError = false;
  String  oldText = '';

  @override
  void initState() {
    if(widget.initText != null){
      setState(() {
        widget.controller.text = widget.initText;
       
      });
    }
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
          Text(widget.title, style:Theme.of(context).textTheme.headline5,),
          SizedBox(height: 5,),
          TextField(
            controller: widget.controller,
            keyboardType: widget.inputType,
            cursorColor: Theme.of(context).primaryColor,
            style: Theme.of(context).textTheme.bodyText1,
            decoration: InputDecoration(
              helperText: helperText,
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
              fillColor: Color(0xFFF3F3F3),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: (isChecked)
                  ? Theme.of(context).primaryColor
                  : Color(0xFFEAEAEA),
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
              suffix: GestureDetector(
                child: Text('중복확인', style: Theme.of(context).textTheme.subtitle1,),
                onTap: (){
                  if(!isError){
                    setState(() {
                      isChecked = false;
                    });
                    checkDuplication().then((resultCode) => {
                      if(resultCode){
                        setState(() {
                          isChecked = true;
                          errorText = null;
                          helperText = '사용 가능합니다.';
                        })
                      }
                      else{
                        setState(() {
                          isError = true;
                          errorText = '중복입니다';
                          // helperText = '중복입니다.';
                        })
                      }
                    });
                  }
                },
              )
            ),
            onChanged: (text){
              if(oldText != text){
                setState(() {
                  isChecked = false;
                  isError = true;
                  helperText = null;
                });
                if(text.length == 0)
                  setState(() {
                    isError = true;
                    helperText = null;
                    errorText = null;
                  });
                if(widget.searchType == 'EMAIL'){
                  if(!isCorrect(emailRegexp, widget.controller.text)){
                    setState(() {
                      errorText = widget.hintText;
                      isError = true;
                    });
                  }
                  else{
                    setState(() {
                      errorText = null;
                      isError = false;
                    });
                  }
                }
                else if(widget.searchType == 'NAME') {
                  if(!isCorrect(nicknameRegexp, widget.controller.text)){
                    setState(() {
                      errorText = widget.hintText;
                      isError = true;
                    });
                  }
                  else{
                    setState(() {
                      errorText = null;
                      isError = false;
                    });
                  }
                }
                oldText = text;
              }
            },
          ),
        ],
      ),
    );
  }


  bool isCorrect(String reqex, String em) {
    RegExp regExp = RegExp(reqex);
    return regExp.hasMatch(em);
  }
  Future<bool> checkDuplication() async{
    try{
      final uri = Uri.parse(commonUri+'/V1/Auth/DuplCheck.json');
      var params = {
        'searchType' : widget.searchType,
        'searchValue' : widget.controller.text,
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JResponse _response;
      if(response.statusCode == 200){
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_response.resultCode == 'SUCC')
          return true;
        else
          return false;
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
          return false;
      } 
    } catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
        return false;
    }
  }
}

class Terms extends StatefulWidget {
  @override
  _TermsState createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  bool valueAll = false;
  bool value1 = false;
  bool value2 = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          title: Text('모든 약관에 동의합니다.', style: Theme.of(context).textTheme.headline5),
          value: valueAll,
          onChanged: (value){
          setState(() {
            valueAll = value;
            if(valueAll)
              setState(() {
                value1 = true;
                value2 = true;
              });
            else 
              setState(() {
                value1 = false;
                value2 = false;
              });
          });
        }),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          tileColor: Color(0xFFF3F3F3),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          secondary: IconButton(
            icon : SvgPicture.asset('assets/arrowRight.svg'),
            onPressed: (){
            },
          ),
          title: Text('서비스 이용약관 (필수)', style: Theme.of(context).textTheme.headline5),
          value: value1, onChanged: (value){
          setState(() {
            value1 = value;
            if(value == false)
              valueAll = false;
          });
        }),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          tileColor: Color(0xFFF3F3F3),
          controlAffinity: ListTileControlAffinity.leading,
          secondary: IconButton(
            icon : SvgPicture.asset('assets/arrowRight.svg'), 
            onPressed: (){
              
            },
          ),
          title: Text('개인정보 취급 방침 (필수)', style: Theme.of(context).textTheme.headline5 ),
          value: value2, onChanged: (value){
          setState(() {
            value2 = value;
            if(value == false)
              valueAll = false;
          });
        })
      ],
    );
  }
}