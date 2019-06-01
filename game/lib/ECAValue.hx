package lib;

abstract ECAValue(ECAValueE) from ECAValueE {
  public var raw(get, never):ECAValueE;
  private inline function get_raw():ECAValueE return this;
  
  @:op(a < b) public function lt(other:ECAValue):Bool return switch [this, other.raw] {
    case [VFloat(a), VFloat(b)]: a < b;
    case [VFloat(a), VInt(b)]: a < b;
    case [VInt(a), VFloat(b)]: a < b;
    case [VInt(a), VInt(b)]: a < b;
    case _: throw 'invalid operation: $this < $other';
  }
  @:op(a > b) public function gt(other:ECAValue):Bool return switch [this, other.raw] {
    case [VFloat(a), VFloat(b)]: a > b;
    case [VFloat(a), VInt(b)]: a > b;
    case [VInt(a), VFloat(b)]: a > b;
    case [VInt(a), VInt(b)]: a > b;
    case _: throw 'invalid operation: $this > $other';
  }
  @:op(a <= b) public function leq(other:ECAValue):Bool return switch [this, other.raw] {
    case [VFloat(a), VFloat(b)]: a <= b;
    case [VFloat(a), VInt(b)]: a <= b;
    case [VInt(a), VFloat(b)]: a <= b;
    case [VInt(a), VInt(b)]: a <= b;
    case _: throw 'invalid operation: $this <= $other';
  }
  @:op(a >= b) public function geq(other:ECAValue):Bool return switch [this, other.raw] {
    case [VFloat(a), VFloat(b)]: a >= b;
    case [VFloat(a), VInt(b)]: a >= b;
    case [VInt(a), VFloat(b)]: a >= b;
    case [VInt(a), VInt(b)]: a >= b;
    case _: throw 'invalid operation: $this >= $other';
  }
}
