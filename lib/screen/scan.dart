import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:last_qr_scanner/last_qr_scanner.dart';
import 'shared_preferences_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_application_qr/bloc/flat_card_bloc.dart';
import 'package:flutter_application_qr/models/ketqua.dart';
import 'package:flutter_application_qr/screen/book.dart';

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

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  var controller;
  var qrTextCache = "nil";

  AudioPlayer audioPlayer = new AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    print('init');
    sharedPreferencesManager.init();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('pause app');
      controller.pauseScanner();
    } else if (state == AppLifecycleState.resumed) {
      controller.resumeScanner();
      print('app resume');
    }
  }

  @override
  void dispose() {
    print('dispose');
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
          setState(() {
            qrText = arguments.toString();
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // var data = sharedPreferencesManager.getString('key');

    //print(data);

    // test = jsonDecode(data);
    // print(test.length);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar(),
      body: Container(
        padding: EdgeInsets.all(33),
        color: new Color(0xFF00B2FB),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Text("$qrText"),
            onCam(),
            resultButton(),
            SizedBox(
              height: 20,
            ),
            // scanButton()
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
          // setState(() {});
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListWord(),
              ));
        },
      ),
    );
  }

  Widget scanButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 11,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: FlatButton(
            height: 85,
            onPressed: () async {
              String scanning = await BarcodeScanner.scan();
              bloc.getApi(scanning);
            },
            color: Colors.white,
            child: Text(
              "Scan",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            )),
      ),
    );
  }

  image() {
    return GestureDetector(
      onTap: () async {
        String scanning = await BarcodeScanner.scan();
        print("ma qr : " + scanning);
        bloc.getApi(scanning);
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(1, 1, 1, 33),
          color: new Color(0xFF00B2FB),
          //padding: EdgeInsets.all(22),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                "assets/istockphoto1024x1024.jpg",
              )
              //Image.asset("assets/QR_EN-231x300.png")
              )),
    );
  }

  Widget huongDan() {
    Size sizeHD = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onTap: () async {
          // String scanning = await BarcodeScanner.scan();
          // bloc.getApi(scanning);
        },
        child: Container(
          height: sizeHD.height / 4,
          color: Colors.white,
          //margin: EdgeInsets.fromLTRB(1, 11, 1, 11),
          padding: EdgeInsets.all(16),
          child: Container(
            width: sizeHD.height / 2,
            child: Text(
              "B1 : Nhấn vào biểu tượng scan hoặc ô này \n\n" +
                  "B2 : Đưa máy quay về mã QR\n" +
                  "(Di chuyển nhẹ camera nếu thiết bị không nhận dạng được mã QR)",
              style: TextStyle(color: Colors.blue, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  resultButton() {
    //Size sideResultButton = MediaQuery.of(context).size;
    return StreamBuilder<KetQua>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            //bloc.dispose();

            // new Future.delayed(Duration(seconds: 3), () {
            //  Scaffold.of(context).showSnackBar(SnackBar(
            //    content: Text(snapshot.error),
            //   ));
            // });

            // Fluttertoast.showToast(
            //     msg: "This is Toast messaget",
            //     toastLength: Toast.LENGTH_SHORT,
            //     gravity: ToastGravity.CENTER,
            //     );
            return Container(
              //height: 100,
              // color: Colors.blue,
              padding: EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: FlatButton(
                color: Colors.white,
                child: Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.warning,color: Colors.red,),
                      Text(
                        snapshot.error,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.blue, fontSize: 22),
                      ),
                    ],
                  ),
                ),
                onPressed: () {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.red)),
              ),
            );
          }

          if (!snapshot.hasData) {
            return huongDan();
          }
          final result = snapshot.data;
          // new Future.delayed(Duration(seconds: 1), () {
          //   // controller.resumeScanner();
          //   //audioPlayer.play(result.audio);
          // });
          audioPlayer.play(result.audio);
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
                      result.word,
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
                Text("B1 : Nhấn vào nút scan"),
                SizedBox(
                  height: 8,
                ),
                Text("B2 : Đưa máy quay về mã QR"),
                SizedBox(
                  height: 8,
                ),
                Text(
                    "(Di chuyển nhẹ camera nếu thiết bị không nhận dạng được mã QR)")
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Đã hiểu "))
          ],
        );
      },
    );
  }

  myAppBar() {
    return AppBar(
        backgroundColor: Colors.white,
        leading: question(),
        toolbarHeight: 44,
        elevation: 0,
        title: Text(
          "MCBooks Flashcard",
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true);
  }

  Widget question() {
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

  Widget onCam() {
    if (qrText.length > 0 && qrText != qrTextCache) {
      bloc.getApi(qrText);
      qrTextCache = qrText;
    }
    return Container(
      color: Colors.white,
      height: 280,
      width: 280,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 33),
      padding: EdgeInsets.all(8),
      child: Stack(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              "assets/istockphoto1024x1024.jpg",
            )
            //Image.asset("assets/QR_EN-231x300.png")
            ),
        LastQrScannerPreview(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
        Center(
          child: Icon(
            Icons.add,
            size: 50,
            color: Colors.white,
          ),
        )
      ]),
      //flex: 4,
    );
  }
}
