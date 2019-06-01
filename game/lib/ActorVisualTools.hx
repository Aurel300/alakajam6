package lib;

class ActorVisualTools {
  static var SINGLETONS:Map<String, Actor> = [];
  
  public static function singleton(vis:String, x:Int, y:Int, ?index:Int = 0):Actor {
    return singletonI(vis, x, y, index);
  }
  
  public static function singletonI(id:String, x:Int, y:Int, ?index:Int = 0):Actor {
    if (!SINGLETONS.exists(id)) SINGLETONS[id] = new Actor(0, 0, index == -1 ? null : visual(id, index));
    SINGLETONS[id].x = x;
    SINGLETONS[id].y = y;
    if (index != -1) SINGLETONS[id].visual = visual(id, index);
    return SINGLETONS[id];
  }
  
  public static function visual(of:String, ?index:Int = 0):ActorVisual {
    return (switch (of) {
      case "dbg-character": {x: 8 + index * 40, y: 0, w: 40, h: 80};
      case _: throw 'no such visual $of';
    });
  }
}
