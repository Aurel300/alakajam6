package lib;

import plu.anim.*;

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
  var mx:Int;
  var my:Int;
  var onClick:()->Void;
  
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
    mouseHover = null;
    onClick = null;
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
          case Button(click, actor):
          var vis = actor.visual();
          var hover = mx.withinIE(0, vis.w) && my.withinIE(0, vis.h);
          if (mouseHold == null || mouseHold == subid) {
            if (hover) {
              mouseHover = subid;
              onClick = click;
            }
          }
          var actor = subid.singletonI(actor, topXY.x, topXY.y, mouseHold == subid ? 2 : (mouseHover == subid ? 1 : 0));
          actor.render(to);
          case Singleton(actor, index): subid.singletonI(actor, topXY.x, topXY.y, index).render(to);
          case Text(txt, w, h): throw "!";
          case Group(rid, sub): walk(rid != null ? rid : subid, sub);
          case Lazy(rid, sub): walk(rid != null ? rid : subid, sub());
        }
        pos.pop();
      }
    }
    walk("root", uix);
  }
}
