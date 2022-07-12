import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/filterList.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'medicineUnit.dart';
import 'medicineFilter.dart';
import 'package:craits/MyWidget/myAppBar.dart';
import 'package:craits/_JClass/medicineList.dart';
import 'package:http/http.dart' as http;

class Medicine extends StatefulWidget {
  final Function goHome;
  Medicine(this.goHome);

  @override
  _MedicineState createState() => _MedicineState();
}
class _MedicineState extends State<Medicine> {
  final uri = Uri.parse(commonUri + '/V1/Medicine/MedicineList.json');
  ScrollController scrollController;
  bool showBackToTopButton = false;
  int cntFilter = 0;
  List<JFilterListCategoryUnit> selectedList = [];
  int iSearchPageNo = 1;
  JMedicineList medicineList;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  bool bLoading = true;
  bool bNetworkErr = false;
  String filterSeqs = '';
  int count = 0;
  int startPrice;
  int endPrice;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();

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
        'searchKeyword' : '', //검색어
        'searchFilterSeqs' : filterSeqs, //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        if(startPrice != null && endPrice != null)
        'searchPrices': '[$startPrice,$endPrice]', // 배열 [최소가격,최대가격]
        'searchPageNo' : iSearchPageNo.toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      // await Future.delayed(Duration(seconds: 3)).timeout(Duration(seconds: 1));
      
      JMedicineList _medicineList;
      if(response.statusCode == 200){
        _medicineList = JMedicineList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
        medicineList = _medicineList;
        if(_medicineList.info != null && medicineList.info.list != null)
          count = medicineList.info.list.length;
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
        'searchKeyword' : '', //검색어
        'searchFilterSeqs' : filterSeqs, //"필터 seq 배열 : 선택된 필터 항목 배열[1, 2, 3, 4 ... 99]"
        if(startPrice != null && endPrice != null)
        'searchPrices': '[$startPrice,$endPrice]', // 배열 [최소가격,최대가격]
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
          medicineList.info.list.addAll(_medicineList.info.list);
          count = medicineList.info.list.length;
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
            child: NetworkErr(onRetry: getData)
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
                child: CircularProgressIndicator(
                ),
                heightFactor: 2,
              );
              return MedicineUnit(context, medicineList.info.list[index]);
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
        title: Text('약'),
        centerTitle: true,
      ),
    );
  }

  SliverList sliverTop() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
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
                              style: Theme.of(context).textTheme.bodyText2,
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
                      builder: (context) => MedicineFilterDialog(
                        selectedList: selectedList,
                        startPrice: startPrice,
                        endPrice: endPrice,
                        onApply: (list, startPrc, endPrc) {
                          setState(() {
                            selectedList = list;
                            filterSeqs = '';
                            for(JFilterListCategoryUnit category in selectedList){
                              for(JFilterListCategoryUnitFliterUnit filter in category.filterList){
                                filterSeqs += '${filter.filterSeq.toString()},';
                              }
                            }
                            startPrice = startPrc;
                            endPrice = endPrc;
                            getData();
                          });
                        }));
                  }),
              ),
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
