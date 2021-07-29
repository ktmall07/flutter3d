import 'package:final_project/object3d.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Technical'),
      debugShowCheckedModeBanner: false,
      title: 'Object Viewer',
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        ),
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        body: Column(
          children: [
            Object3D(
              size: const Size(400.0, 400.0),
              zoom: 15.0,
              path: "assets/male_mesh.obj",
            ),
          ],
        ),
      ),
    );
  }
}
