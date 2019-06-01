package lib;

class Ren {
  public var x:Int;
  public var y:Int;
  public var ui:UI;
  
  public function position(x:Int, y:Int):Void {
    this.x = x;
    this.y = y;
  }
  public function tick():Void throw "no override";
  public function render(to:ISurface):Void {
    if (ui != null) ui.render(to, x, y);
  }
  public function mouse(e:MouseEvent):Bool {
    return ui.mouse(e);
  }
  public function key(e:KeyboardEvent):Bool {
    //return ui.key(e);
    return false;
  }
}
