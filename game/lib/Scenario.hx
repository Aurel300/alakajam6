package lib;

import lib.story.*;

class Scenario {
  public static var creds:Int = 130;
  
  public static function init():Void {
    ArcExplore.init();
    ArcBar.init();
    
    
    E.when(LeftRoom("foo"), true, [
      E.f(trace("nice"))
    ]);
  }
}
