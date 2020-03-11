import 'dart:io';

import 'package:bg_download/bg_download.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pedantic/pedantic.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:round_buttons/round_buttons.dart';

class _DownloaderWidgetState extends State<DownloaderWidget> {
  _DownloaderWidgetState({
    @required this.storageDir,
    @required this.url,
  });

  final Directory storageDir;
  final String url;

  bool isDownloaded = false;
  File file;
  int progress = 0;
  bool isDownloading = false;

  BgDownloader _downloader;
  String _received = "0";
  String _total = "?";
  String _status = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              child: !isDownloaded
                  ? isDownloading
                      ? _downloader.isFilesizeKnown
                          ? CircularPercentIndicator(
                              progressColor: Colors.green,
                              backgroundColor: Colors.grey,
                              radius: 140.0,
                              lineWidth: 10.0,
                              percent: progress / 100,
                              center: Text("$progress%", textScaleFactor: 2.5),
                            )
                          : const Text("")
                      : BigRoundButton(
                          text: "Download",
                          iconData: Icons.file_download,
                          onPressed: () async {
                            setState(() {
                              isDownloading = true;
                              _status = "Connecting ...";
                            });
                            _downloader = BgDownloader(
                                url: url,
                                directory: storageDir,
                                onDownloaded: (f) {
                                  file = f;
                                  print("Download completed: ${file.path}");
                                  setState(() {
                                    isDownloaded = true;
                                    _status = "Download completed";
                                  });
                                },
                                onProgress: (p) => setState(() {
                                      //print("PROGRESS: $progress");
                                      _total ??= p.totalHumanized;
                                      if (_status == "Connecting ...") {
                                        var str = "Downloading ";
                                        if (p.hasTotal) {
                                          str += "${p.totalHumanized}";
                                        } else {
                                          str += "file of unknown size";
                                        }
                                        _status = str;
                                      }
                                      if (p.state.hasNewPercentValue(
                                          p.receivedPercent)) {
                                        progress = p.receivedPercent;
                                      }
                                      _received = p.receivedHumanizedFormated;
                                    }));
                            unawaited(_downloader.run());
                          },
                        )
                  : BigRoundButton(
                      iconData: Icons.filter_none,
                      color: Colors.green,
                      text: "Open",
                      onPressed: () async {
                        unawaited(OpenFile.open(file.path));
                        //if (file.path.split("/").last == "flashlinks.apk") {
                        //  exit(0);
                        // }
                        await Navigator.of(context).pushReplacementNamed("/");
                      },
                    ),
            )),
        if (isDownloading)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                _status,
                textScaleFactor: 1.3,
              )),
        if (isDownloading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: (_received != "0")
                ? Text(_received,
                    textScaleFactor: 1.5,
                    style: const TextStyle(color: Colors.white))
                : const Text(""),
          ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: isDownloading
                ? CancelButton(onPressed: () {
                    _downloader.cancel();
                    Navigator.of(context).pushReplacementNamed("/");
                  })
                : CancelButton(onPressed: () {
                    Navigator.of(context).pushReplacementNamed("/");
                  })),
      ],
    );
  }
}

/// The downloader widget
class DownloaderWidget extends StatefulWidget {
  /// Default constructor
  const DownloaderWidget({
    @required this.storageDir,
    @required this.url,
  });

  /// The directory where to download
  final Directory storageDir;

  /// The url of the file
  final String url;

  @override
  _DownloaderWidgetState createState() =>
      _DownloaderWidgetState(storageDir: storageDir, url: url);
}
