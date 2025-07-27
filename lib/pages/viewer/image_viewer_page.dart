import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String path;
  const ImageViewerPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: InteractiveViewer(
          child: Center(child: Image.file(File(path))),
        ),
      );
}
