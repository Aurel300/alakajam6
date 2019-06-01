package lib;

class GSTest extends GameState {
  var renMetro:RenMetro;
  
  public function new() {
    
  }
  
  override public function load():Void {
    Scenario.init();
    renMetro = new RenMetro();
  }
  
  override public function tick(delta:Float):Void {
    renMetro.position(0, 0);
    renMetro.tick();
    var win = Platform.window;
    renMetro.render(win);
  }
  
  override public function mouse(e:MouseEvent):Void {
    renMetro.mouse(e);
  }
}