import 'package:examproject2324/models/imageApp.dart';
import 'package:http/http.dart' as http;

class ImageAppService {
  Future<List<ImageApp>> getImages() async {
    var client = http.Client();
    var uri = Uri.parse('http://192.168.1.21:8080/photo/all');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return imageFromJson(jsonString);
    } else {
      return [];
    }
  }
}