::: topbar
[![](topbar.jpg){border="0"}](index.html)
:::

::: main
[\[Main\]](index.html)\
*[\[Previous\]](rewardingtheeffort.htm)   [\[Next\]](verify.htm)*

## Controlling the Action

The TADS 3 library defines a fair number of actions (see the end of the
en_us.t library file for their grammar definitions, which will give you
some idea of the range of actions available), together with default
responses. For some standard actions like TAKE, DROP, EXAMINE, OPEN,
LOCK and PUT ON the standard responses are often all you need; for many
of the others, such as BREAK, CLEAN, JUMP OVER or POUR the standard
response is merely a message saying that the proposed action is
impossible or that it has no effect.

As we have seen over the last few pages, you won\'t get very far in
writing a game in TADS 3 without customizing the standard library
behaviour for various actions under particular circumstances. Indeed, a
substantial part of writing IF-code consists in just this task (writing
custom action handling). Over the course of this chapter we\'ve covered
quite a few of the concepts and methods used to customize actions in
TADS 3, but before we carry on to anything else, we should first review
what we have learned in a more systematic fashion, filling in all the
most significant gaps as we go.

So, to start again from the beginning. Customizing actions in TADS 3
generally involves using the `dobjFor()` and `iobjFor()` constructs.
Wherever you see dobj and iobj in TADS 3, remember that they are
abbreviations for **d**irect **obj**ect and **i**ndirect **obj**ect. IF
typically has three kinds of commands: simple commands like **look** and
**inventory** that have no objects at all, single-object commands like
**climb tree** or **take stick** that have one object, called the direct
object, and two-object commands like **move nest with stick** or **put
nest on branch** or **hit troll with sword** that have both a direct
object (in these examples the nest or the troll) and an indirect object
(in these examples the stick, the branch or the sword). The direct
object is normally the one that immediately follows the verb, while the
indirect object is usually the second of the two objects, and usually
comes after a preposition such as \'with\' or \'on\'. I say \'usually\'
because English sometimes allows more than one phrasing: **give fred the
book** means the same as **give the book to fred**, and in both cases
the book would be the direct object and Fred would be the indirect
object. If in doubt, always think of the longer version of the command
phrasing that includes the preposition (such as \'to\') when deciding
which object is the direct object and which the indirect object.

Customizing the behaviour of a single-object command, like **enter the
cottage** or **climb the tree** is relatively straightforward. You
simply need to define `dobjFor(Whatever)` on the direct object of the
command and then specify what happens (how exactly we do that is
something we\'ll get to in a minute or two). For a two-object command
such as **move nest with stick** it\'s more complicated; you often need
to define `dobjFor(Whatever)` on the direct object and
`iobjFor(Whatever)` on the indirect object. At the very least, if you
want the action to go ahead, you need to ensure that both of the objects
involved in the action will allow it, so that the play doesn\'t get a
message like \"You can\'t move the nest\" or \"You can\'t move anything
with the stick\".

A further complication, which we won\'t go into very far here, is that
there can be things that look like direct or indirect objects but are
considered to be something else by TADS 3. For example in the command
**ask fred about the weather**, Fred is indeed the direct object, but
\'the weather\' is the *topic object*. In the command **enter qwerty on
keyboard**, the keyboard is actually the direct object and \'qwerty\' is
the *literal object*). Beyond making sure that you\'re aware of this
complication, we can afford to ignore it for now (when you want the full
story, read the article on [How to Create Verbs](..\techman\t3verb.htm)
in the Technical Manual).

\
Before considering how to use the `iobjFor()` and `dobjFor()` macros, it
may be a good idea to take a closer look at what they actually mean.
They are, in fact, macros that define *propertysets*, which are simply a
short-hand device for defining a set of properties which have a common
element in their name (e.g. fooTake, fooDrop and fooBar, all of which
start with foo). In the case of the dobjFor and iobjFor macros, it\'s
the name of the action (e.g. Take) plus the role of the action (dobj or
iobj) that\'s the common element. So if you write:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      dobjFor(Take) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                         foo = \'poop\'  \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                         bar() { say(foo); } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

This is exactly the same, so far as the compiler is concerned, as if you
had written:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      fooDobjTake = \'poop\' \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      barDobjTake() { say(foo); } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The above example is not especially useful, since the library makes no
use of these property and method names (although you could always define
them to do something useful in your own code); the library does,
however, call a number of properties and methods on the direction object
and indirect object of any action. For example, if the action is
TakeWith the following properties/methods will be invoked respectively
on the direct and indirect objects of the command:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------------------
                                      remapDobjTakeWith         remapIobjTakeWith \

  ----------------------------------- -----------------------------------------------

  ----------------------------------- ---------------------------------------------------
                                      preCondDobjTakeWith         preCondIobjTakeWith \

  ----------------------------------- ---------------------------------------------------

  ----------------------------------- ---------------------------------------------------
                                      verifyDobjTakeWith()       verifyIobjTakeWith() \

  ----------------------------------- ---------------------------------------------------

  ----------------------------------- ---------------------------------------------------
                                      checkDobjTakeWith()         checkIobjTakeWith() \

  ----------------------------------- ---------------------------------------------------

  ----------------------------------- --------------------------------------------------
                                      actionDobjTakeWith()      actionIobjTakeWith() \

  ----------------------------------- --------------------------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Any of these properties/methods may be defined (or invoked) using these
names (and sometimes it may be useful to do so); dobjFor and iobjFor
merely provide a convenient way of defining these properties without
having to remember their full names, and for grouping the related
methods together in the code layout; e.g.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

dobjFor(TakeWith)\
{\
   remap = nil\
   preCond = \[touchObj\]\
   verify()\
   {\
       if(heldBy == gActor)\
         illogicalAlready(\'{You/he} {is} already holding {the dobj/him}. \');\
   }\
\
   check()\
   {\
     if(gDobj == poisonousSnake)\
       failCheck(\'You think better of it. \');\
   }\
\
   action()\
   {  \
      \"{You/he} take{s} {the dobj/him} with {the iobj/him}. \";\
      gDobj.moveInto(gActor);\
   }\
}\
\
The [verify()](verify.htm), [check()](check.htm), [action()](action.htm)
and [preCondition](precond.htm) methods are described in some detail in
the articles \"[How to Create Verbs in TADS
3](../techman/t3verb.htm){target="_top"}\", \"[TADS 3 Action
results](../techman/t3res.htm){target="_top"}\" and \"[On good usage of
verify() and check() in TADS 3
games](../techman/t3verchk.htm){target="_top"}\" in the *Technical
Manual*. These are all articles you will want to read sooner rather than
later; you might find it particularly useful to read the \"TADS 3
Actions results\" article at the end of this chapter if you want more
help on the ground we\'re about to cover.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\

------------------------------------------------------------------------

*Getting Started in TADS 3*\
[\[Main\]](index.html)\
*[\[Previous\]](rewardingtheeffort.htm)   [\[Next\]](verify.htm)*
:::
