import lib.*;
import jam.*;

class Main {
  public static function main():Void {
    var game = new Game([
       "load" => new GSLoad()
      ,"game" => new GSTest()
    ], {
       window: {width: 400, height: 300, scale: 2}
      ,assets: {
        bitmaps: [
           {alias: "character", url: "png/character.png"}
          ,{alias: "metro", url: "png/metro.png"}
        ]
      }
    });
    game.state("load");
  }
}
