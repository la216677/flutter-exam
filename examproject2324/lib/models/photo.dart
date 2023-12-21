import 'song.dart';

class Photo {
  int id;
  String path;
  Song? song;

  Photo({required this.id, required this.path, this.song});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      path: json['path'],
      song: json['song'] != null ? Song.fromJson(json['song']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'song': song?.toJson(),
    };
  }

  // Getters
  int get getId => id;
  String get getPath => path;
  Song? get getSong => song;

  // Setters
  set setId(int id) => this.id = id;
  set setPath(String path) => this.path = path;
  set setSong(Song? song) => this.song = song;
}