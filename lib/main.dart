import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
  final GlobalKey _cameraKey = GlobalKey();
  GlobalKey _imageKey = new GlobalKey();
  GlobalKey _cropImageKey = new GlobalKey();
  String pathImage = "";
  Widget imageRepaint = Container();
  bool isCapture = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    _controller = CameraController(widget.camera, ResolutionPreset.high);

    _initializeControllerFuture = _controller.initialize();
  }

  Future<String> _cutPhoto(path) async {
    try {
      RenderRepaintBoundary boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      img.Image imageConvert = image as img.Image;
      imageConvert = img.copyCrop(imageConvert, 1, 1, 1, 1);
      Uint8List pngBytes = imageConvert.getBytes();
      //String bs64 = base64Encode(pngBytes);

      Directory tempDir = await getTemporaryDirectory();

      File imageFile = await File('${tempDir.path}/image.png').create();
      imageFile.writeAsBytes(pngBytes);

      return imageFile.path;
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
      // ImageProperties properties =
      //     await FlutterNativeImage.getImageProperties(path);

      // int width = properties.width ?? 0;
      // int height = properties.height ?? 0;
      // var offset = (properties.height! - properties.width!) / 2;

      // File croppedFile = await FlutterNativeImage.cropImage(
      //     path,
      //     0,
      //     ((12 * height) / 100).round(),
      //     width,
      //     height - ((12 * height) / 100).round());

      // return croppedFile.path;
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<void> _captureImgCamereAndUseInWidget() async {
    try {
      //print('inside');
      var image = await _controller.takePicture();
      Size currentSize = _cameraKey.currentContext!.size!;
      imageRepaint = RepaintBoundary(
        child: SizedBox(
          width: currentSize.width,
          height: currentSize.height,
          child: Image.file(File(image.path)),
        ),
      );

      isCapture = true;
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
    } catch (e) {
      throw Exception(e);
    }
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
    Size size = MediaQuery.of(context).size;
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
                  _captureImgCamereAndUseInWidget();
                  String valueCutImage = await _cutPhoto(pathImage);
                  // ignore: use_build_context_synchronously
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             PageImagePreview(imagePath: valueCutImage)));

                  // initState();
                },
                iconSize: (width * 0.1),
                icon: const Icon(Icons.camera),
              ),
            ),
            // IconButton(
            //     onPressed: () => {}, icon: const Icon(Icons.flash_on))
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            isCapture ? imageRepaint : Container(),
            SizedBox(
              key: _imageKey,
              child: FutureBuilder(
                future: _initializeControllerFuture,
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(
                      _controller,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
            ),
            DottedBorder(
              dashPattern: const [10, 10],
              strokeWidth: 2,
              color: Colors.white54,
              child: SizedBox(
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
        )
      ],
    ) // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}
