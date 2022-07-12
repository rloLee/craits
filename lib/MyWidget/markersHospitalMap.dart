
import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/hospitalList.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class MarkersHosptalMap extends StatefulWidget {
  final double dCurLat;
  final double dCurLng;
  final Function(JHospitalListUnit hospital) onClick;

  MarkersHosptalMap({
    // @required this.hospitalList,
    @required this.dCurLat,
    @required this.dCurLng,
    @required this.onClick,
  });
  
  @override
  _MarkersHosptalMapState createState() => _MarkersHosptalMapState();
}

class _MarkersHosptalMapState extends State<MarkersHosptalMap> {
  List<JHospitalListUnit> hospitalList;
  Completer<NaverMapController> _controller = Completer();
  List<Marker> _markers = [];
  int oldPos ; 
  bool bDispose = false;

  @override
  void initState() {
    getDataSetMarkers(widget.dCurLat, widget.dCurLng);
    super.initState();
  }

  @override
  void dispose() {
    bDispose = true;
    super.dispose();
  }

  void setMarkers(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayImage.fromAssetImage(
        assetName: 'assets/markerHospital.png', 
        context : this.context
      ).then((image) {
        _markers.clear();
        for(int index = 0; index< hospitalList.length; index++){
          JHospitalListUnit hospital =hospitalList[index];
          double dHosLat = double.tryParse(hospital.yPos.toString());
          double dHosLng = double.tryParse(hospital.xPos.toString());
          setState(() {
            _markers.add(Marker(
              markerId: index.toString(),
              position: LatLng(dHosLat,dHosLng),
              captionText: hospital.hospNm,
              captionColor: const Color(0xFF262626),
              captionTextSize: 14.0,
              alpha: 1,
              captionOffset: 10,
              icon: image,
              anchor: AnchorPoint(0.5, 1),
              width: 30,
              height: 40,
              // infoWindow: hospital.hospNm,
              onMarkerTab: _onMarkerTap));
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
        child: Column(
          children: <Widget>[
            _naverMap(),
          ],
        ),
    );
  }
  _naverMap() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          NaverMap(
            initialCameraPosition: CameraPosition(target: LatLng(widget.dCurLat,widget.dCurLng)),
            markers: _markers,
            initLocationTrackingMode: LocationTrackingMode.NoFollow,
            onCameraIdle: () async{
              final controller = await _controller.future;
              controller.getCameraPosition().then((position) {
                  getDataSetMarkers(position.target.latitude, position.target.longitude);
                }
              );
            },
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    );
  }

  void _onMapCreated(NaverMapController controller) {
    _controller.complete(controller);
  }

  void _onMarkerTap(Marker marker, Map<String, int> iconSize) {
    int pos = _markers.indexWhere((m) => m.markerId == marker.markerId);
    setState(() {
      if(pos == oldPos){
        oldPos = null;
        widget.onClick(null);
      }
      else{
        oldPos = pos;
        widget.onClick(hospitalList[int.parse(marker.markerId)]);
      }
    });
  }

  Future getDataSetMarkers(double dCurLat, double dCurLong) async {
  final uri = Uri.parse(commonUri + '/V1/Hospital/HospitalList.json');
    try{
      int iSearchPageNo = 1;

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchOrder' : 'DISTANCE',  //정렬 - NAME : 이름순 - DISTANCE : 거리순 - REVIEW : 평점순 - LAST : 최신순
        'searchPosLat' : dCurLat.toStringAsFixed(5), //위치정보 (위도)
        'searchPosLng' : dCurLong.toStringAsFixed(5), //위치정보 (경도)
        'searchPageNo' : iSearchPageNo.toString(), // 시작 인덱스
        'searchPageSize' : '10', //페이지 크기 (기본 : 10)
        'searchKeyword' : '', //검색어
        'searchFilterSeqs' : '', 
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JHospitalList _hospitalList;
      if(response.statusCode == 200) {
        _hospitalList = JHospitalList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
      if(!bDispose){
        setState(() {
          hospitalList = _hospitalList.info.list;
        });
      }
      if(mounted)
        setMarkers();
    } on TimeoutException catch(_){
      
      if(mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
    } 
    catch(_) {
      if(mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
    }
  }
}