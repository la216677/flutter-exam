import 'dart:io';

import 'package:examproject2324/views/otherView.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo.dart';
import '../models/song.dart';
import '../utils/db_helper.dart';
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
  List<Map<String, dynamic>> _Items = [];
  bool _isLoading = false;

  late PageController _pageController;
  late Future<List<Photo>> _photos;

  final player = AudioPlayer();
  late Source audioUrl;

  File? _image;
  File? _song;

  Future getImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    var uri = Uri.parse('http://192.168.1.21:8080/photo/upload');
    var request = http.MultipartRequest('POST', uri);

    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      _image!.path,
      contentType: MediaType(
          'image', 'jpeg'), // Changez le type en fonction de votre fichier
    );

    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Upload réussi');
    } else {
      print('Échec de l\'upload');
    }
  }

  int currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

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

  Future<void> deletePhoto(String path) async {
    // get photo to delete song
    var uri2 = Uri.parse('http://192.168.1.21:8080/photo/$path');
    var response2 = await http.get(uri2);
    var photo = json.decode(response2.body);
    var idSong = photo['song']['id'];

    var uri3 = Uri.parse('http://192.168.1.21:8080/photo/$path');
    var response3 = await http.delete(uri3);

    if (response3.statusCode == 200) {
      print('Photo supprimée avec succès');

      // delete song
      var uri4 = Uri.parse('http://192.168.1.21:8080/song/id/$idSong');
      var response4 = await http.delete(uri4);

      if (response4.statusCode == 200) {
        print('Song supprimée avec succès');
      } else {
        print('Échec de la suppression de la song');
      }
    } else {
      print('Échec de la suppression de la photo');
    }
  }

  Future<void> getSong() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      final pickedFile = await FilePicker.platform.pickFiles(type: FileType.audio);

      if (pickedFile != null) {
        _song = File(pickedFile.files.single.path!);
      } else {
        print('No song selected.');
      }
    } else {
      print('Storage permission is denied');
    }
  }

  Future<void> uploadSong(String photoId) async {
    var uri = Uri.parse('http://192.168.1.21:8080/song/upload');
    var request = http.MultipartRequest('POST', uri);

    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      _song!.path,
      contentType: MediaType('audio', 'mpeg'), // Changez le type en fonction de votre fichier
    );

    request.files.add(multipartFile);

    var uploadResponse = await request.send();


    if (uploadResponse.statusCode == 200) {
      final respStr = await uploadResponse.stream.bytesToString();
      if(respStr == "") {
        print('No song  because it exists');
        return;
      }
      print('Upload réussi');
      // Obtenez l'objet Song à partir de la réponse
      var uri2 = Uri.parse('http://192.168.1.21:8080/song/$respStr');
      var response = await http.get(uri2);
      var song = json.decode(response.body);

      final songId = song['id']; // Utilisez l'ID de la chanson ici

      // get photo to update and update
      var uri4 = Uri.parse('http://192.168.1.21:8080/photo/id/$photoId');
      var response2 = await http.get(uri4);
      var photo = json.decode(response2.body);

      var uri3 = Uri.parse('http://192.168.1.21:8080/photo/update');

      Photo photoToUpdate = Photo.fromJson(photo);
      photoToUpdate.setSong = Song(id: songId, path: respStr);

      var response3 = await http.put(
        uri3,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(photoToUpdate.toJson()),
      );

      if (response3.statusCode == 200) {
        print('Song updated successfully');
      } else {
        print('Failed to update song');
      }
    } else {
      print('Échec de l\'upload');
    }
  }




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
                            audioUrl = UrlSource(
                                'http://192.168.1.21:8080/songs/${snapshot
                                    .data![index].song!.path}');
                            player.play(audioUrl);
                            print('Card clicked');
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
                                    Image.network(
                                      'http://192.168.1.21:8080/photos/${snapshot
                                          .data![index].path}',
                                      height: 200,
                                      width: 200,
                                    ),
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
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Image.network(
                                  'http://192.168.1.21:8080/photos/${snapshot.data![index].path}',
                                  height: 100,
                                  width: 100,
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await deletePhoto(snapshot.data![index].path);
                                    setState(() {
                                      _photos = fetchPhotos(); // Mettez à jour la liste des photos
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.music_note),
                                  onPressed: () async {
                                    await getSong();
                                    await uploadSong(snapshot.data![index].id.toString()); // Passez l'ID de la photo ici
                                    setState(() {
                                      _photos = fetchPhotos(); // Mettez à jour la liste des photos
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
                          _photos = fetchPhotos(); // Mettez à jour la liste des photos
                        });
                      },
                      tooltip: 'Pick Image',
                      child: Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        )
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
    final items = await SQLHelper.getItems();
    setState(() {
      _Items = items;
      _isLoading = false;
    });
  }

  Future<List<Photo>> fetchPhotos() async {
    final response =
    await http.get(Uri.parse('http://192.168.1.21:8080/photo/all'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((photo) => Photo.fromJson(photo)).toList();
    } else {
      throw Exception('Erreur lors du chargement des photos');
    }
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addNewItem() async {
    if (_titleController.text.isEmpty) {
      return;
    }
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshItems();
  }

  Future<void> _updateItem(int id) async {
    if (_titleController.text.isEmpty) {
      return;
    }
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshItems();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Item deleted'),
      ),
    );
    _refreshItems();
  }

  void showBottomSheet(int? id) {
    if (id != null) {
      final existingItem = _Items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) =>
          Container(
            padding: EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + 50,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    hintText: 'Enter title',
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: _image == null
                      ? Text('No image selected.')
                      : Image.file(_image!, height: 200, width: 200),
                ),
                FloatingActionButton(
                  onPressed: getImage,
                  tooltip: 'Pick Image',
                  child: Icon(Icons.add_a_photo),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_image != null) {
                        await uploadImage();
                      }
                      if (id == null) {
                        await _addNewItem();
                      } else {
                        await _updateItem(id);
                      }
                      _titleController.clear();
                      _descriptionController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        id == null ? 'Add' : 'Update',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }
}
