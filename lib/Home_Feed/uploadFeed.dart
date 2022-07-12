import 'dart:convert';
import 'package:craits/Common/com.dart';
import 'package:craits/_JClass/feedList.dart';
import 'package:craits/MyWidget/loadingDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:http/http.dart' as http;

import 'feed_comment.dart';

class UploadFeed extends StatefulWidget {
  final Function onRefresh;
  UploadFeed({@required this.onRefresh});
  @override
  _UploadFeedState createState() => _UploadFeedState();
}

class _UploadFeedState extends State<UploadFeed> {
  FocusNode textFocus = FocusNode();
  TextEditingController textcontroller = TextEditingController();
  int iImgCnt = 0;
  List<XFile> _imageFileList = [];
  bool isVideo = false;
  ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
              icon: SvgPicture.asset('assets/close.svg'),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text('글쓰기'),
          actions: [
            TextButton(
              onPressed: feedUpload, 
              child: Text('완료', style: Theme.of(context).textTheme.headline5,))
          ],
          bottom: PreferredSize(
            child: Divider(),
            preferredSize: Size.fromHeight(1.0),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              if (_imageFileList != null && _imageFileList.length > 0)
                Container(
                  height: 90,
                  child: selectedImageListView(),
                ),
              Expanded( //글
                child: TextField(
                  focusNode: textFocus,
                  controller: textcontroller,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    hintText: '여기에 내용을 입력해 주세요.',
                    hintStyle: Theme.of(context).textTheme.subtitle2,
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyText1,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 500,
                )
              ),
              Divider(
                thickness: 1,
                height: 1,
              ),
              Container(
                  //이미지 추가 버튼
                  child: MaterialButton(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/image.svg',
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '$iImgCnt/10',
                      style: Theme.of(context).textTheme.subtitle2,
                    )
                  ],
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  showAdaptiveActionSheet(
                    context: context,
                    actions: <BottomSheetAction>[
                      BottomSheetAction(
                        title: Text(
                          '사진 찍기',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        onPressed: () {
                          isVideo = false;
                          _onImageButtonPressed(ImageSource.camera,
                              context: context);
                          Navigator.pop(context);
                        },
                      ),
                      BottomSheetAction(
                        title: Text(
                          '사진 보관함',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        onPressed: () {
                          isVideo = false;
                          _onImageButtonPressed(ImageSource.gallery, context: context, isMultiImage: true);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                    cancelAction: CancelAction(
                        title: Text(
                      '취소',
                      style: Theme.of(context).textTheme.headline4,
                    )));
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Future feedUpload() async {
    try {
      final uri = Uri.parse(commonUri + '/V1/Feed/RegisterFeed.json');
      showDialog(context: context, builder: (context) => LoadingDialog()); //로딩
      var params = {
        'user_auth_id': user.userAuthId,
        'content': textcontroller.text,
        'x_pos': dCurLong.toString(),
        'y_pos': dCurLat.toString(),
      };
      final newUri = uri.replace(queryParameters: params);
      var headers = {"Content-Type": "multipart/form-data"};
      var request = http.MultipartRequest('POST', newUri);
      request.headers.addAll(headers);
      for (int i = 0; i < _imageFileList.length; i++)
        request.files.add(
          await http.MultipartFile.fromPath(
            'picture${i.toString()}', _imageFileList[i].path,),
        );
      var response = await request.send().timeout(timeoutDuration);

      Navigator.pop(context); //로딩끝

      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((event) {
          JFeedUpload _feedList = JFeedUpload.fromJson(jsonDecode(event));
          if (_feedList.resultCode == 'SUCC') {
            widget.onRefresh();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FeedComment(feed: _feedList.list,onDelete: widget.onRefresh,)));
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(milliseconds: 1500),
                content: Text('네트워크 오류가 발생했습니다.'))
              );
          }
        });
      } 
      else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('네트워크 오류가 발생했습니다.'))
        );
      }
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context, bool isMultiImage = false}) async {
    if (iImgCnt == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Text('사진은 10장까지 첨부할 수 있습니다.'))
        );
      return;
    }
    if (isMultiImage) {
      try {
        final pickedFileList = await _picker.pickMultiImage(
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 50,
        );
        if(pickedFileList!=null && pickedFileList.length > 0)
          setState(() {
            _imageFileList.addAll(pickedFileList);
            if (_imageFileList.length > 10){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(milliseconds: 1500),
                  content: Text('사진은 10장까지 첨부할 수 있습니다.'))
                );
              _imageFileList.removeRange(10, _imageFileList.length);
            }
            iImgCnt = _imageFileList.length;
          });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: 1500),
            content: Text('오류가 발생했습니다.'))
          );
      }
    } else {
      try {
        XFile pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 50,
          preferredCameraDevice: CameraDevice.rear
        );
        if(pickedFile != null)
          setState(() {
            _imageFileList.add(pickedFile);
            iImgCnt = _imageFileList.length;
          });
      } 
      catch (_) {
        
      }
    }
  }

  ListView selectedImageListView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 70,
                  width: 70,
                  child: Image.file(
                    File(_imageFileList[index].path),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Positioned(
              child: MaterialButton(
                padding: EdgeInsets.zero,
                minWidth: 0,
                height: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withAlpha(180),
                  foregroundColor: Colors.white,
                  maxRadius: 12,
                  child: Icon(
                    Icons.close,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _imageFileList.removeAt(index);
                    iImgCnt = _imageFileList.length;
                  });
                },
              ),
              top: -10,
              right: -10,
            ),
          ],
        );
      },
      itemCount: _imageFileList.length,
    );
  }
}
