import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

enum Name {minsu, san, juui, yeongun, yunseo, jimin}

Map<Name, Color> namecolors = <Name, Color>{
  Name.minsu: const Color(0xff191970),
  Name.san: const Color(0xff40826d),
  Name.juui: const Color(0xffebb563),
  Name.yeongun: const Color(0xff007ba7),
  Name.yunseo: const Color(0xffeb7f63),
  Name.jimin: const Color(0xfff27d68),
};

Map<Name, String> nameString = <Name, String>{
  Name.minsu: '민수',
  Name.san: '산',
  Name.juui: '주의',
  Name.yeongun: '영운',
  Name.yunseo: '윤서',
  Name.jimin: '지민',
};

class Uploadpage extends StatelessWidget {
  const Uploadpage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: Uploadwidget(),
    );
  }
}

class Uploadwidget extends StatefulWidget {
  const Uploadwidget({super.key});

  @override
  State<Uploadwidget> createState() => UploadWidgetStateDefault();
}

class UploadWidgetStateDefault extends State<Uploadwidget> {
  bool connecting = false;
  Name _selectedSegment = Name.minsu;
  File? audiofile;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "노래민수야고마워 데모 페이지\n",
          style: TextStyle(fontSize: 25),
            ),
            const Text(
              "원하는 노래를 업로드하고, 목소리를 골라주세요",
              style: TextStyle(fontSize: 15),
            ),
            CupertinoButton(
              child: const Text('음악 파일 선택'),
              onPressed: () async {
                audiofile = await pickfile();
                setState(() {});
              },
            ),
            CupertinoSlidingSegmentedControl<Name>(
              backgroundColor: CupertinoColors.systemGrey2,
              groupValue: _selectedSegment,
              thumbColor: namecolors[_selectedSegment]!,
              onValueChanged: (Name? value) {
                if (value != null) {
                  setState(() {
                    _selectedSegment = value;
                  });
                }
              },
              children: const <Name, Widget> {
                Name.minsu: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '민수',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                Name.san: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '산',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                Name.juui: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '주의',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                Name.yeongun: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '영운',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                Name.yunseo: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '윤서',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                Name.jimin: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '지민',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
              }
            ),
            const SizedBox(
              width: 30,
              height: 30,
            ),
            CupertinoButton.filled(
              onPressed: audiofile == null ? null :  () async {
                connecting = await postFile(audiofile!, _selectedSegment);
                setState(() {});
              },
              child: const Text('업로드'),
            ),
            const SizedBox(
              width: 15,
              height: 15,
            ),
            connecting ? const CupertinoActivityIndicator(
              radius: 15.0,
              color: CupertinoColors.activeBlue
            ) : const SizedBox(
              width: 30,
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

Future<File?> pickfile() async {
  debugPrint('file picker started');
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
  if (result != null) {
    // User picked the file

    debugPrint('picked');
    debugPrint(result.files.single.path!);

    return File(result.files.single.path!);
  } else {
    // User canceled the picker
    debugPrint('canceled');
    return null;
  }
}

Future<bool> postFile(File file, Name name) async {
  var url = 'http://10.0.2.2:8000';

  debugPrint(nameString[name]);
  FormData formData = FormData.fromMap({
    'file': file,
    'name': nameString[name],
  });

  var dio = Dio();
  try {
    debugPrint('posting data');
    var response = await dio.post(
      url,
      data: formData,
    );
    debugPrint(response.data.toString());
    return true;
  } catch (err) {
    // error occured
    debugPrint('error');
    return false;
  }
}