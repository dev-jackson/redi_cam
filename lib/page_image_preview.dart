import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageImagePreview extends StatefulWidget {
  final String imagePath;

  const PageImagePreview({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<PageImagePreview> createState() => _PageImagePreviewState();
}

class _PageImagePreviewState extends State<PageImagePreview> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image preview"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Container(
            child: Image.file(
              File(widget.imagePath),
            ),
          ),
        ),
      ),
    );
  }
}
