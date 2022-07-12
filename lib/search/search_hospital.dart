import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/filterList.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:craits/_JClass/HospitalList.dart';
import 'package:http/http.dart' as http;
import '../menu1_Hospital/hospitalDetail.dart';


class HospitalSearch extends StatefulWidget {
  HospitalSearch({Key key, this.searchKeyword}) : super(key: key);
  final String searchKeyword;

  @override
  HospitalSearchState createState() => HospitalSearchState();
}

class HospitalSearchState extends State<HospitalSearch> {
  final uri = Uri.parse(commonUri + '/V1/Hospital/HospitalList.json');
  ScrollController scrollController;
  bool showBackToTopButton = false;
  int cntFilter = 0; 
  // String sLocation = '';
  final double dCurLat = 0.0; //현재위치
  final double dCurLong = 0.0 ; //현재위치
  List<JFilterListCategoryUnit> selectedList = [];
  int iSearchPageNo = 1;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  bool bLoading = true;
  bool bNetworkErr = false;
  final String valueChoose = 'NAME';
  JHospitalList hospitalList;
  int count = 0;
  String searchKeyword;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    searchKeyword = widget.searchKeyword;
    init();
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
        'searchPosLat' : '', //위치정보 (위도)
        'searchPosLng' : '', //위치정보 (경도)
        'searchKeyword' : searchKeyword, //검색어
        'searchFilterSeqs' : '', //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        'searchPageNo' : iSearchPageNo.toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
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
        'searchPosLat' : '', //위치정보 (위도)
        'searchPosLng' : '', //위치정보 (경도)
        'searchKeyword' : searchKeyword, //검색어
        'searchFilterSeqs' : '', //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        'searchPageNo' : (++iSearchPageNo).toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
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
        hospitalList.info.list.addAll(_hospitalList.info.list);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: showBackToTopButton == false
        ? null
        : FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(
                0,
                duration: Duration(milliseconds: 500),
                curve: Curves.linear);
            },
            child: Icon(
              Icons.arrow_upward,
              color: Theme.of(context).primaryColor,
            ),
            mini: true,
            backgroundColor: Colors.white,
          ),
      body: 
      (searchKeyword!= null && searchKeyword.trim().length > 0)?
      SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: getData,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              sliverList()
            ],
          ),
        ),
      )
      :
      Container(),
    );
  }

  Widget sliverList(){
    if(bLoading){
      if(bNetworkErr)
        return SliverFillRemaining(
          child: Center(
            child:NetworkErr(onRetry:getData)
          )
        );
      else
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator()),
        );
    }
    else{
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
                widthFactor: 0.5,
                heightFactor: 2,
              );
            else
              return Column(
                children: [
                  HospitalUnit(context, hospitalList.info.list[index], dCurLat, dCurLong),
                  Divider(
                    thickness: 3,
                    color: Color(0xFFF2F4F6),
                  )
                ],
              );
          },
          childCount: bMoreData? count + 1 : count,
        ));
      }
    }
  }
}

//진료기록 낱개
class HospitalUnit extends StatelessWidget {
  final SvgPicture star0 = SvgPicture.asset('assets/Star_x.svg', height: 18,);
  final SvgPicture starhalf = SvgPicture.asset('assets/Star_half.svg', height: 18,);
  final SvgPicture star1 = SvgPicture.asset('assets/Star_o.svg', height: 18,);
  final BuildContext context;
  
  final JHospitalListUnit hospitalListUnit;
  String sName = ''; 
  String sAddress = '';
  String sTel = '';
  double dScore = 0.0;
  int iCntReview = 0;
  double dCurLat;
  double dCurLong;

  HospitalUnit(this.context, this.hospitalListUnit, this.dCurLat, this.dCurLong)
 {
   sName = hospitalListUnit.hospNm ?? '';
   sAddress = hospitalListUnit.addr ?? ''; 
   sTel = hospitalListUnit.telNo ?? '';
   dScore = hospitalListUnit.reviewScore != null ? double.tryParse(hospitalListUnit.reviewScore.toString()) : 0.0;
   iCntReview = hospitalListUnit.reviewCnt!= null ? int.tryParse(hospitalListUnit.reviewCnt.toString()) : 0;
 } 

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      child: InkWell(
        onTap: (){
          FocusScope.of(context).unfocus();
          Navigator.push(context,MaterialPageRoute(builder: (context) => 
            HospitalDetail(
              hospitalName: hospitalListUnit.hospNm.toString(),
              searchId: hospitalListUnit.id.toString(),
              searchPosLat: dCurLat.toString(),
              searchPosLng: dCurLong.toString(),)
            ),
          );
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: 180
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sName, style: Theme.of(context).textTheme.headline1, ),
              Row(
                children: [
                  (dScore >= 0.5)? (dScore >= 1? star1 : starhalf) :star0,
                  (dScore >= 1.5)? (dScore >= 2? star1 : starhalf) :star0,
                  (dScore >= 2.5)? (dScore >= 3? star1 : starhalf) :star0,
                  (dScore >= 3.5)? (dScore >= 4? star1 : starhalf) :star0,
                  (dScore >= 4.5)? (dScore >= 5? star1 : starhalf) :star0,
                  Text(' $dScore ', style: Theme.of(context).textTheme.headline3 ,),
                  Text('($iCntReview)', style: Theme.of(context).textTheme.subtitle2,)
                ],
              ),
              Text(
                sAddress,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Row(
                children: [
                  SvgPicture.asset('assets/tel.svg', ),
                  SizedBox(width: 5,),
                  Text(
                    sTel,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
              Row(
                children: [
                  for(int i = 0; i < hospitalListUnit.specialList.length; i++)
                    Text(
                      i > 0
                      ? ' · ${hospitalListUnit.specialList[i].toString()}'
                      : hospitalListUnit.specialList[i].toString(), 
                      style: Theme.of(context).textTheme.subtitle1,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}