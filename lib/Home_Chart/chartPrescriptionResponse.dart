import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Chart/chartDetail.dart';
import 'package:craits/Home_Chart/chartReceiptResponse.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:craits/_JClass/recordResult.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'chartPrescriptionResponseEdit.dart';

class ChartPrescriptionResponse extends StatefulWidget {
  final JRecordInfoP recordInfo;
  final Function onApply;

  ChartPrescriptionResponse(this.recordInfo, this.onApply);


  @override
  _ChartPrescriptionResponseState createState() => _ChartPrescriptionResponseState();
}

class _ChartPrescriptionResponseState extends State<ChartPrescriptionResponse> {
  JRecordInfoP recordInfo;

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
                hopitalInfo(),
                medicinList(recordInfo.info.medicineList),
                otherInfo(),
                buttons()
              ],
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

//처방의약품
  Container medicinList(List<JRecordInfoMedicineListUnit> medicineList){

    List<Widget> medicineWidgetList = [];
    for(JRecordInfoMedicineListUnit medicine in medicineList){
      medicineWidgetList.add(
        Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row( 
              children: [
                Expanded(
                  flex:5, 
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine.name.toString(), 
                                style:
                                  medicine.match != 'N'
                                  ? (medicine.resultType!= null && medicine.resultType.length > 0)? TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: Colors.red) :  Theme.of(context).textTheme.headline2
                                  :  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: Color(0xFFEC7676))),
                              //
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
  Container hopitalInfo(){
    return Container(
      height: 120,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Row(
        children: [
          Container( padding: const EdgeInsets.only(right: 15), child: SvgPicture.asset('assets/hospital.svg')),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(recordInfo.info.hospitalName?? '', style: Theme.of(context).textTheme.headline3),
                Text(recordInfo.info.hospitalAddr?? '', style: Theme.of(context).textTheme.subtitle2,),
                Text(recordInfo.info.hospitalTel?? '', style: Theme.of(context).textTheme.subtitle2,),
              ],
            ),
          ),
          Container(
            child: 
            // Image(image:  NetworkImage(recordInfo.info.imageUrl), width: 100, fit: BoxFit.fill,),
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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('처방 날짜', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.publishedDate?? '', style: Theme.of(context).textTheme.bodyText1)
          ],),
      ],),
    );
  }

  Container buttons(){
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 15, 8, 15),
              child: DefaultButton(
                text: '정보수정',
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ChartPrescriptionResponseEdit(recordInfo.info, widget.onApply)));
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 15, 15, 15),
              child: DefaultButton(
                text: '저장완료',
                onPressed: (){
                  postData();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future postData() async{
    try{final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RegisterRecord.json');
      Map<dynamic, dynamic> paramInfo = {
        'user_auth_id' : user.userAuthId,
        'record_id' : recordInfo.info.recordId,
      };
      paramInfo.addAll(recordInfo.info.toJson());

      showDialog(
        barrierDismissible: false,
        context: context, builder: (context) //Indigator 보여주기
      => AlertDialog( 
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(20.0),
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

      //////////
      /////////////http Post
      var body = json.encode(paramInfo);
      http.Response response = await http.post(uri, 
        headers: {"Content-Type": "application/json"},
        body: body
      ).timeout(timeoutDuration);

      Navigator.pop(context); //닫기
      
      JRecordResult _recordResult;
      if(response.statusCode == 200){
        _recordResult = JRecordResult.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_recordResult.resultCode == 'SUCC'){
          if(_recordResult.info.bundleId.isNotEmpty)
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChartDetail(searchBundleId: _recordResult.info.bundleId, tabIndex: 0,),));
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