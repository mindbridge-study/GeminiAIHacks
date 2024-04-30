import 'dart:io';
import 'package:flutter/material.dart';
class PhotoGallaryPage extends StatelessWidget {
  final List<File> picList;
  const PhotoGallaryPage({Key? key, required this.picList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: picList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(imageFile: picList[index]),
                ),
              );
            },
            child: Card(
              child: Image.file(
                picList[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
class FullScreenImage extends StatelessWidget {
  final File imageFile;
  const FullScreenImage({Key? key, required this.imageFile}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateTime.now().toString()),
      ),
      body: Center(
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
