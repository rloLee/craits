import 'dart:async';
import 'dart:convert';
import 'package:craits/MyWidget/markerMap.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:craits/MyWidget/customTabIndigator.dart';
import 'package:craits/_JClass/pharmacyDetail.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/Common/com.dart';
import 'package:http/http.dart' as http;

class PharmacyDetailInfo extends StatefulWidget {
  final String searchId;
  final String searchPosLat;
  final String searchPosLng;

  PharmacyDetailInfo({
    @required this.searchId,
    @required this.searchPosLat,
    @required this.searchPosLng,
  });

  @override
  _PharmacyDetailInfoState createState() => _PharmacyDetailInfoState();
}

class _PharmacyDetailInfoState extends State<PharmacyDetailInfo> with TickerProviderStateMixin{
  final uri = Uri.parse(commonUri + '/V1/Pharmacy/PharmacyDetail.json');
  JPharmacyDetailInfo pharmacyDetailInfo;
  List<Widget> widgetList;
  AutoScrollController autoScrollController;
  TabController tabController;
  JPharmacyDetail pharmacyDetail;
  bool bNetworkErr = false;
  bool bLoading = true;
  MarkerMap map;
  
  Future getData() async {
    try{
      String searchId = widget.searchId;
      String searchPosLat = widget.searchPosLat;
      String searchPosLng = widget.searchPosLng;

      if(mounted)
        setState(() {
          bLoading = true;
          bNetworkErr = false;
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchId' : searchId.toString(),  //병원 ID
        'searchPosLat' : searchPosLat, //위치정보 (위도)
        'searchPosLng' : searchPosLng, //위치정보 (경도)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      JPharmacyDetail _pharmacyDetail;
      if(response.statusCode == 200){
        _pharmacyDetail =JPharmacyDetail.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
          );
        if(mounted)
          setState(() {
            bNetworkErr = false;
          });
        return;
      }

      if(mounted){
        setState(() {
          pharmacyDetail = _pharmacyDetail;
        });
        map = MarkerMap(
          strCaption: pharmacyDetail.info.pharmacyNm, 
          strLat: pharmacyDetail.info.yPos.toString(), 
          strLng: pharmacyDetail.info.xPos.toString(),
          assetName: 'assets/markerPharmacy.png',);
        setState(() {
          bLoading = false;
        });

      }
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
    } catch(_){
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  //스크롤 버튼 클릭시 이동
  Future _scrollToIndex(int index) async {
    await autoScrollController.scrollToIndex(index,
      preferPosition: AutoScrollPosition.begin);
    autoScrollController.highlight(index);
  }
  
  //스크롤 버튼
  Widget _wrapScrollTag({int index, Widget child}) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: autoScrollController,
      index: index,
      child: child,
    );
  }

  _buildSliverAppbar() {
    return SliverAppBar(
      elevation: 1.0,
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      pinned: true,
      title: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: DefaultTabController(
          length: 4 ,
          child: TabBar(
            indicatorPadding: const EdgeInsets.symmetric(vertical: 8.0),
            indicator: CustomTabIndicator(),
            controller: tabController,
            labelColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 14.0),
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle: const TextStyle(fontSize: 14.0),
            isScrollable: true,
            onTap: (index) async {
              _scrollToIndex(index);
            },
            tabs: <Widget>[
              Tab(text: '기본정보'),
              Tab(text: '영업시간'),
              Tab(text: '접수시간'),
              Tab(text: '교통정보'),
            ]
          ),
        ),
      ),
    );
  }

  @override
    void initState() {
      getData();

      tabController = TabController(length: 4, vsync: this);
      
      autoScrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, 0),
        axis: Axis.vertical,
      )..addListener(
        (){ 
          setState(() {
            if(isInScroll(0))
              tabController.index = 0;
            else if(isInScroll(1))
              tabController.index = 1;
            else if(isInScroll(2))
              tabController.index = 2;
            else if(isInScroll(3))
              tabController.index = 3;
          });
        }
      );
      super.initState();
    }

    bool isInScroll (int index){
      if(autoScrollController.tagMap[index]!=null){
      var renderObject = autoScrollController.tagMap[index].context.findRenderObject();
      RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
      var bottom = viewport.getOffsetToReveal(renderObject, 1.0);
      var top = viewport.getOffsetToReveal(renderObject, 0.0);

      if( //bottom.offset > autoScrollController.offset || 
        autoScrollController.offset > top.offset)
          return false;
      else
        return true; 
      }
      return false;
    }

  @override
  Widget build(BuildContext context) {
    if (bLoading){
      if(bNetworkErr)
        return Scaffold(
          body: Center(
            child:Container(
              height: MediaQuery.of(context).size.height - 200,
              child: NetworkErr(onRetry:getData)
            )
          )
        );
      else
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
            ),
          ),
        );
    }
    else{
      if(pharmacyDetail.resultCode == 'FAIL')
        return NoData("상세정보를 조회할 수 없습니다.");
      else{
        pharmacyDetailInfo = pharmacyDetail.info;
        widgetList = [
          drCnt(), 
          trmt(), 
          rev(), 
          trafficInfo() 
        ];
        List<Widget> sliverList = [];
        for(int i = 0; i < widgetList.length; i++){
          sliverList.add(
            _wrapScrollTag(
              index: i,
              child: widgetList[i]
            )
          );
          sliverList.add(
            Divider( thickness: 7, color: Color(0xFFF2F4F6), height: 7,)
          );
        }
        return Scaffold(
          body: CustomScrollView(
            controller: autoScrollController,
            slivers: [
              _buildSliverAppbar(),
              SliverList(delegate: SliverChildListDelegate(
                sliverList
              )),
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    '병원 정보 출처 : ${pharmacyDetailInfo.dataOrigin} \n데이터 최종 수정일 : ${pharmacyDetailInfo.dataDate}',
                    style: TextStyle(fontSize: 13.0, color: Color(0xFF959595)),
                )),
              )
            ],
          )
        );
      }
    }
  }

  //기본정보, 인력
   ExpansionTile drCnt() {
    return ExpansionTile(
      maintainState: false,
      initiallyExpanded: true,
      title: Container(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본정보',
              style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF959595),
                  height: 2,
                  fontWeight: FontWeight.normal),
            ),
            Text(
              '인력',
              style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF262626),
                  fontWeight: FontWeight.w700,
                  height: 1.5),
            ),
          ],
        ),
      ),
      children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
            child: Card(
              color: const Color(0xFFF4F5F9),
              shadowColor: Colors.black26,
              elevation: 8.0,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(drCntUnit(pharmacyDetailInfo.gdrCnt, '약사') != null)
                      drCntUnit(pharmacyDetailInfo.gdrCnt, '약사'),
                    if(drCntUnit(pharmacyDetailInfo.intnCnt, '사회복지사') != null)
                      drCntUnit(pharmacyDetailInfo.intnCnt, '사회복지사'),
                    if(drCntUnit(pharmacyDetailInfo.resdntCnt, '물리치료사') != null)
                      drCntUnit(pharmacyDetailInfo.resdntCnt, '물리치료사'),
                    if(drCntUnit(pharmacyDetailInfo.sdrCnt, '작업치료사') != null)
                      drCntUnit(pharmacyDetailInfo.sdrCnt, '작업치료사'),
                  ],
                ),
              ),
            ))
      ]);
  }

  Widget drCntUnit(dynamic cnt, String text){
    int count = int.tryParse(cnt.toString());
    if (count !=null && count > 0)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text, style: TextStyle(
                fontSize: 14.0, color: Color(0xFF262626)),
          ),
          Text(
            cnt.toString(), style: TextStyle(
                fontSize: 14.0, color: Color(0xFF262626)),
          ),
        ],
      );
    else 
      return null;
  }

