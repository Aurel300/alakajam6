package lib;

import lib.RenCyber.Tile;
import lib.RenCyber.Unit;

class CyberAI {
  public function new() {
    
  }
  
  public function tick(ren:RenCyber):Void {
    var units = ren.units.filter(u -> !u.player && (!u.acted || u.curMP > 0));
    function closest(toX:Int, toY:Int, where:Tile->Bool):Tile {
      var ret = null;
      var rdist = 10000;
      for (t in ren.map) if (where(t)) {
        var dist = (t.x - toX).abs() + (t.y - toY).abs();
        if (dist < rdist) {
          ret = t;
          rdist = dist;
        }
      }
      return ret;
    }
    function free(x:Int, y:Int, to:Unit):Bool {
      if (!x.withinIE(0, ren.mapW) || !y.withinIE(0, ren.mapH)) return false;
      var tile = ren.tileAt(x, y);
      return tile.present && (tile.unit == null || tile.unit == to);
    }
    
    // TODO: dumb down heuristics
    // heuristic: moving fast units first can result in more HP
    units.sort((a, b) -> b.curMP - a.curMP);
    
    for (u in units) {
      var actions = ren.calculateAvailable(u);
      var any = false;
      if (u.faction == Enemy) {
        if (u.head.path != null) u.followingPath = u.head.path;
        if (u.followingPath != null) {
          var ox = 0;
          var oy = 0;
          switch (u.followingPath.direction) {
            case Up: oy = -1;
            case Right: ox = 1;
            case Down: oy = 1;
            case Left: ox = -1;
          }
          if (u.curMP > 0 && free(u.head.x + ox, u.head.y + oy, u)) return ren.doAction(u, Move([{ox: ox, oy: oy}]));
        }
      }
      for (tile => action in actions) {
        any = true;
        
      }
      if (any) {
        // execute and return
      }
    }
    
    trace("meh", units.length);
    ren.doAction(null, PassTurn);
  }
}
