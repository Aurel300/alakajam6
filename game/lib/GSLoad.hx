package lib;

class GSLoad extends GameState {
  public function new() {}
  
  var loader:Loader;
  //var loadText = new TextFragment("");
  
  public function add(loader:Loader):Void {
    this.loader = this.loader.concat(loader);
    game.state("load");
  }
  
  override public function load():Void {
    loader = [ for (cat in [
        Actor.load()
      ]) for (sub in cat) sub ];
  }
  
  override public function tick(delta:Float):Void {
    Platform.window.fill(Colour.fromARGB32(0xFF0C0421));
    if (loader == null) return;
    if (loader.length > 0) {
      //if (TextFragment.fonts != null) {
      //  loadText.text = loader[0].desc != null ? loader[0].desc : "Loading ...";
      //}
      if (loader[0].run()) {
        loader.shift();
        if (loader.length == 0 && Debug.AUTO_LOAD) game.state("game");
      }
    }
    //if (loader != null && loader.length == 0 && TextFragment.fonts != null) {
    //  loadText.text = "Click to start game";
    //}
    //if (TextFragment.fonts != null) {
      //Platform.window.fillRect(0, Main.SCREEN_H - 20, 300, 20, Colour.fromARGB32(0xFFE3CCA8));
      //Platform.window.blitAlpha(4, Main.SCREEN_H - 16, loadText.size(292, 16));
    //}
  }
  
  override public function mouse(e:MouseEvent):Void switch (e) {
    case Up(_, _, _):
    if (loader != null && loader.length == 0) game.state("game");
    case _:
  }
}
