import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:craits/Etc/popUpDialog_evalute.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:craits/_JClass/response.dart';
import 'package:http/http.dart' as http;
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Chart/chartDetail.dart';
import 'package:craits/MyWidget/customDropdown.dart';
import 'package:craits/_JClass/recordInfoNameList.dart';
import 'package:craits/_JClass/bundleList.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:flutter/material.dart';
import 'package:craits/MyWidget/calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:craits/Home_Chart/photoSend.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
//
//진료기록 리스트 구성
//

bool bDeleteMode = false; 

//진료기록 탭
class HomeMyChart extends StatefulWidget {
  @override
  _HomeMyChartState createState() => _HomeMyChartState();
}

class _HomeMyChartState extends State<HomeMyChart>  with AutomaticKeepAliveClientMixin<HomeMyChart>{
  bool get wantKeepAlive => true;
  final uri = Uri.parse(commonUri + '/V1/MedicalRecord/BundleList.json');
  DateTime dateFrom = DateTime.now().add(Duration(days: -365));
  DateTime dateTo = DateTime.now();
  ScrollController scrollController;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  JBundleList recordList; 
  int iSearchPageNo = 1;
  bool bLoading = true;
  bool bNetworkErr = false;
  Map<String, String> names = {'':'전체'};  //이름 드롭다운 리스트
  Map<String, String> hospitals = {'':'전체'};  //병원 드롭다운 리스트
  List<int> selectedIndex = []; //삭제나 공유하려고 선택한 번들의 'recordList.list의 index'
  String selectedHosipital = ''; 
  String selectedName = '';

