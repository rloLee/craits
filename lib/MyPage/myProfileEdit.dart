import 'dart:convert';
import 'dart:io';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:craits/Common/com.dart';
import 'package:craits/MyPage/myProfileImage.dart';
import 'package:craits/_JClass/profileInfo.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/calendar.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:craits/_JClass/response.dart';
import 'package:http/http.dart' as http;
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

final key = new GlobalKey<_TextFieldDuplicationInfoState>();

class MyProfileEdit extends StatefulWidget {
  final JProfileInfo profileInfo;
  MyProfileEdit(this.profileInfo);

  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {
  final cropKey = GlobalKey<CropState>();
  final picker = ImagePicker();
  File _image;
  bool bImageChanged = false;
  String strBirthday;
  
  TextEditingController textNicknameController = TextEditingController();
  TextFieldDuplicationInfo textNickName;
  TextFieldInfo bloodtype;
  TextFieldInfo weight;
  TextFieldInfo height;

  @override
  void initState() {
    strBirthday = widget.profileInfo!=null ? widget.profileInfo.info.birthday : '';
    textNickName = TextFieldDuplicationInfo(
      key: key,
      title: '닉네임', 
      hintText: '2~15자 한글, 영문, 숫자로 입력해주세요.', 
      initText: widget.profileInfo.info.name ?? '',
      controller: textNicknameController,
      searchType: 'NAME',
    );
    bloodtype = TextFieldInfo(title: '혈액형', initText: widget.profileInfo.info.bloodType ?? '',);
    weight = TextFieldInfo(title: '몸무게', initText: widget.profileInfo.info.weight.toString(), inputType: TextInputType.number,);
    height = TextFieldInfo(title: '키', initText: widget.profileInfo.info.height.toString(), inputType: TextInputType.number,);
    super.initState();
  }
  
  Future getImage(ImageSource _source, BuildContext context) async {
    try{
      final pickedFile = await picker.getImage(source: _source);

      if (pickedFile != null) {
        
        _image = File(pickedFile.path);

        var file = await Navigator.push(context, MaterialPageRoute(builder: (context)=> MyProfileImage(_image)));

        if(file!=null){
          setState(() {
            _image = file;
            bImageChanged = true;
          });
        }
      } 
    } on PlatformException catch (error) {
      print(error);
    } catch (error) {
      print(error);
    }
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
          title: Text('프로필'),
          leading: IconButton(
            icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
          })),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: Column(
                children: [
                  ClipOval(
                    child: (bImageChanged)?
                    Image.file(_image, width: 100, height:100, fit: BoxFit.cover)
                    : (widget.profileInfo != null && widget.profileInfo.info.imageUrl != null)?
                      Image.network(widget.profileInfo.info.imageUrl, width:100, height:100, fit: BoxFit.cover,
                        errorBuilder: (context, exception, stackTrace){
                          return Image.asset('assets/noProfile.png', width:100, height:100, fit: BoxFit.cover);
                        },)   
                      : Image.asset('assets/noProfile.png', width:100, height:100, fit: BoxFit.cover),
                  ),
                  MaterialButton(
                    minWidth: 0,
                    height: 0,
                    child: Text('프로필 사진 변경', style: Theme.of(context).textTheme.subtitle2,), 
                    onPressed: (){
                      showAdaptiveActionSheet(
                        context: context,
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: Text('사진 찍기', style: Theme.of(context).textTheme.headline4,),
                            onPressed: () {
                              //카메라 실행
                              getImage(ImageSource.camera, context);
                              Navigator.of(context).pop();
                            },
                          ),
                            BottomSheetAction(
                            title: Text('사진 보관함', style: Theme.of(context).textTheme.headline4,),
                            onPressed: (){
                              //저장소
                              getImage(ImageSource.gallery, context);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                        cancelAction: CancelAction(
                          title: Text('취소', style: Theme.of(context).textTheme.headline4,))
                      );
                    },
                  )
                ],
              ),),
              Text('이메일', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
              SizedBox(height: 5,),
              TextField(
                cursorColor: Theme.of(context).primaryColor,
                style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
                decoration: InputDecoration(
                  hintText: (user.email!=null)? user.email : '',
                  contentPadding: const EdgeInsets.all(10),
                  enabled: false,
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
              textNickName,
              Text('생일', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
              SizedBox(height: 5,),
              MaterialButton(
                padding: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.all(7.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strBirthday, style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontWeight: FontWeight.w500), textAlign: TextAlign.start,),
                    ]
                  ),
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),  
                    color: const Color(0xFFF3F3F3),
                    border: Border.all(
                      color: const Color(0xFFEAEAEA)
                    )
                  ),
                ),
                onPressed: () async{
                  DateTime _dateTime = DateTime.tryParse(strBirthday) ?? DateTime.now();
                  final result = await showDialog(context: context, builder: (context) => MyCalendar(_dateTime, DateRangePickerView.decade));
                  setState(() {
                    if(result != null){
                      strBirthday = DateFormat('yyyy-MM-dd').format(result).toString();
                    }
                  });
                }),
              bloodtype,
              weight,
              height,
              SizedBox(height: 10,),
              DefaultButton(
                text: '프로필 수정',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if(key.currentState.isError == false && key.currentState.isChecked)
                    updateProfile();
                  else {
                    showDialog(context: context, builder: (context)=>OkDialog(text: '닉네임을 확인해주세요.', onOk:(){}));
                  }
                }),
            ],
          ),
        )
      ),
    );
  }

  Future updateProfile() async{
      final uri = Uri.parse(commonUri + '/V1/Auth/UpdateProfile.json');

      showDialog(context: context,barrierDismissible: false,  builder: (_)  => LoadingDialog());
      var params = {
        'user_auth_id' : user.userAuthId,
        'name' : textNicknameController.text,
        'birthday' : strBirthday,
        'blood_type' : bloodtype.finalText(),
        'weight' : weight.finalText(),
        'height' : height.finalText(),
      };

      final newUri = uri.replace(queryParameters: params);
      var headers = {"Content-Type": "multipart/form-data"};
      var request = http.MultipartRequest('POST', newUri);
      request.headers.addAll(headers);

      if(_image != null)
        request.files.add(
          await http.MultipartFile.fromPath('picture', _image.path),
        );

      var response = await request.send();

      Navigator.pop(context); //로딩끝

      JResponse _response;
      if(response.statusCode == 200){
        response.stream.transform(utf8.decoder).listen((event) { 
          _response = JResponse.fromJson(jsonDecode(event));
          if(_response.resultCode == 'SUCC')
            Navigator.pop(context, true);
          else
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1500),
                content: Text('오류가 발생했습니다.'))
            );
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
  }
} 

