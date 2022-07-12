import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Chart/chartDetail.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:craits/_JClass/recordResult.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'chartReceiptDetail.dart';
import 'chartReceiptResponseEdit.dart';

class ChartReceiptResponse extends StatefulWidget {
  final JRecordInfoR recordInfo;
  final Function onApply;

  ChartReceiptResponse(this.recordInfo, this.onApply);


  @override
  _ChartReceiptResponseState createState() => _ChartReceiptResponseState();
}

class _ChartReceiptResponseState extends State<ChartReceiptResponse> {
  JRecordInfoR recordInfo;

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
                otherInfo(),
                paymentInfo(recordInfo.info.paymentList),
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
            // Image(image:  NetworkImage(recordInfo.info.imageUrl), width: 100, fit: BoxFit.fill,),\
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


  //진료비세부사항
  Container paymentInfo(List<JRecordInfoPaymentListUnit> paymentList){
    List<String> getPaymentList(String paymentValue){
      var paymentList = paymentValue.split(',');
      return paymentList;
    }
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 10),
            color: Colors.white,
            child: Column(
              children: [
                for(JRecordInfoPaymentListUnit payment in paymentList)
                Container(
                  margin: EdgeInsets.only(bottom: 20  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${payment.type?? ''}', style: Theme.of(context).textTheme.headline3, ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('본인 부담금', style: Theme.of(context).textTheme.caption,),
                          Text(getPaymentList(payment.value)[0], style: Theme.of(context).textTheme.bodyText2,)
                      ],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('공단 부담금', style: Theme.of(context).textTheme.caption,),
                          Text(getPaymentList(payment.value)[1], style: Theme.of(context).textTheme.bodyText2)
                      ],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('전액 본인부담', style: Theme.of(context).textTheme.caption,),
                          Text(getPaymentList(payment.value)[2], style: Theme.of(context).textTheme.bodyText2)
                      ],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('선택 진료료', style: Theme.of(context).textTheme.caption,),
                          Text(getPaymentList(payment.value)[3], style: Theme.of(context).textTheme.bodyText2)
                      ],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('선택진료료 이외', style: Theme.of(context).textTheme.caption,),
                          Text(getPaymentList(payment.value)[4], style: Theme.of(context).textTheme.bodyText2)
                      ],)
                  ],),
                ),
              ],
            ),
          ),
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
                color: const Color(0xFFEC7676),
                text: '정보수정',
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ChartReceiptResponseEdit(recordInfo.info, widget.onApply)));
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChartDetail(searchBundleId: _recordResult.info.bundleId, tabIndex: 2,)));
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