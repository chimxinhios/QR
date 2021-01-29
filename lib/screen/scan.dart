import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:last_qr_scanner/last_qr_scanner.dart';
import 'shared_preferences_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_qr/bloc/flat_card_bloc.dart';
import 'package:flutter_application_qr/models/ketqua.dart';
import 'package:flutter_application_qr/screen/book.dart';
import 'package:permission_handler/permission_handler.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;
  FlatCardBloc bloc = FlatCardBloc();
  String qrResult = "";
  List<String> list = [];
  List<KetQua> listResult = new List();
  List test;
  bool internet = true;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  var controller;
  bool offCam = false;
  String resultText = "";

  AudioPlayer audioPlayer = new AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    permission();
    sharedPreferencesManager.init();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void permission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    // print(statuses[Permission.camera]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      controller.pauseScanner();
    } else if (state == AppLifecycleState.resumed) {
      controller.resumeScanner();
    }
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    final channel = controller.channel;
    controller.init(qrKey);
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onRecognizeQR":
          dynamic arguments = call.arguments;
          //check();
          qrText = arguments.toString();
          print("qr text is : $qrText");
          controller.pauseScanner();
          if (qrText.length > 0) {
            bloc.getApi(qrText.replaceAll("\\s\\s+", " ").trim());
            setState(() {
              offCam = true;
            });
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar(),
      body: Container(
        padding: EdgeInsets.all(33),
        color: new Color(0xFF00B2FB),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            onCam(),
            resultButton(),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.import_contacts,
          color: Colors.blue,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListWord(),
              ));
        },
      ),
    );
  }

  Widget huongDan(resultText) {
    Size sizeHD = MediaQuery.of(context).size;
    if (resultText.length > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
          child: Container(
            height: sizeHD.height * 0.15,
            width: sizeHD.width,
            color: Colors.white,
            //margin: EdgeInsets.fromLTRB(1, 11, 1, 11),
            padding: EdgeInsets.all(16),
            child: Container(
              width: sizeHD.height / 2,
              child: Center(
                child: Text(
                  resultText,
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),      
        child: Container(
          height: sizeHD.height * 0.23,
          width: sizeHD.width,
          color: Colors.white,
          //margin: EdgeInsets.fromLTRB(1, 11, 1, 11),
          padding: EdgeInsets.all(12),
          child: Container(
            width: sizeHD.height / 2,
            child: Text(
              " - Đưa máy quay về mã QR\n" +
                  "(Di chuyển nhẹ camera nếu thiết bị không nhận dạng được mã QR)\n\n" +
                  " - Ấn vào ô Camera phía trên để mở lại camera",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ),
      
    );
  }

  resultButton() {
    return StreamBuilder<KetQua>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            resultText = snapshot.error;
            // print(snapshot.error);
            // new Future.delayed(Duration(seconds: 5), () {
            //   Scaffold.of(context).showSnackBar(SnackBar(
            //     content: Text(snapshot.error),
            //   ));
            // });
          }

          if (!snapshot.hasData) {
            return huongDan(resultText);
          }
          final result = snapshot.data;
          resultText = result.word;
          // new Future.delayed(Duration(seconds: 1), () {
          //   // controller.resumeScanner();
          //   //audioPlayer.play(result.audio);
          // });
          //audioPlayer.play(result.audio);
          //controller.pauseScanner();
          // qrResult = snapshot.data;
          return Container(
            height: 120,
            // color: Colors.blue,
            padding: EdgeInsets.fromLTRB(22, 10, 22, 0),
            child: FlatButton(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.volume_up,
                    color: Colors.blue,
                  ),
                  Flexible(
                    child: Text(
                      snapshot.error == true ? snapshot.error : result.word,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.blue, fontSize: 22),
                    ),
                  ),
                  Text("    "),
                ],
              ),
              onPressed: () {
                var url = result.audio;
                audioPlayer.play(url);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                //side: BorderSide(color: Colors.red)
              ),
            ),
          );
        });
  }

  Future<void> _showAlert() async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("Hướng Dẫn"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                SizedBox(
                  height: 12,
                ),
                Text(
                  "B1 : Đưa máy quay về mã QR",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "(Di chuyển nhẹ camera nếu thiết bị không nhận dạng được mã QR)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "B2 : Ấn vào từ vừa tìm thấy để nghe lại từ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "B3 : Ấn vào ô camera để mở lại camera",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Đã hiểu  "))
          ],
        );
      },
    );
  }

  Widget onCam() {
    Size size = MediaQuery.of(context).size;
    return Container(
        color: Colors.white,
        height: size.width * 0.7,
        width: size.width,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 33),
        //padding: EdgeInsets.all(8),
        child: camera()
        );
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      internet = true;
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      internet = true;
      return true;
    }

    internet = false;
    return false;
  }

  Widget camera() {
    Size size = MediaQuery.of(context).size;
    var siz = size.width * 0.8;
    if (offCam == true) {
      return GestureDetector(
        onTap: () async {

          setState(() {
            offCam = false;
            controller.resumeScanner();
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Stack(children: [
            Center(
              child: Image.asset(
                "assets/scan-icon.jpg",
              ),
            ),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("  "),
                Icon(
                  Icons.camera,
                  size: siz * 0.4,
                ),
                Text("Ấn vào đây để quét lại",
                    style: TextStyle(fontSize: 19, color: Colors.blue[700]))
              ],
            )),
          ]),
        ),
        //),
      );
    }
    return Stack(
      children: [
        LastQrScannerPreview(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
        Center(
          child: Icon(
            Icons.add,
            size: 55,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  myAppBar() {
    return AppBar(
        backgroundColor: Colors.white,
        leading: guide(),
        toolbarHeight: 44,
        elevation: 0,
        title: Text(
          "MCBooks Flashcard",
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true);
  }

  Widget guide() {
    return IconButton(
      icon: Icon(
        Icons.help,
        color: Colors.blueAccent,
      ),
      onPressed: () {
        _showAlert();
      },
    );
  }
}
