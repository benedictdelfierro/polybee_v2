import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver/gallery_saver.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late Future<ListResult> futureFiles;
  final storageRef = FirebaseStorage.instance.ref();
  Map<int, double> downloadProgress = {};

  @override
  void initState() {
    super.initState();
    futureFiles = storageRef.child('/videos').listAll();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: FutureBuilder<ListResult>(
          future: futureFiles,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final files = snapshot.data!.items;
              return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    double? progress = downloadProgress[index];
                    return ListTile(
                      title: Text(file.name),
                      subtitle: progress != null
                          ? LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.black26,
                            )
                          : null,
                      trailing: IconButton(
                        icon: Icon(Icons.download),
                        color: Colors.black,
                        onPressed: () {
                          downloadFile(index, file);
                        },
                      ),
                    );
                  });
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error occurred'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future downloadFile(int index, Reference ref) async {
    final url = await ref.getDownloadURL();
    final tempdir = await getTemporaryDirectory();
    final path = '${tempdir.path}/${ref.name}';

    await Dio().download(url, path, onReceiveProgress: (received, total) {
      double progress = received / total;
      setState(() {
        downloadProgress[index] = progress;
      });
    });
    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
      print("downloaded");
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Downloaded ${ref.name}')));
  }
}
