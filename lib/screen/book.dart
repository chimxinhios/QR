import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_qr/screen/shared_preferences_manager.dart';

class ListWord extends StatefulWidget {
  @override
  _ListWordState createState() => _ListWordState();
}

class _ListWordState extends State<ListWord> {
  AudioPlayer audioPlayer = new AudioPlayer();
  List list = new List();
  @override
  void initState() {
    sharedPreferencesManager.init();

    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    var data = sharedPreferencesManager.getString('key');
    print('leng ${data.length}');
    print("object");
    print('leng list ${list}');
    if (data.length > 0) {
      var data2 = jsonDecode(data);
      list = data2;
    }

    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        backgroundColor: new Color(0xFF00B2FB),
        elevation: 0,
        //leading: _showAlert(),
        title: Text(
          "MCBooks Flashcard",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: body(),
    );
  }

  Widget body() {
    //print('leng list ${list.length}');
    if (list.length < 1) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text(
            "Không có dữ liệu",
            style: TextStyle(fontSize: 22),
          ),
        ),
      );
    }

    Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(size.width / 11, 1, size.width / 11, 1),
      child: ListView.separated(
          // reverse: true,
          itemBuilder: (context, index) {
            return ListTile(
              title: GestureDetector(
                onTap: () async => await audioPlayer.play(list[index]['audio']),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volume_up),
                        Text(
                          "   ${list[index]['word']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                    GestureDetector(
                        onTap: () {
                          _showAlertDelete(index);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ))
                  ],
                ),
              ),
            );
          },
          primary: true,
          separatorBuilder: (context, index) => Divider(
                height: 1,
              ),
          itemCount: list.length),
    );
  }

  Future<void> _showAlertDelete(index) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("Hướng Dẫn"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [Text("Bạn có muốn xóa từ này không ?")],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Huỷ ")),
            TextButton(
                onPressed: () {
                   list.removeAt(index);
                    sharedPreferencesManager.remove('key');
                    sharedPreferencesManager.save('key', list);
                    print('xoa');
                  setState(() {
                   
                  });

                  Navigator.of(context).pop();
                },
                child: Text("Xóa ")),
          ],
        );
      },
    );
  }
}
