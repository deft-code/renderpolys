
#import('dart:html');
#import('dart:json');

final WIDTH = 400;
final HEIGHT = 300;
final CENTER_X = WIDTH/2;
final CENTER_Y = HEIGHT/2;

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
  Page(CanvasRenderingContext2D this.context) {
    
  }
  
  DrawPoly(List<MyPoint> points) {
    assert(points.length>2);
    
    context.beginPath();
    context.lineWidth = 2;
    context.fillStyle = 'cornflowerblue';
    context.strokeStyle = 'darkblue';
    
    context.moveTo(points[0].x, points[0].y);
    
    for( var i=1; i<points.length; i++) {
      context.lineTo(points[i].x, points[i].y);
    }

    context.fill();
    context.closePath();
    context.stroke();
  }
  
  Load(String polys_txt) {
    polys = new List<MyPoly>();
    List<Map> parsed_polys = JSON.parse(polys_txt);
    for( var parsed_poly in parsed_polys) {
      var points = new List<MyPoint>();
      assert(parsed_poly["points"].length>2);
      for( Map v in parsed_poly["points"]) {
        points.addLast(new MyPoint(v["x"],v["y"]));
      }
      polys.add(new MyPoly(points));
    }
  }
  
  Draw() {
    for( var poly in polys) {
      DrawPoly( poly.points);
    }
  }
  
  CanvasRenderingContext2D context;
  List<MyPoly> polys;
}

void main() {
  query("#text").text = "Welcome to Dart!";

  CanvasElement c = query("#canvas");
  print(c.width);
  var p = new Page(c.context2d);
  p.Load(polys_json());
  p.Draw();
}
