import 'dart:async';
import 'dart:convert';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/menu3_Medicine/medicineDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:craits/MyWidget/customTabIndigator.dart';
import 'package:craits/_JClass/medicineDetail.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/Common/com.dart';
import 'package:http/http.dart' as http;

class MedicineDetailInfo extends StatefulWidget {
  final String searchId;

  MedicineDetailInfo({
    @required this.searchId,
  });

  @override
  _MedicineDetailInfoState createState() => _MedicineDetailInfoState();
}

class _MedicineDetailInfoState extends State<MedicineDetailInfo> with TickerProviderStateMixin{
  final uri = Uri.parse(commonUri + '/V1/Medicine/MedicineDetail.json');
  JMedicineDetailInfo medicineDetailInfo;
  List<Widget> widgetList;
  AutoScrollController autoScrollController;
  TabController tabController;
  JMedicineDetail medicineDetail;
  bool bLoading = true;
  bool bNetworkErr = false;
  
  Future getData() async {
    try{
      String searchId = widget.searchId;
      
      if(mounted)
        setState(() {
          bLoading = true;
          bNetworkErr = false;
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchId' : searchId.toString(),  //병원 ID
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);
      
      JMedicineDetail _medicineDetail;
      if(response.statusCode == 200){
        _medicineDetail =JMedicineDetail.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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

      if(mounted)
        setState(() {
          this.medicineDetail = _medicineDetail;
          bLoading = false;
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
    } catch(_){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }

  Future _scrollToIndex(int index) async {
    await autoScrollController.scrollToIndex(index,
      preferPosition: AutoScrollPosition.begin);
    autoScrollController.highlight(index);
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
          length: 3 ,
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
              Tab(text: '기본 정보'),
              Tab(text: '도움말'),
              Tab(text: '비슷한 성분 의약품'),
            ]
          ),
        ),
      ),
    );
  }

