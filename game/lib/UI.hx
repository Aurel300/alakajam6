package lib;

class UI {
  public var uix:Array<UIX>;
  public var mouseHover:String;
  public var mouseHold:String;
  //public var click:IEvent<String>;
  //public var mouseHover:IEvent<String>;
  //public var mouseLeave:IEvent<String>;
  //
  //var emitterClick:Emitter<String>;
  //var emitterMouseHover:Emitter<String>;
  //var emitterMouseLeave:Emitter<String>;
  var hystCache:Map<String, Hyst> = [];
  var htmlCache:Map<String, {x:Int, y:Int, w:Int, h:Int, txt:String, cls:String, el:js.html.Element}> = [];
  var htmlLastTick:Array<String> = [];
  var mx:Int;
  var my:Int;
  var onClick:()->Void;
  
  static var htmlRoot = js.Browser.document.querySelector("#texts");
  
  public function new(uix:Array<UIX>) {
    this.uix = uix;
    //click = (emitterClick = new Emitter()).observer;
    //mouseHover = (emitterMouseHover = new Emitter()).observer;
    //mouseLeave = (emitterMouseLeave = new Emitter()).observer;
  }
  
  public function mouse(e:MouseEvent):Bool {
    return (switch (e) {
      case Move(x, y): mx = x; my = y; false;
      case Up(_, _) if (mouseHold != null):
      if (mouseHover == mouseHold && onClick != null) onClick();
      mouseHold = null;
      true;
      case Down(_, _) if (mouseHover != null):
      mouseHold = mouseHover;
      true;
      case _: false;
    });
  }
  
  public function render(to:ISurface, x:Int, y:Int):Void {
    var pos = [];
    var topXY:{x:Int, y:Int};
    var xy = [topXY = {x: x, y: y}];
    function popXY():Void {
      xy.pop();
      topXY = xy[xy.length - 1];
    }
    function hyst(id:String, target:()->Float, ?ratio:Float):Int {
      if (!hystCache.exists(id)) {
        hystCache[id] = new Hyst(target(), ratio);
      }
      hystCache[id].setTo(target());
      return hystCache[id].tickI();
    }
    var htmlTick = [];
    function html(id:String, txt:String, cls:String, w:Int, h:Int):Void {
      var force = false;
      var c = null;
      if (!htmlCache.exists(id)) {
        var el = js.Browser.document.createElement("div");
        htmlRoot.appendChild(el);
        force = true;
        htmlCache[id] = c = {x: topXY.x, y: topXY.y, w: w, h: h, txt: txt, cls: cls, el: el};
      } else c = htmlCache[id];
      htmlTick.push(id);
      if (force || c.x != topXY.x) { c.el.style.left = '${topXY.x * 2}px'; c.x = topXY.x; }
      if (force || c.y != topXY.y) { c.el.style.top = '${topXY.y * 2}px'; c.y = topXY.y; }
      if (force || c.w != w) { c.el.style.width = '${w * 2}px'; c.w = w; }
      if (force || c.h != h) { c.el.style.height = '${h * 2}px'; c.h = h; }
      if (force || c.txt != txt) { c.el.innerHTML = txt; c.txt = txt; }
      if (force || c.cls != cls) { c.el.className = cls; c.cls = cls; }
    }
    var nextMouseHover = null;
    var nextOnClick = null;
    function walk(id:String, uix:Array<UIX>):Void {
      var mx = this.mx - topXY.x;
      var my = this.my - topXY.y;
      for (i in 0...uix.length) {
        pos.push(i);
        var subid = '$id-$i';
        switch (uix[i]) {
          case At(offX, offY, sub): xy.push(topXY = {x: topXY.x + offX, y: topXY.y + offY}); walk(subid, sub); popXY();
          case AtX(offX, sub): xy.push(topXY = {x: topXY.x + offX, y: topXY.y}); walk(subid, sub); popXY();
          case AtY(offY, sub): xy.push(topXY = {x: topXY.x, y: topXY.y + offY}); walk(subid, sub); popXY();
          //case Hyst(target, ratio, sub): xy.push(topXY = {x: topXY.x + hyst('${subid}x', target, ratio), y: topXY.y + hyst('${subid}y', target, ratio)}); walk(subid, sub); popXY();
          case HystX(target, ratio, sub): xy.push(topXY = {x: topXY.x + hyst(subid, target, ratio), y: topXY.y}); walk(subid, sub); popXY();
          case HystY(target, ratio, sub): xy.push(topXY = {x: topXY.x, y: topXY.y + hyst(subid, target, ratio)}); walk(subid, sub); popXY();
          case If(c, sub): if (c()) walk(subid, sub);
          case IfO(c, ratio, sub): throw "!";
          case Opacity(o, sub): throw "!";
          case HystOpacity(target, ratio, sub): throw "!";
          case Button(click, state, deadzone, actor):
          if (deadzone == null) deadzone = 0;
          var vis = actor.visual();
          var hover = mx.withinIE(deadzone, vis.w - deadzone) && my.withinIE(deadzone, vis.h - deadzone);
          if (mouseHold == null || mouseHold == subid) {
            if (hover) {
              nextMouseHover = subid;
              nextOnClick = click;
            }
          }
          if (state != null) state(mouseHover == subid, mouseHold == subid);
          var actor = subid.singletonI(actor, topXY.x, topXY.y, mouseHold == subid ? 2 : (mouseHover == subid ? 1 : 0));
          actor.render(to);
          case ButtonI(click, state, w, h):
          var hover = mx.withinIE(0, w) && my.withinIE(0, h);
          if (mouseHold == null || mouseHold == subid) {
            if (hover) {
              nextMouseHover = subid;
              nextOnClick = click;
            }
          }
          if (state != null) state(mouseHover == subid, mouseHold == subid);
          case Singleton(actor, index): subid.singletonI(actor, topXY.x, topXY.y, index).render(to);
          case Text(txt, cls, w, h): html(subid, txt, cls, w, h);
          case TextD(txt, cls, w, h): html(subid, txt(), cls != null ? cls() : null, w(), h());
          case Group(rid, sub): walk(rid != null ? rid : subid, sub);
          case Lazy(rid, sub): walk(rid != null ? rid : subid, sub());
          case Fill(c): to.fill(c);
        }
        pos.pop();
      }
    }
    walk("root", uix);
    for (h in htmlLastTick) {
      if (htmlTick.indexOf(h) != -1) continue;
      htmlCache[h].el.remove();
      htmlCache.remove(h);
    }
    htmlLastTick = htmlTick;
    mouseHover = nextMouseHover;
    onClick = nextOnClick;
  }
}
