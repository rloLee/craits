
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';

class MyProfileImage extends StatefulWidget {
  final File sample;
  MyProfileImage(this.sample);

  @override
  _MyProfileImageState createState() => _MyProfileImageState();
}

class _MyProfileImageState extends State<MyProfileImage> {
  final cropKey = GlobalKey<CropState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Crop.file(
              widget.sample,
              scale: 1.0,
              aspectRatio: 1,
              key: cropKey)),
          Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(
                    '취소',
                    style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    '확인',
                    style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
                  ),
                  onPressed: (){
                    _cropImage();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Future<void> _cropImage() async {
    final area = cropKey.currentState.area;
    if (area == null) {
      return;
    }

    final file = await ImageCrop.cropImage(
      file: widget.sample,
      area: area,
    );
    
    Navigator.of(context).pop(file);
  }
} 
