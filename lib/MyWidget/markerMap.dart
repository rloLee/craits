
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'dart:async';

class MarkerMap extends StatefulWidget {
  final String strCaption;
  final String strLat;
  final String strLng;
  final String assetName;

  MarkerMap({
    @required this.strCaption,
    @required this.strLat,
    @required this.strLng,
    @required this.assetName,
  });
  
  @override
  _MarkerMapState createState() => _MarkerMapState();
}

class _MarkerMapState extends State<MarkerMap> {
  Completer<NaverMapController> _controller = Completer();
  List<Marker> _markers = [];
  double dLat;
  double dLng;

  @override
  void initState() {
    dLat = double.tryParse(widget.strLat);
    dLng = double.tryParse(widget.strLng);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayImage.fromAssetImage(
        assetName: widget.assetName, 
        context : this.context
      ).then((image) {
        setState(() {
          _markers.add(Marker(
            markerId: 'id',
            position: LatLng(dLat,dLng),
            captionText: widget.strCaption,
            captionColor: const Color(0xFF262626),
            captionTextSize: 12.0,
            alpha: 1,
            captionOffset: 10,
            icon: image,
            anchor: AnchorPoint(0.5, 1),
            width: 30,
            height: 40,
            onMarkerTab: _onMarkerTap));
        });
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 300,
        child: Column(
          children: <Widget>[
            // _controlPanel(),
            _naverMap(),
          ],
        ),
    );
  }

  // _controlPanel() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         // 추가
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () => setState(() => _currentMode = MODE_ADD),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                   color:
  //                       _currentMode == MODE_ADD ? Colors.black : Colors.white,
  //                   borderRadius: BorderRadius.circular(6),
  //                   border: Border.all(color: Colors.black)),
  //               padding: EdgeInsets.all(8),
  //               margin: EdgeInsets.only(right: 8),
  //               child: Text(
  //                 '추가',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   color:
  //                       _currentMode == MODE_ADD ? Colors.white : Colors.black,
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),

  //         // 삭제
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () => setState(() => _currentMode = MODE_REMOVE),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                   color: _currentMode == MODE_REMOVE
  //                       ? Colors.black
  //                       : Colors.white,
  //                   borderRadius: BorderRadius.circular(6),
  //                   border: Border.all(color: Colors.black)),
  //               padding: EdgeInsets.all(8),
  //               margin: EdgeInsets.only(right: 8),
  //               child: Text(
  //                 '삭제',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   color: _currentMode == MODE_REMOVE
  //                       ? Colors.white
  //                       : Colors.black,
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),

  //         // none
  //         GestureDetector(
  //           onTap: () => setState(() => _currentMode = MODE_NONE),
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 color:
  //                     _currentMode == MODE_NONE ? Colors.black : Colors.white,
  //                 borderRadius: BorderRadius.circular(6),
  //                 border: Border.all(color: Colors.black)),
  //             padding: EdgeInsets.all(4),
  //             child: Icon(
  //               Icons.clear,
  //               color: _currentMode == MODE_NONE ? Colors.white : Colors.black,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  _naverMap() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          NaverMap(
            initialCameraPosition: CameraPosition(target: LatLng(dLat,dLng)),
            //onMapCreated: _onMapCreated,
            //onMapTap: _onMapTap,
            markers: _markers,
            initLocationTrackingMode: LocationTrackingMode.None,
            zoomGestureEnable: false,
          ),
        ],
      ),
    );
  }

  // ================== method ==========================
  void _onMapCreated(NaverMapController controller) {
    _controller.complete(controller);
  }

  // void _onMapTap(LatLng latLng) {
    // if (_currentMode == MODE_ADD) {
    //   _markers.add(Marker(
    //     markerId: DateTime.now().toIso8601String(),
    //     position: latLng,
    //     infoWindow: '테스트',
    //     onMarkerTab: _onMarkerTap,
    //   ));
    //   setState(() {
    //   });
    // }
  // }

  void _onMarkerTap(Marker marker, Map<String, int> iconSize) {
    int pos = _markers.indexWhere((m) => m.markerId == marker.markerId);
    setState(() {
      
    });
    // if (_currentMode == MODE_REMOVE) {
    //   setState(() {
    //     _markers.removeWhere((m) => m.markerId == marker.markerId);
    //   });
    // }
  }
}