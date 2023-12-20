import 'dart:io';

import 'package:examproject2324/views/otherView.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo.dart';
import '../utils/db_helper.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    var uri = Uri.parse('http://http://192.168.1.21:8080/photo/upload');
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
                                'http://192.168.1.21:8080/songs/${snapshot.data![index].song!.path}');
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
                                      'http://192.168.1.21:8080/photos/${snapshot.data![index].path}',
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
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _Items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(_Items[index]['title']),
                          subtitle: Text(_Items[index]['description']),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showBottomSheet(_Items[index]['id']);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _deleteItem(_Items[index]['id']);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton(
                    onPressed: () {
                      showBottomSheet(null);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      // Ajout logo add
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
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
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
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

  Future<List<String>> fetchImages() async {
    final response = await http.get(Uri.parse('https://picsum.photos/v2/list'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => data['url'].toString()).toList();
    } else {
      throw Exception('Erreur lors du chargement des images');
    }
  }

  void playMusic(String url) async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(UrlSource(url));
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
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
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
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Enter description',
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!),
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
