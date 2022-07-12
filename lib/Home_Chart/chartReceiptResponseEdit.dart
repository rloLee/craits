import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Chart/chartDetail.dart';
import 'package:craits/_JClass/recordResult.dart';
import 'package:craits/MyWidget/calendar.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'similarHospitalSelect.dart';
import 'package:http/http.dart' as http;
import 'chartReceiptDetail.dart';

class ChartReceiptResponseEdit extends StatefulWidget {
  ChartReceiptResponseEdit(this.recordInfo, this.onApply){
    recordEditInfo = recordInfo.clone();
  }
  final JRecordInfoRInfo recordInfo;
  final Function onApply;
  JRecordInfoRInfo recordEditInfo;

  @override
  _ChartReceiptResponseEditState createState() => _ChartReceiptResponseEditState();
}

class _ChartReceiptResponseEditState extends State<ChartReceiptResponseEdit> {
   DateInfo publishedDate;

  @override
  void initState() {
    publishedDate = DateInfo(recordEditInfo: widget.recordEditInfo);
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        elevation: 1.0,
        title: Text('정보 수정'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
        onPressed: (){
          Navigator.pop(context);
        })),
      body: widget.recordEditInfo !=null
        ? GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: Container(
            color: Color(0xFFF2F4F6),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HospitalInfo(recordEditInfo: widget.recordEditInfo, recordInfo: widget.recordInfo,),
                  publishedDate,
                  for(JRecordInfoPaymentListUnit payment in widget.recordEditInfo.paymentList)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(payment.description?? '', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
                          SizedBox(height: 5,),
                          PaymentInfo(
                            title: '본인 부담금',
                            initText: payment.getValueSelf(),
                            onApply: (value){
                              payment.setValueSelf(value);
                            },),
                          PaymentInfo(
                            title: '공단 부담금',
                            initText: payment.getValueCorp(),
                            onApply: (value){
                              payment.setValueCorp(value);
                          },),
                          PaymentInfo(
                            title: '전액 본인 부담',
                            initText: payment.getValueSelfAll(),
                            onApply: (value){
                              payment.setValueSelfAll(value);
                          },),
                          PaymentInfo(
                            title: '선택 진료료',
                            initText: payment.getValueSelect(),
                            onApply: (value){
                              payment.setValueSelect(value);
                          },),
                          PaymentInfo(
                            title: '선택 진료료 이외',
                            initText: payment.getValueExcSelect(),
                            onApply: (value){
                              payment.setValueExcSelect(value);
                          },),
                      ],),
                    ),

                  Container(
                    padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
                    child: DefaultButton(
                      text: '저장완료',
                      onPressed: (){
                        postData();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        : Container(
          width: double.infinity,
          child: Center(
            child: CircularProgressIndicator(
              ),
              widthFactor: 0.5,
              heightFactor: 2,
          ),
        ),
    );
  }
  
  Future postData() async{
    try{
      final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RegisterRecord.json');

      Map<dynamic, dynamic> paramInfo = {
        'user_auth_id' : user.userAuthId,
        'record_id' : widget.recordInfo.recordId,
      };
      paramInfo.addAll(widget.recordEditInfo.toJson());

      showDialog(
        barrierDismissible: false,
        context: context, builder: (_) //Indigator 보여주기
      => AlertDialog( 
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        content: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(child: CircularProgressIndicator()),
              Text('저장 중입니다.', style: Theme.of(context).textTheme.bodyText1,)
            ],
          ),),
        )
      );

      ///////////////http Post
      var body = json.encode(paramInfo);
      http.Response response = await http.post(uri, 
        headers: {"Content-Type": "application/json"},
        body: body
      ).timeout(timeoutDuration);

      Navigator.pop(context); //Indigator 닫기

      JRecordResult _recordResult;
      if(response.statusCode == 200){
        _recordResult = JRecordResult.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_recordResult.resultCode == 'SUCC'){
          if(_recordResult.info.bundleId.isNotEmpty){
            Navigator.pop(context); //닫기
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChartDetail(searchBundleId: _recordResult.info.bundleId, tabIndex: 2,)));
          }
          else 
            Navigator.pop(context); //닫기
          widget.onApply(); //피드-진료기록 새로고침
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('오류가 발생했습니다.'))
            );
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
      }
    } on TimeoutException catch(_){
      Navigator.pop(context); //닫기
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

class PaymentInfo extends StatelessWidget {
  final Function(String value) onApply;
  final String title;
  final String initText;
  final TextEditingController controller = TextEditingController();

  PaymentInfo({
    @required this.title,
    @required this.onApply,
    @required this.initText
  }){
    controller.text = initText;
  }

  @override
  Widget build(BuildContext context) {
     return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: (value){
              onApply(value);
            },
            keyboardType: TextInputType.number,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              contentPadding:EdgeInsets.all(10),
              prefixText: title,
              prefixStyle: Theme.of(context).textTheme.caption,
              filled: true,
              fillColor: Color(0xFFF3F3F3),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFEAEAEA),
                  width: 1
                  ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFEAEAEA),
                  width: 1
                  ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
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
      color: Colors.white,
      margin: EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(title.length > 0)
            Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          if(title.length > 0)
            SizedBox(height: 5,),
          TextField(
            controller: controller,
            keyboardType: inputType,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(fontSize: 14.0, color: Color(0xFF262626)),
            decoration: InputDecoration(
              contentPadding:EdgeInsets.fromLTRB(10, 10, 10, 0),
              filled: true,
              fillColor: Color(0xFFF3F3F3),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFEAEAEA),
                  width: 1
                  ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFEAEAEA),
                  width: 1
                  ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
class HospitalInfo extends StatefulWidget {
  HospitalInfo({
    @required this.recordEditInfo, 
    @required this.recordInfo
    });
  final JRecordInfoRInfo recordEditInfo;
  final JRecordInfoRInfo recordInfo;

  @override
  _HospitalInfoState createState() => _HospitalInfoState();
}

class _HospitalInfoState extends State<HospitalInfo> {
  String match;

@override
  void initState() {
    match = widget.recordEditInfo.hospitalMatch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('병원 이름', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          MaterialButton(
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 45),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFFF3F3F3),
                border: Border.all(
                  color: (match == 'Y')
                  ? const Color(0xFFEAEAEA)
                  : const Color(0xFFEC7676),
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(widget.recordEditInfo.hospitalName?? '', style: TextStyle(color: (match == 'Y')
                                  ? const Color(0xFF262626)
                                  : const Color(0xFFEC7676), 
                              fontWeight: FontWeight.w500), ),
                      ),
                        SvgPicture.asset('assets/arrowRight.svg',),
                    ],
                  ),
            ),
              onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=> SimilarHospitalSelect(
                  hospitalName: widget.recordInfo.hospitalName,
                  hospitalList: widget.recordInfo.hospitalList, 
                  onApply: (similarHospital){
                    setState(() {
                      widget.recordEditInfo.hospitalId = similarHospital.id;
                      widget.recordEditInfo.hospitalName = similarHospital.name;
                      widget.recordEditInfo.hospitalAddr = similarHospital.addr;
                      widget.recordEditInfo.hospitalTel = similarHospital.tel;
                      match = 'Y';
                    });
                  })
                  )
              );
            }
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              SvgPicture.asset('assets/location.svg', width:12),
              SizedBox(width:10),
              Flexible(child: Text(widget.recordEditInfo.hospitalAddr?? '', style: Theme.of(context).textTheme.subtitle2,)),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              SvgPicture.asset('assets/tel.svg', width:12),
              SizedBox(width:10),
              Flexible(child: Text(widget.recordEditInfo.hospitalTel?? '', style: Theme.of(context).textTheme.subtitle2,)),
            ],
          )
        ],
      ),
    );
  }
}

class DateInfo extends StatefulWidget {
  final JRecordInfoRInfo recordEditInfo;
  DateInfo({@required this.recordEditInfo});

  @override
  _DateInfoState createState() => _DateInfoState();
}

class _DateInfoState extends State<DateInfo> {
  String strDate;

  @override
  void initState() {
    strDate = widget.recordEditInfo.publishedDate;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('처방일자', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),),
          SizedBox(height: 5,),
          MaterialButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.all(7.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strDate, style: TextStyle(fontSize: 14.0, color: Color(0xFF262626), fontWeight: FontWeight.w500), textAlign: TextAlign.start,),
                ]
              ),
              height: 50,
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
              DateTime _dateTime = DateTime.tryParse(strDate) ?? DateTime.now();
              final result = await showDialog(context: context, builder: (context) => MyCalendar(_dateTime, DateRangePickerView.month));
              setState(() {
                if(result != null){
                  strDate = DateFormat('yyyy-MM-dd').format(result).toString();
                  widget.recordEditInfo.publishedDate = strDate;
                }
              });
            }
          ),
        ],
      ),
    );
  }
}