package lib;

class GSTest extends GameState {
  var renMetro:RenMetro;
  var renCyber:RenCyber;
  
  public function new() {
    
  }
  
  override public function load():Void {
    Scenario.init();
    renMetro = new RenMetro();
    renCyber = new RenCyber();
  }
  
  override public function tick(delta:Float):Void {
    //renMetro.position(0, 0);
    //renMetro.tick();
    renCyber.position(0, 0);
    renCyber.tick();
    var win = Platform.window;
    win.fill(Colour.fromARGB32(0xFF000000));
    //renMetro.render(win);
    renCyber.render(win);
  }
  
  override public function mouse(e:MouseEvent):Void {
    //renMetro.mouse(e);
    renCyber.mouse(e);
  }
}