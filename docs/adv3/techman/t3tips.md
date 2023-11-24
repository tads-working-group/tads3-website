![](topbar.jpg)

[Table of Contents](toc.htm) \| [TADS 3 In Depth](depth.htm) \> Tips: A
Context-Sensitive Help System  
[*Prev:* Lists and Listers](t3lister.htm)     [*Next:* Creating Dynamic
Characters](t3actor.htm)    

# Tips: A Context-Sensitive Help System

*by Krister Fundin*

There are several well-known ways of making a work of interactive
fiction more accessible to inexperienced players. Some sort of built-in
getting-started text or player's guide is one way, though far from
everyone will bother reading these. Another approach is to provide
pointers interactively during play, by responding intelligently to
different kinds of errors and informing the player about commands as
they become relevant. TADS 3 already does this for a few of the standard
system commands, for instance mentioning the NOTIFY OFF command the
first time a score notification is shown. This article explains how to
add new, custom tips of your own to supplement the standard system tips.

The Tips system (originally written as an extension, but integrated with
the standard library as of version 3.0.17) is a simple framework for
creating your own custom tips. The system provides an easy way to define
a custom tip message and trigger its display, and takes care of the
book-keeping needed to ensure that each tip is displayed only once. The
system also includes a command to turn all tips off, and this mode can
be saved as a global default, across all stories; experienced players
who don't want to be bothered with the standard litany of tips in each
new game they play can use this to suppress them across the board.

## Basic usage

Let's continue with a practical example. This example is actually
defined in the library already, so you don't have to copy any of this
into your game, but it's a good illustration of how to use the system.

Many IF stories contain some places where the player can screw up in an
immediately obvious way: accidentally breaking or losing an important
object, getting locked out of a building, etc. Experienced players know
that they can always "take back" a command that does something like this
by typing UNDO. A novice player might not know that it's so easy to get
out of the bind, though, so this looks like a great place for a tip.

To define the tip, you create a Tip object, and provide its message
text. Defining the Tip object is pretty easy using the template:

    undoTip: Tip
       "If this didn't turn out quite as intended, note that you can
       always take back one or more commands by typing
       <<aHref('undo', 'UNDO', 'Take back the most recent command')>>."
    ;

(Remember, the library defines this object already - we're just using it
as an example, so you don't need to add this to your own game.) The
"aHref" part creates a hyperlink that lets the user enter the UNDO
command by clicking on the link. This is by no means necessary, but it's
a nice touch.

Having defined the Tip object, we can trigger the tip message wherever
it's appropriate simply by calling:

    undoTip.showTip();

## Avoiding redundancy

One thing that we should be aware of before we start adding thousands of
tips to our ever so newbie-friendly work, is that for every tip we
display, we might be telling the player something she already knows.
This is why a tip is only shown once by default. In addition to this,
though, it's generally a good idea to pre-emptively cancel a tip if the
player does something to indicate that she wouldn't need it. This can be
done by calling the makeShown() method on the relevant tip.

In the above example, it would be redundant to show a tip about the UNDO
command if the player had actually typed UNDO already in the course of
the game. The player obviously must know about the command if she typed
it in, so she presumably doesn't need to hear about it in a tip. So,
we'd add a line like this somewhere in the Undo action handler:

    undoTip.makeShown();

The library does just this within the Undo action's execAction()
handler, so you don't have to enter this yourself anywhere for this
particular example. For new custom tips you create, you should consider
adding something along the same lines to the appropriate action. For
example, if you were to create a tip to explain the CONSULT command when
the player first encounters an encyclopedia within the game, you could
do something like this:

    modify ConsultAboutAction
       beforeAction()
       {
          inherited();
          consultTip.makeShown();
       }

## Turning tips on and off

Not everyone will need tips, obviously, so the Tips system provides a
command for turning them on and off. This setting is saved when the SAVE
DEFAULTS command is used, so that the tips can be turned off for all
stories that use them. Experienced players who don't want to see tips
again in each game can use this option to turn off tips everywhere.

A way to further save the veteran player from having to deal with all
this is to ask whether to show any tips before starting a new session.
The question doesn't have to be phrased this way, though. We could
simply ask something like "Are you familiar with interactive fiction?"
Then again, even that question could be unnecessary. If the default
settings indicate that the tips have already been turned off at some
earlier point, then it's probably best to just leave them off. We can
test or change this setting by referring to the tipMode.isOn property.

Finally, there are some tips that you'll probably want to show even when
the player has turned off tips in general. If a particular tip explains
some feature that's unique to a particular story or an extension that it
uses, even an experienced player would probably want to see that one. We
can achieve this by overriding the shouldShowTip() method of a tip
object so that it only checks the isShown property and not the tipMode:

    mySpecialTip: Tip
       "In this particular story, etc."

       shouldShowTip()
       {
           return (isShown == nil);
       }
    ;

## Tip display style

The pre-defined Tips have their own \<.tip\> style tag. The text of a
tip will always be wrapped in a pair of these, so that we can alter the
way in which tips are displayed. This can be done by modifying or
replacing the tipStyleTag object, which by default just puts a pair of
parentheses around the text.

On HTML interpreters, some nice-looking styles can be achived, though we
shouldn't get too carried away. The author of the Tips system is quite
fond of the following style:

    replace tipStyleTag: HtmlStyleTag 'tip'
       htmlOpenText =
           '<blockquote><font size=-1 color=WHITE
           bgcolor=BLUE>&nbsp;TIP:&nbsp;</font>&nbsp;'
       htmlCloseText = '</blockquote>'

       plainOpenText = '('
       plainCloseText = ')'
    ;

If we wanted something completely different, like showing all tips in a
separate banner, then we could modify the Tip class and override the
showTipDesc() property, perhaps to something like this:

    modify Tip
       showTipDesc()
       {
           tipBanner.clearBanner();

           tipBanner.captureOutput({: desc() });
       }
    ;

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](toc.htm) \| [TADS 3 In Depth](depth.htm) \> Tips: A
Context-Sensitive Help System  
[*Prev:* Lists and Listers](t3lister.htm)     [*Next:* Creating Dynamic
Characters](t3actor.htm)    
