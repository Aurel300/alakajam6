package lib.story;

class ArcExplore {
  public static function init():Void {
    // home
    E.whenOR(EnteredRoom(Home), true, [
       BlockRoom()
      ,WalkTo(30)
      ,Wait(60)
      ,Say("What a dump.")
      ,Wait(40)
      ,Say("Home sweet home...")
      ,Wait(40)
      ,BlockRoom(false)
    ]);
    E.whenOR(Interacted(Home, "lamp"), true, [
      Say("what a lamp")
      ,Repeat
      ,E.waitFor(Interacted(Home, "lamp"), true)
      ,Say("fancy")
    ]);
  }
}
