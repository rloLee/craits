import 'dart:async';
import 'dart:convert';

import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/noData.dart';
import 'package:craits/_JClass/followList.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/MyWidget/followDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

//리뷰
class MyFollowingList extends StatefulWidget {

  @override
  _MyFollowingListState createState() => _MyFollowingListState();
}

class _MyFollowingListState extends State<MyFollowingList> {
  int iSearchPageNo = 1;
  bool bLoading  = false;
  bool bNetworkErr = false;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  JFollowList followList;
  ScrollController scrollController;
  
  @override
  void initState() {
    getData();
    scrollController = ScrollController()
      ..addListener(() {
        if(scrollController.position.pixels == scrollController.position.maxScrollExtent && !bMoreData){
          getMoreData();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future getData() async{
    final uri = Uri.parse(commonUri + '/V1/Follow/FollowList.json');
    try{
      if(mounted)
        setState(() {
          bNetworkErr = false;
          bLoading = true;
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchType' : 'FOLLOWING', 
        'searchPageNo' : iSearchPageNo.toString(), // 페이지번호
        'searchPageSize' : '20', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JFollowList _followList;
      if(response.statusCode == 200){
        _followList = JFollowList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          followList = _followList;
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

  Future getMoreData() async{
    final uri = Uri.parse(commonUri + '/V1/Follow/FollowList.json');
    try{
      if(mounted)
        setState(() {
          bMoreData = true;
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchType' : 'FOLLOWING', 
        'searchPageNo' : (++iSearchPageNo).toString(), // 페이지번호
        'searchPageSize' : '20', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JFollowList _followList;
      if(response.statusCode == 200){
        _followList = JFollowList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          followList.info.list.addAll(_followList.info.list);
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
      appBar: AppBar(
        elevation: 1.0,
        title : Text('팔로잉'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
        }),
      ),
      body: (bLoading)
      ? (bNetworkErr)
        ? Center(
          child:Container(
              child: NetworkErr(onRetry: getData)
            ))
        : Center(
            child: CircularProgressIndicator(),
          )
      : followList.resultCode == 'FAIL'?
          Center(child: NoData('팔로우 한 사용자가 없습니다.'))
        : ListView.builder(
          itemCount: followList.info.list.length,
          itemBuilder: (context, index){
            return FollowingUnit(followList.info.list[index]);
        })
    );
  }
}

class FollowingUnit extends StatefulWidget {
  JFollowListInfoListUnit unit;
  FollowingUnit(this.unit);

  @override
  _FollowingUnitState createState() => _FollowingUnitState();
}

class _FollowingUnitState extends State<FollowingUnit> {
  String followFlag = 'Y';
  @override
  Widget build(BuildContext context) {
    return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(right: 15),
                  child: ClipOval(
                    child: (widget.unit.profileImageUrl != null)
                        ? Image.network(
                            widget.unit.profileImageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, exception, stackTrace) {
                              return Image.asset(
                                'assets/noProfile.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover);
                            },
                          )
                        : Image.asset('assets/noProfile.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Text(widget.unit.name.toString(), style: TextStyle(fontSize: 15.0, color: Color(0xFF262626), fontWeight: FontWeight.w500),)),
                Container(
                  height: 35,
                  margin: EdgeInsets.all(10.0),
                  decoration: 
                  followFlag == 'Y'
                    ? ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(20)))
                    : ShapeDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                  child: MaterialButton(
                    onPressed: (){
                        if(followFlag == 'Y') {
                          showDialog(context: context, builder: (context) => FollowDialog(widget.unit.followUserId.toString(), widget.unit.name.toString(), 'N')).then(
                            (value) => {
                              if(value == 'SUCC'){
                                setState(() {
                                  followFlag = 'N';
                                })
                              }
                            }
                          );
                        }
                        else {
                          showDialog(context: context, builder: (context) => FollowDialog(widget.unit.followUserId.toString(), widget.unit.name.toString(), 'Y')).then(
                            (value) => {
                              if(value == 'SUCC'){
                                setState(() {
                                  followFlag = 'Y';
                                })
                              }
                            }
                          );
                        }
                    },
                    child: 
                      followFlag == 'Y'
                      ? Text( '팔로우 중', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14, fontWeight: FontWeight.w500))
                      : Text( '팔로우', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                )
            ],),
          );
  }
}