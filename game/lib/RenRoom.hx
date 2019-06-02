package lib;

class Flicker {
  public var ph:Int = 0;
  public var min:Int;
  public var r:Int;
  public var cur:Int = 0;
  
  public function new(?min:Int = 60, ?r:Int = 220) {
    this.min = min;
    this.r = r;
  }
  
  public function tick():Bool {
    var active = false;
    if (ph++ >= cur) {
      active = true;
      ph = 0;
      cur = Choice.nextBool() ? 0 : min + Std.random(r);
    }
    return active;
  }
}

typedef Bubble = {
   txt:String
  ,cls:String
  ,x:Int
  ,y:Float
  ,ph:Int
  ,id:Int
};

class RenRoom extends Ren {
  static var rooms = [
    Home => new Room(Home, Colour.fromARGB32(0xFFCCC0B6), 0, 36, 464, [
       {type: Visual("bgs-home", 0)}
      ,{type: Character(Player), offY: 59}
      ,{type: Visual("bgs-home", 1)}
      ,{type: Visual("bgs-home-light", 2), offX: -30, offY: -36}
      ,{type: Visual("bgs-home-light", -2), offX: -30, offY: -36, visible: false}
    ], [
      {id: "lamp", name: "Lamp", x: 101, y: 38, w: 13, h: 8}
    ], {
      var flicker = new Flicker();
      (ren) -> {
        ren.room.layers[3].visible = !flicker.tick();
        ren.room.layers[4].visible = !ren.room.layers[3].visible;
      };
    })
  ];
  
  public var room:Room;
  
  var bubbleId = 0;
  public var bubbles:Array<Bubble> = [];
  
  public var blocked:Bool = false;
  public var interactiveHover:String;
  public var interactiveHold:String;
  public var nextInteractiveHover:String;
  public var nextInteractiveHold:String;
  public var tooltip:String = "";
  public var layerX:Array<Int>;
  public var layerY:Array<Int>;
  public var interactiveX:Array<Int>;
  public var interactiveY:Array<Int>;
  public var camX:Hyst = new Hyst(0, .98);
  public var camY:Hyst = new Hyst(0, .98);
  public var camCX:Float;
  public var camCY:Float;
  
  public function loadRoom(id:RoomName, ?playerAtX:Int):Void {
    if (!rooms.exists(id)) throw 'no such room $id';
    room = rooms[id];
    layerX = [];
    layerY = [];
    interactiveX = [];
    interactiveY = [];
    blocked = false;
    if (playerAtX != null) {
      lib.Character.chars[Player].place(playerAtX);
      camX.setTo(lib.Character.chars[Player].x, true);
    }
    camX.minValue = -20;
    camX.maxValue = room.width - 400;
    interactiveHold = interactiveHover = nextInteractiveHold = nextInteractiveHover = null;
    // TODO: reset camera
    for (i in room.interactives) {
      if (i.layer == null) i.layer = 0;
      if (i.active == null) i.active = true;
      if (i.extraSize == null) i.extraSize = 4;
    }
    ui.uix = [
       Fill(room.colour)
      ,Group("layers", [
        for (i in 0...room.layers.length) {
          UIX.If(() -> room.layers[i].visible, [HystX(() -> layerX[i], [
            HystY(() -> layerY[i], [
              switch (room.layers[i].type) {
                case Visual(id, index): UIX.Singleton(id, index);
                case Character(n): UIX.Lazy(() -> lib.Character.chars[n].ui());
                case _: throw "!";
              }
            ])
          ])]);
        }
      ])
      ,Group("interactives", [
        for (i in 0...room.interactives.length) {
          var int = room.interactives[i];
          UIX.If(() -> int.active, [HystX(() -> interactiveX[i] - int.extraSize, [
            HystY(() -> interactiveY[i] - int.extraSize, [
              ButtonI(() -> onInteract(int), function(hover, hold):Void {
                if (hover) nextInteractiveHover = int.id;
                if (hold) nextInteractiveHold = int.id;
              }, int.w + int.extraSize * 2, int.h + int.extraSize * 2)
            ])
          ])]);
        }
      ])
      ,Lazy("speech", () -> [
        for (b in bubbles) {
          UIX.Group('${b.id}', [
            At(b.x, b.y.floor(), [
               Text(b.txt, 'speech stroke ${b.cls}', 130, 40)
              ,Text(b.txt, 'speech ${b.cls}', 130, 40)
            ])
          ]);
        }
      ])
      ,At(8, 200 - 20, [
        TextD(
          () -> tooltip
          ,() -> "tooltip stroke" + (interactiveHold != null ? " hold" : (interactiveHover != null ? " hover" : ""))
          ,() -> 400
          ,() -> 20
        )
        ,TextD(
          () -> tooltip
          ,() -> "tooltip" + (interactiveHold != null ? " hold" : (interactiveHover != null ? " hover" : ""))
          ,() -> 400
          ,() -> 20
        )
      ])
    ];
    ECA.handleEvent(EnteredRoom(room.name));
  }
  
