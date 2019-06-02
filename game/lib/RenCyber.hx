package lib;

using lib.RenCyber.MapTools;

class RenCyber extends Ren {
  public var map:Array<Tile>;
  public var units:Array<Unit>;
  public var mapW:Int;
  public var mapH:Int;
  public var playerTurn:Bool = true;
  
  // player
  public var ai:CyberAI = new CyberAI();
  public var selected:Unit;
  public var available:Map<Tile, TileAction> = [];
  
  public var unitPath:{unit:Unit, path:Array<{len:Int, step:TAStep}>};
  
  function updateUI():Void {
    var ti = -1;
    ui.uix = [
      Group("map", [
        for (y in 0...mapH) for (x in 0...mapW) {
          var tile = map[++ti];
          if (tile.unit == null) {
            tile.faction = Neutral;
          } else {
            tile.faction = tile.unit.faction;
          }
          if (!tile.present) continue;
          var bridgeV = (y < mapH - 1 && tile.unit != null && map[ti + mapW].unit == tile.unit);
          var bridgeH = (x < mapW - 1 && tile.unit != null && map[ti + 1].unit == tile.unit);
          var o = [
             UIX.At(8, 22, [Singleton("cyber-tile-bridge-v", bridgeV ? 1 + (tile.faction:Int) : 0)])
            ,UIX.Button(() -> tileClick(tile), 'cyber-tile${(tile.faction:Int)}')
          ];
          if (bridgeH) o.unshift(At(22, 10, [Singleton("cyber-tile-bridge-h", tile.faction)]));
          if (tile.unit != null && tile == tile.unit.head)
            o.push(UIX.At(4, 4, [Singleton("cyber-unit", tile.unit.type)]));
          if (available.exists(tile))
            o.push(UIX.At(4, 4, [Singleton("cyber-unit-over", switch(available[tile]) {
              case Move(_): 0;
              case Attack(_, _): 1;
              case _: 0;
            })]));
          UIX.At(x * 24, y * 24, o);
        }
      ])
      // actual UI
      ,At(0, 200, [
        HystX(() -> uiLocked() ? -80 : 0, 0.95, [
           Button(() -> if (!uiLocked()) doAction(null, PassTurn), 4, "cyber-button")
          ,Text("End turn", "big-button", 72, 24)
          ,AtY(20, [
             Button(() -> if (!uiLocked()) doAction(null, PassTurn), 4, "cyber-button")
            ,Text("Next unit", "big-button", 72, 24)
          ])
        ])
      ])
    ];
  }
  
  public function turn(player:Bool):Void {
    available = [];
    playerTurn = player;
    for (u in units) {
      //if (u.player == player) {
      u.curMP = u.maxMP;
      u.moved = false;
      u.acted = false;
    }
    updateUI();
  }
  
  public function calculateAvailable(unit:Unit):Map<Tile, TileAction> {
    var visitedAttack = [];
    var visited = [];
    available = [];
    var path = [];
    function visitAttack(tile:Tile, nrange:Int, range:Int):Void {
      //if (visitedAttack.indexOf(tile) != -1) return;
      //visitedAttack.push(tile);
      if (tile.present && tile.unit != null && tile.unit.player != unit.player && !tile.unit.invincible) {
        if (!available.exists(tile) || (switch (available[tile]) {
          case Attack(opath, _): opath.length > path.length;
          case _: false;
        })) available[tile] = Attack(path.copy(), tile.unit);
      }
      if (range > 0) {
        if (tile.x > 0) {        visitAttack(map[tile.ti - 1], nrange + 1, range - 1); }
        if (tile.x < mapW - 1) { visitAttack(map[tile.ti + 1], nrange + 1, range - 1); }
        if (tile.y > 0) {        visitAttack(map[tile.ti - mapW], nrange + 1, range - 1); }
        if (tile.y < mapH - 1) { visitAttack(map[tile.ti + mapW], nrange + 1, range - 1); }
      }
    }
    function visit(tile:Tile, nmp:Int, mp:Int):Void {
      //if (visited.indexOf(tile) != -1) return;
      //visited.push(tile);
      if (!tile.present) return;
      if (tile.unit != null && tile.unit != unit) return;
      visitAttack(tile, 0, unit.range);
      if (tile.unit == unit && tile == tile.unit.head && nmp != 0) return;
      if (!available.exists(tile) || (switch (available[tile]) {
        case Move(opath): opath.length > path.length;
        case _: false;
      })) available[tile] = Move(path.copy());
      if (mp > 0) {
        if (tile.x > 0) {        path.push({ox: -1, oy: 0}); visit(map[tile.ti - 1], nmp + 1, mp - 1); path.pop(); }
        if (tile.x < mapW - 1) { path.push({ox: 1, oy: 0}); visit(map[tile.ti + 1], nmp + 1, mp - 1); path.pop(); }
        if (tile.y > 0) {        path.push({ox: 0, oy: -1}); visit(map[tile.ti - mapW], nmp + 1, mp - 1); path.pop(); }
        if (tile.y < mapH - 1) { path.push({ox: 0, oy: 1}); visit(map[tile.ti + mapW], nmp + 1, mp - 1); path.pop(); }
      }
    }
    if (unit.curMP > 0) visit(unit.head, 0, unit.curMP);
    else if (!unit.acted) visitAttack(unit.head, 0, unit.range);
    available.remove(unit.head);
    return available;
  }
  
