import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import './upload_screen.dart';

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
              "변환된 노래에요",
              style: TextStyle(fontSize: 20),
            ),
            CupertinoButton(
              onPressed: _playbutton,
              child: Icon(
                isplaying ? CupertinoIcons.pause : CupertinoIcons.play,
                size: 40
              )
            ),
            CupertinoButton(
              onPressed: () {
                if(isplaying){
                  _player?.stop();
                }
                Navigator.of(context).pushAndRemoveUntil(CupertinoPageRoute(builder: (context) => const Uploadpage()), (Route<dynamic> route) => false);
              },
              child: const Text(
                "한번 더 하기!",
                style: TextStyle(fontSize: 20),
              )
            )
          ]
        )
      )
    );
  }
}