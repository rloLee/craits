import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/customDropdown.dart';
import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:craits/_JClass/filterList.dart';
import 'package:craits/_JClass/geocode.dart';
import 'package:craits/_JClass/reverseGeocode.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/menu1_Hospital/hospitalMap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'hospitalUnit.dart';
import 'hospitalFilter.dart';
import 'package:craits/MyWidget/myAppBar.dart';
import 'package:craits/_JClass/hospitalList.dart';
import 'package:http/http.dart' as http;
import 'package:kpostal/kpostal.dart';

class Hospital extends StatefulWidget {
  final Function goHome;
  Hospital(this.goHome);

  @override
  _HospitalState createState() => _HospitalState();
}

class _HospitalState extends State<Hospital> {
  final uri = Uri.parse(commonUri + '/V1/Hospital/HospitalList.json');
  ScrollController scrollController;
  bool showBackToTopButton = false;
  int cntFilter = 0; 
  List<JFilterListCategoryUnit> selectedList = [];
  int iSearchPageNo = 1;
  JHospitalList hospitalList;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  bool bLoading = true;
  bool bNetworkErr = false;
  String filterSeqs = '';
  
  String valueChoose = 'DISTANCE';
  final Map<String, String> sortItem = {
    'DISTANCE':'거리순',
    'NAME':'이름순',
    'REVIEW':'평점순',
    'LAST':'최신순',
  }; //정렬기준 dropdown 리스트
  int count = 0;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (scrollController.offset >= 400) {
            if(scrollController.position.userScrollDirection == ScrollDirection.forward)
              showBackToTopButton = true; // show the back-to-top button
            else 
              showBackToTopButton = false; // hide the back-to-top button
          } else {
            showBackToTopButton = false; // hide the back-to-top button
      
          }
        });
        if(scrollController.position.pixels == scrollController.position.maxScrollExtent && !bMoreData){
          getMoreData();
        }
      });
    super.initState();
  }

  Future init() async {
    await getPosition();
    getData();
  }

  Future getData() async {
    try{
      if(mounted)
        setState(() {
          bLoading = true;
          bNetworkErr = false;
        });

      iSearchPageNo = 1;

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchOrder' : valueChoose,  //정렬 - NAME : 이름순 - DISTANCE : 거리순 - REVIEW : 평점순 - LAST : 최신순
        'searchPosLat' : dCurLat.toStringAsFixed(5), //위치정보 (위도)
        'searchPosLng' : dCurLong.toStringAsFixed(5), //위치정보 (경도)
        'searchKeyword' : '', //검색어
        'searchFilterSeqs' : filterSeqs, //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        'searchPageNo' : iSearchPageNo.toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
        'searchSido' : sSido, //(시/도)
        'searchSigungu' : sSigungu, //(시/군/구)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JHospitalList _hospitalList;
      if(response.statusCode == 200){
        _hospitalList = JHospitalList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          hospitalList = _hospitalList;
          if(_hospitalList.info != null && hospitalList.info.list != null)
            count = hospitalList.info.list.length;
          bLoading = false;
        });

    } on TimeoutException catch(_){
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
        'searchOrder' : valueChoose,  //정렬 - NAME : 이름순 - DISTANCE : 거리순 - REVIEW : 평점순 - LAST : 최신순
        'searchPosLat' : dCurLat.toString(), //위치정보 (위도)
        'searchPosLng' : dCurLong.toString(), //위치정보 (경도)
        'searchKeyword' : '', //검색어
        'searchFilterSeqs' : filterSeqs, //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        'searchPageNo' : (++iSearchPageNo).toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
        'searchSido' : sSido, //(시/도)
        'searchSigungu' : sSigungu, //(시/군/구)
      };
      
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JHospitalList _hospitalList;
      if(response.statusCode == 200){
        _hospitalList = JHospitalList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          hospitalList.info?.list?.addAll(_hospitalList.info?.list);
          count = hospitalList.info.list.length;
          bMoreData = false;    
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

  Future getPosition() async {
    final uriGeo = Uri.parse('https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc');
    bool serviceEnabled;
    LocationPermission permission;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        //위치 권한 거부
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showDialog(context: context, builder: (context)=> OkCancelDialog(text: '이 기능을 사용하려면 설정에서 위치 권한을 허용해야 합니다.', onOk: () async {
          await openAppSettings();
          Navigator.pop(context);
        }));
      }

      if(permission == LocationPermission.whileInUse || permission == LocationPermission.always){
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if(mounted)
          setState(() {
            dCurLong = position.longitude;
            dCurLat = position.latitude;
          });
      }

      var params = {
        'coords' : dCurLong.toString() + ',' + dCurLat.toString(),
        'output' : 'json',  //정렬 - NAME : 이름순 - DISTANCE : 거리순 - REVIEW : 평점순 - LAST : 최신순
      };

      var headers = {
        'X-NCP-APIGW-API-KEY-ID' : naverClientId,
        'X-NCP-APIGW-API-KEY' : naverClientSecretId,
      };
      
      final newUri = uriGeo.replace(queryParameters: params);
      http.Response response = await http.get(newUri, headers: headers);
      if(response.statusCode == 200){
        JReverseGeocode reverseGeocode = JReverseGeocode.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(reverseGeocode.status.code == 0){
          if(mounted)
            setState(() {
              sLocation = '${reverseGeocode.results[0].region.area2.name} ${reverseGeocode.results[0].region.area3.name} ${reverseGeocode.results[0].region.area4.name}';
              sSigungu = reverseGeocode.results[0].region.area1.name;
              sSido = reverseGeocode.results[0].region.area2.name;
            });
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('위치 정보를 불러올 수 없습니다.'))
            );
          if(mounted)
            setState(() {
              dCurLat = 37.563600; 
              dCurLong = 126.962370 ; 
              sLocation = '';
              sSigungu = '';
              sSido = '';
            });
        }
      }
      else{
        if(mounted)
          setState(() {
            sLocation = '';
            sSigungu = '';
            sSido = '';
          });
      }
    } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('오류가 발생했습니다.'))
          );
    }
  }
  
  Future changePosition(String address) async {
    final uriGeo = Uri.parse('https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode');
    bool serviceEnabled;
    LocationPermission permission;
    try {
      var params = {
        'query' : address,
      };

      var headers = {
        'X-NCP-APIGW-API-KEY-ID' : naverClientId,
        'X-NCP-APIGW-API-KEY' : naverClientSecretId,
        'Accept' : 'application/json',
      };
      
      final newUri = uriGeo.replace(queryParameters: params);
      http.Response response = await http.get(newUri, headers: headers);

      if(response.statusCode == 200){
        JGeocode geocode = JGeocode.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        if(geocode.status == 'OK'){
          setState(() {
            dCurLat = double.tryParse(geocode.addresses[0].y);
            dCurLong = double.tryParse(geocode.addresses[0].x);
          });
          getData();
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text('네트워크 오류가 발생했습니다.'))
            );
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('오류가 발생했습니다.'))
        );
      }
    }
    catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('오류가 발생했습니다.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: showBackToTopButton == false
        ? null
        : FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: Icon(
              Icons.arrow_upward,
              color: Theme.of(context).primaryColor,
            ),
            mini: true,
            backgroundColor: Colors.white,
          ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: getData,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            sliverAppbar(),
            sliverTop(),
            if (filterSeqs.trim().length > 0)
              sliverFilterBox(),
            if (filterSeqs.trim().length > 0)
              SliverToBoxAdapter(
                child: Divider(),
              ),
            sliverList()
          ],
        ),
      ),
    );
  }

  Widget sliverList(){
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
    else {
      if(hospitalList.resultCode == 'FAIL'){
        return SliverFillRemaining(
          child: NoData("병원을 조회할 수 없습니다."),
        );
      } 
      else{
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index){
            if(index == count)
              return Center(
                child: CircularProgressIndicator(),
                heightFactor: 2,
              );
            else
              return HospitalUnit(context, hospitalList.info.list[index], dCurLat, dCurLong);
          },
          childCount: bMoreData? count + 1 : count,
        ));
      }
    }
  }

  SliverAppBar sliverAppbar() {
    return SliverAppBar(
      floating: true,
      flexibleSpace: MyAppBar(),
      bottom: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'),
          onPressed: () {
            widget.goHome();
          }),
        title: Text('병원'),
        centerTitle: true,
      ),
    );
  }
  SliverList sliverTop() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  SvgPicture.asset('assets/location.svg'),
                  SizedBox(
                    width: 5,
                  ),
                  Text('현재 위치 : ${sSearchLocation??sLocation}', style: Theme.of(context).textTheme.bodyText2,),
                  IconButton(
                    onPressed: (){
                      setState(() {
                        sSearchLocation = null;
                        sSearchSigungu = null;
                        sSearchSido = null;
                      });
                      getPosition();
                      getData();
                      }, 
                    icon: Icon(Icons.my_location_sharp, color: Theme.of(context).primaryColor,)),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => KpostalView(
                          callback: (Kpostal result) {
                            setState(() {
                              sSearchLocation = '${result.sigungu} ${result.roadname} ';
                              sSearchSigungu = result.sigungu;
                              sSearchSido = result.sido;
                            });
                            changePosition(result.address);
                          }, 
                        ),
                      ));
                    },
                    child: Text('변경')),
                ],
              ),
              TextButton(
                onPressed: 
                (hospitalList != null && hospitalList.info.list.length > 0)
                ? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalMap(dCurLat: dCurLat, dCurLong: dCurLong,)));
                }
                : null,
                child: SvgPicture.asset('assets/map.svg')),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFDADCDE), width: 1))
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFDADCDE), width: 1))
          ),
          child: Row(
            children: [
              Expanded(
                //필터버튼
                flex: 1,
                child: MaterialButton(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      cntFilter > 0
                        ? Text(
                            '필터 ($cntFilter)',
                            style: Theme.of(context).textTheme.bodyText1,
                          )
                        : Text(
                            '필터',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                      SvgPicture.asset('assets/filter.svg')
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => HospitalFilterDialog(
                        selectedList: selectedList,
                        onApply: (list) {
                          setState(() {
                            selectedList = list;
                            filterSeqs = '';
                            for(JFilterListCategoryUnit category in selectedList){
                              for(JFilterListCategoryUnitFliterUnit filter in category.filterList){
                                filterSeqs += '${filter.filterSeq.toString()},';
                              }
                            }
                            getData();
                          });
                        }));
                  }),
              ),
              Expanded(
                //정렬버튼
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Color(0xFFDADCDE), width: 1))
                  ),
                  height: 45,
                  child: CustomDropdown(
                    icon: SvgPicture.asset('assets/arrowDown.svg'),
                    child: Text('거리순', style: Theme.of(context).textTheme.bodyText2,),
                    onChange: (value, key) {
                      setState(() {
                        valueChoose = key;
                        getData();
                      });
                    },
                    dropdownButtonStyle: DropdownButtonStyle(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textStyle: Theme.of(context).textTheme.bodyText2,
                    ),
                    dropdownStyle: DropdownStyle(
                      height: 150,
                      elevation: 5,
                      padding: EdgeInsets.all(10),
                    ),
                    dropdownItemStyle: DropdownItemStyle(
                      height: 30,
                      textStyle: Theme.of(context).textTheme.bodyText2,
                      highlightColor: Theme.of(context).primaryColor.withOpacity(0.1)
                    ),
                    items: sortItem ?? {}
                  ),
                  // DropdownButtonHideUnderline(
                  //   child: DropdownButton(
                  //     isExpanded: true,
                  //     value: valueChoose,
                  //     items: sortItem.keys
                  //         .map<DropdownMenuItem<String>>((String value) {
                  //       return DropdownMenuItem(
                  //         value: value,
                  //         child: Text(
                  //           sortItem[value],
                  //           style: Theme.of(context).textTheme.bodyText2,
                  //         ),
                  //       );
                  //     }).toList(),
                  //     onChanged: (value) {
                  //       setState(() {
                  //         valueChoose = value;
                  //         getData();
                  //       });
                  //     },
                  //   ),
                  // ),
                )),
            ],
          ),
        ),
      ]),
    );
  }
  SliverToBoxAdapter sliverFilterBox(){
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            for (int i = 0; i < selectedList.length; i++)
              for(int j = 0; j < selectedList[i].filterList.length; j++)
                Row(
                  children: [
                    Container(
                      height: 30,
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            selectedList[i].filterList.remove(selectedList[i].filterList[j]);
                          });
                          filterSeqs = '';
                          for(JFilterListCategoryUnit category in selectedList){
                            for(JFilterListCategoryUnitFliterUnit filter in category.filterList){
                              filterSeqs += '${filter.filterSeq.toString()},';
                            }
                          }
                          getData();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              selectedList[i].filterList[j].filterDesc,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SvgPicture.asset(
                              'assets/deleteFilter.svg',
                              width: 18,
                            )
                          ],
                        ),
                      ),
                      decoration: ShapeDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    ),
                    SizedBox(
                      width: 5,
                    )
                  ],
                ),
          ],
        ),
      ),
    );
  }
}