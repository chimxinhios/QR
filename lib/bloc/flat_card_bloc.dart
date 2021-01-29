import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_qr/models/ketqua.dart';
import 'package:flutter_application_qr/screen/shared_preferences_manager.dart';
import 'package:http/http.dart' as http;

class FlatCardBloc {
  StreamController _streamController = new StreamController();
  StreamSink<KetQua> get sink => _streamController.sink;
  Stream<KetQua> get stream => _streamController.stream;
  String baseUrl = "https://flashcard.mcbooksapp.com/api/";
  FlatCardBloc() {
    _streamController = StreamController<KetQua>.broadcast();
  }
  void dispose() {
    _streamController.close();
  }

  List list = new List();
  bool checkList = false;
  AudioPlayer audioPlayer = new AudioPlayer();
  getApi(qrScanning) async {
    print("get API");
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        new Future.delayed(Duration(seconds: 0), () async {

          var response = await http.get(baseUrl + qrScanning);       
          var data = sharedPreferencesManager.getString('key');
          print(data.length);
          if (data.length > 0) {
            list = jsonDecode(data);
          }
          if (response.statusCode > 199 && response.statusCode < 300) {
            print('Response status: ${response.statusCode}');
            final json = jsonDecode(response.body);
            final Kq = KetQua.fromJson(json);
          
            
            // print("Day la ket qua : ${Kq.word.length}");
            if (Kq.word.length < 1) {
              print("add err");
              sink.addError('Vui lòng thử lại');
            } else {
                audioPlayer.play(Kq.audio);
            new Future.delayed(Duration(seconds: 3), () {
              audioPlayer.play(Kq.audio);
              new Future.delayed(Duration(seconds: 3), () {
                audioPlayer.play(Kq.audio);
              });
            });
              sink.add(Kq);
              print(Kq.toJson());
              if (list == null) {
                list.add(Kq);
                sharedPreferencesManager.save('key', list);
                print('add list');
              } else if (list != null) {
                list.forEach((element) {
                  if (Kq.word == element['word']) {
                    print('trung');
                    checkList = true;
                  }
                });
                if (checkList == false) {
                  if (list.length < 20) {
                    list.add(Kq);
                    sharedPreferencesManager.save('key', list);
                  } else {
                    list.removeAt(1);
                    list.add(Kq);
                    sharedPreferencesManager.save('key', list);
                  }
                }
              }
            }
          } else {
            print('Response status: ${response.statusCode}');
          }
        });
      }
    } on SocketException catch (_) {
      sink.addError("Không thể kết nối đến server");
      //print('not connected');
    }
  }
}
