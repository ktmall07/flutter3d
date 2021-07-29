import 'dart:core';
import 'dart:ui';
import 'package:vector_math/vector_math.dart';

class Model {
  List<Vector3> verts = <Vector3>[];
  List<List<int>> faces = <List<int>>[];

  List<Color> colors = <Color>[];
  Map<String, Color> materials = {};

  Color _toRGBA(double r, double g, double b) {
    return Color.fromRGBO(
        (r * 255).toInt(), (g * 255).toInt(), (b * 255).toInt(), 1);
  }

  Model() {
    verts = <Vector3>[];
    faces = <List<int>>[];
    colors = <Color>[];
    materials = {
      "frontal": _toRGBA(0.848100, 0.607500, 1.000000),
      "occipital": _toRGBA(1.000000, 0.572600, 0.392400),
      "parietal": _toRGBA(0.379700, 0.830900, 1.000000),
      "temporal": _toRGBA(1.000000, 0.930700, 0.468300),
      "cerebellum": _toRGBA(0.506300, 1.000000, 0.598200),
      "stem": _toRGBA(0.500000, 0.500000, 0.500000)
    };
  }

  void loadFromString(String string) {
    List<String> lines = string.split("\n");
    // ignore: avoid_function_literals_in_foreach_calls
    lines.forEach((line) {
      // Vertex
      if (line.startsWith("v ")) {
        var values = line.substring(3).split(" ");
        // print("value: ${values[0]}");
        verts.add(Vector3(
          double.parse(values[0]),
          double.parse(values[1]),
          double.parse(values[2]),
        ));
      }
      // Face
      else if (line.startsWith("f ")) {
        var values = line.substring(2).split(" ");
        faces.add(List.from([
          int.parse(values[0].split("/")[0]),
          int.parse(values[1].split("/")[0]),
          int.parse(values[2].split("/")[0]),
        ]));
        // colors.add(materials[mat]!);
        colors.add(const Color(0xFFFFFFFF));
      }
    });
  }
}
