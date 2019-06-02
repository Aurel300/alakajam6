package lib;

enum UIX {
  At(offX:Int, offY:Int, sub:Array<UIX>);
  AtX(offX:Int, sub:Array<UIX>);
  AtY(offY:Int, sub:Array<UIX>);
  //Hyst(target:()->{x:Float, y:Float}, ?ratio:Float, sub:Array<UIX>);
  HystX(target:()->Float, ?ratio:Float, sub:Array<UIX>);
  HystY(target:()->Float, ?ratio:Float, sub:Array<UIX>);
  If(_:()->Bool, sub:Array<UIX>);
  IfO(_:()->Bool, ?ratio:Float, sub:Array<UIX>);
  Opacity(o:Float, sub:Array<UIX>);
  HystOpacity(target:()->Float, ?ratio:Float, sub:Array<UIX>);
  Button(click:()->Void, ?state:(hover:Bool, hold:Bool)->Void, ?deadzone:Int, actor:String);
  ButtonI(click:()->Void, ?state:(hover:Bool, hold:Bool)->Void, w:Int, h:Int);
  Singleton(actor:String, ?index:Int);
  Text(txt:String, ?cls:String, w:Int, h:Int);
  TextD(txt:()->String, ?cls:()->String, w:()->Int, h:()->Int);
  Group(?id:String, sub:Array<UIX>);
  Lazy(?id:String, sub:()->Array<UIX>);
  Fill(c:Colour);
}
