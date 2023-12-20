import 'package:examproject2324/views/otherView.dart';
import 'package:flutter/material.dart';
import '../models/photo.dart';
import '../utils/db_helper.dart';
import 'package:audioplayers/audioplayers.dart';
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

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    OtherView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('L\' app des Musicos')),
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : ListView.builder(
            itemCount: _Items.length,
            itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(15),
                child: ListTile(
                  onTap: () async {
                    var url =
                        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
                    var response = await http.get(Uri.parse(url));
                    if (response.statusCode == 200) {
                      AudioPlayer audioPlayer = AudioPlayer();
                      await audioPlayer.play(UrlSource(url));
                    } else {
                      print(
                          'Request failed with status: ${response.statusCode}.');
                    }
                  },
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _Items[index]['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _Items[index]['description'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showBottomSheet(_Items[index]['id']);
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          )),
                      IconButton(
                        onPressed: () => _deleteItem(_Items[index]['id']),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Autre Vue',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
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

  late Future<List<Photo>> _photos;
  @override
  void initState() {
    super.initState();
    _refreshItems();
    _photos = fetchPhotos();
  }


  Future<List<Photo>> fetchPhotos() async {
    final response = await http.get(Uri.parse('http://192.168.1.21:8080/photo/all'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((photo) => Photo.fromJson(photo)).toList();
    } else {
      throw Exception('Erreur lors du chargement des photos');
    }
  }



  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
                      )),
                )
              ],
            )));
  }

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
}
