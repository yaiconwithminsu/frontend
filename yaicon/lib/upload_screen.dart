import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import './result_screen.dart';

enum Name {minsu, san, juui, yeongun, yunseo, jimin}

var url = 'http://10.0.2.2:8000';

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
  int? id;
  Name _selectedSegment = Name.minsu;
  File? audiofile;
  File? receivedfile;

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
                // from here
                // if (!mounted) return;
                // Navigator.push(
                //   context,
                //   CupertinoPageRoute(builder: (context) => Resultpage(audio: audiofile!))
                // );
                // return;
                // to here is test code
                id = await postFile(audiofile!, _selectedSegment);
                setState(() {});
                if(id == null) return;
                receivedfile = await downloadFile(id!);
                id = null;
                setState(() {});
                if(receivedfile != null){
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => Resultpage(audio: receivedfile!))
                  );
                }
              },
              child: const Text('업로드'),
            ),
            const SizedBox(
              width: 15,
              height: 15,
            ),
            id != null ? const CupertinoActivityIndicator(
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

Future<int?> postFile(File file, Name name) async {
  int? id;
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
    if (response.statusCode == 200) {
      id = response.data;
    } else {
      debugPrint('response is not 200');
    }
  } catch (err) {
    // error occured
    debugPrint('error');
  } finally {
    dio.close();
  }

  return id;
}

Future<File?> downloadFile(int id) async {
  debugPrint('checking server side action is done');
  bool waiting = true;
  var dio = Dio();
  while(waiting) {
    try {
      debugPrint('getting status');
      var response = await dio.get(
        url,
        queryParameters: {'id': id},
      );
      debugPrint(response.data.toString());
      waiting = response.data; // false if work is done
    } catch (err) {
      // error occured
      debugPrint('error while checking status');
    }
  }
  File? ret;

  try {
    var response = await dio.get(
      url,
      queryParameters: {'id': - id},
    );
    ret = File(response.data);
    debugPrint('download done!');
  } catch(err) {
    debugPrint('error while downloading converted file');
  }

  dio.close();

  return ret;
}