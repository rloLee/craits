import 'dart:async';
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/markerMap.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:craits/MyWidget/customTabIndigator.dart';
import 'package:craits/_JClass/hospitalDetail.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:http/http.dart' as http;

class HospitalDetailInfo extends StatefulWidget {
  final String searchId;
  final String searchPosLat;
  final String searchPosLng;

  HospitalDetailInfo({
    @required this.searchId,
    @required this.searchPosLat,
    @required this.searchPosLng,
  });

  @override
  _HospitalDetailInfoState createState() => _HospitalDetailInfoState();
}

class _HospitalDetailInfoState extends State<HospitalDetailInfo> with TickerProviderStateMixin{
  final uri = Uri.parse(commonUri + '/V1/Hospital/HospitalDetail.json');
  JHospitalDetailInfo hospitalDetailInfo;
  List<Widget> widgetList;
  AutoScrollController autoScrollController;
  TabController tabController;
  JHospitalDetail hospitalDetail;
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
      
      JHospitalDetail _hospitalDetail;
      if(response.statusCode == 200){
        _hospitalDetail =JHospitalDetail.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          this.hospitalDetail = _hospitalDetail;
        });

        map = MarkerMap(
          strCaption: hospitalDetail.info.hospNm, 
          strLat: hospitalDetail.info.yPos.toString(), 
          strLng: hospitalDetail.info.xPos.toString(),
          assetName: 'assets/markerHospital.png',);
      
        setState(() {
          bLoading = false;
        });
      }
      
    } on TimeoutException catch(_) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        setState(() {
          bNetworkErr = true;
        });
      }
    } catch(_){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    }
  }

  Future _scrollToIndex(int index) async {
    try{
      await autoScrollController.scrollToIndex(index,preferPosition: AutoScrollPosition.begin);
      autoScrollController.highlight(index);
    }
    catch(_){
    }
  }
  
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
          length: 6 ,
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
              Tab(text: '시설 및 운영정보'),
              Tab(text: '의사 현황'),
              Tab(text: '진료 시간'),
              Tab(text: '접수 시간'),
              Tab(text: '응급실'),
              Tab(text: '교통정보'),
            ]
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
    void initState() {
      getData();
      tabController = TabController(length: 6, vsync: this);
      
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
            else if(isInScroll(4))
              tabController.index = 4;
            else if(isInScroll(5))
              tabController.index = 5;
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
    else {
      if(hospitalDetail.resultCode == 'FAIL')
        return NoData("상세정보를 조회할 수 없습니다.");
      else{
        hospitalDetailInfo = hospitalDetail.info;
        widgetList = [
          facility(),
          drCnt(),
          trmt(),
          rev(),
          emy(),
          trafficInfo(),
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
                    '병원 정보 출처 : ${hospitalDetailInfo.dataOrigin} \n데이터 최종 수정일 : ${hospitalDetailInfo.dataDate}',
                    style: TextStyle(fontSize: 13.0, color: Color(0xFF959595)),
                )),
              )
            ],
          )
        );
      }
    }
  }

  ExpansionTile facility() {
    if(hospitalDetailInfo.facilityList.length > 0 )
      hospitalDetailInfo.facilityList.sort((a, b) => a.fieldOrd.toString().compareTo(b.fieldOrd.toString()));
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
              '시설 및 운영정보',
              style: TextStyle(
                fontSize: 14.0,
                color: Color(0xFF959595),
                height: 2,
                fontWeight: FontWeight.normal),
            ),
            Text(
              '시설',
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 5.0,
                  crossAxisSpacing: 30,
                  children: [
                    for (int i = 0; i < hospitalDetailInfo.facilityList.length; i++)
                      if(hospitalDetailInfo.facilityList[i].fieldValue != null)
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                hospitalDetailInfo.facilityList[i].fieldNm.toString().replaceAll('병상수', ''),
                                style: Theme.of(context).textTheme.bodyText1
                              ),
                            ),
                            Text(
                              hospitalDetailInfo.facilityList[i].fieldValue,
                              style: Theme.of(context).textTheme.bodyText1
                            ),
                          ],
                        ),
                      ),
                  ],
                )),
            ))
      ]);
  }

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
                '진료 과목 및 의사 현황',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFF959595),
                  height: 2,
                  fontWeight: FontWeight.normal),
              ),
              Text(
                '의사수',
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
                      Row(
                        children: [
                          Text(
                            '총 인원 : ',
                            style: Theme.of(context).textTheme.bodyText1
                          ),
                          Text(
                            '${hospitalDetailInfo.drTotCnt}명',
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFF262626),
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Divider(
                        height: 20,
                      ),
                      if(drCntUnit(hospitalDetailInfo.mdeptGdrCnt, '의과일반의')!=null)
                        drCntUnit(hospitalDetailInfo.mdeptGdrCnt, '의과일반의'),
                      if(drCntUnit(hospitalDetailInfo.mdeptIntnCnt, '의과인턴')!=null)
                        drCntUnit(hospitalDetailInfo.mdeptIntnCnt, '의과인턴'),
                      if(drCntUnit(hospitalDetailInfo.mdeptResdntCnt, '의과레지던트')!=null)
                        drCntUnit(hospitalDetailInfo.mdeptResdntCnt, '의과레지던트'),
                      if(drCntUnit(hospitalDetailInfo.mdeptSdrCnt, '의과전문의')!=null)
                        drCntUnit(hospitalDetailInfo.mdeptSdrCnt, '의과전문의'),
                      if(drCntUnit(hospitalDetailInfo.detyGdrCnt, '치과일반의')!=null)
                        drCntUnit(hospitalDetailInfo.detyGdrCnt, '치과일반의'),
                      if(drCntUnit(hospitalDetailInfo.detyIntnCnt, '치과인턴')!=null)
                        drCntUnit(hospitalDetailInfo.detyIntnCnt, '치과인턴'),
                      if(drCntUnit(hospitalDetailInfo.detyResdntCnt, '치과레지던트')!=null)
                        drCntUnit(hospitalDetailInfo.detyResdntCnt, '치과레지던트'),
                      if(drCntUnit(hospitalDetailInfo.detySdrCnt, '치과전문의')!=null)
                        drCntUnit(hospitalDetailInfo.detySdrCnt, '치과전문의'),
                      if(drCntUnit(hospitalDetailInfo.cmdcGdrCnt, '한방일반의')!=null)
                        drCntUnit(hospitalDetailInfo.cmdcGdrCnt, '한방일반의'),
                      if(drCntUnit(hospitalDetailInfo.cmdcIntnCnt, '한방인턴')!=null)
                        drCntUnit(hospitalDetailInfo.cmdcIntnCnt, '한방인턴'),
                      if(drCntUnit(hospitalDetailInfo.cmdcResdntCnt, '한방레지던트')!=null)
                        drCntUnit(hospitalDetailInfo.cmdcResdntCnt, '한방레지던트'),
                      if(drCntUnit(hospitalDetailInfo.cmdcSdrCnt, '한방전문의')!=null)
                        drCntUnit(hospitalDetailInfo.cmdcSdrCnt, '한방전문의'),
                    ],
                  ),
                ),
              ))
        ]);
  }

  //인원수 낱개;;
  Widget drCntUnit(dynamic cnt, String text){
    int count = int.tryParse(cnt.toString());
    if (count !=null && count > 0)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: Theme.of(context).textTheme.bodyText1),
          Text(cnt, style: Theme.of(context).textTheme.bodyText1),
        ],
      );
    else 
      return null;
  }

  //진료시간
  ExpansionTile trmt() {
    if(hospitalDetailInfo.trmtList.length > 0 )
      hospitalDetailInfo.trmtList.sort((a, b) => a.fieldOrd.toString().compareTo(b.fieldOrd.toString()));
    if(hospitalDetailInfo.lunchList.length > 0 )
      hospitalDetailInfo.lunchList.sort((a, b) => a.fieldOrd.toString().compareTo(b.fieldOrd.toString()));
    return ExpansionTile(
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '진료시간',
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
                  if(hospitalDetailInfo.trmtList == null || hospitalDetailInfo.trmtList.length == 0)
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
                    itemCount: hospitalDetailInfo.trmtList.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( 
                              hospitalDetailInfo.trmtList[index].fieldNm?? '',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: const Color(0xFF262626),
                                fontWeight: FontWeight.w700,),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              hospitalDetailInfo.trmtList[index].fieldValue?? '휴진',
                              style: Theme.of(context).textTheme.bodyText1),
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
                          if(hospitalDetailInfo.lunchList == null || hospitalDetailInfo.lunchList.length == 0)
                            Row(
                              children: [
                                Text('-', style: Theme.of(context).textTheme.subtitle2,),
                              ],
                            )
                          else
                            for (int i = 0; i < hospitalDetailInfo.lunchList.length; i++)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: 
                                      Text(
                                        hospitalDetailInfo.lunchList[i].fieldNm ?? '',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Color(0xFF959595),
                                            fontWeight: FontWeight.normal),
                                      ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      hospitalDetailInfo.lunchList[i].fieldValue ?? '-',
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

  ExpansionTile rev() {
    if(hospitalDetailInfo.revList.length > 0 )
      hospitalDetailInfo.revList.sort((a, b) => a.fieldOrd.toString().compareTo(b.fieldOrd.toString()));
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
                if(hospitalDetailInfo.revList == null || hospitalDetailInfo.revList.length == 0)
                Row(
                  children: [
                    Text('-', style: Theme.of(context).textTheme.subtitle2,),
                  ],
                )
                else
                  for (int i = 0; i < hospitalDetailInfo.revList.length; i++)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hospitalDetailInfo.revList[i].fieldNm ?? '',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: const Color(0xFF262626),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10,),
                        Flexible(
                          child: Text(
                            hospitalDetailInfo.revList[i].fieldValue ?? '-',
                            style: Theme.of(context).textTheme.bodyText1),
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

  ExpansionTile emy() {
    String dayYN;
    String nightYn;
    String dayTel1;
    String dayTel2;
    String nightTel1;
    String nightTel2;
    for(JHospitalDetailInfoFieldUnit emyInfo in hospitalDetailInfo.emyList) {
      if(emyInfo.fieldNm.toString().contains('주간')) {
        if(emyInfo.fieldNm.toString().contains('여부')) {
          dayYN = emyInfo.fieldValue.toString();
        }
        else if(emyInfo.fieldNm.toString().contains('전화번호 1')){
          dayTel1 = emyInfo.fieldValue;
        }
        else if(emyInfo.fieldNm.toString().contains('전화번호 2')){
          dayTel2 = emyInfo.fieldValue;
        }
      }
      else if(emyInfo.fieldNm.toString().contains('야간')) {
        if(emyInfo.fieldNm.toString().contains('여부')) {
          nightYn = emyInfo.fieldValue.toString();
        }
        else if(emyInfo.fieldNm.toString().contains('전화번호 1')){
          nightTel1 = emyInfo.fieldValue;
        }
        else if(emyInfo.fieldNm.toString().contains('전화번호 2')){
          nightTel2 = emyInfo.fieldValue;
        }
      }
    }

    return ExpansionTile(
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '응급실',
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '주간',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: const Color(0xFF262626),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(dayYN =='Y'? '운영' : '미운영', style: Theme.of(context).textTheme.bodyText1),
                          if(dayTel1 != null)
                            Text(dayTel1, style: Theme.of(context).textTheme.caption),
                          if(dayTel2 != null)
                            Text(dayTel2, style: Theme.of(context).textTheme.caption),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '야간',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: const Color(0xFF262626),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(nightYn =='Y'? '운영' : '미운영', style: Theme.of(context).textTheme.bodyText1),
                          if(nightTel1 != null)
                            Text(nightTel1, style: Theme.of(context).textTheme.caption),
                          if(nightTel2 != null)
                            Text(nightTel2, style: Theme.of(context).textTheme.caption),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  ExpansionTile trafficInfo() {
    Map<String, String> mapTraffic = Map();
    for(JHospitalDetailInfoTrafficUnit unit in hospitalDetail.info.trafficList){
      if(mapTraffic.containsKey(unit.fieldNm.toString())){
        mapTraffic[unit.fieldNm.toString()] += ', ${unit.lineNo.toString()} ${unit.arivPlc.toString()}';
      }
      else{
        mapTraffic[unit.fieldNm.toString()] = '${unit.lineNo.toString()} ${unit.arivPlc.toString()}';
      }
    }

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
          child: Card(
            color: const Color(0xFFF4F5F9),
            shadowColor: Colors.black26,
            elevation: 8.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hospitalDetailInfo.addr ?? '', 
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for(String key in mapTraffic.keys)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(flex:2, child: Text('${key}', style: TextStyle(
                              fontSize: 13.0,
                              color: const Color(0xFF262626),
                              fontWeight: FontWeight.w500,
                            ),),),
                          Expanded(
                            flex:8, 
                            child: Text('${mapTraffic[key]}', style: TextStyle(
                                fontSize: 13.0,
                                color: const Color(0xFF262626),
                                fontWeight: FontWeight.normal,
                              ),),
                          ),
                        ],)
                      ],
                    ),
                  )
                ],
              ),
          ),
        ),
      ],
    );
  }
}