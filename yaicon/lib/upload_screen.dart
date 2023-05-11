import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import './result_screen.dart';

enum Name {minsu, chim}

Map<Name, Color> namecolors = <Name, Color>{
  Name.minsu: const Color(0xff191970),
  Name.chim: const Color(0xffebb563),
};

Map<Name, String> nameString = <Name, String>{
  Name.minsu: '민수',
  Name.chim: '침착맨'
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
  PlatformFile? audiofile;
  bool? received;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
                Name.chim: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '침착맨',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
              }
            ),
            const SizedBox(
              width: 30,
              height: 30,
            ),
            const Text('포트 번호 입력'),
            SizedBox(
              width: 120,
              height: 40,
              child: CupertinoTextField(
                controller: _textController,
                keyboardType: TextInputType.number,
                placeholder: 'port',
                onChanged: (text){
                  setState(() {});
                },
              )
            ),
            const SizedBox(
              width: 30,
              height: 30,
            ),
            CupertinoButton.filled(
              onPressed: (audiofile == null) || (_textController.text == '') ? null :  () async {
                // from here
                // if (!mounted) return;
                // Navigator.push(
                //   context,
                //   CupertinoPageRoute(builder: (context) => Resultpage(audio: audiofile!))
                // );
                // return;
                // to here is test code
                id = await postFile(audiofile!, _selectedSegment, int.parse(_textController.text));
                var tmpid = id;
                setState(() {});
                if(id == null) return;
                received = await downloadFile(id!, int.parse(_textController.text));
                id = null;
                setState(() {});
                if(received != null){
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => Resultpage(audio: tmpid!, port: int.parse(_textController.text,)))
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

Future<PlatformFile?> pickfile() async {
  debugPrint('file picker started');
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
  if (result != null) {
    // User picked the file

    debugPrint('picked');
    // debugPrint(result.files.single.path!);

    return result.files.single;
  } else {
    // User canceled the picker
    debugPrint('canceled');
    return null;
  }
}

Future<int?> postFile(PlatformFile file, Name name, int port) async {
  int? id;
  var url = 'http://165.132.46.80:${port}/minsu/';
  debugPrint(nameString[name]);
  try {
      MultipartRequest request = MultipartRequest('POST', Uri.parse(url));
      request.fields['name'] = nameString[name]!;
      
      //요청에 이미지 파일 추가
      request.files.add(MultipartFile.fromBytes('audio', file.bytes!, filename: file.name));
      var response = await request.send();
      
      if (response.statusCode == 200) {
        debugPrint('getting response');
        final body = await response.stream.bytesToString();
        debugPrint(body);
        // jsonBody를 바탕으로 data 핸들링

        id = int.parse(body);
      }
    } catch (e) {
      Exception(e);
    } finally {
      
    }
  return id;
}

Future<bool?> downloadFile(int id, int port) async {
  bool waiting = true;
  // Uint8List? ret;
  var url = 'http://165.132.46.80:${port}/minsu/';
  while(waiting){
    try {
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('checking server side action');
      Response response = await get(Uri.parse('$url?id=$id'));
      final body = response.body;
      debugPrint(body);
      waiting = body == 'False';
    } catch (e) {
      Exception(e);
      return null;
    }
  }

  return true;
  // try {
  //   debugPrint('downloading converted audio');
  //   Response response = await get(Uri.parse('$url?id=-$id'));
  //   ret = response.bodyBytes;
  //   debugPrint('downloading done');
  // } catch (e) {
  //   debugPrint('error while downloading audio');
  //   Exception(e);
  // }

  // return ret;
}