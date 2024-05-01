import 'dart:io';
import 'dart:developer' as developer;
import 'photo_gallary_page.dart';
import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController cameraController;
  Future<void>? cameraValue;
  List<File> picList = [];
  List<CameraDescription> cameras = [];
  bool flash = false;
  bool rear = true;

  Future<File> saveImage(XFile image) async {
    try {
      final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('$downloadPath/$fileName');
      await file.writeAsBytes(await image.readAsBytes());
      MediaScanner.loadMedia(path: file.path); // Ensure media is scanned
      return file;
    } catch (e) {
      developer.log('Error saving or scanning file', error: e, name: 'CameraPage');
      rethrow; // Optionally rethrow to handle the error upstream
    }
  }

  void takePhoto() async {
    XFile? image;

    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) {
      return;
    }
    if (flash == false) {
      await cameraController.setFlashMode(FlashMode.off);
    } else {
      await cameraController.setFlashMode(FlashMode.torch);
    }
    image = await cameraController.takePicture();
    if (cameraController.value.flashMode == FlashMode.torch) {
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
    }

    final file = await saveImage(image);

    setState(() {
      picList.add(file);
    });
    await Gal.putImage(file.path);

    MediaScanner.loadMedia(path: file.path);
  }

  void startCamera(int cameraIndex) {
    cameraController = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize().then((_) {
      setState(
          () {}); // Ensure the camera is initialized before setting the state
    });
  }

  Future<void> checkPermissionsAndStartCamera() async {
    if (Platform.isIOS || Platform.isAndroid) {
      final PermissionStatus cameraStatus = await Permission.camera.status;

      if (!cameraStatus.isGranted) {
        final PermissionStatus permissionStatus =
            await Permission.camera.request();
        if (permissionStatus.isGranted) {
          developer.log('Camera permission granted');
          final PermissionStatus storageStatus =
              await Permission.storage.status;
          if (!storageStatus.isGranted) {
            final PermissionStatus permissionStatus =
                await Permission.storage.request();
            if (permissionStatus.isGranted) {
              developer.log('Storage permission granted');
            } else if (permissionStatus.isPermanentlyDenied) {
              developer.log('Storage permission permanently denied');
              return;
            } else if (!permissionStatus.isGranted) {
              developer.log('Storage permission not granted');
              return;
            }
          }
        } else if (permissionStatus.isPermanentlyDenied) {
          developer.log('Camera permission permanently denied');
          return;
        } else if (!permissionStatus.isGranted) {
          developer.log('Camera permission not granted');
          return;
        }
      }
    }

    findAvailableCameras();
  }

  void findAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        setState(() {
          startCamera(0);
        }); // Call setState to update the UI with the available cameras
      }
    } catch (e) {
      // Handle the error appropriately
      developer.log('Failed to get available cameras:', error: e);
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermissionsAndStartCamera();
  }

  @override
  void dispose() {
    if (cameraController.value.isInitialized) {
      cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: takePhoto,
        backgroundColor: Colors.amber,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.camera_alt,
          size: 40,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.done:
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
                default:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 5, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.amber, shape: BoxShape.circle),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          flash = !flash;
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.amber, shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: flash
                              ? const Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : const Icon(Icons.flash_off),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          rear = !rear;
                          startCamera(rear ? 0 : 1);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.amber, shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: rear
                              ? const Icon(
                                  Icons.camera_rear,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : const Icon(Icons.camera_front),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhotoGallaryPage(picList: picList),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: rear
                              ? const Icon(
                                  Icons.photo_album,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : const Icon(Icons.camera_front),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 75),
              child: FutureBuilder(
                future: fetchText(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        snapshot.data.toString(),
                        style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 255, 255, 255)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



  Future<String> fetchText() async { // Omar change this so it returns the AI output lol
    await Future.delayed(Duration(seconds: 7));
    return "sample text";
  }
}