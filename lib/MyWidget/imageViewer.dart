import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class NetworkImagesViewer extends StatefulWidget {
  final List<String> urlList;
  final int index;

  NetworkImagesViewer({this.urlList, this.index = 0});

  @override
  _NetworkImagesViewerState createState() => _NetworkImagesViewerState();
}

class _NetworkImagesViewerState extends State<NetworkImagesViewer> {
  PageController pageController;
  int _current;

  @override
  void initState() {
    _current = widget.index;
    pageController = new PageController(initialPage: widget.index);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
      leading: IconButton(
        icon: SvgPicture.asset('assets/arrowLeft.svg', color: Colors.white,), 
          onPressed: (){
            Navigator.pop(context);
          }),
        backgroundColor: Colors.black,
        title: Text('${_current+1}/${widget.urlList.length}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal,),),
      ),
      body: PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(widget.urlList[index]),
          initialScale: PhotoViewComputedScale.contained,
          minScale: 0.2,
          maxScale: 1.5
          // heroAttributes: PhotoViewHeroAttributes(tag: widget.urlList[index].id),
        );
      },
      itemCount: widget.urlList.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
      // backgroundDecoration: widget.backgroundDecoration,
      pageController: pageController,
      onPageChanged: (index){
        setState(() {
          _current = index;
        });
      }),
    );
  }
}




class FileImageViewer extends StatefulWidget {
  final String path;

  FileImageViewer({this.path});

  @override
  _FileImageViewerState createState() => _FileImageViewerState();
}

class _FileImageViewerState extends State<FileImageViewer> {
  PageController pageController;
  int _current;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
      leading: IconButton(
        icon: SvgPicture.asset('assets/arrowLeft.svg', color: Colors.white,), 
          onPressed: (){
            Navigator.pop(context);
          }),
        backgroundColor: Colors.black,
      ),
      body: PhotoView(
        imageProvider: FileImage(File(widget.path)),
        minScale: 0.2,
        maxScale: 1.5,
      )
    );
  }
}
