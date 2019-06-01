package lib;

class ECAThread {
  public var eca:ECA;
  public var parent:ECAThread;
  public var locals:Map<String, ECAValueE> = [];
  public var position:Array<Int> = [0];
  public var suspended:Bool = false;
  public var suspendedECA:Array<lib.ECA.ECARegistered>;
  public var labels:Map<String, Array<Int>> = [];
  public var doAdvance:Bool;
  
  public function new(eca:ECA, parent:ECAThread) {
    this.eca = eca;
    this.parent = parent;
    initLabels();
    ECA.threads.push(this);
  }
  
  function initLabels():Void {
    var position = [];
    var referenced = [];
    function walk(actions:Array<ECAAction>):Void {
      for (i in 0...actions.length) switch (actions[i]) {
        case Switch(branches): position.push(i); branches.map((b) -> walk(b.a)); position.pop();
        case Label(name) if (labels.exists(name)): throw 'duplicate label $name';
        case Label(name): labels[name] = position.concat([i]);
        case Repeat if (labels.exists("-repeat")): throw "duplicate repeat";
        case Repeat: labels["-repeat"] = position.concat([i]);
        case GoTo(name): referenced.push(name);
        case _:
      }
    }
    walk(eca.actions);
    trace(referenced);
    for (r in referenced) if (!labels.exists(r)) throw 'no such label $r';
  }
  
  function getStack():Array<{?actions:Array<ECAAction>, ?action:ECAAction}> {
    var posStack:Array<{?actions:Array<ECAAction>, ?action:ECAAction}> = [{actions: eca.actions}];
    var top = posStack[0];
    var current:ECAAction = null;
    for (index in position) {
      if (top.actions != null) {
        posStack.push(top = {action: top.actions[index]});
      } else {
        posStack.push(top = {actions: switch (current) {
          case Switch(branches): branches[index].a;
          case _: throw 'invalid position: $position $current[$index]';
        }});
      }
    }
    return posStack;
  }
  
  public function terminate():Void {
    ECA.threads.remove(this);
  }
  
  public function run():Void {
    if (suspended) {
      return;
    }
    if (position.length == 0) {
      if (labels.exists("-repeat")) {
        position = labels["-repeat"].copy();
      } else {
        terminate();
        return;
      }
    }
    while (true) {
      var posStack = getStack();
      var top = posStack[posStack.length - 1];
      if (top == null || top.action == null) throw 'invalid position stack: $posStack';
      doAdvance = true;
      switch (top.action) {
        case Switch(branches):
        for (i in 0...branches.length) {
          if (branches[i].c()) {
            position.push(i);
            position.push(0);
            doAdvance = false;
            break;
          }
        }
        case GoTo(name):
        position = labels[name].copy();
        posStack = getStack();
        case Repeat | Label(_):
        case _: exec(top.action);
      }
      if (doAdvance) {
        posStack.pop();
        var work = true;
        while (work && posStack.length > 0 && position.length > 0) {
          work = false;
          if (++position[position.length - 1] >= posStack[posStack.length - 1].actions.length) {
            position.pop();
            posStack.pop();
            posStack.pop();
            work = true;
          }
        }
        if (posStack.length == 0 || position.length == 0) break;
      }
      if (suspended) break;
    }
  }
  
  public function exec(action:ECAAction):Void {
    switch (action) {
      case Func(f): f(eca, this);
      case Next(ecas):
      suspendedECA = [ for (e in ecas) ECA.registerE(e, this) ];
      suspend();
      case Wait(ticks):
      ECA.schedule(ticks, this);
      suspend();
      case WaitFor(e, c):
      suspendedECA = [ ECA.registerT(e, c, this) ];
      suspend();
      case Say(msg, from):
      trace(msg, from);
      case _: 'cannot exec $action';
    }
  }
  
  public function suspend():Void {
    suspended = true;
  }
  
  public function wakeup(?runAfter:Bool = true):Void {
    if (suspendedECA != null) {
      suspendedECA.map(ECA.unregister);
      suspendedECA = null;
    }
    suspended = false;
    if (runAfter) run();
  }
}
