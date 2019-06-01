package lib;

using lib.RenCyber.MapTools;

class RenCyber extends Ren {
  var map:Array<Tile>;
  var units:Array<Unit>;
  var mapW:Int;
  var mapH:Int;
  
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
          UIX.At(x * 24, y * 24, o);
        }
      ])
      // actual UI
    ];
  }
  
  function tileClick(tile:Tile):Void {
    trace("click", tile.x, tile.y);
  }
  
  function loadMap(lines:Array<Array<TileSpec>>):Void {
    mapW = lines[0].length;
    mapH = lines.length;
    var specs = [ for (l in lines) for (t in l) t ];
    units = [ for (t in specs) switch (t) {
      case Unit(spec):
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
      ({faction: faction, type: type}:Unit);
      case _: continue;
    } ];
    var ti = -1;
    var joins = [];
    map = [ for (y in 0...mapH) {
      for (x in 0...mapW) {
        switch (specs[++ti]) {
          case Unit(_): ({x: x, y: y, ti: ti, present: true, unit: units.shift(), faction: Neutral}:Tile);
          case Empty: ({x: x, y: y, ti: ti, present: true, unit: null, faction: Neutral}:Tile);
          case None: ({x: x, y: y, ti: ti, present: false, unit: null, faction: Neutral}:Tile);
          case JoinTo(ox, oy):
          var tile = ({x: x, y: y, ti: ti, present: true, unit: null, faction: Neutral}:Tile);
          joins.push({ox: ox, oy: oy, tile: tile});
          tile;
        }
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
      "...............".units([]),
      "...........X<..".units([Pl(T(Ninja))]),
      "..OOOOOOO..^...".units([]),
      "..OOOOOOOO>^...".units([]),
      "..OOOOOOO......".units([]),
      "...............".units([]),
    ]);
    updateUI();
  }
  
  override public function tick():Void {
    
  }
}

enum abstract Faction(Int) to Int {
  var Neutral;
  var Player;
  var Enemy;
  var Alarmed;
}

enum UnitType {
  Ninja;
  
}

enum TileSpec {
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

@:structInit
class Unit {
  public var tiles:Array<Tile> = [];
  public var faction:Faction;
  public var type:UnitType;
}

@:structInit
class Tile {
  public var x:Int;
  public var y:Int;
  public var ti:Int;
  public var present:Bool;
  public var unit:Unit;
  public var faction:Faction;
}

class MapTools {
  public static function units(s:String, u:Array<UnitSpec>):Array<TileSpec> {
    return s.split("").map((t) -> switch (t) {
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
  }
}
