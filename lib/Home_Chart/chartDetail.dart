import 'package:craits/Home_Chart/chartEnvelopeDetail.dart';
import 'package:craits/Home_Chart/chartPrescriptionDetail.dart';
import 'package:craits/Home_Chart/chartReceiptDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

//
//진료기록 낱개 선택 시 화면. 상세보기 상단 탭(처방전,약봉투,영수증) 구성
//

class ChartDetail extends StatefulWidget {
  final String searchBundleId;
  final int tabIndex;
  
  ChartDetail({
    @required this.searchBundleId, 
    this.tabIndex = 0, 
    });

  @override
  _ChartDetailState createState() => _ChartDetailState();
}

class _ChartDetailState extends State<ChartDetail> with TickerProviderStateMixin<ChartDetail> {

  TabController tabController ;

  @override
  void initState() {
    tabController = TabController(initialIndex: widget.tabIndex, length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar:AppBar(
          elevation: 1.0,
          title: Text('상세보기'),
          leading: IconButton(
            icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
          }),
          bottom: TabBar(
            controller: tabController,
            indicatorWeight: 3.0,
            tabs: <Widget>[
              Tab(text:'처방전'),
              Tab(text:'약봉투',),
              Tab(text:'영수증'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: <Widget>[
            ChartPrescriptionDetail(searchRecordId: widget.searchBundleId),
            ChartEnvelopeDetail(searchRecordId: widget.searchBundleId),
            ChartReceiptDetail(searchRecordId: widget.searchBundleId),
          ],
        ),
      ),
    );
  }
}