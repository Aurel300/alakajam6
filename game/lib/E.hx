package lib;

import haxe.macro.Expr;

class E {
  public static macro function whenOR(event:Expr, cond:Expr, actions:Expr):Expr {
    return macro (new ECA(
         e -> e.match($event)
        ,() -> $cond
        ,$actions
      )).once().register();
  }
  
  public static macro function whenR(event:Expr, cond:Expr, actions:Expr):Expr {
    return macro (new ECA(
         e -> e.match($event)
        ,() -> $cond
        ,$actions
      )).register();
  }
  
  public static macro function when(event:Expr, cond:Expr, actions:Expr):Expr {
    return macro new ECA(
         e -> e.match($event)
        ,() -> $cond
        ,$actions
      );
  }
  
  public static macro function waitFor(event:Expr, cond:Expr):Expr {
    return macro ECAAction.WaitFor(e -> e.match($event), () -> $cond);
  }
  
  public static macro function f(expr:Expr):Expr {
    return macro ECAAction.Func((eca, thread) -> $expr);
  }
}
