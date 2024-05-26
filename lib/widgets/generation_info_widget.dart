import 'package:flutter/material.dart';

import '../models/generation_info.dart';

class ImgInfoWidget extends StatelessWidget {
  final ImgInfo imgInfo;

  const ImgInfoWidget({super.key, required this.imgInfo});

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Info'),
          content: Text(imgInfo.info!),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfoDialog(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            ListTile(
              title: imgInfo.type == 'img'
                  ? Text('Generated Image')
                  : Text('Plain Log'),
            ),
            imgInfo.type == 'img'
                ? Expanded(
                    child: Row(children: [
                    Expanded(
                        flex: 4,
                        child:
                            FittedBox(fit: BoxFit.contain, child: imgInfo.img)),
                    Expanded(
                        flex: 1,
                        child: ListTile(
                          title: Text('Generation Info'),
                          subtitle: Text(imgInfo.info),
                        ))
                  ]))
                : ListTile(
                    subtitle: Text(imgInfo.info),
                  )
          ],
        ),
      ),
    );
  }
}
