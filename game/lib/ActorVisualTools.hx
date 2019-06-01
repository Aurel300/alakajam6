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
    var pos = (switch (of) {
      case "character-dbg": {x: 8 + index * 40, y: 0, w: 40, h: 80};
      case "metro-bg": {x: 0, y: 0, w: 400, h: 300};
      case "metro-area": {x: index * 32, y: 304, w: 32, h: 32};
      case "metro-train": {x: 96, y: 304, w: 16, h: 16};
      case "cyber-tile0": {x: index * 24, y: 0, w: 24, h: 32};
      case "cyber-tile1": {x: index * 24, y: 32, w: 24, h: 32};
      case "cyber-tile2": {x: index * 24, y: 64, w: 24, h: 32};
      case "cyber-tile3": {x: index * 24, y: 96, w: 24, h: 32};
      case "cyber-tile-bridge-v": {x: 72, y: index * 8, w: 8, h: 8};
      case "cyber-tile-bridge-h": {x: 80 + index * 4, y: 0, w: 4, h: 9};
      case _: throw 'no such visual $of';
    });
    return {source: of.split("-")[0], x: pos.x, y: pos.y, w: pos.w, h: pos.h};
  }
}
