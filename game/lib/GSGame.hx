package lib;

class GSGame extends GameState {
  public static var I:GSGame;
  
  public var renRoom:RenRoom;
  public var renMetro:RenMetro;
  public var renCyber:RenCyber;
  var lastScreenHeight = 400;
  var screenEl = js.Browser.document.querySelector("#game");
  public var screenHeight = new Hyst(400, .9);
  
  public var showMetro = new Bitween(90);
  public var showCyber = new Bitween(90);
  
  var visRoom:Bool;
  var visMetro:Bool;
  var visCyber:Bool;
  
  public function new() {
    I = this;
  }
  
  override public function to(from:GameState):Void {
    Scenario.init();
    renRoom = new RenRoom();
    renRoom.position(0, 0);
    renMetro = new RenMetro();
    renCyber = new RenCyber();
    //showCyber.setTo(true);
    renRoom.loadRoom(Home);
  }
  
  var first = true;
  override public function tick(delta:Float):Void {
    renMetro.position(0, 400 - (showMetro.timed(Timing.sineInOut) * 400).floor());
    renCyber.position(0, -400 + (showCyber.timed(Timing.sineInOut) * 400).floor());
    
    visRoom = !showMetro.isOn && !showCyber.isOn;
    visMetro = !showMetro.isOff;
    visCyber = !showCyber.isOff;
    
    screenHeight.setTo(showMetro.state.match(On | ToOn(_)) || showCyber.state.match(On | ToOn(_)) ? 300 : 200);
    var nextScreenHeight = screenHeight.tickI();
    if (nextScreenHeight != lastScreenHeight) {
      screenEl.style.height = '${nextScreenHeight * 2}px';
      lastScreenHeight = nextScreenHeight;
    }
    
    if (visRoom) renRoom.tick();
    if (visMetro) renMetro.tick();
    if (visCyber) renCyber.tick();
    
    var win = Platform.window;
    win.fill(Colour.fromARGB32(0xFF000000));
    
    if (visRoom) renRoom.render(win);
    if (visMetro) renMetro.render(win);
    if (visCyber) renCyber.render(win);
  }
  
  override public function mouse(e:MouseEvent):Void {
       (visMetro ? renMetro.mouse(e) : false)
    || (visCyber ? renCyber.mouse(e) : false)
    || (visRoom ? renRoom.mouse(e) : false);
  }
}