  public function doAction(unit:Unit, action:TileAction):Void {
    unitPath = null;
    switch (action) {
      case Move(path): unitPath = {unit: unit, path: path.map(p -> {len: 10, step: TAStep.Move(p.ox, p.oy)})};
      case Attack(path, target):
      unitPath = {unit: unit, path: path.map(p -> {len: 10, step: TAStep.Move(p.ox, p.oy)})};
      unitPath.path.push({len: 15, step: Attack(target)});
      case PassMove: unit.curMP = 0; unit.moved = true;
      case PassAction: unit.moved = true; unit.acted = true;
      case PassTurn: turn(!playerTurn);
    }
  }
  
  function uiLocked():Bool {
    return !playerTurn || unitPath != null;
  }
  
  function selectUnit(unit:Unit):Void {
    trace("selected", unit.curMP);
    selected = unit;
    if (selected.faction == Player) calculateAvailable(selected);
    else available = [];
    updateUI();
  }
  
  function tileClick(tile:Tile, ?force:Bool = false):Void {
    trace("click", tile.ti, selected != null ? selected.head.ti : "no sel");
    if (!force && uiLocked()) return;
    if (selected != null && available.exists(tile)) {
      doAction(selected, available[tile]);
      available = [];
      if (unitPath != null) unitPath.path.push({len: 1, step: Select(selected)});
    } else if (tile.unit != null) {
      selectUnit(tile.unit);
      return;
    } else {
      selected = null;
    }
    updateUI();
  }
  
  function removeUnit(unit:Unit):Void {
    units.remove(unit);
    if (selected == unit) selected = null;
  }
  
  function loadMap(lines:Array<Array<TileSpec>>):Void {
    mapW = lines[0].length;
    mapH = lines.length;
    var specs = [ for (l in lines) for (t in l) t ];
    units = [ for (t in specs) switch (t) {
      case Path(_, Unit(spec)) | Unit(spec):
      var faction = Enemy;
      var type = Ninja;
      function handleUnitspec(spec:UnitSpec):Void {
        handleUnitspec(switch (spec) {
          case Pl(u): faction = Player; u;
          case Ne(u): faction = Neutral; u;
          case Al(u): faction = Alarmed; u;
          case T(u): type = u; return;
          case _: return;
        });
      }
      handleUnitspec(spec);
      new Unit(faction, type);
      case _: continue;
    } ];
    var tunits = units.copy();
    var ti = -1;
    var joins = [];
    map = [ for (y in 0...mapH) {
      for (x in 0...mapW) {
        var tile:Tile = null;
        function handleTilespec(spec:TileSpec):Tile return tile = (switch (spec) {
          case Path(p, t):
          handleTilespec(t);
          tile.path = p;
          tile;
          case Unit(_):
          var unit = tunits.shift();
          var tile = ({x: x, y: y, ti: ti, present: true, unit: unit, faction: Neutral}:Tile);
          unit.tiles.push(tile);
          tile;
          case Empty: ({x: x, y: y, ti: ti, present: true, unit: null, faction: Neutral}:Tile);
          case None: ({x: x, y: y, ti: ti, present: false, unit: null, faction: Neutral}:Tile);
          case JoinTo(ox, oy):
          var tile = ({x: x, y: y, ti: ti, present: true, unit: null, faction: Neutral}:Tile);
          joins.push({ox: ox, oy: oy, tile: tile});
          tile;
        });
        handleTilespec(specs[++ti]);
      }
    } ];
    var work = true;
    while (work) {
      work = false;
      joins = [ for (j in joins) {
        var rti = j.tile.ti + j.ox + j.oy * mapW;
        if (map[rti].unit != null) {
          map[rti].unit.tiles.push(j.tile);
          j.tile.unit = map[rti].unit;
          work = true;
          continue;
        }
        j;
      } ];
    }
    if (joins.length > 0) throw "cannot join";
  }
  
  public function new() {
    ui = new UI([]);
    loadMap([
      "...............".tiles("...............", []),
      "...........X<..".tiles("...............", [Pl(T(Ninja))]),
      "..OOOOOX<..^...".tiles("..v<...v<......", [T(Watchdog)]),
      "..OOOXOOOO>^...".tiles("...............", [T(Bait)]),
      "..>XOOOOO......".tiles("..>^...>^......", [T(Watchdog)]),
      "...............".tiles("...............", []),
    ]);
    updateUI();
  }
  
