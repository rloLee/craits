import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/imageViewer.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/_JClass/response.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/menu1_Hospital/hospitalDetail.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:flutter_svg/svg.dart';
import 'package:craits/menu3_Medicine/medicineDetail.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

String appDocPath;

// ignore: must_be_immutable
class ChartPrescriptionDetail extends StatefulWidget {
  final String searchRecordId;
  ChartPrescriptionDetail({
    @required this.searchRecordId,
    });
  @override
  _ChartPrescriptionDetailState createState() => _ChartPrescriptionDetailState();
}

class _ChartPrescriptionDetailState extends State<ChartPrescriptionDetail> with AutomaticKeepAliveClientMixin<ChartPrescriptionDetail>  {
  bool get wantKeepAlive => true;
  final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RecordInfo.json');
  JRecordInfoP recordInfo;
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
      if(mounted)
        setState(() {
          body = null;
          bNetworkErr = false;
        });
      String searchId = widget.searchRecordId;
      
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchBundleId' : searchId,  
        'searchRecordType' : 'P',  
      };
      
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JRecordInfoP _recordInfo;
      if(response.statusCode == 200){
        _recordInfo =JRecordInfoP.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
      if(mounted)
        setState(() {
          recordInfo = _recordInfo;
          if(recordInfo.resultCode == 'FAIL') body = NoData('등록된 처방전이 없습니다.');
          else body = bodyData();
        });
    } on TimeoutException catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
      if(mounted)
      setState(() {
        bNetworkErr = true;
      });
    } catch(_) {
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
              child: CircularProgressIndicator(
              ),
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
                    medicinList(recordInfo.info.medicineList),
                    hospitalInfo(),
                    otherInfo(),
                    photo(),
                    // Container(
                    //   padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                    //   color: Colors.white,
                    //   child: DefaultButton(
                    //     text: '수정하기',
                    //     color: const Color(0xFFEC7676),
                    //     onPressed: (){
                    //       Navigator.push(context, MaterialPageRoute(builder: (context)=> ChartPrescriptionResponseEdit(recordInfo.info, (){})));
                    //     },
                    //   )
                    // ),
                  ],
                ),
              ),
            ) ;
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
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
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
          for(JRecordInfoMedicineListUnit medicine in medicineList)
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row( 
              children: [
                Expanded(
                  flex:5, 
                  child: GestureDetector(
                    onTap: (){
                      //약상세정보창
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MedicineDetail(medicineNm: medicine.name, searchId: medicine.id)));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(medicine.name??'', style: Theme.of(context).textTheme.headline3, maxLines: 3, overflow: TextOverflow.ellipsis,),
                              if(medicine.resultType!=null && medicine.resultType.length > 0)...{
                                if(medicine.resultType == 'ALTER')  //대체의약품 -파란색
                                  Text('- ${medicineType(medicine.resultType)}', style: Theme.of(context).textTheme.subtitle1.apply(color: Color(0xFF007AFF)),)
                                else                                //중복처방 OR 오처방 - 빨간색
                                  Text('- ${medicineType(medicine.resultType)}', style: Theme.of(context).textTheme.subtitle1.apply(color: Color(0xFFEC7676)),),
                              },
                              Text(medicineDurs(medicine.resultDurs??''), style: TextStyle(color: Color(0xFFEC7676)),),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                      ],
                    ),
                  )),
                SvgPicture.asset('assets/arrowRight.svg',),
                Expanded(
                  flex:5, 
                  child: Row(
                    children: [
                      Expanded(child: Text(medicine.doseSize?? '0', style: TextStyle( color: Color(0xFF777777), fontSize: 16), textAlign: TextAlign.right,  )),
                      Expanded(child: Text(medicine.doseNumber?? '0', style: TextStyle( color: Color(0xFF777777),fontSize: 16), textAlign: TextAlign.right )),
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

  //병원
  Container hospitalInfo(){
    return Container(
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: MaterialButton(
        padding: EdgeInsets.all(20),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => 
            HospitalDetail(hospitalName: recordInfo.info.hospitalName?? '', searchId: recordInfo.info.hospitalId, searchPosLat:  '0.0', searchPosLng:  '0.0')));
          },
          child: Row(
            children: [
              Container( padding: EdgeInsets.only(right: 15), child: SvgPicture.asset('assets/hospital.svg')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recordInfo.info.hospitalName?? '', style: Theme.of(context).textTheme.bodyText1),
                    Text(recordInfo.info.hospitalAddr?? '', style: Theme.of(context).textTheme.subtitle2,),
                    Text(recordInfo.info.hospitalTel?? '', style: Theme.of(context).textTheme.subtitle2,),
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
              Text('처방 날짜', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.publishedDate?? '' , style: Theme.of(context).textTheme.bodyText1)
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
            :Container(
              child: Center(
                child: SvgPicture.asset('assets/noImage.svg', fit: BoxFit.contain,)
              )
            ) 
        ],
      )
    );
  }
}