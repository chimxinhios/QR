// To parse this JSON data, do
//
//     final ketQua = ketQuaFromJson(jsonString);

import 'dart:convert';

KetQua ketQuaFromJson(String str) => KetQua.fromJson(json.decode(str));

String ketQuaToJson(KetQua data) => json.encode(data.toJson());

class KetQua {
    KetQua({
        this.word,
        this.lang,
        this.audio,
        this.qrcode,
        this.categoryId,
    });

    String word;
    String lang;
    String audio;
    String qrcode;
    String categoryId;

    factory KetQua.fromJson(Map<String, dynamic> json) => KetQua(
        word: json["word"],
        lang: json["lang"],
        audio: json["audio"],
        qrcode: json["qrcode"],
        categoryId: json["categoryId"],
    );

    Map<String, dynamic> toJson() => {
        "word": word,
        "lang": lang,
        "audio": audio,
        "qrcode": qrcode,
        "categoryId": categoryId,
    };
}