  public inline function tileAt(x:Int, y:Int):Tile return map[x + y * mapW];
  
  override public function tick():Void {
    if (unitPath != null) {
      if (--unitPath.path[0].len <= 0) {
        switch (unitPath.path.shift().step) {
          case Move(ox, oy):
          unitPath.unit.curMP--;
          unitPath.unit.moveTo(tileAt(unitPath.unit.head.x + ox, unitPath.unit.head.y + oy));
          case Attack(target):
          unitPath.unit.curMP = 0;
          unitPath.unit.acted = true;
          if (target.damage(unitPath.unit.attack)) removeUnit(target);
          case Select(unit): selectUnit(unit);
        }
        if (unitPath.path.length == 0) {
          unitPath.unit.moved = true;
          unitPath = null;
        }
        updateUI();
      }
    } else if (!playerTurn) ai.tick(this);
  }
}

enum TAStep {
  Move(ox:Int, oy:Int);
  Attack(target:Unit);
  Select(unit:Unit);
}

enum TileAction {
  Move(path:Array<{ox:Int, oy:Int}>);
  Attack(path:Array<{ox:Int, oy:Int}>, target:Unit);
  PassMove;
  PassAction;
  PassTurn;
}

enum abstract Faction(Int) to Int {
  var Neutral;
  var Player;
  var Enemy;
  var Alarmed;
}

enum abstract UnitType(Int) to Int {
  var Ninja;
  var Key;
  var Lock;
  var Bait;
  var Watchdog;
}

enum TileSpec {
  Path(p:PathSpec, t:TileSpec);
  Unit(u:UnitSpec);
  Empty;
  None;
  JoinTo(ox:Int, oy:Int);
}

enum UnitSpec {
  // default is enemy
  Pl(u:UnitSpec);
  Ne(u:UnitSpec);
  Al(u:UnitSpec);
  
  T(u:UnitType);
}

class Unit {
  public var faction:Faction;
  public var type:UnitType;
  public var tiles:Array<Tile> = [];
  public var moved:Bool = false;
  public var acted:Bool = false;
  
  public var head(get, never):Tile;
  function get_head():Tile return tiles[0];
  
  public var player(get, never):Bool;
  function get_player():Bool return faction == Player;
  
  // stats
  public var curMP:Int;
  public var maxHP:Int;
  public var maxMP:Int;
  public var attack:Int;
  public var range:Int;
  public var invincible:Bool = false;
  
  // AI only
  public var followingPath:PathSpec;
  
  public function new(faction:Faction, type:UnitType) {
    this.faction = faction;
    this.type = type;
    var stats = (switch (type) {
      case Ninja:    [2, 4, 2, 1];
      case Key:      invincible = true; [1, 2, 0, 0];
      case Lock:     invincible = true; [1, 0, 0, 0];
      case Bait:     [4, 1, 1, 1];
      case Watchdog: [3, 2, 2, 1];
    });
    maxHP = stats[0];
    curMP = maxMP = stats[1];
    attack = stats[2];
    range = stats[3];
  }
  
  public function moveTo(tile:Tile):Void {
    tile.unit = this;
    tiles.remove(tile);
    tiles.unshift(tile);
    while (tiles.length > maxHP) {
      tiles.pop().unit = null;
    }
  }
  
  public function damage(dmg:Int):Bool {
    for (i in 0...dmg) {
      tiles.pop().unit = null;
      if (tiles.length == 0) return true;
    }
    return false;
  }
}

@:structInit
class Tile {
  public var x:Int;
  public var y:Int;
  public var ti:Int;
  public var present:Bool;
  public var unit:Unit;
  public var faction:Faction;
  public var path:PathSpec = null;
}

typedef PathSpec = {
   tile:Int
  ,direction:Dir
};

class MapTools {
  public static function tiles(s:String, paths:String, u:Array<UnitSpec>):Array<TileSpec> {
    var ti = -1;
    return s.split("").map((t) -> {
      var ts:TileSpec = (switch (t) {
        case "X":
        if (u.length == 0) throw 'not enough units for line $s';
        Unit(u.shift());
        case "O": Empty;
        case ".": None;
        case "<": JoinTo(-1, 0);
        case ">": JoinTo(1, 0);
        case "^": JoinTo(0, -1);
        case "v": JoinTo(0, 1);
        case _: throw 'invalid tile $t';
      });
      switch(paths.charAt(++ti)) {
        case "^": ts = Path({tile: ti, direction: Up}, ts);
        case ">": ts = Path({tile: ti, direction: Right}, ts);
        case "v": ts = Path({tile: ti, direction: Down}, ts);
        case "<": ts = Path({tile: ti, direction: Left}, ts);
        case _:
      }
      ts;
    });
  }
}
