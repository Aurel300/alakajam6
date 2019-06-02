package lib.story;

class ArcBar {
  public static function init():Void {
    var sketchy = false;
    var sketchy2 = false;
    E.whenOR(EnteredRoom(Bar)/*Interacted(Bar, "bobbard")*/, true, [
      /* Say("Hey, Bob.")
      ,Say("What's up, Cy?", Bobbard)
      ,Say("I think I'm ready to take on AIC0.")
      ,Say("Haha, good one.", Bobbard)
      ,Wait(30)
      ,Face(false)
      ,Wait(80)
      ,WalkTo(380)
      ,Say("I'm serious.")
      ,Wait(40)
      ,Say("You're gonna <em>die</em>, man.", Bobbard)
      ,Wait(40)
      ,Say("Many have tried.", Bobbard)
      ,Say("Guess how many live to tell the tale?", Bobbard)
      ,Wait(30)
      ,Face(false)
      ,Wait(40)
      ,Say("That's right, zero.", Bobbard)
      ,Face(true)
      ,Say("Come on, Bob.")
      ,Say("You know I'm good.")
      ,Say("I just need better biosoft.")
      ,Wait(40)
      ,Say("You know people...")
      ,Say("<em>Expensive</em> people, Cy.", Bobbard)
      ,Say("I'll get the money.")
      ,Wait(80)
      ,Say("Just ...", Bobbard)
      ,Wait(40)
      ,Say("Don't tell why you need the soft.", Bobbard)
      ,Say("They'll think you blew a fuse.", Bobbard)
      ,Say("Yeah, yeah ...")
      ,Say("So who should I talk to?")
      ,Say("You'll need 800 creds, Cy.", Bobbard)
      ,Say("Come back when you have them.", Bobbard)
      
      ,*/Label("need-cash")
      ,Next([
        E.when(Interacted(Bar, "bobbard"), Scenario.creds < 800, [
          WalkTo(100)
          ,Say("You got the cash yet, Cy?", Bobbard)
          ,Say("Remember, 800 creds.", Bobbard)
          ,Say("Maybe deck some systems?", Bobbard)
        ])
        ,E.when(Interacted(Bar, "bobbard"), Scenario.creds >= 800, [
           Say("I got the cash.")
          ,Say("Alright...", Bobbard)
          ,Wait(60)
          ,Say("Talk to the sketchy looking guy behind the bar.", Bobbard)
          ,Say("'sketchy looking guy'?")
          ,Say("You'll know him when you see him.", Bobbard)
          ,Say("Say I sent you.", Bobbard)
          ,Say("Thanks, Bob.")
          ,E.f(sketchy = true)
        ])
      ])
      ,Switch([
        {c: () -> !sketchy, a: [GoTo("need-cash")]}
      ])
      
      ,Label("sketchy-talk")
      ,Next([
        E.when(Interacted(Bar, "bobbard"), !sketchy2, [
           Say("Talked to Seno yet?", Bobbard)
        ])
        ,E.when(Interacted(Bar, "bobbard"), sketchy2, [
           Say("I hope you know what you're doing.", Bobbard)
          ,Say("Well...")
        ])
      ])
      ,Switch([
        {c: () -> !sketchy2, a: [GoTo("sketchy-talk")]}
      ])
    ]);
    E.whenR(Interacted(BarBack, "seno"), !sketchy, [
      Random([
         [Say("Piss off.", Seno)]
        ,[Say("What are you lookin' at?", Seno)]
        ,[Say("Get lost.", Seno)]
      ])
    ]);
    E.whenOR(Interacted(BarBack, "seno"), sketchy, [
       Say("Piss off.", Seno)
      ,Say("Bob sent me.")
      ,Say("...", Seno)
      ,Wait(90)
      ,Say("He said you have some good biosoft.")
      ,Say("...", Seno)
      ,Wait(90)
      ,Say("You got the creds?", Seno)
      ,Say("800, all yours.")
      ,Say("Here.", Seno)
      ,Wait(60)
      ,Say("Don't tell a soul.", Seno)
      ,E.f(sketchy2 = true)
      ,Label("done")
      ,E.waitFor(Interacted(BarBack, "seno"), true)
      ,Say("I got nothing else for you.", Seno)
      ,GoTo("done")
    ]);
  }
}
