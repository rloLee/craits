import 'package:flutter/material.dart';
import 'package:craits/_JClass/medicineDetail.dart';
import 'medicineDetailInfo.dart';
import 'medicineDetailReview.dart';

class MedicineDetail extends StatefulWidget {
  final String medicineNm;
  final String searchId;

  MedicineDetail({
    @required this.medicineNm,
    @required this.searchId,
  });

  @override
  _MedicineDetailState createState() => _MedicineDetailState();
}

class _MedicineDetailState extends State<MedicineDetail> {
  JMedicineDetail pharmacyDetail;
  bool showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:AppBar(
          elevation: 1.0,
          title: Text(widget.medicineNm),
          iconTheme: IconThemeData(
            color: Colors.black87
          ),
        ), 
        body: MedicineDetailInfo(searchId: widget.searchId,),
      )
      // Scaffold(
      //   backgroundColor: Colors.white,
      //   appBar:AppBar(
      //     elevation: 1.0,
      //     title: Text(widget.medicineNm),
      //     iconTheme: IconThemeData(
      //       color: Colors.black87
      //     ),
      //     bottom: TabBar(
      //       indicatorWeight: 3,
      //       tabs: <Widget>[
      //         Tab(
      //           text: '상세정보',
      //         ),
      //         Tab(
      //           text: '리뷰',
      //         ),
      //       ],
      //     ),
      //   ), 
      //   body: TabBarView(
      //     children: <Widget>[
      //       MedicineDetailInfo(searchId: widget.searchId,),
      //       MedicineDetailReview(widget.searchId)
      //     ],
      //   )
      // )
    );
  }
}
