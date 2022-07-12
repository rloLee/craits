import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/medicineList.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/menu3_Medicine/medicineDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class MedicineSearch extends StatefulWidget {
  MedicineSearch({Key key, this.searchKeyword}) : super(key: key);
  final String searchKeyword;

  @override
  MedicineSearchState createState() => MedicineSearchState();
}

class MedicineSearchState extends State<MedicineSearch> {
  final uri = Uri.parse(commonUri + '/V1/Medicine/MedicineList.json');
  ScrollController scrollController;
  bool showBackToTopButton = false;
  int cntFilter = 0; 
  int iSearchPageNo = 1;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  bool bLoading = true;
  bool bNetworkErr = false;
  final String valueChoose = 'DISTANCE';
  JMedicineList medicineList;
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
        'searchKeyword' : searchKeyword, //검색어
        'searchFilterSeqs' : '', //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        'searchPrices': '', // 배열 [최소가격,최대가격]
        'searchPageNo' : iSearchPageNo.toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JMedicineList _medicineList;
      if(response.statusCode == 200){
        _medicineList = JMedicineList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
        medicineList = _medicineList;
        if(_medicineList.info != null && medicineList.info.list != null)
          count = medicineList.info.list.length;
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
        'searchKeyword' : searchKeyword, //검색어
        'searchFilterSeqs' : '', //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        'searchPrices': '', // 배열 [최소가격,최대가격]
        'searchPageNo' : (++iSearchPageNo).toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
      };
      
      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      JMedicineList _medicineList;
      if(response.statusCode == 200){
        _medicineList = JMedicineList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          medicineList.info.list.addAll(_medicineList.info.list);
          count = medicineList.info.list.length;
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
      if(medicineList.resultCode == 'FAIL'){
        return SliverFillRemaining(
          child: NoData("약을 조회할 수 없습니다."),
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
                  MedicineUnit(context, medicineList.info.list[index]),
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
class MedicineUnit extends StatelessWidget {
  final SvgPicture star0 = SvgPicture.asset('assets/Star_x.svg', height: 18,);
  final SvgPicture starhalf = SvgPicture.asset('assets/Star_half.svg', height: 18,);
  final SvgPicture star1 = SvgPicture.asset('assets/Star_o.svg', height: 18,);
  final BuildContext context;
  // final int index;

  
  final JMedicineListInfoListUnit medicineListUnit;
  String sName = ' '; 
  String sCompany = '';
  // final double dScore = 0.0;
  String sPrice = '0';
  // final int iCntReview = 0;
  String sImageUrl ;

  MedicineUnit(this.context, this.medicineListUnit) {
    sName =  medicineListUnit.medicineNm;
    sCompany = medicineListUnit.entpNm;
    sPrice = medicineListUnit.avgPrice;
    sImageUrl = medicineListUnit.imageUrl;
  } 

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      child: InkWell(
        onTap: (){
          FocusScope.of(context).unfocus();
          Navigator.push(context,MaterialPageRoute(builder: (context) => 
            MedicineDetail(
              medicineNm: medicineListUnit.medicineNm,
              searchId: medicineListUnit.id,)
            ),
          );
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: 150,
            //minWidth: double.infinity
            ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sName, style: Theme.of(context).textTheme.headline1, maxLines: 3, overflow: TextOverflow.ellipsis,),
                      // Row(
                      //   children: [
                      //     (dScore >= 0.5)? (dScore >= 1? star1 : starhalf) :star0,
                      //     (dScore >= 1.5)? (dScore >= 2? star1 : starhalf) :star0,
                      //     (dScore >= 2.5)? (dScore >= 3? star1 : starhalf) :star0,
                      //     (dScore >= 3.5)? (dScore >= 4? star1 : starhalf) :star0,
                      //     (dScore >= 4.5)? (dScore >= 5? star1 : starhalf) :star0,
                      //     Text(' $dScore ', style: Theme.of(context).textTheme.headline3 ,),
                      //     Text('($iCntReview)', style: Theme.of(context).textTheme.subtitle2,)
                      //   ],
                      // ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${sPrice??'-'} 원',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(width: 5,),
                          Flexible(
                            child: Text(
                              sCompany,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(medicineListUnit.etcOtcCd ?? '', style: Theme.of(context).textTheme.subtitle1,),
                          if(medicineListUnit.classNm != null)
                            Flexible(child: Text(' · ${medicineListUnit.classNm ?? ''}', style: Theme.of(context).textTheme.subtitle1,)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: sImageUrl != null
                    ? Image.network(sImageUrl, fit: BoxFit.fill , 
                        errorBuilder: (context, exception, stackTrace){
                          return SvgPicture.asset('assets/noImage.svg', fit: BoxFit.fill);
                        },) 
                    // Image(image:  NetworkImage(sImageUrl), fit: BoxFit.fill,) 
                    : SvgPicture.asset('assets/noImage.svg', fit: BoxFit.fill,)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}