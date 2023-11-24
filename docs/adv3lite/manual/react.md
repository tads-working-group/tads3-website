![](topbar.jpg)

[Table of Contents](toc.htm) \| [Actions](action.htm) \> Reacting to
Actions  
[*Prev:* Implicit Actions](implicit.htm)     [*Next:* Defining New
Actions](define.htm)    

# Reacting to Actions

In the section on [action results](actres.htm) we saw how to make the
objects directly involved in an action *respond* to it. In the present
section we shall discuss how to make other objects not directly involved
in an action *react* to it. When an action takes place, every object in
scope gets a chance to react to it both beforehand and afterwards, or
even to veto the action before it takes place. On most objects this is
achieved through their **beforeAction()** and **afterAction()** methods.
These methods also work on the room, but you can instead use
roomBeforeAction() and roomAfterAction() on the actor's current room,
which ensures (a) that even if other rooms are in scope for some reason,
only the one containing the current actor will react and (b) that the
room get a chance to react before anything else. [Travel](#travel)
actions can be handled a little differently (see below). Finally, you
can use **actorAction()** on the actor, which is another type of before
notification.

As a first approximation, the beforeAction(), roomBeforeAction() and
regionBeforeAction() methods are run just before the main action takes
place, and the afterAction(), roomAfterAction() and regionAfterAction()
methods just after, assuming the action actually does go ahead. The
slight complication is in *precisely* when the before notifications are
run in the case of TActions or TIActions (actions with direct and
possibly indirect objects). These can either run after the check phase
(the default) or before it, depending on the value of
gameMain.beforeRunsBeforeCheck (which is nil by default). Usually this
is the more logical sequence, since if the action is ruled out at the
check phase there seems to be little point in other objects reacting to
it (and possibly vetoing it), but the adv3 default is the other way
round, and the option is provided in case you want to do it the adv3
way.

The [Scene](scene.htm) class also provides beforeAction() and
afterAction() methods that work in much the same way. These are called
on every currently active Scene immediately before roomBeforeAction()
and roomAfterAction() (and their regional equivalents), allowing you to
define Scene-specific action responses, or else to rule our certain
actions together during a Scene by using the exit macro in that Scene's
beforeAction method, for example:

    interviewScene: Scene
       beforeAction()
       {
          if(gActionIs(Jump))
          {
             "It will hardly help your employment prospects if you start leaping around
              in front of your prospective employer. ";
              exit;
          }
        }
    ;    

As illustrated in the foregoing example, if you want your code to react
to an Action, you probably need to test what action it is. You can do
this with the **gActionIs(*action*)** macro. For example, to prevent
someone jumping in a room with a low ceiling you might write:

        roomBeforeAction()
        {
            if(gActionIs(Jump))
            {
                "Better not, you might bang your head!";
                exit;
            }
        }

Note how we use the **exit** macro to veto the action here.

Alternatively you might allow the jumping to go ahead and then report
that the player character has banged his head on the ceiling:

        roomAfterAction()
        {
            if(gActionIs(Jump))
                "You bang your head on the ceiling. ";
        }

If you want to test whether the current action is one among several
actions, you can use the macro gActionIn(*action1, action2, ...*)
instead, which evaluates to true if any of the listed actions is true.

For actions involving one or more objects you may also want to test
which objects were involved. In beforeAction() and roomBeforeAction()
that's straightforward, you can just test the values of **gDobj** and
**gIobj** for the direct and indirect objects respectively. In the
afterAction() and roomAfterAction() methods it may be a little more
complicated. If the action was only carried out on a single direct
object, or a single direct object plus a single indirect object, then
you can use gDobj and gIobj again. But if the action involved a sequence
of objects (e.g. TAKE ALL) then gDobj and gIobj will only give you the
final pair in the sequence. Since commands seldom involve a series of
indirect objects you're probably safe using gIobj, but to test for the
direct objects involved it's safer to use gActionList, which contains a
list of all the direct objects that made it to the action stage (i.e.
all the direct objects for which the action succeeded. For example:

        afterAction()
        {
            if(gActionList.indexOf(redBall) != nil)
                "You've just done something to the red ball. ";
        }

The **actorAction()** method is called on the current actor (carrying
out the action) just before any of the other before notifications. This
can be useful if you temporarily want to prevent an actor (in particular
the player character) from carrying out certain kinds of action because
s/he's temporarily incapacitated or tied up; for example:

    actorAction()
    {
        /* Be careful not to disable the system actions! */
       if(gAction.ofKind(SystemAction))
         return;
         
       if(gActionIn(Examine, ListenTo, Smell,  Listen, SmellSomething))
         return;

        "You can't do that while you're bound and gagged!";
           exit;   
    } 

  

## Reacting to Travel

Since a travel action (the action corresponding to commands like GO
NORTH or WEST) is an action like any other, you can test for it with
gActionIs(Travel), but that only tells you that the player character
went (or tried to go) somewhere. If you want to test for which way s/he
went you can combine a test for the action and the direction like so:

       if(gActionIs(Travel) && gAction.direction == eastDir)

But to make this a little easier adv3Lite provides the
gTravelActionIs(dir) macro, which you could use like this:

       if(gTravelActionIs(east))

But there's a problem with testing for travel actions this way.
Consider, for example, the case where going east would take the player
character through a door. In this case the player would get the same
result from the commands EAST and GO THROUGH DOOR, so to make sure we
covered both eventualities we'd have to test for:

       if(gTravelActionIs(east) || (gActionIs(GoThrough) && gDobj == frontDoor))

A better way of doing this is to test not for what direction an actor
travelled in, but what TravelConnector was traversed in the process. We
can do this with **beforeTravel(traveler, connector)** and
**afterTravel(traveler, connector)**, which are called on every object
in scope when *connector* is traversed by *traveler*. Note that since a
successful travel action generally results in the traveler starting in
one place and finishing in another, the set of objects that are in scope
will generally change between the beforeTravel() and afterTravel()
notifications; the beforeTravel() notifications will be called on every
object in scope in the room the traveler starts out in (including the
room itself) while the afterTravel() notifications will be called on all
the objects in the destination once the traveler has arrived there.

In any case, rather than using gTravelActionIs() in a beforeAction() or
afterAction() method, it's normally better to use the beforeTravel() and
afterTravel() methods and test for the connector, e.g.:

    beforeTravel(traveler, connector)
    {
        if(traveler == gPlayerChar && connector == frontDoor)
          ...
    }

The limitation on this is that the notifications are only called where
there's a TravelConnector (Room, Door or other TravelConnector object)
to be traversed. Where exits point to strings, methods or nothing at all
you may have to fall back on using gTravelActionIs() in a beforeAction()
or afterAction() routine. The problem is that in this kind of case there
is no connector object to pass as a parameter to the beforeTravel()
notification methods. Instead, when you define the direction property of
a Room as a method or double-quoted string, beforeTravel(gActor,
direction) will be called on every object in scope (allowing any one of
them to veto the proposed travel with an exit macro if desired).
Normally before travel notifications are called as
beforeTravel(traveler, connector), but since in this case there's no
connector object to pass as a parameter we pass the direction object
(e.g. westDir if the actor is trying to go west) instead.

Another potential complication with beforeTravel() notifications is that
they could end up getting called twice during the course of the same
travel action. If one travel connector (typically a TravelConnector or
Door) leads to another (typically a Room, which also inherits from the
TravelConnector class), then what could happen is that the before travel
notifications are triggered on both connectors, both the Door and the
Room it leads to, say. This probably isn't what we normally want; when
we use a beforeTravel(traveler, connector) routine we don't really want
to have to write code that tests for both connectors; normally we'd only
want to test for the one that's connected directly to a direction
property of the traveler's starting location. Neither do we want any
code we've put into a beforeTravel() method to be triggered twice, once
for the Door or other intermediate connector and once for the Room it
leads to. To deal with this problem the first TravelConnector suppresses
the triggering of the beforeTravel notifications on the next provided
the first TravelConnector's **dontChainNotifications** property is true
(which, by default, it is). This means you shouldn't have to worry about
the second beforeTravel notification being triggered on the same turn,
since it will be suppressed. If you actually want both sets of
beforeTravel notifications to be triggered for any reason, just override
dontChainNotifications on the first TravelConnector to nil.

There is also an **afterTravel(traveler connector**) method which is
called on every object in scope just after *traveler* has traveled via
*connector*. Note that this may occur more than once in the course of
the same travel action, e.g. if the traveler travels through a door into
a room then the afterTravel notifications will be sent both by the door
and by the room.

------------------------------------------------------------------------

*adv3Lite Library Manual*  
[Table of Contents](toc.htm) \| [Actions](action.htm) \> Reacting to
Actions  
[*Prev:* Implicit Actions](implicit.htm)     [*Next:* Defining New
Actions](define.htm)    