  @override
  void initState() {
    setState(() {
      bDeleteMode = false;  //초기엔 delete모드 X
    });
    getNames();     //이름 리스트 불러온 후, 드롭다운 리스트 생성
    getHospitals(); //병원 리스트 불러온 후, 드롭다운 리스트 생성
    getData();      //진료 기록 리스트 불러온 후 recordList로
    
    //스크롤 맨끝 - 진료기록 리스트 Add
    scrollController = ScrollController()
      ..addListener(() {
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent && !bMoreData){
        getMoreData();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  //초기 데이터 가져오기
  Future getData() async {
    try{
      setState(() {
        bLoading = true;
        bNetworkErr = false;
        bDeleteMode = false;
        selectedIndex = [];
      });

      iSearchPageNo = 1;

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchStartDate' : DateFormat('yyyy-MM-dd').format(dateFrom).toString(), //시작날짜(YYYY-MM-DD)
        'searchEndDate' : DateFormat('yyyy-MM-dd').format(dateTo).toString(), //종료날짜(YYYY-MM-DD)
        'searchPatientNm' : selectedName??'',       //선택이름
        'searchHospialNm' : selectedHosipital??'',  //선택병원
        'searchPageNo' : iSearchPageNo.toString(),  //시작인덱스
        'searchPageSize' : '10',  //페이지 크기. 기본:10
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},).timeout(timeoutDuration);

      JBundleList _recordList;
      if(response.statusCode == 200){
        _recordList =JBundleList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
        return;
      }

      if(mounted)
        setState(() {
          recordList = _recordList;
          bLoading = false;
        });
    } 
    on TimeoutException catch(_){
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
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  Future getMoreData() async{
    try{
      if(mounted)
        setState(() {
          bMoreData = true;    
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchStartDate' : DateFormat('yyyy-MM-dd').format(dateFrom).toString(), //시작날짜(yyyy-MM-dd)
        'searchEndDate' : DateFormat('yyyy-MM-dd').format(dateTo).toString(), //종료날짜(yyyy-MM-dd)
        'searchPatientNm' : selectedName??'',       //선택이름
        'searchHospialNm' : selectedHosipital??'',  //선택병원
        'searchPageNo' : (++iSearchPageNo).toString(),  //시작인덱스
        'searchPageSize' : '10',  //페이지 크기. 기본:10
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JBundleList _recordList;
      if(response.statusCode == 200){
        _recordList =JBundleList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
        if(mounted)
          setState(() {
            bMoreData = false;   
          });
      }

      if(mounted)
        setState(() {
          recordList.list.addAll(_recordList.list);
          bMoreData = false;    
        });
    } on TimeoutException catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      if(mounted)
        setState(() {
          bMoreData = false;   
        });
    } 
    catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  Future getNames() async{
    final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RecordResultNameList.json');
    try{			

      var params = {
        'user_auth_id' : user.userAuthId,
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JRecordNameList _recordNameList;
      if(response.statusCode == 200){
        _recordNameList =JRecordNameList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_recordNameList.list.length > 0){
          setState(() {
            names.addAll((Map.fromIterable(_recordNameList.list, key: (e) => e.patientName, value: (e) => e.patientName)));
          });
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        return;
      }

    } on TimeoutException catch(_){
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
          content: Text('오류가 발생했습니다.'))
      );
    }
  }
   
  Future getHospitals() async{
    final uri = Uri.parse(commonUri + '/V1/MedicalRecord/RecordResultHospitalList.json');
    try{	

      var params = {
        'user_auth_id' : user.userAuthId,
      };
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JRecordHospitalList _recordHospitalList;
      if(response.statusCode == 200){
        _recordHospitalList =JRecordHospitalList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(_recordHospitalList.list.length > 0){
          setState(() {
            hospitals.addAll((Map.fromIterable(_recordHospitalList.list, key: (e) => e.hospitalName, value: (e) => e.hospitalName)));
          });
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        return;
      }

    } on TimeoutException catch(_){
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
          content: Text('오류가 발생했습니다.'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: buttonChartUpload(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: getData,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Theme.of(context).backgroundColor, width: 8))
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 45,
                        child: Row(
                          children: [
                          //날짜 변경 버튼
                          Expanded(
                            child: Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 15,),
                                Text('${DateFormat('yyyy.MM.dd').format(dateFrom).toString()}', style: Theme.of(context).textTheme.bodyText1,),
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () async {
                                      final result = await showDialog(context: context, builder: (context) => MyCalendar(dateFrom, DateRangePickerView.month));
                                      setState(() {
                                        if(result != null){
                                          dateFrom = result;
                                          getData();
                                        }
                                      });
                                    },
                                    child:  SvgPicture.asset('assets/calendar 1.svg')
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(child: Text('-', style: Theme.of(context).textTheme.bodyText1,)),
                          Expanded(
                            child: Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 15,),
                                Text('${DateFormat('yyyy.MM.dd').format(dateTo).toString()}', style: Theme.of(context).textTheme.bodyText1,),
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () async {
                                      final result = await showDialog(context: context, builder: (context) => MyCalendar(dateTo, DateRangePickerView.month));
                                      setState(() {
                                        if(result != null){
                                          dateTo = result;
                                          getData();
                                        }
                                      });
                                    },
                                    child:  SvgPicture.asset('assets/calendar 1.svg')
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],),
                    ),
                    if(bDeleteMode)
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: const Color(0xFFE3E3E3)))),
                        height: 45,
                        child: Row(
                          children: [
                            MaterialButton(
                              minWidth: 0,
                              child: SvgPicture.asset('assets/arrowLeft.svg', color: Theme.of(context).primaryColor,),
                              onPressed: (){
                                setState(() {
                                  bDeleteMode = false;
                                });
                                getData();
                              },  
                            ),
                            Expanded(
                              child: Text(selectedIndex.length.toString(),style: Theme.of(context).textTheme.subtitle1,)
                            ),
                            MaterialButton(
                              minWidth: 0,
                              child: SvgPicture.asset('assets/share.svg', color: Theme.of(context).primaryColor,),
                              onPressed: (){
                                shareBundlesImage();
                              }, 
                            ),
                            MaterialButton(
                              minWidth: 0,
                              child: SvgPicture.asset('assets/trash.svg', color: Theme.of(context).primaryColor,),
                              onPressed: (){
                                if(selectedIndex.length > 0){
                                  //선택한 번들 있으면 삭제
                                  deleteBundle().then((result){
                                    if(result){
                                      bDeleteMode = false;
                                      getData();
                                    }
                                    else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          duration: Duration(milliseconds: 1500),
                                          content: Text('오류가 발생했습니다.'))
                                      );
                                    }
                                  });
                                }
                                else{
                                  //선택한 번들 없으면 
                                  bDeleteMode = false;
                                }
                              },  
                            ),
                          ],
                        ),
                      )
                    else
                      //병원선택칸,이름 선택칸
                      Container(
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: const Color(0xFFE3E3E3)))),
                        height: 45,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(border: Border(left: BorderSide(color: const Color(0xFFE3E3E3)))),
                                  child: CustomDropdown(
                                    icon: SvgPicture.asset('assets/arrowDown.svg'),
                                    child: Text(selectedHosipital==''? '병원 선택' : selectedHosipital, style: Theme.of(context).textTheme.subtitle2,),
                                    onChange: (value, key) {
                                      setState(() {
                                        selectedHosipital = key;
                                      });
                                      getData();                                     
                                    },
                                    dropdownButtonStyle: DropdownButtonStyle(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      textStyle: Theme.of(context).textTheme.subtitle2,
                                    ),
                                    dropdownStyle: DropdownStyle(
                                      height: 150,
                                      elevation: 5,
                                      padding: EdgeInsets.all(10),
                                    ),
                                    dropdownItemStyle: DropdownItemStyle(
                                      height: 40,
                                      textStyle: Theme.of(context).textTheme.subtitle2,
                                      highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                                    ),
                                    items:  hospitals?? {}
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(border: Border(left: BorderSide(color: const Color(0xFFE3E3E3)))),
                                  child: CustomDropdown(
                                    icon: SvgPicture.asset('assets/arrowDown.svg'),
                                    child: Text(selectedName==''?'이름 선택' : selectedName, style: Theme.of(context).textTheme.subtitle2,),
                                    onChange: (value, key) {
                                      setState(() {
                                        selectedName = key;
                                      });
                                      getData();
                                    },
                                    dropdownButtonStyle: DropdownButtonStyle(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      textStyle: Theme.of(context).textTheme.subtitle2,
                                    ),
                                    dropdownStyle: DropdownStyle(
                                      height: 200,
                                      elevation: 5,
                                      padding: EdgeInsets.all(10),
                                    ),
                                    dropdownItemStyle: DropdownItemStyle(
                                      height: 40,
                                      textStyle: Theme.of(context).textTheme.subtitle2,
                                      highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                                    ),
                                    items: names ?? {}
                                ),
                              ),
                            ),
                            Container(
                              width: 50,
                              child: Container(
                                decoration: BoxDecoration(border: Border(left: BorderSide(color: const Color(0xFFE3E3E3)))),
                                child: MaterialButton(
                                  padding: EdgeInsets.zero,
                                  minWidth: 0,
                                  child: SvgPicture.asset('assets/write.svg', color: Color(0xFF8B8B8B),),
                                  onPressed: (){
                                    setState(() {
                                      bDeleteMode = true;
                                    });
                                  },
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ])
                )
              ]),
            ),
            chartListview()
        ],),
      ),
    );
  }
  
  //진료기록 리스트뷰
  Widget chartListview()  {
  if(bLoading){
      if(bNetworkErr)
        return SliverFillRemaining(
          child: Center(
            child: NetworkErr(onRetry:getData)
          )
        );
      else
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
            )),
        );
    }
    else{
      if(recordList.resultCode == "FAIL"){
        return SliverFillRemaining(
          child: NoData("등록된 진료기록이 없습니다."),
        );
      }
      else{
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index){
            if(index == recordList.list.length)
              return Center(
                child: CircularProgressIndicator(
                ),
                heightFactor: 2,
              );
              return ChartUnit(
                  // onDelete: (){
                  //   setState(() {
                  //     recordList.list.removeAt(index);
                  //   });
                  // },
                  recordListUnit: recordList.list[index],
                  onDeleteModeChange: (){
                    setState(() {
                      bDeleteMode = true;
                    });
                  },
                  onSelect: (isSelected){
                    if(isSelected){
                      setState(() {
                        selectedIndex.add(index);
                      });
                    }
                    else{
                      setState(() {
                        selectedIndex.remove(index);
                      });
                    }
                  },
                );
          },
          childCount: bMoreData? recordList.list.length + 1 : recordList.list.length,
        ));
      }
    }
  }

  FloatingActionButton buttonChartUpload(){
    File _image;
    final picker = ImagePicker();
    Future getImage(ImageSource _source, BuildContext context) async {
      try{
        final pickedFile = await picker.pickImage(source: _source, maxWidth: 1080, preferredCameraDevice: CameraDevice.rear);
        setState(() {
          if (pickedFile != null){
            _image = File(pickedFile.path);
            Navigator.push(context, MaterialPageRoute(builder: (context) => Photo(_image, (){ getData(); } )));
          } 
        });
      } on PlatformException catch (_) {
      } catch (_) {
      }
    }
    return FloatingActionButton(
        heroTag: 'chartButton',
        onPressed: () {
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
        child: SvgPicture.asset('assets/camera.svg'),
        backgroundColor: Theme.of(context).primaryColor,
      );
    }
    
  shareBundlesImage() async {
    try{
      //선택한 번들 아이디 ',' 연결
      List<List<JRecordList>> list = selectedIndex.map((index) => recordList.list[index].recordList).toList();

      List<String> imageFilesName = [];
      list.forEach((element) {
       imageFilesName.addAll(element.map((e) => e.imageOriginal));
      });

      List<String> imageFilesPath = [];
      
      final Directory _appDocDir = await getApplicationDocumentsDirectory();
      final String _appDocPath = _appDocDir.path;

      // int _noImageCnt = 0;
      for(var file in imageFilesName){
        await File('$_appDocPath/$file').exists().then((value)async {
          if(value){
            imageFilesPath.add('$_appDocPath/$file');
          }
          // else{
          //   _noImageCnt ++;
          // }
        });
      }
      
      if(imageFilesPath.length > 0){
        Share.shareFiles(imageFilesPath).catchError((_){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('오류가 발생했습니다.'))
          );
        });
      }
      else{
        showDialog(context: context, builder: (context)=>OkDialog(text: '원본 사진이 모두 만료되어 불러올 수 없습니다.', onOk: (){
          setState(() {
            bDeleteMode = false;
          });
          getData();
        }));
      }
    }
    catch(_){
      return false;
    }
  } 

  Future<bool> deleteBundle() async {
    final uri = Uri.parse(commonUri + '/V1/MedicalRecord/DeleteBundle.json');
    try{
      //선택한 번들 아이디 ',' 연결
      String bundleIds = selectedIndex.map((index) => recordList.list[index].bundleId).join(',');
      //선택한 이미지 파일명 list화 
      List<List<JRecordList>> a = selectedIndex.map((index) => recordList.list[index].recordList).toList();
      List<String> imageFiles = [];
      a.forEach((element) {
       imageFiles.addAll(element.map((e) => e.imageOriginal));
      });

      var params = {
        'user_auth_id' : user.userAuthId,
        'bundle_ids' : bundleIds
      };
      
      showDialog(context: context, builder: (context)=> LoadingDialog());

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      Navigator.pop(context);
      
      JResponse _response;
      if(response.statusCode == 200){
        _response = JResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

        if(_response.resultCode =='SUCC'){
          //어플데이터에서 사진파일들 삭제
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          imageFiles.forEach((file) async {
            await File('$appDocPath/$file').exists().then((value) async{
              if(value)
                await File('$appDocPath/$file').delete();
            });
          });

          return true;
        }
        else{
          return false;
        }
      }
      else {
        return false;
      }
    }
    catch(_){
      return false;
    }
  }
}