class TextFieldInfo extends StatelessWidget {
  final String title;
  final String initText;
  final TextInputType inputType;
  final TextEditingController controller = TextEditingController();

  TextFieldInfo({
    @required this.title,
    @required this.initText,
    this.inputType = TextInputType.text
  }){
    controller.text = initText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          TextField(
            controller: controller,
            keyboardType: inputType,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(fontSize: 14.0, color: Color(0xFF262626),),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
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
                  color: const Color(0xFFEAEAEA),
                  width: 1
                  ),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  setText(String text){
    controller.text = text;
  }

  String finalText(){
    return controller.text;
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
    Key key,
    @required this.title,
    @required this.controller,
    @required this.searchType,
    @required this.hintText,
    this.initText,
    this.inputType = TextInputType.text,
  }): super(key: key);

  @override
  _TextFieldDuplicationInfoState createState() => _TextFieldDuplicationInfoState();
}

class _TextFieldDuplicationInfoState extends State<TextFieldDuplicationInfo> {
  String nicknameRegexp = r'^[a-zA-Z가-힣0-9]{2,15}$';
  String errorText; 
  String helperText;
  bool isChecked = true;
  bool isError = false;
  String oldText;
  String orgText;

  @override
  void initState() {
    if(widget.initText != null){
      setState(() {
        widget.controller.text = widget.initText;
        oldText = widget.initText;
        orgText = widget.initText;
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
          Text(widget.title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          TextFormField(
            controller: widget.controller,
            keyboardType: widget.inputType,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(fontSize: 14.0, color: const Color(0xFF262626)),
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
              suffix: widget.controller.text == orgText? null
                : GestureDetector(
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
                if(widget.searchType == 'NAME') {
                  if(isCorrect(nicknameRegexp, widget.controller.text) == false){
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
      final uri = Uri.parse(commonUri + '/V1/Auth/DuplCheck.json');
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
