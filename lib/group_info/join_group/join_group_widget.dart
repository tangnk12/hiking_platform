import 'package:flutter/material.dart';
import 'dart:typed_data';

class JoinGroupWidget extends StatelessWidget {
  final String title;
  final bool showTitle;
  final Uint8List? groupImage;
  // final List<InfoItem> dataList;

  const JoinGroupWidget(
      {Key? key,
      required this.title,
      this.showTitle = false,
      // this.dataList = infoData,
      required this.groupImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          // Image.network(groupImage,
          //     width: double.infinity, height: 200, fit: BoxFit.cover),
          Image.memory(groupImage!,
              width: double.infinity, height: 200, fit: BoxFit.cover),
        ],
      ),
    );
  }
}
