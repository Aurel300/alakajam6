package lib;

class ActorVisualTools {
  static var SINGLETONS:Map<String, Actor> = [];
  
  public static function singleton(vis:String, x:Int, y:Int, ?index:Int = 0):Actor {
    return singletonI(vis, x, y, index);
  }
  
  public static function singletonI(id:String, ?vis:String, x:Int, y:Int, ?index:Int = 0):Actor {
    if (vis == null) vis = id;
    if (!SINGLETONS.exists(id)) SINGLETONS[id] = new Actor(0, 0, index == -1 ? null : visual(vis, index));
    SINGLETONS[id].x = x;
    SINGLETONS[id].y = y;
    if (index != -1) SINGLETONS[id].visual = visual(vis, index);
    return SINGLETONS[id];
  }
  
  public static function visual(of:String, ?index:Int = 0):ActorVisual {
    var orig = of;
    var spl = of.split("-");
    var flipH = false;
    var light = null;
    if (spl[spl.length - 1] == "fh") {
      flipH = true;
      spl.pop();
      of = spl.join("-");
    }
    if (spl[spl.length - 1] == "light") {
      spl.pop();
      of = spl.join("-");
      light = Colour.fromARGB32(switch (of) {
        case "bgs-home": 0xFF4E3634;
        case "bgs-bar": 0xFF261046;
        case _: 0xAA000000;
      });
    }
    var pos = (switch (of) {
      case "character-dbg": {x: 8 + index * 40, y: 0, w: 40, h: 64};
      case "character-player": {x: 8 + index * 40, y: 88, w: 40, h: 64};
      case "character-bobbard": {x: 8 + index * 40, y: 64, w: 40, h: 24};
      case "metro-bg": {x: 0, y: 0, w: 400, h: 300};
      case "metro-area": {x: index * 32, y: 304, w: 32, h: 32};
      case "metro-train": {x: 96, y: 304, w: 16, h: 16};
      case "cyber-tile0": {x: index * 24, y: 0, w: 24, h: 32};
      case "cyber-tile1": {x: index * 24, y: 32, w: 24, h: 32};
      case "cyber-tile2": {x: index * 24, y: 64, w: 24, h: 32};
      case "cyber-tile3": {x: index * 24, y: 96, w: 24, h: 32};
      case "cyber-tile-bridge-v": {x: 72, y: index * 8, w: 8, h: 8};
      case "cyber-tile-bridge-h": {x: 80 + index * 4, y: 0, w: 4, h: 9};
      case "cyber-unit": {x: 80 + index * 16, y: 16, w: 16, h: 16};
      case "cyber-unit-over": {x: 80 + index * 16, y: 32, w: 16, h: 16};
      case "cyber-button": {x: 80, y: 48 + index * 24, w: 72, h: 24};
      case "bgs-home": {x: 0, y: 0 + index * 128, w: 464, h: 128};
      case "bgs-bar": {x: 0, y: 3 * 128 + index * 128, w: 464, h: 128};
      case _: throw 'no such visual $of';
    });
    return {source: spl[0], light: light, id: light != null ? orig : null, x: pos.x, y: pos.y, w: flipH ? -pos.w : pos.w, h: pos.h};
  }
}
