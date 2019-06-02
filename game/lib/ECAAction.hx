package lib;

enum ECAAction {
  Func(_:(ECA, ECAThread)->Void);
  Next(_:Array<ECA>, ?suspend:Bool);
  Switch(_:Array<{c:()->Bool, a:Array<ECAAction>}>);
  Wait(_:Int);
  WaitFor(_:(ECAEvent)->Bool, c:()->Bool);
  
  Label(_:String);
  Repeat;
  GoTo(_:String);
  
  BlockRoom(?block:Bool);
  Say(msg:String, ?from:CharName);
}
