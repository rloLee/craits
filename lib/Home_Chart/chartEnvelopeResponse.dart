import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Chart/chartDetail.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:craits/_JClass/recordResult.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'chartEnvelopeResponseEdit.dart';
//
//진료기록쓰기 사진 등록 -> 약봉투 응답 받았을 때 화면
//
class ChartEnvelopeResponse extends StatefulWidget {
  final JRecordInfoE recordInfo;
  final Function onApply;
  ChartEnvelopeResponse(this.recordInfo, this.onApply);

  @override
  _ChartEnvelopeResponseState createState() => _ChartEnvelopeResponseState();
}

class _ChartEnvelopeResponseState extends State<ChartEnvelopeResponse> {
  JRecordInfoE recordInfo;

  @override
  void initState() {
    recordInfo = widget.recordInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        elevation: 1.0,
        title: const Text('정보 확인'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/close.svg'), 
            onPressed: (){
              Navigator.pop(context);
            }),
        ],
      ),
      body: recordInfo !=null
        ? Container(
          color: const Color(0xFFF2F4F6),
          child: SingleChildScrollView(
            child: Column(
              children: [
                pharmacyInfo(),
                medicineList(recordInfo.info.medicineList),
                paymentInfo(),
                otherInfo(),
                buttons()
              ],
            ),
          ),
        )
        : Container(
            width: double.infinity,
            child: Center(
              child: CircularProgressIndicator(),
              widthFactor: 0.5,
              heightFactor: 2,
            ),
          ),
    );
  }

