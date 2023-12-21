import 'dart:convert';
import 'dart:typed_data';

import 'package:examproject2324/models/photo.dart';

class Song {
  int id;
  String name;
  String type;
  Uint8List songData;
  Photo? photo;

  Song({required this.id, required this.name, required this.type, required this.songData, this.photo});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      songData: base64Decode(json['songData']),
      photo: json['photo'] != null ? Photo.fromJson(json['photo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'songData': base64Encode(songData),
      'photo': photo?.toJson(),
    };
  }

  // Getters
  int get getId => id;
  String get getName => name;
  String get getType => type;
  Uint8List get getSongData => songData;
  Photo? get getPhoto => photo;

  // Setters
  set setId(int id) => this.id = id;
  set setName(String name) => this.name = name;
  set setType(String type) => this.type = type;
  set setSongData(Uint8List songData) => this.songData = songData;
  set setPhoto(Photo? photo) => this.photo = photo;
}
