
library renderpolies;

import 'dart:html';
import 'dart:json';
import 'dart:math';
import 'package:box2d/box2d_browser.dart';

final WIDTH = 400;
final HEIGHT = 300;
final CENTER_X = 0;//WIDTH/2;
final CENTER_Y = 0;//HEIGHT/2;

String polys_json() {
  return """
[
  {
    "points": [
      {"x":${CENTER_X+50},"y":${CENTER_Y+50}},
      {"x":${CENTER_X+50},"y":${CENTER_Y-50}},
      {"x":${CENTER_X-50},"y":${CENTER_Y-50}},
      {"x":${CENTER_X-50},"y":${CENTER_Y+50}}
    ]
  },
  {
    "points": [
      {"x":${CENTER_X+140},"y":${CENTER_Y+40}},
      {"x":${CENTER_X+130},"y":${CENTER_Y-30}},
      {"x":${CENTER_X+50},"y":${CENTER_Y-50}},
      {"x":${CENTER_X+50},"y":${CENTER_Y+50}}
    ]
  },
  {
    "points": [
      {"x":${CENTER_X-50},"y":${CENTER_Y+40}},
      {"x":${CENTER_X-50},"y":${CENTER_Y-20}},
      {"x":${CENTER_X-100},"y":${CENTER_Y+40}}
    ]
  }
]
""";
}

class MyPoint {
  num x;
  num y;

  MyPoint( this.x, this.y ){}
}

class MyPoly {
  List<MyPoint> points;
  MyPoly(this.points){}
}

class Page {
  static final int border = 5;
  Page(CanvasRenderingContext2D this.context) {
    width_ = context.canvas.width;
    height_ = context.canvas.height;
  }

  DrawPoly(List<MyPoint> points) {
    assert(points.length>2);

    context.lineWidth = 2;
    context.fillStyle = 'cornflowerblue';
    context.strokeStyle = 'darkblue';

    context.beginPath();

    context.moveTo(points[0].x, points[0].y);

    for( var i=1; i<points.length; i++) {
      context.lineTo(points[i].x, points[i].y);
    }

    context.fill();
    context.closePath();
    context.stroke();
  }

  Load(String polys_txt) {
    min_x = double.INFINITY;
    max_x = -min_x;
    min_y = min_x;
    max_y = max_x;

    polys = new List<MyPoly>();
    List<Map> parsed_polys = parse(polys_txt);
    for( var parsed_poly in parsed_polys) {
      var points = new List<MyPoint>();
      assert(parsed_poly["points"].length>2);
      for(Map v in parsed_poly["points"]) {
        num x = v["x"];
        num y = v["y"];
        min_x = min(min_x, x);
        max_x = max(max_x, x);
        min_y = min(min_y, y);
        max_y = max(max_y, y);
        points.addLast(new MyPoint(x, y));
      }
      polys.add(new MyPoly(points));
    }
  }

  void SetView(num x, num y, {num width, num height}) {
    context.clearRect(0, 0, width_, height_);
    context.setTransform(1, 0, 0, 1, 0, 0);
    var w = width_/2;
    var h = height_/2;
    context.translate(w, h);
    context.translate(x, y);
    var scale = width_/width;
    print("scale: $scale");
    context.scale(scale, -scale);
  }

  Draw() {
    print("center: (${center_x},${center_y})");
    SetView(center_x, center_y, width: max_x-min_x);
    for( var poly in polys) {
      DrawPoly( poly.points);
    }
    print("minmax x: $min_x, $max_x");
    print("minmax y: $min_y, $max_y");
  }

  num get center_x => min_x + (max_x-min_x)/2;
  num get center_y => min_y + (max_y-min_y)/2;

  CanvasRenderingContext2D context;
  List<MyPoly> polys;
  num min_x;
  num min_y;
  num max_x;
  num max_y;
  int width_;
  int height_;
}

void main() {
  query("#text").text = "Welcome to Dart!";

  CanvasElement c = query("#canvas");
  print(c.width);
  var p = new Page(c.context2d);
  p.Load(polys_json());
  p.Draw();
}
