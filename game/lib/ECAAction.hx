package lib;

enum ECAAction {
  Func(_:(ECA, ECAThread)->Void);
  Next(_:Array<ECA>, ?wait:Bool, ?complete:Bool);
  Switch(_:Array<{c:()->Bool, a:Array<ECAAction>}>);
  Random(_:Array<Array<ECAAction>>);
  Wait(_:Int);
  WaitFor(_:(ECAEvent)->Bool, c:()->Bool);
  
  Label(_:String);
  Repeat;
  GoTo(_:String);
  
  BlockRoom(?block:Bool);
  WalkTo(x:Int, ?c:CharName, ?suspend:Bool);
  Face(right:Bool, ?c:CharName);
  Say(msg:String, ?from:CharName, ?suspend:Bool);
}
