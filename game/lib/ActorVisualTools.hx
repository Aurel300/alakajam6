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
      case _: throw 'no such visual $of';
    });
    return {source: of.split("-")[0], x: pos.x, y: pos.y, w: pos.w, h: pos.h};
  }
}
