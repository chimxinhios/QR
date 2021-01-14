import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter_application_qr/models/ketqua.dart';
import 'package:flutter_application_qr/screen/shared_preferences_manager.dart';
import 'package:http/http.dart' as http;

class FlatCardBloc {
  StreamController _streamController = new StreamController();
  StreamSink<KetQua> get sink => _streamController.sink;
  Stream<KetQua> get stream => _streamController.stream;
  String baseUrl = "http://flashcard.mcbooksapp.com/api/";
  FlatCardBloc() {
    _streamController = StreamController<KetQua>.broadcast();
  }
  void dispose() {
    _streamController.close();
  }
 
  List list = new List();
  bool checkList = false;
  getApi(qrScanning) async {
    print("get API");
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        new Future.delayed(Duration(seconds: 0), () async {
          // final result2 = await InternetAddress.lookup(url);
          // if (result2.isNotEmpty && result2[0].rawAddress.isNotEmpty) {
          //   print("object");
          // } else {
          //   print("a");

          // }
          // if (await http.get(baseUrl) == false) {
          //   print('null');
          // }
          var response = await http.get(baseUrl + qrScanning)
              // .timeout(
              //   Duration(seconds: 3),
              //   onTimeout: () {
              //    // return false;
              //   },
              //)
              ;
          print("headers : ${response.statusCode}");
          var data = sharedPreferencesManager.getString('key');
          print(data.length);
          if (data.length > 0) {
            list = jsonDecode(data);
          }
          //print('a ; ${list.length}');
          if (response.statusCode > 199 && response.statusCode < 300) {
            print('Response status: ${response.statusCode}');
            final json = jsonDecode(response.body);
            final Kq = KetQua.fromJson(json);
           // print("Day la ket qua : ${Kq.word.length}");
            if (Kq.word.length < 1) {
              sink.addError('Vui lòng thử lại');
            } else {
              sink.add(Kq);
              print(Kq.toJson());
              if (list == null) {
                print('list nil');
                list.add(Kq);

                print('list nil2');

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
                    print('add list1');
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
