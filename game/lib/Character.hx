package lib;

class Character {
  public static var chars = [
    Player => new Character(Player, "character-dbg", [
       "idle" => "0"
      ,"walking" => "len:4 x:0 1 x:3 2 x:0 3 bail:1 x:6 4 bail:0 x:0 5 x:1 6 x:3 7 x:6 8"
    ])
  ];
  
  public var name:CharName;
  public var actor:String;
  public var animations:Map<String, Animation>;
  public var animation:Animation;
  public var frame:Int = 0;
  public var ph:Int = 0;
  public var x:Int = 0;
  public var facing:Bool = true; // true = right
  public var targetX:Int = 0;
  public var targetFacing:Bool = true;
  public var targetThen:()->Void;
  
  public function new(name:CharName, actor:String, specs:Map<String, String>) {
    this.name = name;
    this.actor = actor;
    animations = [ for (name => spec in specs) name => {
      var next = "idle";
      var len = 0;
      var offX = 0;
      var bail = false;
      var frames = [ for (fspec in spec.split(" ")) {
        if (fspec.startsWith("len:")) {  len = Std.parseInt(fspec.substr(4)); continue; }
        if (fspec.startsWith("x:")) {    offX = Std.parseInt(fspec.substr(2)); continue; }
        if (fspec.startsWith("bail:")) { bail = fspec.substr(5) == "1"; continue; }
        {
           index: Std.parseInt(fspec)
          ,offX: offX
          ,len: len
          ,bail: bail
        }
      } ];
      {
         id: name
        ,frames: frames
        ,next: next
      };
    } ];
    animate("idle");
  }
  
  public function walk(toX:Int, ?facing:Bool, ?then:()->Void):Void {
    targetX = toX;
    targetFacing = facing != null ? facing : (targetX == x ? facing : targetX > x);
    targetThen = then;
  }
  
  function animate(id:String):Void {
    if (!animations.exists(id)) throw 'no such animation $id';
    animation = animations[id];
    ph = 0;
    frame = 0;
  }
  
  public function place(atX:Int):Void {
    x = atX;
    animate("idle");
  }
  
  public function ui():Array<UIX> {
    var xdist = targetX - x;
    var close = xdist.abs() <= 10;
    if (ph == 0) {
      if (animation.frames[frame].offX != 0) x += animation.frames[frame].offX * (facing ? 1 : -1);
      if (animation.frames[frame].bail && close) animate("idle");
    }
    var ret = [UIX.AtX(x - 20, [Singleton(facing ? actor : '$actor-fh', animation.frames[frame].index)])];
    if (animation.id != "idle") {
      if (animation.id != "idle") {
        ph++;
        if (ph >= animation.frames[frame].len) {
          ph = 0;
          frame++;
          if (frame >= animation.frames.length) animate(animation.next);
        }
      }
    }
    if (animation.id == "idle") {
      if (!close) {
        facing = xdist > 0;
        animate("walking");
      } else if (facing != targetFacing) {
        facing = targetFacing;
      } else if (targetThen != null) {
        targetThen();
        targetThen = null;
      }
    }
    return ret;
  }
}

typedef Animation = {
   id:String
  ,frames:Array<AFrame>
  ,next:String
};

typedef AFrame = {
   index:Int
  ,offX:Int
  ,len:Int
  ,bail:Bool
};
