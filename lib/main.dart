import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //final cameras = await availableCameras();

  //final camera = cameras.first;
  runApp(MaterialApp(
    home: CameraPage(
      /*camera: camera,*/
    ),
  ));
}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, /*required this.camera*/}) : super(key: key);

  //final CameraDescription camera;
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    //
    // _controller = CameraController(widget.camera, ResolutionPreset.medium);
    //
    // _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(onPressed: () => {}, icon: const Icon(Icons.camera, size: 60,)),
                // IconButton(
                //     onPressed: () => {}, icon: const Icon(Icons.flash_on))
              ],
            ),
            Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    child: Container(
                      width: width * 0.88,
                      color: Colors.red,
                    ),
                  ), DottedBorder(
                        dashPattern: [10,10],
                        strokeWidth: 2,
                        color: Colors.white54,
                        child:
                        Container(
                          height: height * 0.9,
                          width: width * 0.80
                        )),
                  Padding(
                   padding: const EdgeInsets.only(bottom: 40),
                   child: Container(
                     alignment: Alignment.bottomCenter,
                     decoration:
                     const BoxDecoration(color: Colors.transparent),
                     child: Container(
                       decoration: const BoxDecoration(color: Colors.black12),
                       height: 40,
                       width: width * 0.75,
                       child: const Center(child: Text("BANDA")),
                     )),
                   ),
                  // FutureBuilder(
                  //   future: _initializeControllerFuture,
                  //   builder: (context, snapshot) {
                  //     return CameraPreview(_controller);
                  //   },
                  // )
                ],
              )
            )
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}
