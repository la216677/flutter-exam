import 'dart:typed_data';
import 'song.dart';

class Photo {
  int id;
  String name;
  String type;
  Uint8List imageData;
  Song? song;

  Photo({required this.id, required this.name, required this.type, required this.imageData, this.song});

  factory Photo.fromJson(Map<String, dynamic> json, {Uint8List? imageData}) {
    return Photo(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      imageData: imageData ?? Uint8List(0),
      song: json['song'] != null ? Song.fromJson(json['song']) : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'imageData': imageData,
      'song': song?.toJson(),
    };
  }

  // Getters
  int get getId => id;
  String get getName => name;
  String get getType => type;
  Uint8List get getImageData => imageData;
  Song? get getSong => song;

  // Setters
  set setId(int id) => this.id = id;
  set setName(String name) => this.name = name;
  set setType(String type) => this.type = type;
  set setImageData(Uint8List imageData) => this.imageData = imageData;
  set setSong(Song? song) => this.song = song;

}
