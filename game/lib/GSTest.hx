package lib;

class GSTest extends GameState {
  public function new() {
    
  }
  
  var ph = 0;
  override public function tick(delta:Float):Void {
    var win = Platform.window;
    win.fill(Colour.fromARGB32(0xFFFFFFFF));
    "dbg-character".singleton(0, 0, 1 + ((ph++ >> 3) % 8)).render(win);
  }
}