  public function sayBy(txt:String, c:Character):Void {
    say(txt, c.x, 'by-${c.name}');
  }
  
  public function say(txt:String, x:Int, cls:String):Void {
    for (b in bubbles) {
      if (b.txt == txt) return;
    }
    if (x < 10) x = 10;
    if (x > 400 - 140) {
      x = 400 - 140;
      cls += " right";
    }
    bubbles.push({
       txt: txt
      ,cls: cls
      ,x: x
      ,y: 70
      ,ph: -60 //txt.split(" ").length * -30
      ,id: bubbleId++
    });
  }
  
  function onInteract(i:RoomInteractive):Void {
    if (blocked) return;
    ECA.handleEvent(Interacted(room.name, i.id));
  }
  
  public function new() {
    ui = new UI([]);
  }
  
  override public function tick():Void {
    if (room.onTick != null) room.onTick(this);
    var top = 70.0;
    for (i in 0...bubbles.length) {
      var b = bubbles[bubbles.length - 1 - i];
      if (b.y > top) b.y--;
      top = b.y - 20;
    }
    bubbles = [ for (b in bubbles) {
      if (b.ph >= 0) b.y -= b.ph / 25;
      b.ph++;
      if (b.y < -40) continue;
      b;
    } ];
    // TODO: optimise only if camera moved?
    camX.setTo(lib.Character.chars[Player].x - 200);
    camCX = camX.tick();
    camCY = camY.tick();
    for (i in 0...room.layers.length) {
      var l = room.layers[i];
      layerX[i] = l.offX + room.offX - (l.parallaxX * camCX).floor();
      layerY[i] = l.offY + room.offY - (l.parallaxY * camCY).floor();
    }
    for (i in 0...room.interactives.length) {
      var int = room.interactives[i];
      interactiveX[i] = layerX[int.layer] + int.x;
      interactiveY[i] = layerY[int.layer] + int.y;
    }
    interactiveHover = nextInteractiveHover;
    interactiveHold = nextInteractiveHold;
    if (interactiveHold != null) {
      tooltip = room.interactivesMap[interactiveHold].name;
    } else if (interactiveHover != null) {
      tooltip = room.interactivesMap[interactiveHover].name;
    }
    if (blocked) {
      interactiveHover = interactiveHold = null;
    }
    nextInteractiveHover = nextInteractiveHold = null;
  }
}

class Room {
  public var name:RoomName;
  public var colour:Colour;
  public var offX:Int;
  public var offY:Int;
  public var width:Int;
  public var layers:Array<RoomLayer>;
  public var interactives:Array<RoomInteractive>;
  public var interactivesMap:Map<String, RoomInteractive>;
  public var onTick:(RenRoom)->Void;
  
  public function new(name:RoomName, colour:Colour, offX:Int, offY:Int, width:Int, layers:Array<RoomLayer>, interactives:Array<RoomInteractive>, ?onTick:(RenRoom)->Void) {
    this.name = name;
    this.colour = colour;
    this.offX = offX;
    this.offY = offY;
    this.width = width;
    this.layers = layers;
    this.interactives = interactives;
    interactivesMap = [ for (i in interactives) i.id => i ];
    this.onTick = onTick;
  }
}

@:structInit
class RoomLayer {
  public var type:RoomLayerType;
  public var offX:Int = 0;
  public var offY:Int = 0;
  public var parallaxX:Float = 1;
  public var parallaxY:Float = 1;
  public var visible:Bool = true;
}

enum RoomLayerType {
  Visual(_:String, ?index:Int);
  Character(_:CharName);
}

typedef RoomInteractive = {
   id:String
  ,name:String
  ,?layer:Int
  ,?active:Bool
  ,x:Int
  ,y:Int
  ,w:Int
  ,h:Int
  ,?maxDist:Int
  ,?extraSize:Int
};