//진료기록 낱개
class ChartUnit extends StatefulWidget {

  final JBundleListUnit recordListUnit;
  final Function onDeleteModeChange;  //deletemode로 변경
  final Function(bool) onSelect; //check 변경 시
  ChartUnit({
    Key key, 
    @required this.recordListUnit, 
    // @required this.onDelete, 
    @required this.onDeleteModeChange,
    @required this.onSelect,
  }):super(key: key);

  @override
  _ChartUnitState createState() => _ChartUnitState();
}

class _ChartUnitState extends State<ChartUnit> with AutomaticKeepAliveClientMixin<ChartUnit>{
  bool get wantKeepAlive => true;
  bool bSelected;
  int tabIndex = 0;
  @override
  void initState() {
    bSelected = false;
    
    bool b1 = false;
    bool b2 = false;
    bool b3 = false;

    widget.recordListUnit.recordList.forEach((record) {
      if(record.recordType == 'P') b1 = true;
      else if(record.recordType == 'E') b2 = true;
      else if(record.recordType == 'R') b3 = true;
    });

    if(b1) tabIndex = 0;
    else if (b2) tabIndex = 1;
    else if (b3) tabIndex = 2;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(bDeleteMode){
          setState(() {
            bSelected = !bSelected;
          });
          widget.onSelect(bSelected);
        }
        else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => 
          ChartDetail(searchBundleId: widget.recordListUnit.bundleId.toString(), tabIndex: tabIndex,)));
        }
      },
      onLongPress: (){
        widget.onDeleteModeChange();
        setState(() {
          bSelected = !bSelected;
        });
        widget.onSelect(bSelected);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).backgroundColor, width: 8))
        ),
        child: Row(
            children: [
              if(bDeleteMode) 
              Container(
                padding: const EdgeInsets.only(left:20),
                  child: 
                    (bSelected)?
                      Icon(Icons.check_circle, color: Theme.of(context).primaryColor,)
                    :
                      Icon(Icons.circle_outlined, color: Color(0xFFC4C4C4), ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 45,
                        child: Row(//날짜, 리뷰쓰기, 상세보기
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                          children: [
                            Text('${widget.recordListUnit.recordDate.substring(0,4)}.${widget.recordListUnit.recordDate.substring(4,6)}.${widget.recordListUnit.recordDate.substring(6,8)}'??'', style: TextStyle(color: Color(0xFF777777), fontSize: 14.0, fontWeight: FontWeight.w500),), //저장날짜
                            if(!bDeleteMode)
                            TextButton(
                              onPressed: (){
                                showDialog(context: context, builder: (context) => PopupEvalute(bundleId: widget.recordListUnit.bundleId.toString()));
                              }, 
                              child: Text('평가하기', style: Theme.of(context).textTheme.subtitle1,)
                            ), 
                          ],
                        ),
                      ),
                      Divider(),
                      Container(
                        constraints: BoxConstraints(minHeight: 80), //이미지, 병원정보
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(widget.recordListUnit.patientName??'' , style: TextStyle(fontSize: 16.0, color: Color(0xFF262626), fontWeight: FontWeight.w700),),
                                  SizedBox(width: 5,),
                                  Text(widget.recordListUnit.subjectName??'', style: Theme.of(context).textTheme.subtitle2,),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Text(widget.recordListUnit.hospitalName??'', style: Theme.of(context).textTheme.subtitle2,),
                                  SizedBox(width: 5,),
                                  Text(widget.recordListUnit.pharmacyName??'', style: Theme.of(context).textTheme.subtitle2,),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
