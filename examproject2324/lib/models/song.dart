class Song {
  int id;
  String path;

  Song({required this.id, required this.path});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
    };
  }

  // Getters
  int get getId => id;
  String get getPath => path;

  // Setters
  set setId(int id) => this.id = id;
  set setPath(String path) => this.path = path;
}