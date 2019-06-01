package lib;

typedef MapArea = {id:String, name:String, desc:String, x:Int, y:Int, ?stopX:Int, ?stopY:Int};

class RenMetro extends Ren {
  static final metroWidth = 35;
  static var metroMap
  =("...........OOOXOOOOOOOOOOOOOXOO...."
  + "...........O......................."
  + "OXOOOOOOOOOOOOOOOOOOOOOOOO........."
  + "...........O.............O........."
  + "...........O.............OOOOOOO..."
  + "...........O.............O........."
  + "...........O.............O........."
  + "...........O.............X........."
  + ".OOXOOOOOOOO.............O........."
  + ".........................O........."
  + ".........................O........."
  + "...............OOOOOOOOOOOOOOOOOOOO"
  + "...............O.........O........."
  + "...............O.........O........."
  + "...............O.........OOXOOOO..."
  + "...............X..................."
  + "...............O..................."
  + "...........OOOOO...................").split("");
  static var metroStops = [
     "clinic-outside"
    ,"home-outside"
    ,"checkpoint-outside"
    ,"kino-outside"
    ,"police-outside"
    ,"bar-outside"
    ,"hospital-outside"
  ];
  static var mapAreas:Array<MapArea> = [
     {id: "clinic-outside", name: "Butch's Practice", desc: "...", x: 200, y: 72}
    ,{id: "home-outside", name: "Manor Sector (Home)", desc: "...", x: 312, y: 72}
    ,{id: "aico", name: "AIC0 Complex", desc: "...", x: 56, y: 88}
    ,{id: "checkpoint-outside", name: "Military Checkpoint", desc: "...", x: 96, y: 88}
    ,{id: "police-outside", name: "Police Station", desc: "...", x: 112, y: 136}
    ,{id: "kino-outside", name: "Kino7", desc: "...", x: 272, y: 144}
    ,{id: "hospital-outside", name: "St Josh Hospital", desc: "...", x: 192, y: 208}
    ,{id: "bar-outside", name: "Bobbard's Bar", desc: "...", x: 304, y: 216}
  ];
  static var mapAreasM:Map<String, MapArea>;
  
  var metroTX:Int = 28;
  var metroTY:Int = 0;
  var metroPath:Array<{len:Int, ox:Int, oy:Int}> = [];
  var connectivity:Array<Array<Int>>;
  
  function pathfind(tx:Int, ty:Int):Void {
    var visited:Map<Int, Bool> = [];
    var path = [];
    var target = tx + ty * metroWidth;
    var start = metroTX + metroTY * metroWidth;
    function dfs(pos:Int):Bool {
      if (visited.exists(pos)) return false;
      visited[pos] = true;
      path.push(pos);
      if (pos == target) throw 0;
      connectivity[pos].map(dfs);
      path.pop();
      return false;
    }
    if (try dfs(start) catch (_:Int) true) {
      var last = start;
      metroPath = [ for (pos in path.slice(1)) {
        var ox = (pos - last).abs() == 1 ? (pos > last ? 1 : -1) : 0;
        var oy = (pos - last).abs() != 1 ? (pos > last ? 1 : -1) : 0;
        last = pos;
        {len: 8, ox: ox, oy: oy};
      } ];
      if (metroPath.length == 0) arrival();
    }
  }
  
  function arrival():Void trace("here");
  
  public function new() {
    mapAreasM = [ for (a in mapAreas) a.id => a ];
    var mi = -1;
    var metroHeight = Std.int(metroMap.length / metroWidth);
    var stops = metroStops.copy();
    connectivity = [ for (y in 0...metroHeight) {
      for (x in 0...metroWidth) {
        switch (metroMap[++mi]) {
          case "X":
          var area = mapAreasM[stops.shift()];
          area.stopX = x;
          area.stopY = y;
          case _:
        }
        []
        .concat(y > 0 && metroMap[mi - metroWidth] != "." ? [mi - metroWidth] : [])
        .concat(y < metroHeight - 1 && metroMap[mi + metroWidth] != "." ? [mi + metroWidth] : [])
        .concat(x > 0 && metroMap[mi - 1] != "." ? [mi - 1] : [])
        .concat(x < metroWidth - 1 && metroMap[mi + 1] != "." ? [mi + 1] : []);
      }
    } ];
    ui = new UI([
       Singleton("metro-bg")
      ,Group([ for (a in mapAreas) {
        UIX.At(a.x - 4, a.y - 4, [Button(() -> {
          if (a.stopX != null) pathfind(a.stopX, a.stopY);
        }, "metro-area")]);
      } ])
      ,HystX(() -> metroTX * 8 + 100 - 8, .9, [HystY(() -> metroTY * 8 + 100 - 8, .9, [Singleton("metro-train")])])
    ]);
  }
  
  override public function tick():Void {
    if (metroPath.length > 0) {
      if (--metroPath[0].len <= 0) {
        var off = metroPath.shift();
        metroTX += off.ox;
        metroTY += off.oy;
        if (metroPath.length == 0) arrival();
      }
    }
  }
}
