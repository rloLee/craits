import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/imageViewer.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/defaultButton.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:flutter_svg/svg.dart';
import 'package:craits/menu2_Pharmacy/pharmacyDetail.dart';
import 'package:craits/menu3_Medicine/medicineDetail.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
//
//상세보기 - 약봉투 (진료기록에서 선택했을 때)
//
String appDocPath;

class ChartEnvelopeDetail extends StatefulWidget {
  final String searchRecordId;
  final Function onDelete;
  ChartEnvelopeDetail({
    @required this.searchRecordId, 
    this.onDelete
    });

  @override
  _ChartEnvelopeDetailState createState() => _ChartEnvelopeDetailState();
}

class _ChartEnvelopeDetailState extends State<ChartEnvelopeDetail> with AutomaticKeepAliveClientMixin<ChartEnvelopeDetail> {
  bool get wantKeepAlive => true;
  final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RecordInfo.json');
  JRecordInfoE recordInfo;
  bool bNetworkErr = false;
  Widget body;

  @override
  void initState() {
    pictureFolder();
    getData();
    super.initState();
  }

  Future pictureFolder() async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    appDocPath = appDocDir.path;
  }

  //초기 데이터 가져오기
  Future getData() async {
    try{
      if (mounted)
      setState(() {
        body = null;
        bNetworkErr = false;
      });
      
      String searchId = widget.searchRecordId;
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchBundleId' : searchId,  
        'searchRecordType' : 'E',  
      };

      Uri newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JRecordInfoE _recordInfo;
      if(response.statusCode == 200){
        _recordInfo =JRecordInfoE.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if(mounted)
        setState(() {
          bNetworkErr = true;
        });
      }
      if (mounted)
      setState(() {
        recordInfo = _recordInfo;
        if(recordInfo.resultCode == 'FAIL') 
          body = NoData('등록된 약봉투가 없습니다.');
        else 
          body = bodyData();
      });
    } on TimeoutException catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
      if (mounted)
      setState(() {
        bNetworkErr = true;
      });
    } catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: body ?? ( 
              (bNetworkErr)? 
                NetworkErr(onRetry:getData)
              : Center(
                  child: CircularProgressIndicator(),
                )
      )
    );
  }

  Widget bodyData(){
    return Container(
      color: Color(0xFFF2F4F6),
      child: SingleChildScrollView(
        child: Column(
          children: [
            medicinList(recordInfo.info.medicineList), //의약품리스트
            pharmacyInfo(),
            paymentInfo(),
            otherInfo(),
            photo(),
            // Container(
            //   padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
            //   color: Colors.white,
            //   child: DefaultButton(
            //     text: '수정하기',
            //     color: const Color(0xFFEC7676),
            //     onPressed: (){
            //       Navigator.push(context, MaterialPageRoute(builder: (context)=> ChartEnvelopeResponseEdit(recordInfo.info, (){})));
            //     },
            //   )
            // ),
            if(widget.onDelete != null)
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                color: Colors.white,
                child: DefaultButton(
                  fontColor : Color(0xFFEC7676),
                  text: '삭제하기',
                  color: Colors.white,
                  borderSide: BorderSide(color: Color(0xFFEC7676),),
                  onPressed: (){
                    showDialog(
                      context: context, 
                      builder: (context) => OkCancelDialog(
                        text: '진료기록을 삭제하시겠습니까?', 
                        onOk: (){
                          deleteRecord().then((resultCode) {
                            if(resultCode!=null){
                              if(resultCode == 'SUCC') {
                                widget.onDelete();
                                Navigator.of(context).pop();
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: Duration(milliseconds: 1500),
                                    content: Text('오류가 발생했습니다.'))
                                );
                              }
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: Duration(milliseconds: 1500),
                                  content: Text('오류가 발생했습니다.'))
                              );
                            }
                            Navigator.pop(context);
                          });
                      },)
                    );
                  },
                )
              )
          ],
        ),
      ),
    );
  }

  Future deleteRecord() async{
    final uri = Uri.parse(commonUri + '/V1/MedicalRecord/DeleteRecord.json');
    try{
      showDialog(context: context,barrierDismissible: false,  builder: (_)  => LoadingDialog());

      var params = {
        'user_auth_id' : user.userAuthId,
        'record_id' : widget.searchRecordId.toString(), 
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(Duration(seconds: 15));

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
    } on TimeoutException catch(_){
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
//처방의약품
  Container medicinList(List<JRecordInfoMedicineListUnit> medicineList){

    return Container(
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      padding: EdgeInsets.all(20),
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
          //약, 투약량, 투약횟수
          for(JRecordInfoMedicineListUnit medicine in medicineList)
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row( 
              children: [
                //약 이름 
                Expanded(
                  flex:5, 
                  child: GestureDetector(
                    onTap: (){
                      //약 상세정보 창 띄우기
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MedicineDetail(medicineNm: medicine.name, searchId: medicine.id)));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(medicine.name??'', style: TextStyle(fontSize: 16.0,  color: Colors.red,fontWeight: FontWeight.w700,),),
                              if(medicine.resultType != null && medicine.resultType.toString().length > 0)...{
                                if(medicine.resultType == 'ALTER')  //대체의약품 -파란색
                                  Text('- ${medicineType(medicine.resultType)}', style: TextStyle(color: Color(0xFF007AFF)),)
                                else                                //중복처방 OR 오처방 - 빨간색
                                  Text('- ${medicineType(medicine.resultType)}', style: TextStyle(color: Color(0xFFEC7676)),),
                              },
                              Text(medicineDurs(medicine.resultDurs??''), style: TextStyle(color: Color(0xFFEC7676)),),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                      ],
                    ),
                  )),
                SvgPicture.asset('assets/arrowRight.svg',width: 7,),
                //투약량 횟수
                Expanded(
                  flex:5, 
                  child: Row(
                    children: [
                      Expanded(child: Text(medicine.doseSize??'0', style: TextStyle( color: Color(0xFF777777), fontSize: 16), textAlign: TextAlign.right,  )),
                      Expanded(child: Text(medicine.doseNumber??'0', style: TextStyle( color: Color(0xFF777777),fontSize: 16), textAlign: TextAlign.right )),
                      Expanded(child: Text(medicine.doseDays??'0', style: TextStyle( color: Color(0xFF777777),fontSize: 16), textAlign: TextAlign.right )),
                    ],
                  )
                ),
              ],
            ),
          )
      ],),
    );
  }

  //약국정보
  Container pharmacyInfo(){
    return Container(
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: MaterialButton(
        padding: EdgeInsets.all(20),
          onPressed: (){
            //약국 상세정보 이동
            Navigator.push(context, MaterialPageRoute(builder: (context) => 
            PharmacyDetail(pharmacyName: recordInfo.info.pharmacyName.toString(), searchId: recordInfo.info.pharmacyId, searchPosLat: '0.0', searchPosLng: '0.0')));
          },
          child: Row(
            children: [
              Container( padding: EdgeInsets.only(right: 15), child: SvgPicture.asset('assets/hospital.svg')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recordInfo.info.pharmacyName?? '', style: Theme.of(context).textTheme.bodyText1),
                    Text(recordInfo.info.pharmacyAddr?? '', style: Theme.of(context).textTheme.subtitle2,),
                    Text(recordInfo.info.pharmacyTel?? '', style: Theme.of(context).textTheme.subtitle2,),
                  ],
                ),
              ),
              Container(child:SvgPicture.asset('assets/arrowRight.svg',),)
            ],
          ),
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
              Text(recordInfo.info.patientName??'', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('약사명', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.pharmacistName??'', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('조제일자', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.medicineDate??'', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('투약일', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.totalTakeDays??'', style: Theme.of(context).textTheme.bodyText1)
          ],)
      ],),
    );
  }

  //비용
  Container paymentInfo(){
    return Container(
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
              Text(recordInfo.info.paymentTotal??'', style: Theme.of(context).textTheme.bodyText1,)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('본인 부담금', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.paymentSelf??'', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('보험 부담금', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.paymentInsurance??'', style: Theme.of(context).textTheme.bodyText1)
          ],),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('비급여(전액 본인)', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.paymentNoneInsurance??'', style: Theme.of(context).textTheme.bodyText1)
          ],)
      ],),
    );
  }

  Widget photo() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 10),
      color: Colors.white, 
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('첨부사진', style: Theme.of(context).textTheme.headline2, ),
          SizedBox(height: 10,),
          (recordInfo.info.imageOriginal!= null)? 
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>FileImageViewer(
                  path: '$appDocPath/${recordInfo.info.imageOriginal}',)));
              },
              child: Center(
                child: Image.file(
                  File('$appDocPath/${recordInfo.info.imageOriginal}'),
                  errorBuilder: (context, child, loadingProgress){
                    return Container(
                      child: Center(
                        child: SvgPicture.asset('assets/noImage.svg', fit: BoxFit.contain,)
                      )
                    ) ;
                  },
                ),
              ),
            ) 
            : Container(
              child: Center(
                child: SvgPicture.asset('assets/noImage.svg', fit: BoxFit.contain,)
              )
            ) 
        ],
      )
    );
  }
}