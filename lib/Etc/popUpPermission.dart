import 'package:craits/MyWidget/okCancelDialog.dart';
import 'package:craits/MyWidget/okDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
//
//첫실행 시 권한 확인 화면
//
class PopupPermission extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(20, 60, 20, 60),
      elevation: 0.0,
      backgroundColor: Colors.white,  
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SvgPicture.asset('assets/logoText_black_small.svg', width: 100,),
                  SizedBox(height: 10,),
                  Text('크레이츠 앱 사용을 위해\n다음 접근 권한들을 허용해 주세요.', style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center, ),
                ],
              ),
            ),
            Divider(height: 2, thickness: 2,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex:1,
                            child:SvgPicture.asset('assets/permissionStorage.svg', width: 54,)),
                          Expanded(
                            flex:3,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('저장공간 (필수)', style: Theme.of(context).textTheme.headline5,),
                              Text('앱 이용 기록, 진료 기록 이미지 저장', style: TextStyle(fontSize: 15.0, color: Color(0xFF959595)), )
                            ],
                          ),
                        )
                      ],),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex:1,
                            child:SvgPicture.asset('assets/permissionAlarm.svg', width: 54,)),
                          Expanded(
                            flex:3,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('알림 (선택)', style: Theme.of(context).textTheme.headline5,),
                              Text('복용 시간 알림, 증상 문의 알림, \n피드 댓글 및 좋아요 알림', style: TextStyle(fontSize: 15.0, color: Color(0xFF959595)), )
                            ],
                          ),
                        )
                      ],),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex:1,
                            child:SvgPicture.asset('assets/permissionLocation.svg', width: 54,),),
                          Expanded(
                            flex:3,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('위치 (선택)', style: Theme.of(context).textTheme.headline5,),
                              Text('사용자 위치 기반 병원 및 약국 조회,\n사용자 위치 기반 피드 조회', style: TextStyle(fontSize: 15.0, color: Color(0xFF959595)), )
                            ],
                          ),
                        )
                      ],),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex:1,
                            child:SvgPicture.asset('assets/permissionCamera.svg', width: 54,)),
                          Expanded(
                            flex:3,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('사진 및 카메라 (선택)', style: Theme.of(context).textTheme.headline5,),
                              Text('프로필, 진료 기록, 피드 사진 첨부', style: TextStyle(fontSize: 15.0, color: Color(0xFF959595)), )
                            ],
                          ),
                        )
                      ],),
                    ),
                    Divider(height: 2, thickness: 2,),
                    // Container(
                    //   padding: EdgeInsets.all(20),
                    //   child: Text('※ 선택적 접근 권한은 해당 기능을 사용할 때 허용이 필요하며, 허용하지 않으시더라도 크레이츠를 이용하실 수 있으나 일부 서비스의 이용이 제한될 수 있습니다.', 
                    //     style: Theme.of(context).textTheme.subtitle2,),
                    // ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('※ 선택적 접근 권한은 해당 기능을 사용할 때 허용이 필요하며, 허용하지 않으시더라도 크레이츠를 이용하실 수 있으나 일부 서비스의 이용이 제한될 수 있습니다.', 
                            style: Theme.of(context).textTheme.subtitle2,),
                          SizedBox(height: 20,),
                          Text('접근 권한 변경 방법', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500)),
                          Text('휴대폰 설정 > 앱 또는 어플리케이션 관리 > 크레이츠 > 권한에서 각 권한별 변경이 가능합니다.', 
                            style: Theme.of(context).textTheme.subtitle2,),
                        ],
                      ), 
                    )
                  ],
                ),
            )),
            MaterialButton(
              minWidth: double.infinity,
              height: 48,
              color: Theme.of(context).primaryColor, 
              padding: EdgeInsets.zero,
              disabledColor: Theme.of(context).disabledColor,
              child: Text('확인', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white),),
              onPressed: () async{
                //저장공간 권한 요청하기
                var status = await Permission.storage.request();
                if(status.isGranted){
                  Navigator.of(context).pop(true);
                }
                if(status.isDenied) {
                  showDialog(context: context, builder: (context) => OkCancelDialog(
                    text: '크레이츠 서비스를 이용할 수 있도록 권한을 허용해주세요.', 
                    onOk: () async{
                      status = await Permission.storage.request();
                    }));
                }
                if(status.isPermanentlyDenied) {
                  showDialog(context: context, builder: (context) => OkDialog(
                    text: '크레이츠 서비스를 이용할 수 있도록 기기의 설정 메뉴에서 권한을 허용해주세요.',                   
                    onOk: () async{
                      await openAppSettings();
                      },
                    ));
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
