![](topbar.jpg)

[Table of Contents](toc.htm) \| [Actions](action.htm) \> Action
Reference  
[*Prev:* Debugging Commands](debug.htm)     *Next:* [Actors](actor.htm)
   

# Action Reference

## How To Use This Reference

This reference section is designed to fulfil two purposes: (1) to make
it easy for you to find the name of the Action you want if you only know
the grammar (the form of the command) that leads to it (e.g. KILL FRED);
and (2) to provide basic information to help with the customizing of
action responses (for fuller information you may need to consult the
library source code).

If you know the name of the action you're looking for, you can go
straight to the [Action List](#actionlist) below to find it (and follow
the directions there). If you don't, you can use the [Grammar
List](#grammar) immediately below to find it. For example, to find what
action would be triggered by KILL FRED, click on K in the list of
letters at the start of the Grammar List, and find the line that reads
'**kill** something'. At the end of the line you'll see the hyperlinked
action name Attack. Clicking on the link will take you to further
information about the Attack action in the Action List.

## Grammar List

[A](#A) [B](#B) [C](#C) [D](#D) [E](#E) [F](#F) [G](#G) [H](#H) [I](#I)
[J](#J) [K](#K) [L](#L) [M](#M) [N](#N) [O](#O) [P](#P) [Q](#Q) [R](#R)
[S](#S) [T](#T) [U](#U) [V](#V) [W](#W) [X](#X) [Y](#Y) [Z](#Z)

### A

**a** topic [AskAboutImplicit](#AskAboutImplicit)  
**a** someone **about** topic [AskAbout](#AskAbout)  
**a** someone **for** topic [AskFor](#AskFor)  
**a** someone **how/if/when/where/whether/who** topic
[QueryAbout](#QueryAbout)  
**a for** topic [AskForImplicit](#AskForImplicit)  
**a for** topic **from** someone [AskFor](#AskFor)  
**a how/if/what/when/where/whether/who** [QueryVague](#QueryVague)  
**a how/if/when/where/whether/who** topic [Query](#Query)  
**about** [About](#About)  
**activate** something [SwitchOn](#SwitchOn)  
**aft** [Travel](#Travel)  
**again** [Again](#Again)  
**affirmative** [SayYes](#SayYes)  
**are** topic [Query](#Query)  
**ask** topic [AskAboutImplicit](#AskAboutImplicit)  
**ask** someone **about** topic [AskAbout](#AskAbout)  
**ask** someone **for** topic [AskFor](#AskFor)  
**ask** someone **how/if/when/where/whether/who** topic
[QueryAbout](#QueryAbout)  
**ask about** topic [AskAboutImplicit](#AskAboutImplicit)  
**ask for** topic [AskForImplicit](#AskForImplicit)  
**ask for** topic **from** someone [AskFor](#AskFor)  
**ask how/if/what/when/where/whether/who** [QueryVague](#QueryVague)  
**ask how/if/what/when/where/whether/who** topic [Query](#Query)  
**attach** something [Attach](#Attach)  
**attach** something **to** something [AttachTo](#AttachTo)  
**attack** something [Attack](#Attack)  
**attack** something **with** something [AttackWith](#AttackWith)  

### B

**back** [GoBack](#GoBack)  
**blow** something **out** [Extinguish](#Extinguish)  
**blow out** something [Extinguish](#Extinguish)  
**board** something [Board](#Board)  
**break** something [Break](#Break)  
**brief** [Brief](#Brief)  
**bye** [Goodbye](#Goodbye)  
**buckle \[up\]** something [Fasten](#Fasten)  
**buckle** something **to** something [FastenTo](#FastenTo)  
**burn** something [Burn](#Burn)  
**burn** something **with** something [BurnWith](#BurnWith)  

### C

**c** [Continue](#GoTo)  
**can** topic [Query](#Query)  
**clean** something [Clean](#Clean)  
**clean** something **with** something [CleanWith](#CleanWith)  
**climb** something [Climb](#Climb)  
**climb down** [ClimbDownVague](#ClimbDownVague)  
**climb down** something [ClimbDown](#ClimbDown)  
**climb in/inside/in to/into** something [Enter](#Enter)  
**climb on/on to/onto** something [Board](#Board)  
**climb out** [GetOut](#GetOff)  
**climb out of** something [GetOutOf](#GetOutOf)  
**climb up** [ClimbUpVague](#ClimbUpVague)  
**climb up** something [ClimbUp](#ClimbUp)  
**close** something [Close](#Close)  
**cogitate** [Think](#Think)  
**cogitate about** topic [ThinkAbout](#ThinkAbout)  
**consult** something **about/on** topic [ConsultAbout](#ConsultAbout)  
**connect** something [Attach](#Attach)  
**connect** something **to** something [AttachTo](#AttachTo)  
**consume** something [Eat](#Eat)  
**continue** [Continue](#GoTo)  
**could** topic [Query](#Query)  
**credits** [Credits](#Credits)  

### D

**d** [Travel](#Travel)  
**debug** [DebugI](#DebugI)  
**debug actions/doers/messages/spelling/status/stop/off**
[Debug](#Debug)  
**deactivate** something [SwitchOff](#SwitchOff)  
**destroy** something [Break](#Break)  
**detach** something [Detach](#Detach)  
**detach** something **from** something [DetachFrom](#DetachFrom)  
**dig** something [Dig](#Dig)  
**dig** something **with** something [DigWith](#DigWith)  
**disconnect** something [Detach](#Detach)  
**disconnect** something **from** something [DetachFrom](#DetachFrom)  
**disembark** [GetOut](#GetOff)  
**do/does** topic [Query](#Query)  
**doff** something [Doff](#Doff)  
**don** something [Wear](#Wear)  
**douse** something [Extinguish](#Extinguish)  
**down** [Travel](#Travel)  
**drag** something direction [PushTravelDir](#PushTravelDir)  
**drag** something **down** something
[PushTravelClimbDown](#PushTravelClimbDown)  
**drag** something **in/in to/into** something
[PushTravelEnter](#PushTravelEnter)  
**drag** something **out/out** of something
[PushTravelGetOutOf](#PushTravelGetOutOf)  
**drag** something **through/thru something**
[PushTravelThrough](#PushTravelThrough)  
**drag** something **up** something
[PushTravelClimbUp](#PushTravelClimbUp)  
**drink** something [Drink](#Drink)  
**drop** something [Drop](#Drop)  
**drop** something **on/onto/on to/upon** something [PutOn](#PutOn)  

### E

**e** [Travel](#Travel)  
**east** [Travel](#Travel)  
**eat** something [Eat](#Eat)  
**enter** [GoIn](#GoIn)  
**enter** something [Enter](#Enter)  
**enter** literal **in/in to/into/on/with** something
[EnterOn](#EnterOn)  
**eval** literal [Evaluate](#Evaluate)  
**examine** something [Examine](#Examine)  
**extinguish** something [Extinguish](#Extinguish)  
**exit** [GoOut](#GoOut)  
**exit** something [GetOutOf](#GetOutOf)  
**exit colo\[u\]r off/on/blue/green/red/yellow**
[ExitsColour](#ExitsColour)  
**exits** [Exits](#Exits)  
**exits all** [ExitsMode](#ExitsMode)  
**exits colo\[u\]r off/on/blue/green/red/yellow**
[ExitsColour](#ExitsColour)  
**exits look** [ExitsMode](#ExitsMode)  
**exits none** [ExitsMode](#ExitsMode)  
**exits off/on** [ExitsMode](#ExitsMode)  
**exits status/status line/statusline** [ExitsMode](#ExitsMode)  

### F

**f** [Travel](#Travel)  
**fasten** something [Fasten](#Fasten)  
**fasten** something **to** something [FastenTo](#FastenTo)  
**feel** something [Feel](#Feel)  
**fiat lux** [FiatLux](#FiatLux)  
**find** topic [ConsultWhatAbout](#ConsultWhatAbout)  
**find** topic **in/on** something [ConsultAbout](#ConsultAbout)  
**flip** something [Flip](#Flip)  
**follow** something [Follow](#Follow)  
**fore** [Travel](#Travel)  
**full/full score/fullscore** [FullScore](#FullScore)  

### G

**g** [Again](#Again)  
**get** something [Take](#Take)  
**get** something **from/out of/off/off of** something
[TakeFrom](#TakeFrom)  
**get down** [GetOut](#GetOff)  
**get down from** something [GetOff](#GetOff)  
**get in/inside/in to/into** something [Enter](#Enter)  
**get off** [GetOut](#GetOff)  
**get off/off of** something [GetOff](#GetOff)  
**get on/on to/onto** something [Board](#Board)  
**get out** [GetOut](#GetOff)  
**get out of** something [GetOutOf](#GetOutOf)  
**get up** [Stand](#Stand)  
**give** something [GiveToImplicit](#GiveToImplicit)  
**give** someone something [GiveTo](#GiveTo)  
**give** something **to** someone [GiveTo](#GiveTo)  
**gn** something [GoNear](#GoNear)  
**goodbye/good-bye/good bye** [Goodbye](#Goodbye)  
**go** [VagueTravel](#VagueTravel)  
**go** direction [Travel](#Travel)  
**go back** [GoBack](#GoBack)  
**go down** [ClimbDownVague](#ClimbDownVague)  
**go down** something [ClimbDown](#ClimbDown)  
**go in/inside/in to/into** something [Enter](#Enter)  
**go near** something [GoNear](#GoNear)  
**go through/thru** something [GoThrough](#GoThrough)  
**go to\|to the** direction [Travel](#Travel)  
**go to** somewhere [GoTo](#GoTo)  
**go up** [ClimbUpVague](#ClimbUpVague)  
**go up** something [ClimbUp](#ClimbUp)  
**gonear** something [GoNear](#GoNear)  
**greet** someone [TalkTo](#TalkTo)  

### H

**hallo** [Hello](#Hello)  
**have/has** topic [Query](#Query)  
**hello** [Hello](#Hello)  
**hi** [Hello](#Hello)  
**hit** something [Attack](#Attack)  
**hit** something **with** something [AttackWith](#AttackWith)  
**hint** [Hints](#Hints)  
**hints** [Hints](#Hints)  
**hints off** [HintsOff](#HintsOff)  
**holler** [Yell](#Yell)  
**how** topic [Query](#Query)  

### I

**i** [Inventory](#Inventory)  
**if** topic [Query](#Query)  
**ignite** something [Burn](#Burn)  
**ignite** something **with** something [BurnWith](#BurnWith)  
**imbibe** something [Drink](#Drink)  
**in** [Travel](#Travel)  
**insert** something **in/into/in to/inside/inside of** something
[PutIn](#PutIn)  
**inspect** something [Examine](#Examine)  
**inv** [Inventory](#Inventory)  
**inventory** [Inventory](#Inventory)  
**is** topic [Query](#Query)  

### J

**jump** [Jump](#Jump)  
**jump** something [JumpOver](#JumpOver)  
**jump off** [JumpOffIntransitive](#JumpOffIntransitive)  
**jump off** something [JumpOff](#JumpOff)  
**jump over** something [JumpOver](#JumpOver)  

### K

**kick** something [Attack](#Attack)  
**kill** something [Attack](#Attack)  
**kill** something **with** something [AttackWith](#AttackWith)  
**kiss** something [Kiss](#Kiss)  

### L

**l** [Look](#Look)  
**l** something [Examine](#Examine)  
**l** topic **up** [ConsultWhatAbout](#ConsultWhatAbout)  
**l** topic **up in/on** something [ConsultAbout](#ConsultAbout)  
**l around** [Look](#Look)  
**l at** something [Examine](#Examine)  
**l behind** something [LookBehind](#LookBehind)  
**l for** topic [ConsultWhatAbout](#ConsultWhatAbout)  
**l for** topic **in/on** something [ConsultAbout](#ConsultAbout)  
**l in/inside** something [LookIn](#LookIn)  
**l tests** (/fully) [ListTests](#ListTests)  
**l through/thru** something [LookThrough](#LookThrough)  
**l under** something [LookUnder](#LookUnder)  
**l up** topic [ConsultWhatAbout](#ConsultWhatAbout)  
**l up** topic **in/on** something [ConsultAbout](#ConsultAbout)  
**leave** [GoOut](#GoOut)  
**leave** something [GetOutOf](#GetOutOf)  
**let there be light** [FiatLux](#FiatLux)  
**lie down** [Lie](#Lie)  
**lie down in** something [LieIn](#LieIn)  
**lie down on** something [LieOn](#LieOn)  
**lie in** something [LieIn](#LieIn)  
**lie on** something [LieOn](#LieOn)  
**light** something [Light](#Light)  
**light** something **with** something [BurnWith](#BurnWith)  
**list tests** (/fully) [ListTests](#ListTests)  
**listen** [Listen](#Listen)  
**listen to** something [ListenTo](#ListenTo)  
**lock** something [Lock](#Lock)  
**lock** something **with** something [LockWith](#LockWith)  
**look** [Look](#Look)  
**look** something [Examine](#Examine)  
**look** topic **up** [ConsultWhatAbout](#ConsultWhatAbout)  
**look** topic **up in/on** something [ConsultAbout](#ConsultAbout)  
**look around** [Look](#Look)  
**look at** something [Examine](#Examine)  
**look behind** something [LookBehind](#LookBehind)  
**look for** topic [ConsultWhatAbout](#ConsultWhatAbout)  
**look for** topic **in/on** something [ConsultAbout](#ConsultAbout)  
**look in/inside** something [LookIn](#LookIn)  
**look through/thru** something [LookThrough](#LookThrough)  
**look under** something [LookUnder](#LookUnder)  
**look up** topic [ConsultWhatAbout](#ConsultWhatAbout)  
**look up** topic **in/on** something [ConsultAbout](#ConsultAbout)  

### M

**move** something [Move](#Move)  
**move** something direction [PushTravelDir](#PushTravelDir)  
**move** something **down** something
[PushTravelClimbDown](#PushTravelClimbDown)  
**move** something **in/in to/into** something
[PushTravelEnter](#PushTravelEnter)  
**move** something **out/out** of something
[PushTravelGetOutOf](#PushTravelGetOutOf)  
**move** something **to/under** something [MoveTo](#MoveTo)  
**move** something **through/thru something**
[PushTravelThrough](#PushTravelThrough)  
**move** something **up** something
[PushTravelClimbUp](#PushTravelClimbUp)  
**move** something **with** something [MoveWith](#MoveWith)  

### N

**n** [Travel](#Travel)  
**ne** [Travel](#Travel)  
**negative** [SayNo](#SayNo)  
**no** [No](#No)  
**north** [Travel](#Travel)  
**northeast** [Travel](#Travel)  
**notify** [Notify](#Notify)  
**notify off** [NotifyOff](#NotifyOff)  
**notify on** [NotifyOn](#NotifyOn)  

### O

**offer** something [GiveToImplicit](#GiveToImplicit)  
**offer** someone something [GiveTo](#GiveTo)  
**offer** something **to** someone [GiveTo](#GiveTo)  
**open** something [Open](#Open)  
**out** [Travel](#Travel)  
**out of** something [GetOutOf](#GetOutOf)  

### P

**p** [Travel](#Travel)  
**peer through/thru** something [LookThrough](#LookThough)  
**pick** something **up** [Take](#Take)  
**pick up** something [Take](#Take)  
**place** something **behind** something [PutBehind](#PutBehind)  
**place** something **in/into/in to/inside/inside of** something
[PutIn](#PutIn)  
**place** something **on/onto/on to/upon** something [PutOn](#PutOn)  
**place** something **under** something [PutUnder](#PutUnder)  
**plug** something **in** [PlugIn](#PlugIn)  
**plug** something **in/in to/into** something [PlugInto](#PlugInto)  
**plug in** something [PlugIn](#PlugIn)  
**pn** something [Purloin](#Purloin)  
**ponder** [Think](#Think)  
**ponder about** topic [ThinkAbout](#ThinkAbout)  
**port** [Travel](#Travel)  
**pour** something [Pour](#Pour)  
**pour** something **in/in to/into** something [PourInto](#PourInto)  
**pour** something **on/on to/onto** something [PourOnto](#PourOnto)  
**press** something [Push](#Push)  
**pull** something [Pull](#Pull)  
**pull** something direction [PushTravelDir](#PushTravelDir)  
**pull** something **down** something
[PushTravelClimbDown](#PushTravelClimbDown)  
**pull** something **in/in to/into** something
[PushTravelEnter](#PushTravelEnter)  
**pull** something **out/out** of something
[PushTravelGetOutOf](#PushTravelGetOutOf)  
**pull** something **through/thru something**
[PushTravelThrough](#PushTravelThrough)  
**pull** something **up** something
[PushTravelClimbUp](#PushTravelClimbUp)  
**punch** something [Attack](#Attack)  
**purloin** something [Purloin](#Purloin)  
**push** something [Push](#Push)  
**push** something direction [PushTravelDir](#PushTravelDir)  
**push** something **down** something
[PushTravelClimbDown](#PushTravelClimbDown)  
**push** something **in/in to/into** something
[PushTravelEnter](#PushTravelEnter)  
**push** something **out/out** of something
[PushTravelGetOutOf](#PushTravelGetOutOf)  
**push** something **to/under** something [MoveTo](#MoveTo)  
**push** something **through/thru something**
[PushTravelThrough](#PushTravelThrough)  
**push** something **up** something
[PushTravelClimbUp](#PushTravelClimbUp)  
**put** something **down** [Drop](#Drop)  
**put** something **behind** something [PutBehind](#PutBehind)  
**put** something **in/into/in to/inside/inside of** something
[PutIn](#PutIn)  
**put** something **on** [Wear](#Wear)  
**put** something **on/onto/on to/upon** something [PutOn](#PutOn)  
**put** something **out** [Extinguish](#Extinguish)  
**put** something **under** something [PutUnder](#PutUnder)  
**put down** something [Drop](#Drop)  
**put on** something [Wear](#Wear)  
**put out** something [Extinguish](#Extinguish)  

### Q

**q** [Quit](#Quit)  
**quaff** something [Drink](#Drink)  
**quit** [Quit](#Quit)  

### R

**read** something [Read](#Read)  
**read about** topic [ConsultWhatAbout](#ConsultWhatAbout)  
**read about** topic **in/on** something [ConsultAbout](#ConsultAbout)  
**record** \[filename\] [RecordOn](#RecordOn)  
**record events** \[filename\] [RecordEvents](#RecordEvents)  
**record events on** [RecordEvents](#RecordOn)  
**record off** [RecordOff](#RecordOff)  
**record on** [RecordOn](#RecordOn)  
**remove** something [Remove](#Remove)  
**remove** something **from** something [TakeFrom](#TakeFrom)  
**replay** \[filename\] [Replay](#Replay)  
**replay nonstop/quiet** \[filename\] [Replay](#Replay)  
**restart** [Restart](#Restart)  
**restore** \[filename\] [Restore](#Restore)  
**return** [GoBack](#GoBack)  
**rotate** something [Turn](#Turn)  
**rotate** something **to** literal [TurnTo](#TurnTo)  
**rotate** something **with** something [TurnWith](#TurnWith)  
**rq** \[filename\] [Replay](#Replay)  
**ruin** something [Break](#Break)  
**run** [VagueTravel](#VagueTravel)  
**run** direction [Travel](#Travel)  

### S

**s** [Travel](#Travel)  
**save** \[filename\] [Save](#Save)  
**say** topic [Say](#Say)  
**say** topic **to** someone [SayTo](#SayTo)  
**say bye/goodbye/good-bye/good bye** [Goodbye](#Goodbye)  
**say hallo/hello/hi** [Hello](#Hello)  
**say hello to** someone [TalkTo](#TalkTo)  
**say no** [SayNo](#SayNo)  
**say that** topic [Say](#Say)  
**say that** topic **to** someone [SayTo](#SayTo)  
**say yes** [SayYes](#SayYes)  
**sb** [Travel](#Travel)  
**screw** something [Screw](#Screw)  
**screw** something **with** something [ScrewWith](#ScrewWith)  
**score** [Score](#Score)  
**scream** [Yell](#Yell)  
**script** \[filename\] [ScriptOn](#ScriptOn)  
**script off** [ScriptOff](#ScriptOff)  
**script on** [ScriptOn](#ScriptOn)  
**se** [Travel](#Travel)  
**search** something [Search](#Search)  
**search** something **for** topic [ConsultAbout](#ConsultAbout)  
**search for** topic [ConsultWhatAbout](#ConsultWhatAbout)  
**search for** topic **in/on** something [ConsultAbout](#ConsultAbout)  
**set** something [Set](#Set)  
**set** something **down** [Drop](#Drop)  
**set** something **behind** something [PutBehind](#PutBehind)  
**set** something **in/into/in to/inside/inside of** something
[PutIn](#PutIn)  
**set** something **on/onto/on to/upon** something [PutOn](#PutOn)  
**set** something **to** literal [SetTo](#SetTo)  
**set** something **under** something [PutUnder](#PutUnder)  
**set down** something [Drop](#Drop)  
**set fire to** something [Burn](#Burn)  
**set fire to** something **with** something [BurnWith](#BurnWith)  
**sit** [Sit](#Sit)  
**sit down** [Sit](#Sit)  
**sit down in** something [SitIn](#SitIn)  
**sit down on** something [SitOn](#SitOn)  
**sit in** something [SitIn](#SitIn)  
**sit on** something [SitOn](#SitOn)  
**sleep** [Sleep](#Sleep)  
**smash** something [Break](#Break)  
**should** topic [Query](#Query)  
**shout** [Yell](#Yell)  
**show** something [ShowToImplicit](#ShowToImplicit)  
**show** someone something [ShowTo](#ShowTo)  
**show** something **to** someone [ShowTo](#ShowTo)  
**shut** something [Close](#Close)  
**smell** [Smell](#Smell)  
**smell** something [SmellSomething](#SmellSomething)  
**sniff** [Smell](#Sniff)  
**sniff** something [SmellSomething](#SmellSomething)  
**south** [Travel](#Travel)  
**southeast** [Travel](#Travel)  
**southwest** [Travel](#Travel)  
**status** [Score](#Score)  
**stand** [Stand](#Stand)  
**stand in\|in to\|into** something [StandIn](#StandIn)  
**stand on\|on to\|onto** something [StandOn](#StandOn)  
**stand up** [Stand](#Stand)  
**starboard** [Travel](#Travel)  
**strike** something **with** something [AttackWith](#AttackWith)  
**sw** [Travel](#Travel)  
**switch** something [SwitchVague](#SwitchVague)  
**switch** something **off** [SwitchOff](#SwitchOff)  
**switch** something **on** [SwitchOn](#SwitchOn)  
**switch off** something [SwitchOff](#SwitchOff)  
**switch on** something [SwitchOn](#SwitchOn)  

### T

**t** topic [TellAboutImplicit](#TellAboutImplicit)  
**t** someone **about** topic [TellAbout](#TellAbout)  
**talk about** topic [TalkAboutImplicit](#TalkAboutImplicit)  
**talk to** someone [TalkTo](#TalkTo)  
**talk to** someone **about** topic [TalkAbout](#TalkAbout)  
**take** something [Take](#Take)  
**take** something off [Doff](#Doff)

dobj

  
**take** something **from/out of/off/off of** something
[TakeFrom](#TakeFrom)  
**take inventory** [Inventory](#Inventory)  
**take off** something [Doff](#Doff)

dobj

  
**taste** something [Taste](#Taste)  
**tell** topic [TellAboutImplicit](#TellAboutImplicit)  
**tell** someone **about** topic [TellAbout](#TellAbout)  
**tell** someone **that** topic [SayTo](#SayTo)  
**tell** someone **to** literal [TellTo](#TellTo)  
**tell me about** topic [AskAboutImplicit](#AskAboutImplicit)  
**terse** [Brief](#Brief)  
**test** literal [DoTest](#DoTest)  
**think** [Think](#Think)  
**think about** topic [ThinkAbout](#ThinkAbout)  
**throw** something [Throw](#Throw)  
**throw** something direction [ThrowDir](#ThrowDir)  
**throw** someone something [ThrowTo](#ThrowTo)  
**throw** something **at** something [ThrowAt](#ThrowAt)  
**throw** something **to/to the** direction [ThrowDir](#ThrowDir)  
**throw** something **to** someone [ThrowTo](#ThrowTo)  
**throw d/down** something [ThrowDir](#ThrowDir)  
**topics** [Topics](#Topics)  
**toss** something [Throw](#Throw)  
**toss** something direction [ThrowDir](#ThrowDir)  
**toss** something **at** something [ThrowAt](#ThrowAt)  
**toss** something **to/to the** direction [ThrowDir](#ThrowDir)  
**toss** something **to** someone [ThrowTo](#ThrowTo)  
**touch** something [Feel](#Feel)  
**turn** something [Turn](#Turn)  
**turn** something **off** [SwitchOff](#SwitchOff)  
**turn** something **on** [SwitchOn](#SwitchOn)  
**turn** something **to** literal [TurnTo](#TurnTo)  
**turn** something **with** something [TurnWith](#TurnWith)  
**turn off** something [SwitchOff](#SwitchOff)  
**turn on** something [SwitchOn](#SwitchOn)  
**twist** something [Turn](#Turn)  
**twist** something **to** literal [TurnTo](#TurnTo)  
**twist** something **with** something [TurnWith](#TurnWith)  
**type** literal [Type](#Type)  
**type** literal **on** something [TypeOn](#TypeOn)  
**type on** something [TypeOnVague](#TypeOnVague)  

### U

**u** [Travel](#Travel)  
**unbuckle** something [Unfasten](#Unfasten)  
**unbuckle** something **from** something
[UnfastenFrom](#UnfastenFrom)  
**undo** [Undo](#Undo)  
**unfasten** something [Unfasten](#Unfasten)  
**unfasten** something **from** something
[UnfastenFrom](#UnfastenFrom)  
**unlock** something [Unlock](#Unlock)  
**unlock** something **with** something [UnlockWith](#UnlockWith)  
**unplug** something [Unplug](#Unplug)  
**unplug** something **from** something [UnplugFrom](#UnplugFrom)  
**unscrew** something [Unscrew](#Unscrew)  
**unscrew** something **with** something [UnscrewWith](#UnscrewWith)  
**up** [Travel](#Travel)  

### V

**verbose** [Verbose](#Verbose)  
**version** [Version](#Version)  

### W

**wait** [Wait](#Wait)  
**walk** [VagueTravel](#VagueTravel)  
**walk** direction [Travel](#Travel)  
**walk down** [ClimbDownVague](#ClimbDownVague)  
**walk down** something [ClimbDown](#ClimbDown)  
**walk in/inside/in to/into** something [Enter](#Enter)  
**walk through/thru** something [GoThrough](#GoThrough)  
**walk to\|to the** direction [Travel](#Travel)  
**walk to** somewhere [GoTo](#GoTo)  
**walk up** [ClimbUpVague](#ClimbUpVague)  
**walk up** something [ClimbUp](#ClimbUp)  
**wear** something [Wear](#Wear)  
**what/when/where/whether/who** topic [Query](#Query)  
**wordy** [Verbose](#Verbose)  
**would** topic [Query](#Query)  
**wreck** something [Break](#Break)  
**write** literal [Write](#Write)  
**write** literal **in/on** something [WriteOn](#WriteOn)  

### X

**x** something [Examine](#Examine)  

### Y

**yell** [Yell](#Yell)  
**yes** [SayYes](#SayYes)  

### Z

**z** [Wait](#Wait)  

## Action List

The table below lists each of the actions defined in the adv3Lite
library, and summarizes the effects of each action and the conditions
under which it is allowed to proceed. The purpose is to give game
authors a quick reference to the main properties they may need to
customize to allow an action to go ahead or explain why it can't. System
actions and debugging actions are listed in a different colour, since
game code is less likely to need to customize these.

The table deals with three classes of action: (1) those that take no
Thing objects (IActions, SystemActions, TopicActions and
LiteralActions); (2) those that take one Thing object (TActions,
TopicTActions and LiteralTActions) and (3) those that take two Thing
objects (TIActions). Class (1) and (2) actions are listed in a single
row of the table; class (3) actions take two rows. Class (1) actions
have a dash in the **obj** column (indicating that no objects are
involved). Class (2) actions have 'dobj' in the **obj** column,
indicating that the information given relates to the direct object of
the action. Class (3) actions have 'dobj' in the **obj** column in the
first row, and 'iobj' in the **obj** column in the second row,
indicating that the information given in each row relates to the direct
object and indirect objects of the action respectively.

For Class (2) and (3) actions the remaining columns relate to how the
action handling is defined on the Thing class. The **Verify
Property/Condition** column holds the name of the basic property that
must be true for the action to go ahead with that object, together with
the default value of that property in the form propName = val. For
example, the basic property determining whether something can be opened
is isOpenable, which is nil by default on Thing, so it appears as
isOpenable = nil. Sometimes this property depends on the value of
another property, e.g. isTakeable = !isFixed, meaning a Thing is
takeable if it is not fixed in place. Occasionally this colummn just
holds the value nil, which means that the verfy routine on Thing fails
the action unconditionally (as is mainly the case with conversational
actions).

The **Failure Message** column then holds the name of the property that
defines the message to be displayed if the action fails on account of
not meeting the Verify Property/Condition requirement. For example, if
the player attempts to OPEN an object whose isOpenable property is nil,
the object's cannotOpenMsg property is displayed. Knowing this property
name makes it easy for game authors to customize the failure messages on
particular objects or classes of object.

The **Action Result** column attempts to summarize the *main* result of
the action if it is allowed to proceed. Note that actions may have
additional side effects not shown in the table. Where an entry is blank,
no action results are defined for that action on Thing. Where the action
column contains an entry like report { DMsg (so and so) }, this means
that the action method does nothing, but the report phase displays the
report indicated. Occasionally there is a link to another class name,
such as Key; this means that more significant handling for the action is
defined on the class in question and that clicking on the link will take
you to an appropriate code extract where you can see the details of the
handling on that class.

For Class (1) actions there are no verify routines and no corresponding
properties, but where it is possible to summarize the conditions under
which a Class (1) action might fail and the message that would then be
displayed, this information is given in the appropriate column. The
outcome of Class (1) actions is summarized in the **Action Result**
column.

A blank cell indicates that the library defines no verify or action
routine (as the case may be) for the action in question on Thing (though
action handling may be defined on other classes). Actions with blank
entries in the **Action Result** column do nothing on the Thing class
(and will normally be failed at the verify stage).

Sometimes the verification conditions or action outcomes are simply too
complicated to be usefully summarized in the table. Where that is the
case a row of three asterisks (\* \* \*) appears instead. If the
asterisks are hyperlinked, you can click on the link to view a relevant
code extract which should give you the full picture.

In any case a table like this can hardly give the full picture except
for the very simplest cases. In particular, the properties listed in the
**Verify Property/Condition** column are simply those relating to
whether an action can succeed on an object because of the type of object
it is. For example, there is no prospect of an OPEN command operating on
an object unless that object is openable (isOpenable = true), but while
isOpenable = true is a necessary condition for the OPEN command to work,
it may not be sufficient. An OPEN command will also fail, for example,
if the object in question is already open, or if it is locked. In some
cases the presence of further such information is indicated in the table
by a hyperlinked double asterisk ([\*\*](#actionlist)); clicking on the
link will take you to a code extract that should give you a fuller
picture.

For some types of customization there will be no substitute for
consulting the full library source code. The table below should,
however, hopefully reduce the need to do so by listing the properties
you will most commonly need to override.

[A](#aA) [B](#aB) [C](#aC) [D](#aD) [E](#aE) [F](#aF) [G](#aG) [H](#aH)
[I](#aI) [J](#aJ) [K](#aK) [L](#aL) [M](#aM) [N](#N) [O](#aO) [P](#aP)
[Q](#aQ) [R](#aR) [S](#aS) [T](#aT) [U](#aU) [V](#uV) [W](#aW) X
[Y](#aY) Z

**Action**

**obj**

**Verify Property/Condition**

**Failure Message**

**Action Result**

**A**

About

—

versionInfo.showAbout()

Again

—

[\* \* \*](source.htm#Again)

AskAbout

dobj

nil

cannotTalkToMsg

AskAboutImplicit

—

\[[ImplicitConversationAction](source.htm#ImplicitConversationAction)\]

AskFor

dobj

nil

cannotTalkToMsg

AskForImplicit

—

\[[ImplicitConversationAction](source.htm#ImplicitConversationAction)\]

Attach

dobj

isAttachable = nil

cannotAttachMsg

askForIobj(AttachTo)

AttachTo

dobj

isAttachable = nil

cannotAttachMsg

iobj

canAttachToMe = nil

cannotAttachToMsg

Attack

dobj

isAttackable = nil

cannotAttackMsg

AttackWith

dobj

isAttackable = nil

cannotAttackMsg

iobj

canAttackWithMe = nil

cannotAttackWithMsg

**B**

Board

dobj

isBoardable = nil

cannotBoardMsg

gActor.actionMoveInto(self)

Break

dobj

isBreakable = true

cannotBreakMsg

Brief

—

gameMain.verbose = nil

Burn

dobj

isBurnable = nil

cannotBurnMsg

BurnWith

dobj

isBurnable = nil

cannotBurnMsg

iobj

canBurnWithMe = nil

cannotBurnWithMsg

**C**

Clean

dobj

isCleanable = true

cannotCleanMsg

makeCleaned(true)

CleanWith

dobj

isCleanable = true

cannotCleanMsg

makeCleaned(true)

iobj

canCleanWithMe = nil

cannotCleanWithMsg

Climb

dobj

isClimbable = nil

cannotClimbMsg

ClimbDown

dobj

canClimbDownMe = isClimbable

cannotClimbDownMsg

ClimbDownVague

—

askForDobj(ClimbDown)

ClimbUp

dobj

canClimbUpMe = isClimbable

cannotClimbMsg

ClimbUpVague

—

askForDobj(ClimbUp)

Close

dobj

isCloseable = isOpenable [\*\*](source.htm#Thing:Close)

cannotCloseMsg

makeOpen(nil) [\*\*](source.htm#Thing:Close)

ConsultAbout

dobj

isConsultable

cannotConsultMsg

ConsultWhatAbout

—

askForDobj(ConsultAbout)

Continue

—

[\* \* \*](source.htm#Continue)

Credits

—

versionInfo.showCredit()

Cut

dobj

isCuttable = nil

cannotCutMsg

askForIobj(CutWith)

CutWith

dobj

isCuttable = nil

cannotCutMsg

iobj

canCutWithMe = nil

cannotCutWithMsg

**D**

Debug

—

[\* \* \*](source.htm#Debug)

DebugI

—

t3DebugTrace(T3DebugCheck)

DMsg(debugger not present)

t3DebugTrace(T3DebugBreak)

Detach

dobj

isDetachable = nil

cannotDetachMsg

DetachFrom

dobj

isDetachable = nil

cannotDetachMsg

iobj

canDetachFromMe = nil

cannotDetachFromMsg

Dig

dobj

isDiggable = nil

cannotDigMsg

askForIobj(DigWith)

DigWith

dobj

isDiggable = nil

cannotDigMsg

iobj

canDigWithMe = nil

cannotDigWithMsg

Doff

dobj

isDoffable = isWearable [\*\*](source.htm#Thing:Doff)

cannotDoffMsg

makeWorn(nil)

DoTest

—

—

—

run test script

Drink

dobj

isDrinkable = nil

cannotDrinkMsg

Drop

dobj

isDroppable = true

cannotDropMsg

actionMoveInto(gActor.location.dropLocation);

**E**

Eat

dobj

isEdible = nil

cannotEatMsg

moveInto(nil)

Enter

dobj

isEnterable = nil

cannotEnterMsg

gActor.actionMoveInto(self)

EnterOn

dobj

canEnterOnMe = nil

cannotEnterOnMsg

Evaluate

—

Compiler.eval(stripQuotesFrom(cmd.dobj.name))

Examine

dobj

desc; examineStatus(); [\*\*](source.htm#Thing:Examine)

Exits

—

gExitLister != nil

DMsg(no exit lister)

gExitLister.showExitsCommand()

ExitsColour

—

gExitLister != nil

DMsg(no exit lister)

[\* \* \*](source.htm#ExitsColour)

ExitsMode

—

gExitLister != nil

DMsg(no exit lister)

gExitLister.exitsOnOffCommand(stat, stat)

Extinguish

dobj

isExtinguishable = true

cannotExtinguishMsg

makeLit(nil)

**F**

Fasten

dobj

isFastenable = nil

cannotFastenMsg

makeFastened(true)

FastenTo

dobj

isFastenable = nil

cannotFastenMsg

iobj

canFastenToMe = nil

cannotFastenToMsg

Feel

dobj

isFeelable = true

cannotFeelMsg

display(&feelDesc);

FiatLux

—

gPlayerChar.isLit = !gPlayerChar.isLit

Flip

dobj

isFlippable = isSwitchable

cannotFlipMsg

Follow

dobj

isFollowable = nil

cannotFollowMsg

FullScore

—

libGlobal.scoreObj.showFullScore()

**G**

GetOff

dobj

gActor.isIn(self)

actorNotOnMsg

gActor.actionMoveInto(exitLocation)

GetOut

—

GoOut.execAction(cmd)

GetOutOf

dobj

gActor.isIn(self)

actorNotInMsg

gActor.actionMoveInto(exitLocation)

GiveTo

dobj

!isIn(gIobj)

alreadyHasMsg

iobj

nil

cannotGiveToMsg

GiveToImplicit

dobj

\* \* \*

gPlayerChar.currentInterlocutor.handleTopic(&giveTopics, \[self\])

GoBack

—

[\* \* \*](source.htm#GoBack)

Goodbye

—

gPlayerChar.currentInterlocutor != nil

DMsg(not talking)

gPlayerChar.currentInterlocutor.endConversation(endConvBye)

GoIn

—

[\[Travel\]](source.htm#GoIn)

GoNear

dobj

[\* \* \*](source.htm#Thing:GoNear)

getOutermostRoom.travelVia(gActor); [\*\*](source.htm#Thing:GoNear)

GoThrough

dobj

canGoThroughMe = nil

cannotGoThroughMsg

GoTo

dobj

[\* \* \*](source.htm#Thing:GoTo)

[\* \* \*](source.htm#Thing:GoTo)

GoOut

—

[\[Travel or GetOff\]](source.htm#GoOut)

**H**

Hello

—

[\* \* \*](source.htm#Hello)

Hints

—

gHintManager != nil

DMsg(hints not present)

gHintManager.showHints()

HintsOff

—

gHintManager != nil

DMsg(no hints to disable)

gHintManager.disableHints()

**I**

Inventory

—

[\* \* \*](source.htm#Inventory)

**J**

Jump

—

DMsg(jump)

JumpOff

dobj

canJumpOffMe = \[the actor is on dobj\]

cannotJumpOffMsg

gActor.actionMoveInto(location)

JumpOffIntransitive

JumpOver

dobj

canJumpOverMe = nil

cannotJumpOverMsg

**K**

Kiss

dobj

isKissable = true

cannotKissMsg

report { DMsg(kiss) }

**L**

Lie

—

askForDobj(LieOn)

LieIn

dobj

asDobjFor(Enter)

cannotEnterMsg

asDobjFor(Enter)

LieOn

dobj

canLieOnMe = isBoardable

cannotLieOnMsg

asDobjFor(Board)

Light

dobj

isLightable = nil

cannotLightMsg

makeLit(true)

Listen

—

[\* \* \*](source.htm#Listen)

ListenTo

dobj

display(&listenDesc);

ListTests

—

—

—

list available test scripts

Lock

dobj

lockability = notLockable [\*\*](source.htm#Thing:Lock)

notLockableMsg

makeLocked(true) [\*\*](source.htm#Thing:Lock)

LockWith

dobj

lockability = notLockable [\*\*](source.htm#Thing:LockWith)

notLockableMsg

iobj

canLockWithMe = canUnlockWithMe

cannotLockWithMsg

[Key](source.htm#Key:LockWith)

LookBehind

dobj

canLookBehindMe = true

cannotLookBehindMsg

[\* \* \*](source.htm#Thing:LookBehind)

Look

\-

gActor.outermostVisibleParent().lookAroundWithin()

LookIn

dobj

[\* \* \*](source.htm#Thing:LookIn)

LookThrough

dobj

canLookThroughMe = true

cannotLookThroughMsg

say(lookThroughMsg)

LookUnder

dobj

canLookUnderMe = true

cannotLookUnderMsg

[\* \* \*](source.htm#Thing:LookUnder)

**M**

Move

dobj

isMoveable = !isFixed

cannotMoveMsg

report { DMsg(move no effect); }

MoveTo

dobj

isMoveable = !isFixed

cannotMoveMsg

makeMovedTo(gIobj)

iobj

canMoveToMe = true

cannotMoveToMsg

MoveWith

dobj

isMoveable = !isFixed

cannotMoveMsg

report { DMsg(move no effect); }

iobj

canMoveWithMe = nil

cannotMoveWithMsg

**N**

Notify

—

\* \* \*

NotifyOff

—

libGlobal.scoreObj.showNotify.isOn = nil

NotifyOn

—

libGlobal.scoreObj.scoreNotify.isOn = true

**O**

Open

dobj

isOpenable = nil [\*\*](source.htm#Thing:Open)

cannotOpenMsg

makeOpen(true) [\*\*](source.htm#Thing:Open)

**P**

PlugIn

dobj

isPlugable = nil

cannotPlugMsg

PlugInto

dobj

isPlugable = nil

cannotPlugMsg

iobj

canPlugIntoMe = nil

cannotPlugIntoMsg

Pour

dobj

isPourable = nil

cannotPourMsg

PourInto

dobj

isPourable = nil

cannotPourMsg

iobj

canPourIntoMe = (contType == In \|\| remapIn != nil)

cannotPourIntoMsg

PourOnto

dobj

isPourable = nil

cannotPourMsg

iobj

canPourOntoMe = true

cannotPourOntoMsg

Pull

dobj

isPullable = true

cannotPullMsg

say(pullNoEffectMsg)

Purloin

dobj

!isFixed

cannotTakeMsg

moveInto(gActor)

Push

dobj

isPushable = true

cannotPushMsg

say(pushNoEffectMsg)

PushTravelClimbDown

dobj

canPushTravel = nil

cannotPushTravelMsg

doPushTravel(Down) [\*\*](source.htm#Thing:PushTravelClimbDown)

iobj

canClimbDownMe = nil

cannotPushDownMsg

PushTravelClimbUp

dobj

canPushTravel = nil

cannotPushTravelMsg

doPushTravel(Up)

\*\*

iobj

isClimbable = nil

cannotPushUpMsg

PushTravelDir

dobj

canPushTravel = nil

cannotPushTravelMsg

[\* \* \*](source.htm#PushTravelDir)

PushTravelEnter

dobj

canPushTravel = nil

cannotPushTravelMsg

iobj

isEnterable

cannotPushIntoMsg

\* \* \*

PushTravelGetOutOf

dobj

canPushTravel = nil

cannotPushTravelMsg

\* \* \*

iobj

\* \* \*

\* \* \*

\* \* \*

PushTravelThrough

dobj

canPushTravel = nil

cannotPushTravelMsg

doPushTravel(Through)

\*\*

iobj

canGoThroughMe = nil

cannotPushThroughMsg

PutBehind

dobj

!isFixed [\*\*](source.htm#Thing:dobjPutBehind)

cannotTakeMsg

iobj

canPutBehindMe = (contType == Behind)
[\*\*](source.htm#Thing:iobjPutBehind)

cannotPutBehindMsg

gDobj.actionMoveInto(self) [\*\*](source.htm#Thing:iobjPutBehind)

PutIn

dobj

!isFixed [\*\*](source.htm#Thing:dobjPutIn)

cannotTakeMsg

iobj

canPutInMe = (contType == In) [\*\*](source.htm#Thing:iobjPutIn)

cannotPutInMsg

gDobj.actionMoveInto(self) [\*\*](source.htm#Thing:iobjPutIn)

PutOn

dobj

!isFixed [\*\*](source.htm#Thing:dobjPutOn)

cannotTakeMsg

iobj

contType == On [\*\*](source.htm#Thing:iobjPutOn)

cannotPutOnMsg

gDobj.actionMoveInto(self) [\*\*](source.htm#Thing:iobjPutOn)

PutUnder

dobj

!isFixed [\*\*](source.htm#Thing:dobjPutUnder)

cannotTakeMsg

iobj

canPutUnderMe = (contType == Under)
[\*\*](source.htm#Thing:iobjPutUnder)

cannotPutUnderMsg

gDobj.actionMoveInto(self) [\*\*](source.htm#Thing:iobjPutUnder)

**Q**

Query

—

\[ImplicitConversationAction\]

QueryAbout

—

nil

cannotTalkToMsg

QueryVague

—

\[MiscConvAction\]

Quit

—

throw new QuittingException

**R**

Read

dobj

isReadable = propType(&readDesc) != TypeNil

cannotReadMsg

display(&readDesc);

Record

—

\* \* \*

RecordEvents

—

\* \* \*

RecordOff

—

\* \* \*

Remove

dobj

isRemoveable = isTakeable

cannotRemoveMsg

removeDoer:doInstead(Take\|Doff)

Replay

—

\* \* \*

Restart

—

throw new RestartSignal

Restore

—

askAndRestore()

**S**

Save

—

\* \* \*

Say

—

\[[ImplicitConversationAction](source.htm#ImplicitConversationAction)\]

SayNo

—

\[MiscConvAction\]

SayTo

dobj

nil

cannotTalkToMsg

SayYes

—

\[MiscConvAction\]

Screw

dobj

isScrewable = nil

cannotScrewMsg

ScrewWith

dobj

isScrewable = nil

cannotScrewMsg

iobj

canScrewWithMe = nil

cannotScrewWithMsg

Search

dobj

asDobjFor(LookIn)

asDobjFor([LookIn](#LookIn))

Set

dobj

isSettable = nil

cannotSetMsg

SetTo

dobj

canSetMeTo = nil

cannotSetToMsg

makeSetting(gLiteral)

Sit

—

askForDobj(SitOn)

SitIn

dobj

asDobjFor(Enter)

cannotEnterMsg

asDobjFor(Enter)

SitOn

dobj

canSitOnMe = isBoardable

cannotSitOnMsg

asDobjFor(Board)

Score

—

libGlobal.scoreObj.showScore()

ScriptOff

—

\* \* \*

ScriptOn

—

\* \* \*

ShowTo

dobj

iobj

nil

cannotShowToMsg

ShowToImplicit

dobj

\* \* \*

\* \* \*

gPlayerChar.currentInterlocutor.handleTopic(&showTopics, \[self\])

Sleep

—

DMsg(no sleeping)

Smell

—

[\* \* \*](source.htm#Smell)

SmellSomething

dobj

isSmellable = true

cannotSmellMsg

display(&smellDesc);

Stand

—

replaceAction(GetOff, gActor.location) \| DMsg(already standing)

StandIn

dobj

asDobjFor(Enter)

cannotEnterMsg

asDobjFor(Enter)

StandOn

dobj

canStandOnMe = isBoardable

cannotStandOnMsg

asDobjFor(Board)

Strike

dobj

asDobjFor([Attack](#Attack))

SwitchOff

dobj

isSwitchable

notSwitchableMsg

makeOn(nil)

SwitchOn

dobj

isSwitchable

notSwitchableMsg

makeOn(true)

SwitchVague

dobj

isSwitchable

notSwitchableMsg

makeOn(!isOn)

**T**

TalkAbout

dobj

nil

cannotTalkToMsg

TalkAboutImplicit

—

\[[ImplicitConversationAction](source.htm#ImplicitConversationAction)\]

TalkTo

dobj

nil

cannotTalkToMsg

Take

dobj

isTakeable = !isFixed [\*\*](source.htm#Thing:Take)

cannotTakeMsg

actionMoveInto(gActor) [\*\*](source.htm#Thing:Take)

TakeFrom

dobj

isTakeable = !isFixed [\*\*](source.htm#Thing:dobjTakeFrom)

cannotTakeMsg

actionDobjTake()

iobj

[\* \* \*](source.htm#Thing:iobjTakeFrom)

Taste

dobj

isTasteable = true

cannotTasteMsg

display(&tasteDesc);

TellAbout

nil

cannotTalkToMsg

TellAboutImplicit

—

\[[ImplicitConversationAction](source.htm#ImplicitConversationAction)\]

TellTo

Think

—

DMsg(think)

ThinkAbout

—

libGlobal.thoughtManagerObj.handleTopic(cmd.dobj.topicList)

Throw

dobj

isThrowable = !isFixed

cannotThrowMsg

moveInto(getOutermostRoom)

ThrowAt

dobj

verifyDobjThrow()

iobj

canThrowAtMe = true

cannotThrowAtMsg

gDobj.moveInto(getOutermostRoom)

ThrowDir

dobj

isThrowable = !isFixed

cannotThrowMsg

moveInto(getOutermostRoom)

ThrowTo

dobj

verifyDobjThrow()

iobj

canThrowToMe = nil

cannotThrowToMsg

Topics

—

otherActor != nil

DMsg(no interlocutor)

otherActor.showSuggestions(true)

Travel

—

[\* \* \*](source.htm#Travel)

Turn

dobj

isTurnable = true

cannotTurnMsg

report{ say(turnNoEffectMsg) }

TurnTo

dobj

canTurnMeTo = nil

cannotTurnToMsg

makeSetting(gLiteral)

TurnWith

dobj

isTurnable = true

cannotTurnMsg

report{ say(turnNoEffectMsg) }

iobj

canTurnWithMe = nil

cannotTurnWithMsg

Type

—

askForIobj(TypeOn)

TypeOn

dobj

canTypeOnMe = nil

cannotTypeOnMsg

TypeOnVague

dobj

canTypeOnMe = nil

cannotTypeOnMsg

**U**

Unplug

dobj

isUnplugable = isPlugable

cannotUnplugMsg

UnplugFrom

dobj

isUnplugable = isPlugable

cannotUnplugMsg

iobj

canUnplugFromMe = canPlugIntoMe

cannotUnplugFromMsg

Undo

—

undo()

\>

Unfasten

dobj

isUnfastenable = nil

cannotUnfastenMsg

UnfastenFrom

dobj

isUnfastenable = nil

cannotUnfastenMsg

iobj

canUnfastenFromMe

cannotUnfastenFromMsg

Unlock

dobj

lockability = notLockable [\*\*](source.htm#Thing:Unlock)

notLockableMsg

makeLocked(nil) [\*\*](source.htm#Thing:Unlock)

UnlockWith

dobj

lockability = notLockable [\*\*](source.htm#Thing:UnlockWith)

notLockableMsg

[Key](source.htm#Key:UnlockWith)

iobj

canUnlockWithMe

cannotUnlockWithMsg

Unscrew

dobj

isUnscrewable = isScrewable

cannotUnscrewMsg

UnscrewWith

dobj

isUnscrewable = isScrewable

cannotUnscrewMsg

iobj

canUnscrewWithMe = canScrewWithMe

cannotUnscrewWithMsg

**V**

VagueTravel

—

DMsg(vague travel)

Verbose

—

gameMain.verbose = true

Version

—

foreach ModuleID.showVersion()

**W**

Wait

—

DMsg(wait)

Wear

dobj

isWearable = true

cannotWearMsg

makeWorn(true)

Write

—

askForIobj(WriteOn)

WriteOn

dobj

canWriteOnMe = nil

cannotWriteOnMsg

**Y**

Yell

—

DMsg(yell)

------------------------------------------------------------------------

*adv3Lite Library Manual*  
[Table of Contents](toc.htm) \| [Actions](action.htm) \> Action
Reference  
[*Prev:* Debugging Commands](debug.htm)     *Next:* [Actors](actor.htm)
   
