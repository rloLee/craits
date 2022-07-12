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
import 'package:craits/menu1_Hospital/hospitalDetail.dart';
import 'package:flutter/material.dart';
import 'package:craits/_JClass/recordInfo.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

String appDocPath;

class ChartReceiptDetail extends StatefulWidget {
  final String searchRecordId;
  final Function onDelete;
  ChartReceiptDetail({
    @required this.searchRecordId,
    this.onDelete
  });
  @override
  _ChartReceiptDetailState createState() => _ChartReceiptDetailState();
}

class _ChartReceiptDetailState extends State<ChartReceiptDetail> with AutomaticKeepAliveClientMixin<ChartReceiptDetail>  {
  bool get wantKeepAlive => true;
  final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RecordInfo.json');
  JRecordInfoR recordInfo;
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
        bNetworkErr = false;
        body = null;
      });
      String searchId = widget.searchRecordId;
      
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchBundleId' : searchId,  
        'searchRecordType' : 'R',  
      };
      
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JRecordInfoR _recordInfo;
      if(response.statusCode == 200){
        _recordInfo =JRecordInfoR.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
      if (mounted)
        setState(() {
          bNetworkErr = true;
        });
      }
      if (mounted)
      setState(() {
        recordInfo = _recordInfo;
        if(recordInfo.resultCode == 'FAIL') 
          body = NoData('등록된 영수증이 없습니다.');
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
    } 
    catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
    }
  }

  Widget bodyData(){
    return Container(
      color: Color(0xFFF2F4F6),
      child: SingleChildScrollView(
        child: Column(
          children: [
            paymentList(recordInfo.info.paymentList),
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
            //       Navigator.push(context, MaterialPageRoute(builder: (context)=> ChartReceiptResponseEdit(recordInfo.info, (){})));
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
                                Navigator.of(context).pop();
                                widget.onDelete();
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


  @override
  Widget build(BuildContext context) {
    return Material(
      child: body?? ( 
        (bNetworkErr)? 
            NetworkErr(onRetry:getData)
          : Center(
              child: CircularProgressIndicator(),
          )
        )
    );
  }

  Future deleteRecord() async{
    final uri = Uri.parse(commonUri + '/V1/MedicalRecord/DeleteRecord.json');
    try{
      showDialog(context: context,barrierDismissible: false, builder: (_)  => LoadingDialog());

      var params = {
        'user_auth_id' : user.userAuthId,
        'record_id' : widget.searchRecordId.toString(), // FEED ID / COMMENT ID / REPLY ID
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
    catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
    }
    return null;
  }

//진료비 세부사항
  Container paymentList(List<JRecordInfoPaymentListUnit> paymentList){

    int totalCorp = 0;
    int totalIns = 0;
    int totalNoIns = 0;

    String getInsurancePayment(JRecordInfoPaymentListUnit payment){
      int pay1 = int.tryParse(payment.getValueSelf());
      int pay2 = int.tryParse(payment.getValueCorp());
      int pay3 = int.tryParse(payment.getValueSelfAll());

      int totalPayment = pay1 + pay2 + pay3;

      totalCorp += pay2; //공단 부담금 
      totalIns += totalPayment;

      return totalPayment.toString();
    }

    String getNoInsurancePayment(JRecordInfoPaymentListUnit payment){
      int pay4 = int.tryParse(payment.getValueSelect());
      int pay5 = int.tryParse(payment.getValueExcSelect());

      int totalPayment = pay4 + pay5;

      totalNoIns += totalPayment;

      return totalPayment.toString();
    }

    return Container(
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비용', style: Theme.of(context).textTheme.headline1, ),
          SizedBox(height: 10,),
          Row(children: [
            Expanded(
              flex:1,
              child: Text('항목', style: Theme.of(context).textTheme.subtitle2,)),
            Expanded(
              flex:1,
              child: Row(
                children: [ 
                  Expanded(child: Text('급여', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.right)),
                  Expanded(child: Text('비급여', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.right)),
              ],),
            )
          ],),
          Divider( height: 10, color: Color(0xFFF3F3F3),),
          for(JRecordInfoPaymentListUnit payment in paymentList)
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row( 
                children: [
                  Expanded(
                    flex:1, 
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(payment.description, style: Theme.of(context).textTheme.bodyText1),
                            ],
                          ),
                        ),
                      ],
                    )),
                  Expanded(
                    flex:1, 
                    child: Row(
                      children: [
                        Expanded(child: Text('${getInsurancePayment(payment)}원', style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.right,  )),
                        Expanded(child: Text('${getNoInsurancePayment(payment)}원', style:Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.right,  )),
                      ],
                    )
                  ),
                ],
              ),
            ),
          Divider( height: 5, color: Color(0xFFF3F3F3),),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row( 
              children: [
                Expanded(
                  flex:1, 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('합계',  style: TextStyle(color: Color(0xFF262626), fontSize: 14.0, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  )),
                Expanded(
                  flex:1, 
                  child: Row(
                    children: [
                      Expanded(child: Text('$totalIns원', style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.right,  )),
                      Expanded(child: Text('$totalNoIns원', style:Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.right,  )),
                    ],
                  )
                ),
              ],
            ),
          ),
          Divider( height: 5, color: Color(0xFFF3F3F3),),
          //진료비총액
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row( 
              children: [
                Expanded(
                  flex:1, 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('진료비 총액',  style: TextStyle(color: Color(0xFF262626), fontSize: 14.0, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  )),
                Expanded(
                  flex:1, 
                  child: Row(
                    children: [
                      Expanded(child: Text('${totalIns + totalNoIns}원', style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.right,  )),
                    ],
                  )
                ),
              ],
            ),
          ),
          //공단부담
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Row( 
              children: [
                Expanded(
                  flex:1, 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('공단부담', style: TextStyle(color: Color(0xFF959595), fontSize: 14.0, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  )),
                Expanded(
                  flex:1, 
                  child: Row(
                    children: [
                      Expanded(child: Text('- ${totalCorp}원', style: Theme.of(context).textTheme.subtitle2, textAlign: TextAlign.right,  )),
                    ],
                  )
                ),
              ],
            ),
          ),
          Divider( height: 5, color: Color(0xFFF3F3F3),),
          //환자부담총액
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row( 
              children: [
                Expanded(
                  flex:1, 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('환자부담총액',  style: Theme.of(context).textTheme.headline3, textScaleFactor: 1.05,),
                          ],
                        ),
                      ),
                    ],
                  )),
                Expanded(
                  flex:1, 
                  child: Row(
                    children: [
                      Expanded(child: Text('${totalIns + totalNoIns - totalCorp}원', style: Theme.of(context).textTheme.headline3, textScaleFactor: 1.05, textAlign: TextAlign.right,  )),
                    ],
                  )
                ),
              ],
            ),
          ),
      ],),
    );
  }

  //약국정보
  Container hospitalInfo(){
    return Container(
      margin: EdgeInsets.only(top: 10),
      color: Colors.white,
      child: MaterialButton(
        padding: EdgeInsets.all(20),
          onPressed: (){
            //약국 상세정보 이동
            Navigator.push(context, MaterialPageRoute(builder: (context) => 
            HospitalDetail(hospitalName: recordInfo.info.hospitalName, searchId: recordInfo.info.hospitalId, searchPosLat: '0.0', searchPosLng: '0.0')));
          },
          child: Row(
            children: [
              Container( padding: EdgeInsets.only(right: 15), child: SvgPicture.asset('assets/hospital.svg')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recordInfo.info.hospitalName?? '', style: Theme.of(context).textTheme.bodyText1),
                    Row(
                      children: [
                        Text(recordInfo.info.hospitalAddr?? '', style: Theme.of(context).textTheme.subtitle2,),
                        Container(
                          height: 12,
                          child: VerticalDivider( thickness: 1, width: 20,)
                        ),
                        Text(recordInfo.info.hospitalTel?? '', style: Theme.of(context).textTheme.subtitle2,),
                      ],
                    ),
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
              Text('처방날짜', style: Theme.of(context).textTheme.subtitle2,),
              Text(recordInfo.info.publishedDate?? '', style: Theme.of(context).textTheme.bodyText1)
          ],)
      ],),
    );
  }

  // Widget photo(){
  //   return Container(
  //     padding: EdgeInsets.all(20),
  //     margin: EdgeInsets.only(top: 10),
  //     color: Colors.white, 
  //     width: double.infinity,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('첨부사진', style: Theme.of(context).textTheme.headline2, ),
  //         SizedBox(height: 10,),
  //         (recordInfo.info.imageUrl!= null)? 
  //           Image.network(recordInfo.info.imageUrl,
  //             headers: {'user_auth_id': user.userAuthId},
  //             width: double.infinity, fit: BoxFit.contain , 
  //             errorBuilder: (context, exception, stackTrace){
  //               return SvgPicture.asset('assets/noImage.svg', fit: BoxFit.fill, );
  //             },) 
  //           : SvgPicture.asset('assets/noImage.svg', fit: BoxFit.fill),
  //       ],
  //     )
  //   );
  // }


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