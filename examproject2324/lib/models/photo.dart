import 'song.dart';

class Photo {
  final int id;
  final String path;
  final Song? song;

  Photo({required this.id, required this.path, this.song});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      path: json['path'],
      song: json['song'] != null ? Song.fromJson(json['song']) : null,
    );
  }
}