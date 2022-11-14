import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'video_page.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late String plotNumber;
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;
  final db = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              "https://polybee-b7606-default-rtdb.asia-southeast1.firebasedatabase.app")
      .ref();

  late String recordingTs;
  StreamSubscription<Position>? _locationStream;
  StreamSubscription<SensorEvent>? _gyroSubscription;
  StreamSubscription<SensorEvent>? _accelerometerSubscription;
  StreamSubscription<SensorEvent>? _magnetometerSubscription;
  final storageRef = FirebaseStorage.instance.ref();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(
        front,
        ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _startSensorStreams() {
    var dt = DateTime.now().toLocal();
    var newFormat = DateFormat("yyyy-MM-dd-HH:mm:ss");
    recordingTs = newFormat.format(dt);
    print("record ts: $recordingTs");
    _locationStream = _toggleLocationStream(db, recordingTs);
    _gyroSubscription = _toggleGyroscopeEvent(db, recordingTs);
    _accelerometerSubscription = _toggleAccelerometerEvent(db, recordingTs);
    _magnetometerSubscription = _toggleMagnetometerEvent(db, recordingTs);
  }

  _stopSensorStreams() {
    if (_locationStream != null) {
      _locationStream!.cancel();
      _locationStream = null;
    }
    if (_gyroSubscription != null) {
      _gyroSubscription!.cancel();
    }
    if (_accelerometerSubscription != null) {
      _accelerometerSubscription!.cancel();
    }
    if (_magnetometerSubscription != null) {
      _magnetometerSubscription!.cancel();
    }
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      _stopSensorStreams();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(
          filePath: file.path,
          recordingTs: recordingTs,
          plotNumber: plotNumber,
        ),
      );
      print("opening video file path: ${file.path}");
      Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      _startSensorStreams();
      setState(() => _isRecording = true);
    }
  }

  StreamSubscription<Position> _toggleLocationStream(
      DatabaseReference db, String dt) {
    _handlePermission().then((hasPermission) {
      if (!hasPermission) {
        return null;
      }
    });

    StreamSubscription<Position> positionStream;
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (!mounted) {
        return;
      }
      if (position != null && _isRecording) {
        final nextLocation = <String, dynamic>{
          "timestamp": position.timestamp?.toLocal().toString(),
          "longitude": position.longitude,
          "latitude": position.latitude,
          "accuracy": position.accuracy,
          "altitude": position.altitude,
          "heading": position.heading,
          "speed": position.speed,
          "speedAccuracy": position.speedAccuracy,
          "floor": position.floor,
        };
        db
            .child(plotNumber)
            .child(dt)
            .child("geolocation")
            .push()
            .set(nextLocation)
            .then((value) => print('geolocation rec has been inserted'))
            .catchError((error) => print("got error $error"));
      }
    });
    return positionStream;
  }

  StreamSubscription<SensorEvent>? _toggleGyroscopeEvent(
      DatabaseReference db, String dt) {
    SensorManager()
        .isSensorAvailable(Sensors.GYROSCOPE)
        .then((isSensorAvailable) async {
      if (isSensorAvailable) {
        final stream = await SensorManager().sensorUpdates(
            sensorId: Sensors.GYROSCOPE, interval: const Duration(seconds: 5));
        return stream.listen((event) {
          if (!mounted  || !_isRecording) {
            return;
          }
          print("gyro event ${event.data}");
          final nextLocation = <String, dynamic>{
            "x": event.data[0],
            "y": event.data[1],
            "z": event.data[2],
            "timestamp": DateTime.now().toLocal().toString(),
          };
          db
              .child(plotNumber)
              .child(dt)
              .child("gyroscope")
              .push()
              .set(nextLocation)
              .then((value) => print('gyroscope rec has been inserted'))
              .catchError((error) => print("got error $error"));
        });
      }
    });
    return null;
  }

  StreamSubscription<SensorEvent>? _toggleAccelerometerEvent(
      DatabaseReference db, String dt) {
    SensorManager()
        .isSensorAvailable(Sensors.ACCELEROMETER)
        .then((isSensorAvailable) async {
      if (isSensorAvailable) {
        final stream = await SensorManager().sensorUpdates(
            sensorId: Sensors.ACCELEROMETER,
            interval: const Duration(seconds: 5));
        return stream.listen((event) {
          if (!mounted || !_isRecording) {
            return;
          }
          print("accel event ${event.data}");
          final nextLocation = <String, dynamic>{
            "x": event.data[0],
            "y": event.data[1],
            "z": event.data[2],
            "timestamp": DateTime.now().toLocal().toString(),
          };
          db
              .child(plotNumber)
              .child(dt)
              .child("accelerometer")
              .push()
              .set(nextLocation)
              .then((value) => print('accelerometer rec has been inserted'))
              .catchError((error) => print("got error $error"));
        });
      }
    });
    return null;
  }

  StreamSubscription<SensorEvent>? _toggleMagnetometerEvent(
      DatabaseReference db, String dt) {
    SensorManager()
        .isSensorAvailable(Sensors.MAGNETIC_FIELD)
        .then((isSensorAvailable) async {
      if (isSensorAvailable) {
        final stream = await SensorManager().sensorUpdates(
            sensorId: Sensors.MAGNETIC_FIELD,
            interval: const Duration(seconds: 5));
        return stream.listen((event) {
          if (!mounted  || !_isRecording) {
            return;
          }
          print("magnetic event ${event.data}");
          final nextLocation = <String, dynamic>{
            "x": event.data[0],
            "y": event.data[1],
            "z": event.data[2],
            "timestamp": DateTime.now().toLocal().toString(),
          };
          db
              .child(plotNumber)
              .child(dt)
              .child("magnetometer")
              .push()
              .set(nextLocation)
              .then((value) => print('magnetometer rec has been inserted'))
              .catchError((error) => print("got error $error"));
        });
      }
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    plotNumber = ModalRoute.of(context)!.settings.arguments as String;
    print('procesing plot: $plotNumber');
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _isRecording ? [
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.circle,
                    ),
                    onPressed: () => _recordVideo(),
                  ),
                ] : [
                  FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.circle,
                  ),
                  onPressed: () => _recordVideo(),
                ),
                  FloatingActionButton(
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.cancel),
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/');
                      }),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}

Future<bool> _handlePermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return false;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately
    return false;
  }

  return true;
}