//처방의약품
  Container medicineList(List<JRecordInfoMedicineListUnit> medicineList){
    List<Widget> medicineWidgetList = [];
    for(JRecordInfoMedicineListUnit medicine in medicineList){
      medicineWidgetList.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row( 
            children: [
              Expanded(
                flex: 5, 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name, 
                            style:
                              medicine.match != 'N'
                              ? (medicine.resultType!= null && medicine.resultType.length > 0)? TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: Colors.red) :  Theme.of(context).textTheme.headline2
                              :  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: Color(0xFFEC7676))),
                          if(medicine.resultType!= null && medicine.resultType.length > 0)
                            Text('- ${medicineType(medicine.resultType)}', style: TextStyle(color: Color(0xFFEC7676)),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex:5, 
                child: Row(
                  children: [
                    //복용량이 숫자인지 확인 후 아니면 0으로 빨간 글씨로 표시
                    if(int.tryParse(medicine.doseSize.toString())!= null)
                      Expanded(child: Text(medicine.doseSize, style: TextStyle( color: const Color(0xFF777777), fontSize: 16), textAlign: TextAlign.right,))
                    else
                      Expanded(child: Text('인식오류', style: TextStyle( color: const Color(0xFFEC7676), fontSize: 14), textAlign: TextAlign.right,)),

                    //복용횟수가 숫자인지 확인 후 아니면 0으로 빨간 글씨로 표시
                    if(int.tryParse(medicine.doseNumber.toString())!= null)
                      Expanded(child: Text(medicine.doseNumber, style: TextStyle( color:const Color(0xFF777777),fontSize: 16), textAlign: TextAlign.right ))
                    else
                      Expanded(child: Text('인식오류', style: TextStyle( color: const Color(0xFFEC7676), fontSize: 14), textAlign: TextAlign.right,)),

                    //복용일수가 숫자인지 확인 후 아니면 0으로 빨간 글씨로 표시
                    if(int.tryParse(medicine.doseDays.toString())!= null)
                      Expanded(child: Text(medicine.doseDays, style: TextStyle( color:const Color(0xFF777777),fontSize: 16), textAlign: TextAlign.right ))
                    else
                      Expanded(child: Text('인식오류', style: TextStyle( color: const Color(0xFFEC7676), fontSize: 14), textAlign: TextAlign.right,)),
                  ],
                )
              ),
            ],
          ),
        )
      );
      if(int.tryParse(medicine.doseSize.toString()) == null)
        medicine.doseSize = '0';
      if(int.tryParse(medicine.doseNumber.toString()) == null)
        medicine.doseNumber = '0';
      if(int.tryParse(medicine.doseDays.toString()) == null) 
        medicine.doseDays = '0';
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('처방 의약품', style: Theme.of(context).textTheme.headline1, ),
          SizedBox(height: 10,),
          Row(children: [
            Expanded(
              flex:5,
              child: Text('의약품명', style: Theme.of(context).textTheme.subtitle2,)),
            Expanded(
              flex:5,
              child: Row(
                children: [
                  Expanded(child: Text('투약량', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.right)),
                  Expanded(child: Text('횟수', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.right)),
                  Expanded(child: Text('일수', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.right)),
              ],),
            )
          ],),
          Divider( height: 20,),
          ...medicineWidgetList
      ],),
    );
  }

  //약국정보
  Container pharmacyInfo(){
    return Container(
      height: 120,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Row(
          children: [
            Container( padding: EdgeInsets.only(right: 15), child: SvgPicture.asset('assets/hospital.svg')),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: Text(recordInfo.info.pharmacyName ?? '', style: Theme.of(context).textTheme.headline3)),
                    Flexible(child: Text(recordInfo.info.pharmacyAddr ?? '', style: Theme.of(context).textTheme.subtitle2,)),
                    Flexible(child: Text(recordInfo.info.pharmacyTel ?? '', style: Theme.of(context).textTheme.subtitle2,)),
                  ],
                ),
              ),
            ),
            Container(
              child: 
              (recordInfo.info.imageUrl!= null)? 
              Image.network(recordInfo.info.imageUrl, fit: BoxFit.contain , 
                errorBuilder: (context, exception, stackTrace){
                  return SvgPicture.asset('assets/noImage.svg', fit: BoxFit.contain);
                },) 
              : SvgPicture.asset('assets/noImage.svg', fit: BoxFit.contain),
            )
          ],
        ),
    );
  }

  //기타
  Container otherInfo(){
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('환자명', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.patientName ?? '', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('약사명', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.pharmacistName ?? '', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('조제일자', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.medicineDate ?? '', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('투약일', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.totalTakeDays ?? '', style: Theme.of(context).textTheme.bodyText1)
          ],)
      ],),
    );
  }


  //비용
  Container paymentInfo(){

    Widget payment  = Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비용', style: Theme.of(context).textTheme.headline2, ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('약제비 총액', style: Theme.of(context).textTheme.subtitle2,),
              if(int.tryParse(recordInfo.info.paymentTotal.toString())!= null) //숫자인지 확인
                Text(recordInfo.info.paymentTotal, style: Theme.of(context).textTheme.bodyText1)
              else
                Text('인식오류', style: TextStyle( color: const Color(0xFFEC7676)),)

          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('본인 부담금', style: Theme.of(context).textTheme.subtitle2,),
              if(int.tryParse(recordInfo.info.paymentSelf.toString())!= null) //숫자인지 확인
                Text(recordInfo.info.paymentSelf ?? '', style: Theme.of(context).textTheme.bodyText1)
              else
                Text('인식오류', style: TextStyle( color: const Color(0xFFEC7676)),)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('보험 부담금', style: Theme.of(context).textTheme.subtitle2,),
              if(int.tryParse(recordInfo.info.paymentInsurance.toString())!= null) //숫자인지 확인
                Text(recordInfo.info.paymentInsurance, style: Theme.of(context).textTheme.bodyText1)
              else
                Text('인식오류', style: TextStyle( color: const Color(0xFFEC7676)),)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('비급여(전액 본인)', style: Theme.of(context).textTheme.subtitle2,),
              if(int.tryParse(recordInfo.info.paymentNoneInsurance.toString())!= null) //숫자인지 확인
                Text(recordInfo.info.paymentNoneInsurance, style: Theme.of(context).textTheme.bodyText1)
              else
                Text('인식오류', style: TextStyle( color: const Color(0xFFEC7676)),)
          ],)
      ],),
    );
    
    if(int.tryParse(recordInfo.info.paymentTotal.toString()) == null)
      recordInfo.info.paymentTotal = '0';
    if(int.tryParse(recordInfo.info.paymentSelf.toString()) == null)
      recordInfo.info.paymentSelf = '0';
    if(int.tryParse(recordInfo.info.paymentInsurance.toString()) == null)
      recordInfo.info.paymentInsurance = '0';
    if(int.tryParse(recordInfo.info.paymentNoneInsurance.toString()) == null)
      recordInfo.info.paymentNoneInsurance = '0';

    return payment;
  }

  Container buttons(){
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 15, 8, 15),
              child: DefaultButton(
                text: '정보수정',
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ChartEnvelopeResponseEdit(recordInfo.info, widget.onApply)));
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
              child: DefaultButton(
                text: '저장완료',
                onPressed: (){
                  if(recordInfo.info.patientName == null || recordInfo.info.patientName.toString().isEmpty){
                    showDialog(context: context, builder: (context)=> OkDialog(text: '환자명이 인식되지 않았습니다. 정보수정에서 입력해주세요.', onOk: (){}));
                  }
                  else{
                    postData();
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future postData() async{
    try{
      final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RegisterRecord.json');
      Map<dynamic, dynamic> paramInfo = {
        'user_auth_id' : user.userAuthId,
        'record_id' : recordInfo.info.recordId,
      };
      paramInfo.addAll(recordInfo.info.toJson());

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
          if(_recordResult.info.bundleId.isNotEmpty)
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChartDetail(searchBundleId: _recordResult.info.bundleId, tabIndex: 1,)));
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
      Navigator.pop(context); //Indigator 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
    catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }
}