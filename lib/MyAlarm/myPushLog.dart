import 'dart:async';
import 'dart:convert';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:craits/Common/com.dart';
import 'package:craits/Home_Feed/feed_comment.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:craits/_JClass/pushLogList.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

//리뷰
class PushLogList extends StatefulWidget {
  @override
  _PushLogListState createState() => _PushLogListState();
}

class _PushLogListState extends State<PushLogList> {
  final uri = Uri.parse(commonUri + '/V1/Push/PushLogList.json');
  int iSearchPageNo = 1;
  bool bLoading  = false;
  bool bNetworkErr = false;
  bool bMoreData = false; //로딩아이콘 표시할때사용..
  ScrollController scrollController;
  JPushLogList pushLogList;
  List<String> seqReadList = [];
  List<String> seqDeleteList = [];
  bool bDeleteMode = false;

  final Map<String, String> sortItem = {
    ''   : '전체',
    'FOLLOW' : '팔로우 알림',
    'CMT' : '댓글 알림',
    'LIKE' : '좋아요 알림',
    'TAKE' : '약복용 알림',
    'MIS' : '오처방 알림',
    'DUP' : '중복처방 알림',
  }; 
  String sortKey = '';

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
    //푸시확인 일괄처리
    if(seqReadList.length > 0)
      pushRead(seqReadList);

    scrollController.dispose();
    super.dispose();
  }

  Future getData() async{
    try{
      if(mounted)
        setState(() {
          bNetworkErr = false;
          bLoading = true;
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchNotiType' : sortKey,
        'searchPageNo' : iSearchPageNo.toString(), // 페이지번호
        'searchPageSize' : '20', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JPushLogList _pushLogList;
      if(response.statusCode == 200){
        _pushLogList = JPushLogList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          pushLogList = _pushLogList;
          bLoading = false;
        });
    } on TimeoutException catch(_) {
      ScaffoldMessenger.of( context).showSnackBar(
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
    try{
      if(mounted)
        setState(() {
          bMoreData = true;
        });

      var params = {
        'user_auth_id' : user.userAuthId,
        'searchNotiType' : sortKey,
        'searchPageNo' : (++iSearchPageNo).toString(), // 페이지번호
        'searchPageSize' : '20', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JPushLogList _pushLogList;
      if(response.statusCode == 200){
        _pushLogList = JPushLogList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          pushLogList.list.addAll(_pushLogList.list);
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
        title : Text('알림'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
        }),
      ),
      body: (bLoading)
      ? (bNetworkErr)
        ? Center(
            child: Container(
              child: NetworkErr(onRetry: getData)
            ))
        : Center(
            child: CircularProgressIndicator(),
          )
      : RefreshIndicator(
        onRefresh: getData,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: const Color(0xFFE3E3E3)))),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    onPressed: (){
                      showAdaptiveActionSheet(
                        context: context,
                        actions: <BottomSheetAction>[
                          for(String key in sortItem.keys)
                            BottomSheetAction(
                              title: Text(sortItem[key], style: Theme.of(context).textTheme.headline4,),
                              onPressed: () {
                                setState(() {
                                  sortKey = key;
                                });
                                Navigator.of(context).pop();
                                getData();
                              },
                            ),
                        ],
                        cancelAction: CancelAction(
                          title: Text('취소', style: Theme.of(context).textTheme.headline4,))
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      constraints: BoxConstraints(minWidth: 80),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(sortItem[sortKey], style: Theme.of(context).textTheme.bodyText1,),
                          SvgPicture.asset('assets/arrowDown.svg')
                        ],
                      ),
                    ),
                  ),
                  if(bDeleteMode)
                    MaterialButton(
                      padding: EdgeInsets.zero,
                      minWidth: 10,
                      child: SvgPicture.asset('assets/check.svg', ),
                      onPressed: (){
                        setState(() {
                          bDeleteMode = false;
                          pushDelete(seqList: seqDeleteList);
                          // getData();
                          seqDeleteList = [];
                        });
                      })
                  else
                    MaterialButton(
                      padding: EdgeInsets.zero,
                      minWidth: 10,
                      child: SvgPicture.asset('assets/trash.svg', ),
                      onPressed: (){
                        setState(() {
                          bDeleteMode = true;
                        });
                      })
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: pushLogList.list.length,
                itemBuilder: (context, index){
                  //푸시확인 일괄처리를 위해 미확인 푸시 저장
                  if(pushLogList.list[index].hitYn == 'N')
                    seqReadList.add(pushLogList.list[index].seq);
                  return pushLogUnit(
                    unit: pushLogList.list[index],
                    onDelete: (){
                      setState(() {
                        seqDeleteList.add(pushLogList.list[index].seq);
                        pushLogList.list.removeAt(index);
                      });
                    }
                  );
                },
                separatorBuilder : (context, index){
                  return Divider();
                }
              ),
            ),
          ],
        ),
      )
    );
  }


  //푸시 낱개
  Widget pushLogUnit({JPushLogListUnit unit, Function onDelete}){
    String hitYn = unit.hitYn;
    
    return ListTile(
      tileColor: hitYn == 'Y'? Colors.white : Theme.of(context).primaryColor.withOpacity(0.1),
      title: InkWell(
        onTap: (bDeleteMode)? null
          :(){
          //미확인 푸시는 클릭 시 흰색으로..
          if(hitYn == 'N'){
            setState(() {
              hitYn = 'Y';
            });
          }
          
          if(unit.notiType == 'CMT'){
            Navigator.push(context, MaterialPageRoute(builder:(context) => FeedComment(feedId: unit.linkId, onDelete: (){}), ));
          }
          // pushRead 전송은 dispose시 일괄 처리하므로 따로 안 함.
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 80,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.title, style: Theme.of(context).textTheme.headline3,),
                    Text(unit.body, style: Theme.of(context).textTheme.bodyText2,),
                    Text(unit.elapsedTime, style: Theme.of(context).textTheme.caption,)
                  ],
                ),
              ),
              if(bDeleteMode)
                MaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  minWidth: 0,
                  child: SvgPicture.asset('assets/close.svg', ),
                  onPressed: onDelete,
                )
            ],
          ),
        ),
      ),
    );
  }
  
  //푸시 확인 보내기 (seq 리스트 또는 seq 한개)
  Future pushRead(List<String> seqList) async{
    final uri = Uri.parse(commonUri + '/V1/Push/PushRead.json'); 
    try{
        String seqArr = seqList.join(',');;

        var params = {
          'user_auth_id' : user.userAuthId,
          'seqs' : seqArr,
        };
        final newUri = uri.replace(queryParameters: params);
        http.get(newUri).timeout(timeoutDuration);
        // http.Response response = await http.get(newUri).timeout(timeoutDuration);
    } 
    catch(_){

    }
  }
  
  //푸시 지우기 (검토)
  Future pushDelete({@required List<String> seqList}) async{
    final uri = Uri.parse(commonUri + '/V1/Push/PushDelete.json'); 
    try{		
      if(seqList.length > 0){
        String seqs = seqList.join(',');
        var params = {
          'user_auth_id' : user.userAuthId,
          'seqs' : seqs,
        };
        final newUri = uri.replace(queryParameters: params);
        showDialog(context: context, builder: (context)=>LoadingDialog());
        http.Response response = await http.get(newUri).timeout(timeoutDuration);
        Navigator.pop(context);
      }
    } 
    catch(_){

    }
  }
}