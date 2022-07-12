import 'dart:async';
import 'package:craits/Common/com.dart';
import 'package:craits/MyWidget/networkErr.dart';
import 'package:craits/_JClass/noticeList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//
//설정 – 공지사항 화면
//

class Notice extends StatefulWidget {
  Notice({Key key}) : super(key: key);

  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  final uri = Uri.parse(commonUri + '/V1/Board/NoticeList.json');
  int iSearchPageNo = 1;
  bool bMoreData = false; 
  bool bLoading = true;
  bool bNetworkErr = false;
  ScrollController scrollController;
  JNoticeList noticeList;
  List<String> seqReadList = [];

  @override
  void initState() {
    getData();
    scrollController = ScrollController()
      ..addListener(() {
        if(scrollController.position.pixels == scrollController.position.maxScrollExtent && !bMoreData){
          //getMoreData();
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
    if(mounted)
      setState(() {
        bLoading = true;
        bNetworkErr = false;
      });

    try{
      var params = {
        'user_auth_id' : user.userAuthId,
        'searchKeyword' : '',
        'searchPageNo' : iSearchPageNo.toString(),
        'searchPageSize' : '20',
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JNoticeList _noticeList;
      if(response.statusCode == 200) {
        _noticeList = JNoticeList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('네트워크 오류가 발생했습니다.'))
        );
        if(mounted)
          setState(() {
            bNetworkErr = true;
          });
      }

      if(mounted)
        setState(() {
          noticeList = _noticeList;
          bLoading = false;
        });
    }
    on TimeoutException catch(_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
      );
      setState(() {
        bNetworkErr = true;
      });
    } 
    catch (_){
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
        'searchKeyword' : '',
        'searchPageNo' : (++iSearchPageNo).toString(), // 페이지번호
        'searchPageSize' : '20', //페이지 크기 (기본 : 10)
      };

      final newUri = uri.replace(queryParameters: params);
      http.Response response = await http.get(newUri).timeout(timeoutDuration);

      JNoticeList _noticeList;
      if(response.statusCode == 200) {
        _noticeList = JNoticeList.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
          noticeList.list.addAll(_noticeList.list);
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
        title: Text('공지사항'),
        leading: IconButton(
          icon: SvgPicture.asset('assets/arrowLeft.svg'), 
          onPressed: (){
            Navigator.pop(context);
        })),
      body: 
        bLoading?
          (bNetworkErr)?
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height - 200,
                child: NetworkErr(onRetry:getData)))
            : Center(child: CircularProgressIndicator())
        : ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemBuilder: (context, index) {
              //푸시확인 일괄처리를 위해 미확인 푸시 저장
              if(noticeList.list[index].hitYn == 'N')
                seqReadList.add(noticeList.list[index].seq);
              return noticeUnit(unit:noticeList.list[index]);
            },
            itemCount: noticeList.list.length,
          )
    );
  }
  //공지 낱개
  Widget noticeUnit({JNoticeListUnit unit}){
    String hitYn = unit.hitYn;
    return ExpansionTile(
      collapsedBackgroundColor: hitYn == 'Y'? Colors.white : Theme.of(context).primaryColor.withOpacity(0.1),
      tilePadding: EdgeInsets.symmetric(horizontal: 20),
      maintainState: false,
      initiallyExpanded: false,
      title: Text(
        unit.title,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      subtitle: Text(
        unit.regDt?? '',
        style: const TextStyle(fontSize: 12.0, color: Color(0xFFC4C4C4)),
      ),
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: 200
          ),
          color: Color(0xFFF2F4F6),
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          child: Text(unit.content, style: Theme.of(context).textTheme.bodyText2,),
          )
      ]);
  }

  //푸시 확인 보내기 (seq 리스트 또는 seq 한개)
  Future pushRead(List<String> seqList) async{
    final uri = Uri.parse(commonUri + '/V1/Board/NoticeHit.json'); 
    try{
        String seqArr = seqList.join(',');

        var params = {
          'user_auth_id' : user.userAuthId,
          'seqs' : seqArr,
        };
        final newUri = uri.replace(queryParameters: params);
        http.get(newUri).timeout(timeoutDuration);
        // http.Response response = await http.get(newUri).timeout(timeoutDuration);
        // print(response.body);
    } 
    catch(_){

    }
  }

}

