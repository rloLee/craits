import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/pharmacyList.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/menu2_Pharmacy/pharmacyDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;


class PharmacySearch extends StatefulWidget {
  PharmacySearch({Key key, this.searchKeyword}) : super(key: key);
  final String searchKeyword;

  @override
  PharmacySearchState createState() => PharmacySearchState();
}

class PharmacySearchState extends State<PharmacySearch> {
  final uri = Uri.parse(commonUri + '/V1/Pharmacy/PharmacyList.json');
  ScrollController scrollController;
  bool showBackToTopButton = false;
  int cntFilter = 0; 
  int iSearchPageNo = 1;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  bool bLoading = true;
  bool bNetworkErr = false;
  final String valueChoose = 'DISTANCE';
  JPharmacyList pharmacyList;
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

      JPharmacyList _pharmacyList;
      if(response.statusCode == 200){
        _pharmacyList = JPharmacyList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
        if(mounted)
          setState(() {
            bNetworkErr = true;
          });
      }

      if(mounted)
        setState(() {
          pharmacyList = _pharmacyList;
          if(_pharmacyList.info != null && _pharmacyList.info.list != null)
            count = pharmacyList.info.list.length;
        bLoading = false;
       });
    } on TimeoutException catch(_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
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
          duration: const Duration(milliseconds: 1500),
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
      
      JPharmacyList _pharmacyList;
      if(response.statusCode == 200){
        _pharmacyList = JPharmacyList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
      if(mounted)
      setState(() {
        pharmacyList.info.list.addAll(_pharmacyList.info.list);
        count = pharmacyList.info.list.length;
        bMoreData = false;    
      });
    }
    on TimeoutException catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
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
          duration: const Duration(milliseconds: 1500),
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
      if(pharmacyList.resultCode == 'FAIL'){
        return SliverFillRemaining(
          child: NoData("약국을 조회할 수 없습니다."),
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
                  PharmacyUnit(context, pharmacyList.info.list[index]),
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
class PharmacyUnit extends StatelessWidget {
  final SvgPicture star0 = SvgPicture.asset('assets/Star_x.svg', height: 18,);
  final SvgPicture starhalf = SvgPicture.asset('assets/Star_half.svg', height: 18,);
  final SvgPicture star1 = SvgPicture.asset('assets/Star_o.svg', height: 18,);
  final BuildContext context;
  final JPharmacyListUnit parmacyListUnit;
  String sName = ''; 
  String sAddress = '';
  String sTel = '';
  double dScore = 0.0;
  int iCntReview = 0;
  double dCurLat;
  double dCurLong;

  PharmacyUnit(this.context, this.parmacyListUnit)
 {
   sName = parmacyListUnit.pharmacyNm ?? '';
   sAddress = parmacyListUnit.addr ?? ''; 
   sTel = parmacyListUnit.telNo ?? '';
   dScore = parmacyListUnit.reviewScore != null ? double.tryParse(parmacyListUnit.reviewScore.toString()) : 0.0;
   iCntReview = parmacyListUnit.reviewCnt!= null ? int.tryParse(parmacyListUnit.reviewCnt.toString()) : 0;
 } 

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      child: InkWell(
        onTap: (){
          FocusScope.of(context).unfocus();
          Navigator.push(context,MaterialPageRoute(builder: (context) => 
            PharmacyDetail(
              pharmacyName: parmacyListUnit.pharmacyNm.toString(),
              searchId: parmacyListUnit.id.toString(),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  SvgPicture.asset('assets/tel.svg'),
                  SizedBox(width: 5,),
                  Text(
                    sTel,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
              Row(
                children: [
                  for(int i = 0; i < parmacyListUnit.specialList.length; i++)
                    Text(
                      i > 0
                      ? ' · ${parmacyListUnit.specialList[i].toString()}'
                      : parmacyListUnit.specialList[i].toString(), 
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