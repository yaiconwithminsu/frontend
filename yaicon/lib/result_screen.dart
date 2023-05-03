import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class Resultpage extends StatelessWidget {
  const Resultpage({super.key, required this.audio});
  final File audio;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: Resultwidget(audio: audio),
    );
  }
}

class Resultwidget extends StatefulWidget {
  const Resultwidget({super.key, required this.audio});
  final File audio;

  @override
  State<Resultwidget> createState() => ResultWidgetStateDefault();
}

class ResultWidgetStateDefault extends State<Resultwidget> {
  AudioPlayer? _player;
  bool isplaying = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  void _playbutton() {
    if(_player == null) {
      _player = AudioPlayer();
      debugPrint(widget.audio.path);
      _player!.play(DeviceFileSource(widget.audio.path));
    } else {
      if(isplaying) {
      _player!.pause();
      } else {
        _player!.resume();
      }
    }
    
    isplaying = !isplaying;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "원하는 노래를 업로드하고, 목소리를 골라주세요",
              style: TextStyle(fontSize: 15),
            ),
            CupertinoButton(
              onPressed: _playbutton,
              child: Icon(
                isplaying ? CupertinoIcons.pause : CupertinoIcons.play,
                size: 30
              )
            )
          ]
        )
      )
    );
  }
}