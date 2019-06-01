package lib;

import lib.story.*;

class Scenario {
  public static function init():Void {
    ArcExplore.init();
    
    
    E.when(LeftRoom("foo"), true, [
      E.f(trace("nice"))
    ]);
  }
}
