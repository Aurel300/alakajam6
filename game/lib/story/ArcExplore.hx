package lib.story;

class ArcExplore {
  public static function init():Void {
    // home
    E.whenR(EnteredRoom(Home), true, [
      Say("what a dump")
    ]);
    E.whenOR(Interacted(Home, "lamp"), true, [
      Say("what a lamp")
      ,Repeat
      ,E.waitFor(Interacted(Home, "lamp"), true)
      ,Say("fancy")
    ]);
  }
}
