import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    print('No cameras found');
    return;
  }
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(cameras: cameras),
    );
  }
}

class MainPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MainPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  List<File> picList = [];
  bool flash = false;
  bool rear = true;


Future<File> saveImage(XFile image) async {
  final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
  final file = File('$downloadPath/$fileName');

  try {
    await file.writeAsBytes(await image.readAsBytes());
  } catch(_){}

  return file;
}

void takePhoto() async {
  XFile? image;
  
  if(cameraController.value.isTakingPicture || !cameraController.value.isInitialized) {
    return;
  }
  if(flash == false) {
    await cameraController.setFlashMode(FlashMode.off);
  } else {
    await cameraController.setFlashMode(FlashMode.torch);
  }
  image = await cameraController.takePicture();
  if(cameraController.value.flashMode == FlashMode.torch) {
    setState(() {
      cameraController.setFlashMode(FlashMode.off);
    });
  }

  final file = await saveImage(image);

  setState(() {
    picList.add(file);
  });

  MediaScanner.loadMedia(path: file.path);


}

  void startCamera(int cameraIndex) {
    cameraController = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  @override
  void initState() {
    startCamera(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: takePhoto, backgroundColor: Colors.amber, shape: CircleBorder(), child: Icon(Icons.camera_alt, size: 40, color: Colors.black,),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: 100,
                      child: CameraPreview(cameraController),
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(padding: EdgeInsets.only(right: 5, top: 10),
              child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      flash = !flash;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                    child: Padding(padding: EdgeInsets.all(10), child: flash? Icon(Icons.flash_on, color: Colors.white, size: 30,) : Icon(Icons.flash_off),),
                  ),
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      rear = !rear;
                    });
                    rear ? startCamera(0) : startCamera(1);
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                    child: Padding(padding: EdgeInsets.all(10), child: rear? Icon(Icons.camera_rear, color: Colors.white, size: 30,) : Icon(Icons.camera_front),),
                  ),
                ),

              ],
              ),
              ),
              ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(padding: EdgeInsets.only(left: 7, bottom: 75),
                  child: Container(height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: picList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(padding: EdgeInsets.all(2),
                      child: ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: Image (
                        height: 100,
                        width: 100,
                        opacity: AlwaysStoppedAnimation(07),
                        image: FileImage(
                          File(picList[index].path)
                          ),
                          fit: BoxFit.cover,
                      ),
                      
                      ),
                      );

                    },
                    ),
                  ),
                  ),
                  ),],
                  ),

          )

        ],
      ),
    );
  }
}
