package lib;

typedef ECARegistered = {event:(ECAEvent)->Bool, cond:()->Bool, ?eca:ECA, ?thread:ECAThread};

class ECA {
  public static var globals:Map<String, ECAValueE> = [];
  public static var thread:ECAThread;
  public static var tickCounter:Int = 0;
  
  public static var wakeupTicks:Map<Int, Array<ECAThread>> = [];
  public static var registered:Array<ECARegistered> = [];
  public static var threads:Array<ECAThread> = [];
  
  public static function v(name:String, ?def:ECAValueE):ECAValue {
    if (thread.locals.exists(name)) return thread.locals[name];
    if (globals.exists(name)) return globals[name];
    if (def != null) return def;
    throw 'no such value: $name';
  }
  
  public static function schedule(ticks:Int, thread:ECAThread):Void {
    var at = tickCounter + ticks;
    if (!wakeupTicks.exists(at)) wakeupTicks = [];
    wakeupTicks[at].push(thread);
  }
  
  public static function registerE(eca:ECA, ?thread:ECAThread):ECARegistered {
    var ret = {event: eca.eventFunc, cond: eca.condFunc, eca: eca, thread: thread};
    registered.push(ret);
    return ret;
  }
  
  public static function registerT(event:(ECAEvent)->Bool, cond:()->Bool, ?thread:ECAThread):ECARegistered {
    var ret = {event: event, cond: cond, eca: null, thread: thread};
    registered.push(ret);
    return ret;
  }
  
  public static function unregister(reg:ECARegistered):Void {
    registered.remove(reg);
  }
  
  public static function tick():Void {
    tickCounter++;
    if (wakeupTicks.exists(tickCounter)) {
      for (thread in wakeupTicks[tickCounter]) {
        thread.wakeup();
      }
      wakeupTicks.remove(tickCounter);
    }
  }
  
  public static function handleEvent(e:ECAEvent):Void {
    for (r in registered) {
      if (!r.event(e) || !r.cond()) continue;
      if (r.eca != null) r.eca.run(r.thread);
      if (r.thread != null) r.thread.wakeup();
    }
  }
  
  public var eventFunc:(ECAEvent)->Bool;
  public var condFunc:()->Bool;
  public var actions:Array<ECAAction>;
  public var selfRegister:ECARegistered;
  public var doOnce = false;
  
  public function new(eventFunc:(ECAEvent)->Bool, condFunc:()->Bool, actions:Array<ECAAction>) {
    this.eventFunc = eventFunc;
    this.condFunc = condFunc;
    this.actions = actions;
  }
  
  public function run(?parent:ECAThread):ECAThread {
    if (doOnce) unregister(selfRegister);
    return new ECAThread(this, parent);
  }
  
  public function once():ECA {
    doOnce = true;
    return this;
  }
  
  public function register():ECA {
    selfRegister = registerE(this);
    return this;
  }
}
