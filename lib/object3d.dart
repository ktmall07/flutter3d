library flutter_3d_obj;

import 'dart:ui';

import 'package:final_project/model.dart';
import 'package:final_project/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' as Math;

class Object3D extends StatefulWidget {
  final Size size;
  final String path;
  final double zoom;

  // ignore: use_key_in_widget_constructors
  Object3D({required this.size, required this.path, required this.zoom}) {
    // print('Size = $size');
  }

  @override
  _Object3DState createState() => _Object3DState();
}

class _Object3DState extends State<Object3D> {
  double angleX = 0.0;
  double angleY = 0.0;
  double angleZ = 0.0;
  double zoom = 0.0;

  Model model = Model();

  @override
  void initState() {
    rootBundle.loadString(widget.path).then((value) {
      setState(() {
        model.loadFromString(value);
      });
    });
    super.initState();
  }

  _dragX(DragUpdateDetails update) {
    setState(() {
      angleX += update.delta.dy;
      if (angleX > 360) {
        angleX = angleX - 360;
      } else if (angleX < 0) angleX = 360 - angleX;
    });
  }

  _dragY(DragUpdateDetails update) {
    setState(() {
      angleY += update.delta.dx;
      if (angleY > 360) {
        angleY = angleY - 360;
      } else if (angleY < 0) angleY = 360 - angleY;
    });
  }

  _tapUp(TapUpDetails details) {
    setState(() {});
  }

  _tapDown(TapDownDetails details) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomPaint(
        painter: _ObjectPainter(
            widget.size, model, angleX, angleY, angleZ, widget.zoom),
        size: widget.size,
      ),
      onHorizontalDragUpdate: (DragUpdateDetails update) => _dragY(update),
      onVerticalDragUpdate: (DragUpdateDetails update) => _dragX(update),
      onTapUp: (TapUpDetails details) => _tapUp(details),
      onTapDown: (TapDownDetails details) => _tapDown(details),
    );
  }
}

class _ObjectPainter extends CustomPainter {
  double _viewPortX = 0.0;
  double _viewPortY = 0.0;
  double _zoom = 0.0;

  Math.Vector3 camera = Math.Vector3(0.0, 0.0, 0.0);
  Math.Vector3 light = Math.Vector3(0.0, 0.0, 100.0);

  double angleX;
  double angleY;
  double angleZ;

  Size size;

  List<Math.Vector3> verts = <Math.Vector3>[];

  final Model model;

  _ObjectPainter(this.size, this.model, this.angleX, this.angleY, this.angleZ,
      this._zoom) {
    _viewPortX = (size.width / 2).toDouble();
    _viewPortY = (size.height / 2).toDouble();
  }

  Math.Vector3 _calcVertex(Math.Vector3 vertex) {
    var trans =
        Math.Matrix4.translationValues(_viewPortX - 20, _viewPortY + 175, 1);
    trans.scale(_zoom, -_zoom);
    trans.rotateX(Utils.degreeToRadian(angleX));
    trans.rotateY(Utils.degreeToRadian(angleY));
    trans.rotateZ(Utils.degreeToRadian(angleZ));
    // trans.transform(Math.Vector4(50.0, 50.0, 1, 1));
    return trans.transform3(vertex);
  }

  void _drawFace(Canvas canvas, List<int> face, Color color) {
    // Reference the rotated vertices
    var v1 = verts[face[0] - 1];
    var v2 = verts[face[1] - 1];
    var v3 = verts[face[2] - 1];

    var normalVector = Utils.normalVector3(v1, v2, v3);

    Math.Vector3 normalizedLight = Math.Vector3.copy(light).normalized();
    var jnv = Math.Vector3.copy(normalVector).normalized();
    var normal = Utils.scalarMultiplication(jnv, normalizedLight);
    var brightness = normal.clamp(0.0, 1.0);

    // Assign a lighting color
    var r = (brightness * color.red).toInt();
    var g = (brightness * color.green).toInt();
    var b = (brightness * color.blue).toInt();

    var paint = Paint();
    paint.color = Color.fromARGB(255, r, g, b);
    paint.style = PaintingStyle.fill;

    // Paint the face
    var path = Path();
    path.moveTo(v1.x, v1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(v1.x, v1.y);
    path.close();
    canvas.drawPath(path, paint);
  }

  /*
   *  Override the paint method.  Rotate the verticies, sort and finally render
   *  our 3D model.
   */
  @override
  void paint(Canvas canvas, Size size) {
    // Rotate and translate the vertices
    verts = <Math.Vector3>[];
    for (int i = 0; i < model.verts.length; i++) {
      verts.add(_calcVertex(Math.Vector3.copy(model.verts[i])));
    }

    // Sort
    var sorted = <Map<String, dynamic>>[];
    for (var i = 0; i < model.faces.length; i++) {
      var face = model.faces[i];
      sorted.add({
        "index": i,
        "order": Utils.zIndex(
            verts[face[0] - 1], verts[face[1] - 1], verts[face[2] - 1])
      });
    }
    sorted.sort((Map a, Map b) => a["order"].compareTo(b["order"]));

    // Render
    for (int i = 0; i < sorted.length; i++) {
      var face = model.faces[sorted[i]["index"]];
      var color = model.colors[sorted[i]["index"]];
      _drawFace(canvas, face, color);
    }
  }

  /*
   *  We only want to repaint the canvas when the scene has changed.
   */
  @override
  bool shouldRepaint(_ObjectPainter old) {
    return true;
  }
}
