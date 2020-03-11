import 'dart:io';

import 'package:bg_download_widget/bg_download_widget.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const _downloadUrl = "http://ipv4.download.thinkbroadband.com/20MB.zip";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bg download widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DownloadPage(),
    );
  }
}

class _DownloadPageState extends State<DownloadPage> {
  Directory _storageDir;
  bool _ready = false;

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((d) {
      _storageDir = d;
      setState(() => _ready = true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _ready
            ? Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DownloaderWidget(
                          storageDir: _storageDir, url: _downloadUrl)
                    ]))
            : const Center(child: CircularProgressIndicator()));
  }
}

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}
