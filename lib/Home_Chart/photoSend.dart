import 'dart:async';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert'; //json 변환할때
import 'package:craits/_JClass/recordInfo.dart';
import 'package:intl/intl.dart';
import 'chartEnvelopeResponse.dart';
import 'chartPrescriptionResponse.dart';
import 'chartReceiptResponse.dart';
import 'package:path_provider/path_provider.dart';
//
//진료기록쓰기 -> 사진등록 -> 잠시 기다려주세요~ 화면
//
class Photo extends StatefulWidget {
  final File _image;
  final Function onApply;
  
  Photo(this._image, this.onApply);

  @override
  _PhotoState createState() =>_PhotoState(_image);
}

class _PhotoState extends State<Photo> {
  final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RecordRequest.json');
  final File _image;
  _PhotoState(this._image);
  final String url = ''; //
  var recordInfo;

  Future photoSend() async {
    try{

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      
      String fileName = DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString();//이미지 파일명 

      var params = {
        'user_auth_id' : user.userAuthId,
      };
      
      //전송
      final newUri = uri.replace(queryParameters: params);
      var headers = {"Content-Type": "multipart/form-data"};
      var request = http.MultipartRequest('POST', newUri);
      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath('picture', _image.path, filename: '$fileName.jpg'),  
      );
      var response = await request.send();

      //응답화면으로 넘어가기
      if(response.statusCode == 200){
        response.stream.transform(utf8.decoder).listen((event) { 
        JRecordRequest _recordRequest = JRecordRequest.fromJson(jsonDecode(event));
        if(_recordRequest != null && _recordRequest.resultCode!= 'FAIL'){
          String sType = _recordRequest.info.recordType;
          if(sType == 'E') {
            JRecordInfoE _recordinfo = JRecordInfoE.fromJson(jsonDecode(event));
            setState(() {
              recordInfo = _recordinfo;
            });
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => 
              ChartEnvelopeResponse(recordInfo, (){
                widget.onApply();
                _image.copy('$appDocPath/$fileName.jpg',); //기록 저장할때 이미지 내부 데이터 저장
              })));
          }
          else if (sType == 'P') {
            JRecordInfoP _recordinfo = JRecordInfoP.fromJson(jsonDecode(event));
            setState(() {
              recordInfo = _recordinfo;
            });
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => 
              ChartPrescriptionResponse(recordInfo,  (){
                widget.onApply();
                _image.copy('$appDocPath/$fileName.jpg',); //기록 저장할때 이미지 내부 데이터 저장
              })));
          }
          else {
            JRecordInfoR _recordinfo = JRecordInfoR.fromJson(jsonDecode(event));
            setState(() {
              recordInfo = _recordinfo;
            });
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => 
              ChartReceiptResponse(recordInfo, (){
                widget.onApply();
                _image.copy('$appDocPath/$fileName.jpg',); //기록 저장할때 이미지 내부 데이터 저장
              })));
          }
          //오처방, 중복처방 확인 다이얼로그
          if(sType != 'R'){
            if(recordInfo.info.resultTypes!= null){
              showDialog(
                context: context, builder: (context) 
                => AlertDialog(
                    titlePadding: EdgeInsets.all(20),
                    elevation: 0.0,
                    backgroundColor: Colors.white,
                    actionsOverflowButtonSpacing: 20,
                    insetPadding: EdgeInsets.fromLTRB(0,0,0,0),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Container(
                        padding:EdgeInsets.all(20), child: SvgPicture.asset('assets/error.svg')),
                      Container(
                        padding:EdgeInsets.all(5), child: Text('처방전에 ${medicineTypes(recordInfo.info.resultTypes)}이 있습니다.', style: Theme.of(context).textTheme.bodyText1)),
                      Container(
                        child: Text('지금 바로 확인해주세요.', style: Theme.of(context).textTheme.bodyText1)),
                      ],
                    ),
                    actions: [
                      Container(
                        child: TextButton( child:Text('확인', style: Theme.of(context).textTheme.headline3), onPressed: (){
                          Navigator.pop(context);
                        },)),
                    ],
                  ));
              }
          }
        }  
        else {
          showDialog(context: context, builder: (context) => OkDialog(
            onOk: () => Navigator.pop(context),
            text:  _recordRequest.resultMsg ?? '정보 인식에 실패했습니다.',
          ));
        }
      });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    } on TimeoutException catch(_){
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

  double margin = 0;

  @override
  void initState() {
    photoSend();
    animate();
    super.initState();
  }

  Future animate() async{
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      margin = 500;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('정보를 읽고 있는 중입니다.',
              style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Text(
              '사진의 크기가 클 경우 인식 시간이 길어질 수 있습니다.', 
              style: TextStyle(color: Colors.white, fontSize: 13.0), 
              textAlign: TextAlign.center,),
            Text(
              '조금만 기다려주세요.', 
              style: TextStyle(color: Colors.white, fontSize: 13.0), 
              textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Container(
                height: 500,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.0),child: Image.file(_image)),
                    Positioned(
                      top: -100,
                      child: AnimatedContainer(
                        onEnd: (){
                          setState(() {
                            margin == 500?
                              margin = 0 : margin = 500;
                          });
                        },
                        height: 100,
                        margin: EdgeInsets.only(top: margin),
                        duration: Duration(milliseconds: 5000),
                        child: SvgPicture.asset('assets/animation.svg'),
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      )
    );
  }
}