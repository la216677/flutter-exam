// To parse this JSON data, do
//
//     final image = imageFromJson(jsonString);

import 'dart:convert';

List<ImageApp> imageFromJson(String str) => List<ImageApp>.from(json.decode(str).map((x) => ImageApp.fromJson(x)));

String imageToJson(List<ImageApp> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ImageApp {
  int id;
  String path;

  ImageApp({
    required this.id,
    required this.path,
  });

  factory ImageApp.fromJson(Map<String, dynamic> json) => ImageApp(
    id: json["id"],
    path: json["path"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "path": path,
  };
}
