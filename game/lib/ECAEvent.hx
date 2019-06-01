package lib;

enum ECAEvent {
  Tick;
  TickMod(n:Int);
  EnteredRoom(n:RoomName);
  LeftRoom(n:RoomName);
  GotItem(n:ItemName);
  LostItem(n:ItemName);
  TalkedTo(n:CharName);
  Interacted(n:RoomName, i:String);
}
