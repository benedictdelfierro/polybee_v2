import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';


class VideoPage extends StatefulWidget {
  final String filePath;
  final String recordingTs;
  final String plotNumber;

  const VideoPage({Key? key, required this.filePath, required this.recordingTs, required this.plotNumber}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  final storageRef = FirebaseStorage.instance.ref();
  final dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
      "https://polybee-b7606-default-rtdb.asia-southeast1.firebasedatabase.app")
      .ref();
  
  bool _deleteSensors = true;


  @override
  Future<void> dispose() async {
    print("disposing event triggered");
    if (_deleteSensors) {
      print("deleting sensors");
      await _deleteSensorData();
    }
    await _videoPlayerController.dispose();
    super.dispose();
  }


  Future<void> _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(false);
    await _videoPlayerController.play();
  }


  Future<void> _uploadVideo() async {
    setState(() {
      _deleteSensors = false;
    });
    Reference? imagesRef = storageRef.child("videos");
    final fileName = "${widget.plotNumber}-${widget.recordingTs}.mp4";
    final spaceRef = imagesRef.child(fileName);
    try {
      await spaceRef.putFile(File(widget.filePath));
      final url = await spaceRef.getDownloadURL();
      spaceRef.fullPath;
      print("video url : $url");
      dbRef
          .child(widget.plotNumber)
          .child(widget.recordingTs)
          .update({
        "videoUrl": url,
      })
          .then((value) => print('updated video link: $url'))
          .catchError((error) => print("got error $error"));

    } on FirebaseException catch (e) {
      print("error uploading video, $e");
    }
  }

  Future<void> _deleteSensorData() async {
    await dbRef.child("plots/${widget.plotNumber}/${widget.recordingTs}")
        .remove()
        .catchError((err) {
          print("error deleting sensorData");
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _uploadVideo();
              Navigator.pop(context);
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );

  }

}
