
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
      {"x":${CENTER_X-100},"y":${CENTER_Y+80}}
    ]
  }
]
""";
}

class MyPoly {
  List<Vector> points;
  MyPoly(this.points){}
}

class Page {
  static final int border = 5;
  Page(CanvasRenderingContext2D this.context) {
    width_ = context.canvas.width;
    height_ = context.canvas.height;
  }

  DrawPoly(List<Vector> points) {
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
    minv = new Vector(double.INFINITY,double.INFINITY);
    maxv = new Vector(-double.INFINITY,-double.INFINITY);

    polys = new List<MyPoly>();
    List<Map> parsed_polys = parse(polys_txt);
    for( var parsed_poly in parsed_polys) {
      var points = new List<Vector>();
      assert(parsed_poly["points"].length>2);
      for(Map v in parsed_poly["points"]) {
        num x = v["x"];
        num y = v["y"];
        minv.x = min(minv.x, x);
        maxv.x = max(maxv.x, x);
        minv.y = min(minv.y, y);
        maxv.y = max(maxv.y, y);
        points.addLast(new Vector(x, y));
      }
      polys.add(new MyPoly(points));
    }
    print("minv: $minv");
    print("maxv: $maxv");
  }

  void SetView(num x, num y, {num width, num height}) {
    context.clearRect(0, 0, width_, height_);
    context.setTransform(1, 0, 0, 1, 0, 0);
    var w = width_/2;
    var h = height_/2;
    context.translate(w, h);
    //context.translate(-x, -y);
    var scale = width_/width;
    print("scale: $scale");
    //scale = 1;
    context.scale(scale, -scale);
    context.translate(-x, -y);
  }

  Draw() {
    print("center: $center");
    SetView(center_x, center_y, width: maxv.x-minv.x);
    //SetView(0, 0, width: maxv.x-minv.x);
    for( var poly in polys) {
      DrawPoly( poly.points);
    }
    var count = 20;
    var sep = 10;
    var total = count * sep;
    var nib = sep/2;
    context
      ..lineWidth = 1
      ..strokeStyle = "black"
      ..beginPath()
      ..moveTo(total, 0)
      ..lineTo(-total, 0)
      ..moveTo(0, total)
      ..lineTo(0, -total)
      ..closePath()
      ..stroke();
    for(int i = 1; i<=count; ++i) {
      context
        ..lineWidth = .5
        ..strokeStyle = "red"
        ..beginPath()
        //x right
        ..moveTo(i*sep, nib)
        ..lineTo(i*sep, -nib)
        //x left
        ..moveTo(-i*sep, nib)
        ..lineTo(-i*sep, -nib)
        //y top
        ..moveTo(nib, i*sep)
        ..lineTo(-nib, i*sep)
        //y bottom
        ..moveTo(nib, -i*sep)
        ..lineTo(-nib, -i*sep)
        ..closePath()
        ..stroke();
    }
    context
      ..strokeStyle = "cyan"
      ..setTransform(1, 0, 0, 1, 0, 0)
      ..beginPath()
      ..moveTo(width_/2,0)
      ..lineTo(width_/2,height_)
      ..moveTo(0,height_/2)
      ..lineTo(width_,height_/2)
      ..closePath()
      ..stroke();
  }

  Vector get center => new Vector(center_x,center_y);
  num get center_x => minv.x + (maxv.x-minv.x)/2;
  num get center_y => minv.y + (maxv.y-minv.y)/2;

  CanvasRenderingContext2D context;
  List<MyPoly> polys;
  Vector minv;
  Vector maxv;
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
