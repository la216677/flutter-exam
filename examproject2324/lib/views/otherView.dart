import 'package:flutter/material.dart';
import 'package:examproject2324/views/home_page.dart';

class OtherView extends StatelessWidget {
  const OtherView({Key? key}) : super(key: key);

  static const routeName = '/otherView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other View'),
      ),

    );
  }
}