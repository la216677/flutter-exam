class Song {
  final int id;
  final String path;

  Song({required this.id, required this.path});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      path: json['path'],
    );
  }
}