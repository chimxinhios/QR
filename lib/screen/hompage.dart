// import 'package:flutter/material.dart';

// import 'package:flutter_application_qr/scan.dart';

// class Hompage extends StatefulWidget {
//   @override
//   _HompageState createState() => _HompageState();
// }

// class _HompageState extends State<Hompage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("scan"),
//         centerTitle: true,
//       ),
//       body: Container(
//         padding: EdgeInsets.all(50.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Image.network("https://www.iconbunny.com/icons/media/catalog/product/9/6/963.12-scanner-icon-iconbunny.jpg")
//             ,flatbutton("scan", Scan()),
            
//             ],
//         ),
//       ),
//     );
//   }

//   Widget flatbutton(String text, Widget widget) {
//     return FlatButton(
//         onPressed: () {
//           Navigator.of(context).push(MaterialPageRoute(
//             builder: (context) => widget,
//           ));
          
//         },
//         child: Text(text),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0)
//         ),);
//   }
// }
