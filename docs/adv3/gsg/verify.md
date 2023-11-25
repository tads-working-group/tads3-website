::: topbar
[![](topbar.jpg){border="0"}](index.html)
:::

::: main
[\[Main\]](index.html)\
*[\[Previous\]](controllingtheaction.htm)   [\[Next\]](check.htm)*

### Verify

The verify method has two main functions: (a) to veto actions that
plainly should not be allowed to continue (e.g. EAT MOUNTAIN) and
explain the veto, and (b) to help the parser decide which object to
choose in the case of ambiguity (e.g. if OPEN DOOR could refer to either
the currently open red door or the currently closed blue door, verify
can be used to prefer the blue door, since you can\'t open a door
that\'s already open).

\
A verify() routine should never alter the game state (since, among other
things, it will probably be called multiple times during object
resolution). Neither should it directly display a string using a
double-quoted string or say(). Normally it should only contain one or
more of the macros designed to be used in a verify routine,
if-statements to determine which macro to use, or the inherited keyword
to invoke a superclass\'s verify behaviour. A verify routine can also
simply be empty (i.e. contain no code at all); this is often useful when
you want to allow an action to proceed unconditionally.\
\
The macros that can be used in verify routines to define verify results
are:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      logical \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      logicalRank(rank, key) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      logicalRankOrd(rank, key, ord) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      dangerous \

  ----------------------------------- -----------------------------------

  ----------------------------------- ------------------------------------
                                      illogicalAlready(msg, params...) \

  ----------------------------------- ------------------------------------

  ----------------------------------- -----------------------------------
                                      illogicalNow(msg, params...) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      illogical(msg, params...) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      illogicalSelf(msg, params...) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      nonObvious \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      inaccessible(msg, params...) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Of these, only the five that start with i (illogical or inaccessible)
will prevent an action altogether, the rest mainly make the object more
or less likely to be chosen as the object of the action by the parser in
case of uncertainty. This is why it is only these five i-macros that
take a msg parameter, which is single-quoted string (or property
returning one) explaining why the action may not proceed. For now, it\'s
only the four illogical macros that you need to worry about
(inaccessible is rarely needed in game code). Each of the four will
prevent an action from continuing, but in case of ambiguity the parser
will choose an object that returns an illogicalAlready result in
preference to one that returns an illogicalNow result, and either to one
that returns a plain illogical result. All three will be preferred to
something that returns illogicalSelf.\
\
For example, suppose your game has a red door, a red box and a red cup.
It\'s perfectly logical to open a door, but it\'s not a good choice for
an OPEN command if it\'s already open. Likewise, a box can probably be
opened, but perhaps this red box can be broken, and once broken, it\'s
no longer openable. Finally, a cup is never something that can be
opened; the command OPEN CUP would never make sense. You might define
the corresponding verify methods as follows:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

redDoor: Door \'red door\*doors\' \'red door\'\
  dobjFor(Open)\
  {\
   verify()\
   {\
     if(isOpen)\
        illogicalAlready(\'The red door is already open. );\
   }\
  }\
;\
\
redBox: OpenableContainer \'red box\*boxes\' \'red box\'\
  dobjFor(Open)\
  {\
     verify()\
     {\
         if(isBroken)\
            illogicalNow(\'You can no longer open it; it\\\'s broken. \');\
     }\
  }\
;\
\
redCup: Container \'red cup\*cups\' \'red cup\'\
   dobjFor(Open)\
   {\
       illogical(\'You can\\\'t open a cup. \');\
   }\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

If you type **open red** when all three red objects are present, then if
the red door is not closed and the red box is not broken, the parser
will ask which red object you mean (since under these circumstances
either would be equally logical). If the red door were already open, but
the box not yet broken, the parser would choose the red box; if the red
door were already open and the box broken, the parser would choose the
red door (and report that it\'s already open). Finally, if the player
character took the broken red box and the red cup to another location
and you then typed **open red**, the parser would choose the red box
(and report that you can\'t open it because it\'s broken).\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Note that in the library the argument to these illogical macros is
typically a property pointer (e.g. &cannotTakeMsg); roughly speaking,
these refer to properties of the playerActionMessages object (defined in
msg_neu.t). But this is a complication we shall set to one side till
later; in your own code, at least to start with, you can stick to using
single-quoted strings.\
\
The non-i macros all allow the action to proceed (at least to the check
stage, see below), but again affect how likely the object is to be
chosen by the parser in case of ambiguity. The logical macro is simply
the default; a verify() routine that consists solely of the keyword
logical is identical to one that contains nothing at all. The logical
macro is thus strictly speaking redundant, but it may improve the
readability of code to use it in a complex verify() routine with several
different conditions producing different results.\
\
The logicalRank(rank, key) macro allows you to choose the priority the
parser gives to selecting different objects in cases of ambiguity. The
default rank is 100; an object with a logical rank of 150 is regarded as
a particularly suitable target for a command, while one with a logical
rank of 50 would be a possible but not very likely one.\
\
Suppose that in the previous example, when the the door is closed and
the box not broken we wanted the parser to prefer the door to the box in
response to an **open red** command.. To boost the ranking of the door,
we might use logicalRank thus:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

redDoor: Door \'red door\*doors\' \'red door\'\
  dobjFor(Open)\
  {\
   verify()\
   {\
     if(isOpen)\
        illogicalAlready(\'The red door is already open. );\
     else\
        logicalRank(120, \'door\');\
   }\
  }\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Since the (unbroken) red box has a default logical rank of 100, **open
red** will now prefer the door. Note that in this example, \'door\', the
second parameter to the logicalRank macro, is the key value; this is
effectively an arbitrary single-quoted string. Technically it can be
used by the parser in breaking a tie (if two objects have the same
logicalRank with the same key, then the parser knows that it can ignore
this and look for some other way of breaking the tie), but in practice
it seldom matters in game code what you put here.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The final two macros (dangerous and nonObvious) allow an action to
proceed, but only if the player unambiguously names the object. Both
macros also prevent the object ever being chosen as a default object for
the command in question, or in an implicit action.\
\
The dangerous macro is intended to prevent an object being used in an
action when carrying out the action on that object would be plainly
dangerous (e.g. **drink poison**) even though the action is perfectly
possible and the object might be the only suitable one in scope. Thus,
to prevent a bare **drink** command from making the PC drink the poison
when the poison is the only potable object around, you would define the
poison\'s verifyDobjDrink() method as dangerous.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

poison: Thing \'deadly poison\' \'deadly poison\'\
   dobjFor(Drink)\
  {\
      verify() {  dangerous; }\
      action()\
      {\
            \"You feel an unpleasant choking sensation as the poison\
             burns down your throat; then you feel no more. \";\
            finishGameMsg(ftDeath); // this ends the game\
      }\
  }\
;\
\
The nonObvious macro works similarly, but makes the object so marked
even less likely to be chosen in the event of ambiguity. Its main
purpose is to prevent a puzzle being solved accidentally by having an
action carried out implicitly or by default. For example, if we hadn\'t
wanted to make it obvious that the nest could be moved with the stick,
we could have put nonObvious in the verify() section of the
iobjFor(MoveWith) on the stick.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

One last point: the macros we have just been discussing (`illogical `and
the like) are for use only in verify() routines.

So far we have discussed `verify()` mainly in terms of how the parser
selects objects in case of ambiguity. Another way of looking at is that
`verify()` should be used to veto an action only if it should be obvious
to the player (not the player character) that the action is illogical
(e.g. eating a mountain or opening an already-open door). In fact, these
two ways of looking it amount to the same thing: the purpose of
`verify()` is to help the parser decide what the player probably meant
in case of ambiguity. If you want to veto an action which is perfectly
\'logical\' (i.e. one that the player could well have meant) you should
therefore use `check()` instead.\
\

------------------------------------------------------------------------

*Getting Started in TADS 3*\
[\[Main\]](index.html)\
*[\[Previous\]](controllingtheaction.htm)   [\[Next\]](check.htm)*
:::
