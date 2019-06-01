package lib;

class Actor {
  static function reload():Void {
    BMP_SOURCES = [ for (k in ["character", "metro"]) k => Platform.assets.bitmaps[k] ];
    //var palSrc = c.cut(0, 112, 64, 1).get();
    //PAL = [ for (i in 0...14) palSrc[i * 3] ];
    BMP_CACHE = [];
    HID++;
  }
  
  static var HID = 0;
  public static function load():Loader {
    return [{
         run: () -> { reload(); true; }
        ,desc: "Generating actors ..."
      }];
  }
  
  static var BMP_SOURCES:Map<String, Bitmap>;
  public static var PAL:Array<Colour>;
  public static var PARTICLES:Map<String, Bitmap> = null;
  static var BMP_CACHE:Map<String, Bitmap> = [];
  
  public static function generate(to:ActorVisual):Bitmap {
    var ret = BMP_SOURCES[to.source].cut(to.x, to.y, to.w, to.h);
    return ret.lock();
  }
  
  public var x:Int = 0;
  public var y:Int = 0;
  public var hide:Bool = false;
  public var lastHID = 0;
  public var bmp:Bitmap;
  
  private function updateVisual(to:ActorVisual):Void {
    lastHID = HID;
    var id = '${to.x}/${to.y}/${to.w}/${to.h}';
    if (BMP_CACHE.exists(id)) bmp = BMP_CACHE[id];
    else bmp = BMP_CACHE[id] = generate(to);
  }
  
  public var visual(null, set):ActorVisual;
  private function set_visual(to:ActorVisual):ActorVisual {
    updateVisual(to);
    return this.visual = to;
  }
  
  public function new(x:Int, y:Int, ?visual:ActorVisual) {
    this.x = x;
    this.y = y;
    if (visual != null) set_visual(visual);
  }
  
  public function render(to:ISurface, ?ox:Int = 0, ?oy:Int = 0):Void {
#if JAM_DEBUG
    if (lastHID != HID && visual != null) updateVisual(visual);
#end
//    if (!hide && (x + ox).withinIE(-bmp.width, Main.VWIDTH) && (y + oy).withinIE(-bmp.height, Main.VHEIGHT))
      to.blitAlpha(x + ox, y + oy, bmp);
  }
  
  public function renderClip(to:ISurface, ox:Int, oy:Int, sx:Int, sy:Int, sw:Int, sh:Int):Void {
#if JAM_DEBUG
    if (lastHID != HID && visual != null) updateVisual(visual);
#end
    if (!hide) to.blitAlphaRect(x + ox, y + oy, sx, sy, sw, sh, bmp);
  }
}