  @override
    void initState() {
      getData();

      tabController = TabController(length: 3, vsync: this);
      
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

      if( bottom.offset > autoScrollController.offset + autoScrollController.position.viewportDimension || 
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
            child: CircularProgressIndicator(),
          ),
        );
    }
    else{
      if(medicineDetail.resultCode == 'FAIL')
        return NoData("상세정보를 조회할 수 없습니다.");
      else{
        medicineDetailInfo = medicineDetail.info;
        widgetList = [
          defaultInfo(),
          help(),
          sameKind(),
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
            ],
          )
        );
      }
    }
  }

  ExpansionTile defaultInfo() {
    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '기본 정보',
        style: const TextStyle(
            fontSize: 14.0,
            color: Color(0xFF959595),
            height: 2,
            fontWeight: FontWeight.normal),
      ),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기본정보',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: const Color(0xFF262626),
                  fontWeight: FontWeight.w700,
                  height: 1.5),
              ),
              Card(
                color: const Color(0xFFF4F5F9),
                shadowColor: Colors.black26,
                elevation: 8.0,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 150
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(medicineDetailInfo.imageUrl != null)
                        Container(
                          //의약품 이미지
                          child : Image.network(medicineDetailInfo.imageUrl, width: double.infinity, fit: BoxFit.contain , 
                            loadingBuilder: (context, child, loadingProgress) =>
                              (loadingProgress == null) ? child : CircularProgressIndicator(),
                            errorBuilder: (context, exception, stackTrace){
                              return SvgPicture.asset('assets/noImage.svg', fit: BoxFit.contain);
                            },) 
                        ),
                        SizedBox(height: 10,),
                        //명칭
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text('명칭', style:Theme.of(context).textTheme.bodyText1)),
                            Expanded(
                              flex: 8,
                              child: Text(medicineDetailInfo.nm?? '', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),))
                          ],
                        ),
                        SizedBox(height: 10,),
                        //제약회사
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text('제약회사', style:Theme.of(context).textTheme.bodyText1)),
                            Expanded(
                              flex: 8,
                              child: Text(medicineDetailInfo.entpNm ?? '', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),))
                          ],
                        ),
                        SizedBox(height: 10,),
                        //품목분류
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text('품목유형', style:Theme.of(context).textTheme.bodyText1)),
                            Expanded(
                              flex: 8,
                              child: Text(medicineDetailInfo.classNo?? '', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),))
                          ],
                      ),
                      SizedBox(height: 10,),
                      // 전문/일반 구분
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text('구분', style:Theme.of(context).textTheme.bodyText1)),
                          Expanded(
                            flex: 8,
                            child: Text(medicineDetailInfo.etcOtcCd?? '', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500)))
                        ],
                      ),
                      SizedBox(height: 10,),
                      // 성상
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text('성상', style:Theme.of(context).textTheme.bodyText1)
                          ),
                          Expanded(
                            flex: 8,
                            child: Text(medicineDetailInfo.chart?? '', style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),))
                        ],
                      ),
                    ],
                  )),
              ),
            ],
          )),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '저장방법',
                style: const TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF262626),
                    fontWeight: FontWeight.w700,
                    height: 1.5),
              ),
              Card(
                color: const Color(0xFFF4F5F9),
                shadowColor: Colors.black26,
                elevation: 8.0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Text(medicineDetailInfo.storageMethod?? '', style: Theme.of(context).textTheme.bodyText1)
                ),
              ),
            ],
          )),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '보관기간',
                style: const TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF262626),
                    fontWeight: FontWeight.w700,
                    height: 1.5),
              ),
              Card(
                color: const Color(0xFFF4F5F9),
                shadowColor: Colors.black26,
                elevation: 8.0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Text(medicineDetailInfo.validTerm?? '', style: Theme.of(context).textTheme.bodyText1)
                ),
              ),
            ],
          )),
      ]);
  }
  
  ExpansionTile help() {
    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '도움말',
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xFF959595),
          height: 2,
          fontWeight: FontWeight.normal
        ),
      ),
      children: [
        if(medicineDetailInfo.helpContentList == null || medicineDetailInfo.helpContentList.length == 0)
          Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
            child: Card(
              color: const Color(0xFFF4F5F9),
              shadowColor: Colors.black26,
              elevation: 8.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: 
                  Row(
                    children: [
                      Text('-', style: Theme.of(context).textTheme.subtitle2,),
                    ],
                  )
              ),
            ),
          )
        else
        for(JMedicineDetailInfoHelpContentListUnit help in medicineDetailInfo.helpContentList)
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${help.nm}(이)란?',
                style: const TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFF262626),
                    fontWeight: FontWeight.w700,
                    height: 1.5),
              ),
              Card(
                color: const Color(0xFFF4F5F9),
                shadowColor: Colors.black26,
                elevation: 8.0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Text('${help.content?? ''}', style: Theme.of(context).textTheme.bodyText2)
                ),
              ),
            ],
          )),
      ]);
  }

  ExpansionTile sameKind() {
    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      maintainState: false,
      initiallyExpanded: true,
      title: Text(
        '비슷한 의약품',
        style: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF959595),
            height: 2,
            fontWeight: FontWeight.normal),
      ),
      children: [
        Container(
          height: 150,
          child: ListView.builder(
            itemBuilder: (context, index){
              return Card(
                margin: EdgeInsets.all(10),
                color: Colors.white,
                shadowColor: Colors.black45,
                elevation: 10.0,
                child: InkWell(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context) => 
                      MedicineDetail(
                        medicineNm: medicineDetailInfo.sameKindList[index].nm.toString(),
                        searchId: medicineDetailInfo.sameKindList[index].id.toString(),)
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(left:10,),
                    width: 300,
                    child: Row(
                        children: [
                          Expanded(
                            flex : 6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Flexible(
                                child: Text(
                                  medicineDetailInfo.sameKindList[index].nm ?? '', 
                                  style: Theme.of(context).textTheme.headline1,
                                  maxLines: 3, 
                                  overflow: TextOverflow.ellipsis,
                                )),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${medicineDetailInfo.sameKindList[index].avgPrice?? '-'} 원',
                                    style: Theme.of(context).textTheme.bodyText1,
                                    
                                  ),
                                  SizedBox(width: 10,),
                                  Flexible(
                                    child: Text(
                                      medicineDetailInfo.sameKindList[index].entpNm ?? '',
                                      style: Theme.of(context).textTheme.subtitle2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        if( medicineDetailInfo.sameKindList[index].imageUrl != null)
                        Expanded(
                          flex : 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
                            child: Container(
                              height: double.infinity,
                              child:Image.network(medicineDetailInfo.sameKindList[index].imageUrl, fit: BoxFit.fill , 
                                    errorBuilder: (context, exception, stackTrace){
                                      return SvgPicture.asset('assets/noImage.svg', fit: BoxFit.fill);
                                    },) 
                            ),
                          ),
                        ),
                        ],
                      ),
                  ),
                ),
              );
            },
            scrollDirection: Axis.horizontal,
            itemCount: medicineDetailInfo.sameKindList.length,
          ),
        )
      ]);
  }
}