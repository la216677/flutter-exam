class Photo {
  final int id;
  final String path;

  Photo({required this.id, required this.path});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      path: json['path'],
    );
  }
}