import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image/image.dart' as imgServices;
import 'package:image_cropper/image_cropper.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';
import 'package:redi_camera/page_image_preview.dart';

//https://pub.dev/packages/crop_image/example
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final camera = cameras.first;
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CameraPage(
      camera: camera,
    ),
  ));
}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  GlobalKey _cameraKey = new GlobalKey();
  GlobalKey _imageKey = new GlobalKey();
  GlobalKey _cropImageKey = new GlobalKey();
  String pathImage = "";
  bool isCapture = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    _controller = CameraController(widget.camera, ResolutionPreset.high);

    _initializeControllerFuture = _controller.initialize();
  }

  Widget viewImageCapture({required bool isWidget, String path = ""}) {
    if (isWidget && path != "") {
      return RepaintBoundary(
        child: SizedBox(
          child: Image.file(File(path)),
        ),
      );
    }

    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: ((context, snapshot) {
        return CameraPreview(_controller);
      }),
    );
  }

  Future<String> _resizePhoto(path) async {
    try {
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(path);

      int width = properties.width ?? 0;
      int height = properties.height ?? 0;
      var offset = (properties.height! - properties.width!) / 2;

      File croppedFile = await FlutterNativeImage.cropImage(
          path,
          0,
          ((12 * height) / 100).round(),
          width,
          height - ((12 * height) / 100).round());

      return croppedFile.path;
    } catch (e) {
      print(e);
    }

    return "";
  }

  Future<String> _capturePng() async {
    try {
      print('inside');
      // RenderRepaintBoundary boundary = _globalKey.currentContext!
      //     .findRenderObject() as RenderRepaintBoundary;
      // ui.Image image = await boundary.toImage();
      // ByteData byteData =
      //     await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
      // var pngBytes = byteData.buffer.asUint8List();
      // var bs64 = base64Encode(pngBytes);
      // print(pngBytes);
      // print(bs64);
      // final tempDir = await getTemporaryDirectory();
      // File imageFile = await File('${tempDir.path}/image.png').create();
      // imageFile.writeAsBytes(pngBytes);
      var imageFile = await _controller.takePicture();
      String path = imageFile.path;
      return path;
    } catch (e) {
      print(e);
    }
    return "";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //if (!_controller.value.isInitialized) return new Container();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: SizedBox(
            child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: IconButton(
                onPressed: () async {
                  pathImage = await _capturePng();
                  String valueCutImage = await _resizePhoto(pathImage);
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PageImagePreview(imagePath: valueCutImage)));
                },
                iconSize: 65,
                icon: const Icon(Icons.camera),
              ),
            ),
            // IconButton(
            //     onPressed: () => {}, icon: const Icon(Icons.flash_on))
          ],
        ),
        Container(
            child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              key: _imageKey,
              child: FutureBuilder(
                future: _initializeControllerFuture,
                builder: ((context, snapshot) {
                  return CameraPreview(
                    _controller,
                  );
                }),
              ),
            ),
            DottedBorder(
              dashPattern: [10, 10],
              strokeWidth: 2,
              color: Colors.white54,
              child: Container(
                  key: _cropImageKey,
                  height: (80 * height) / 100,
                  width: (80 * width) / 100),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black26),
                    height: height * 0.12,
                    width: width * 0.60,
                    child: const Center(child: Text("BANDA")),
                  )),
            ),
          ],
        ))
      ],
    ) // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}