//영업시간
  ExpansionTile trmt() {
    return ExpansionTile(
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '영업시간',
        style: TextStyle(
          fontSize: 18.0,
          color: Color(0xFF262626),
          fontWeight: FontWeight.w700,
          height: 1.5),
      ),
      children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
            child: Card(
              color: const Color(0xFFF4F5F9),
              shadowColor: Colors.black26,
              elevation: 8.0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [
                  if(pharmacyDetailInfo.trmtList == null || pharmacyDetailInfo.trmtList.length == 0)
                  Row(
                    children: [
                      Text('-', style: Theme.of(context).textTheme.subtitle2,),
                    ],
                  )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 5 / 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20),
                      itemCount: pharmacyDetailInfo.trmtList.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                      pharmacyDetailInfo.trmtList[index].fieldNm ?? '',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: const Color(0xFF262626),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                ),
                                Flexible(
                                  child: Text(
                                    pharmacyDetailInfo.trmtList[index].fieldValue ?? '',
                                    style: TextStyle(
                                        fontSize: 14.0, color: const Color(0xFF262626)),
                                  ),
                                ),
                              ],
                            ),
                        );
                      }),
                    Divider(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 20),
                          child: Text(
                            '점심시간',
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFF959595),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            if(pharmacyDetailInfo.lunchList == null || pharmacyDetailInfo.lunchList.length == 0)
                            Row(
                              children: [
                                Text('-', style: Theme.of(context).textTheme.subtitle2,),
                              ],
                            )
                            else
                              for (int i = 0; i < pharmacyDetailInfo.lunchList.length; i++)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  SizedBox(
                                    width: 50,
                                    child: 
                                      Text(
                                        pharmacyDetailInfo.lunchList[i].fieldNm ?? '',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Color(0xFF959595),
                                            fontWeight: FontWeight.normal),
                                      ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      pharmacyDetailInfo.lunchList[i].fieldValue ?? '-',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Color(0xFF959595),
                                        fontWeight: FontWeight.normal),
                                    ),
                                  ),

                                  ],
                                ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ))
      ],
    );
  }

