import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --------------------- VARIABLES ---------------------
  late PageController _pageController;
  late Future<List<Photo>> _photos;
  File? _image;
  File? _song;
  final player = AudioPlayer();
  late Source audioUrl;

  // --------------------- FONCTIONS ---------------------

  @override
  void initState() {
    super.initState();
    _refreshItems();
    _photos = fetchPhotos();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --------------------- IMAGES ---------------------

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {}
    });
  }

  Future uploadImage() async {
    var uri = Uri.parse('https://molten-guide-408810.ew.r.appspot.com/image');
    var request = http.MultipartRequest('POST', uri);

    var multipartFile = await http.MultipartFile.fromPath(
      'image',
      _image!.path,
      contentType: MediaType(
          'image', 'jpeg'), // Changez le type en fonction de votre fichier
    );
    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode == 200) {
    } else {}
  }

  Future<void> deletePhoto(int id) async {
    var uri3 = Uri.parse(
        'https://molten-guide-408810.ew.r.appspot.com/image/delete/$id');
    var response3 = await http.delete(uri3);

    if (response3.statusCode == 200) {
    } else {}
  }

  int currentIndex = 0;
  Future<List<Photo>> fetchPhotos() async {
    List<Photo> photos = [];
    final response = await http.get(Uri.parse(
        'https://molten-guide-408810.ew.r.appspot.com/image/search/all'));
    if (response.statusCode == 200) {
      var photosJson = json.decode(response.body);
      for (var photoJson in photosJson) {
        // get image with id
        final response2 = await http.get(Uri.parse(
            'https://molten-guide-408810.ew.r.appspot.com/image/search/${photoJson['id']}'));

        Uint8List imageData = response2.bodyBytes;
        photos.add(Photo.fromJson(photoJson, imageData: imageData));
      }
      return photos;
    } else {
      throw Exception('Erreur lors du chargement des photos');
    }
  }

  // --------------------- SONG ---------------------

  Future<void> getSong() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      final pickedFile =
          await FilePicker.platform.pickFiles(type: FileType.audio);

      if (pickedFile != null) {
        _song = File(pickedFile.files.single.path!);
      } else {}
    } else {}
  }

  Future<void> uploadSong(int photoId) async {
    var uri = Uri.parse(
        'https://molten-guide-408810.ew.r.appspot.com/storageSong/uploadSong');
    var request = http.MultipartRequest('POST', uri);
    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      _song!.path,
      contentType: MediaType(
          'audio', 'mpeg'), // Changez le type en fonction de votre fichier
    );
    request.files.add(multipartFile);
    var uploadResponse = await request.send();
    if (uploadResponse.statusCode == 200) {
      final respStr = await uploadResponse.stream.bytesToString();
      if (respStr == "") {
        return;
      }
      // associate song with photo
      var uri2 = Uri.parse(
          'https://molten-guide-408810.ew.r.appspot.com/storageSong/associateSongWithPhoto/$respStr/$photoId');
      var response2 = await http.post(uri2);
      if (response2.statusCode == 200) {
      } else {}
    } else {}
  }

  // --------------------- WIDGETS ---------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('L\' app des Musicos')),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: [
            FutureBuilder<List<Photo>>(
              future: _photos,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(30),
                        // Vous pouvez ajuster la valeur pour obtenir la marge souhaitée
                        child: InkWell(
                          onTap: () {
                            if (snapshot.data![index].getSong != null) {
                              audioUrl = UrlSource(
                                  'https://molten-guide-408810.ew.r.appspot.com/storageSong/downloadSong/${snapshot.data![index].getSong!.getName}');
                              player.play(audioUrl);
                            }
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 300,
                              // Vous pouvez ajuster la valeur pour obtenir la hauteur minimale souhaitée
                              minWidth: 400,
                              // Vous pouvez ajuster la valeur pour obtenir la largeur minimale souhaitée
                              maxHeight: 300,
                              // Vous pouvez ajuster la valeur pour obtenir la hauteur maximale souhaitée
                              maxWidth:
                                  400, // Vous pouvez ajuster la valeur pour obtenir la largeur maximale souhaitée
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Vous pouvez ajuster la valeur pour obtenir l'arrondi souhaité
                              ),
                              color: Colors.red,
                              elevation: 5,
                              // Vous pouvez ajuster la valeur pour obtenir l'ombre souhaitée
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                        image: MemoryImage(
                                            snapshot.data![index].getImageData),
                                        height: 200,
                                        width: 200),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erreur lors du chargement des photos'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            // formulaire pour ajouter un instrument
            FutureBuilder<List<Photo>>(
              future: _photos,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(30),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blueAccent),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Image(
                                        image: MemoryImage(
                                            snapshot.data![index].getImageData),
                                        height: 100,
                                        width: 100),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await deletePhoto(snapshot.data![index]
                                            .getId); // Passez l'ID de la photo ici
                                        setState(() {
                                          _photos =
                                              fetchPhotos(); // Mettez à jour la liste des photos
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.music_note),
                                      onPressed: () async {
                                        await getSong();
                                        await uploadSong(snapshot.data![index]
                                            .getId); // Passez l'ID de la photo ici
                                        setState(() {
                                          _photos =
                                              fetchPhotos(); // Mettez à jour la liste des photos
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: FloatingActionButton(
                          onPressed: () async {
                            await getImage();
                            await uploadImage();
                            setState(() {
                              _photos =
                                  fetchPhotos(); // Mettez à jour la liste des photos
                            });
                          },
                          tooltip: 'Pick Image',
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Édition'),
        ],
      ),
    );
  }

  void _refreshItems() async {
    setState(() {});
  }
}