//접수시간
  ExpansionTile rev() {
    return ExpansionTile(
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '접수시간',
        style: TextStyle(
            fontSize: 18.0,
            color: Color(0xFF262626),
            fontWeight: FontWeight.w700,
            height: 1.5),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
          child: Card(
            color: const Color(0xFFF4F5F9),
            shadowColor: Colors.black26,
            elevation: 8.0,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if(pharmacyDetailInfo.revList == null || pharmacyDetailInfo.revList.length == 0)
                  Row(
                    children: [
                      Text('-', style: Theme.of(context).textTheme.subtitle2,),
                    ],
                  )
                  else
                  for (int i = 0; i < pharmacyDetailInfo.revList.length; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pharmacyDetailInfo.revList[i].fieldNm ?? '',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: const Color(0xFF262626),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          pharmacyDetailInfo.revList[i].fieldValue ?? '',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: const Color(0xFF262626),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
  
  //교통정보
  ExpansionTile trafficInfo() {
    return ExpansionTile(
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '교통정보',
        style: TextStyle(
            fontSize: 18.0,
            color: Color(0xFF262626),
            fontWeight: FontWeight.w700,
            height: 1.5),
      ),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pharmacyDetailInfo.addr ?? '', 
                  style: TextStyle(
                    fontSize: 14.0,
                    color: const Color(0xFF262626),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: map
                ),
                Container(
                  child: Column(
                    children: [
                      for(JPharmacyDetailInfoTrafficUnit unit in pharmacyDetailInfo.trafficList)
                        if(unit.fieldNm.toString() == '지하철')
                          Text('${unit.lineNo.toString()} ${unit.arivPlc.toString()}', style: Theme.of(context).textTheme.bodyText1,),
                    ],
                  ),
                )
              ],
            ),
        ),
      ],
    );
  }
}