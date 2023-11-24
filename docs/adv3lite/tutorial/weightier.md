![](topbar.jpg)

[Table of Contents](toc.htm) \| [Goldskull](goldskull.htm) \> Weightier
Matters  
[*Prev:* Improving the Game](improving.htm)     [*Next:* Everything in
its place](inplace.htm)    

# Weightier Matters

## Weighing it up

In the code used to decide whether or not to spring the trap when the
player character takes the skull from the pedestal, we simply counted
the number of items on the pedestal. This is fine in this game when
there's only two portable objects in any case, but if this puzzle were
part of a rather larger game with rather more portable objects in it, it
might not be the best way to do things.

To illustrate the problem, try adding another small object to the cave
location:

    + pebble: Thing 'tiny pebble; smooth round'
        "It's just a tiny, round pebble, almost perfectly smooth. "
    ;

Now compile and run the game again. You'll find that putting the tiny
pebble on the pedestal works just as well in avoiding the trap as using
the more substantial rock, but that doesn't seem to be right. Presumably
the springing of the trap is in some way related to the weight resting
on the pedestal, and while the rock might plausibly weigh the same as
the skull, the pebble must be a *lot* lighter. Of course we could change
the notifyRemove() method on the pedestal to check precisely which
objects are on the pedestal when the rock or the skull is about to be
removed, but that's rather an ad hoc solution, and the more objects
there are in the game, the more complex and messy and ad hoc it will
become, and the more chances there are of it not working properly. In
principle the player should be able to use any combination of objects
that weigh as much as or more than the skull and it should work to avoid
springing the trap.

The best way to produce a fully general solution, then, is to have the
springing of the trap dependent on the total weight of all the items
resting on the pedestal. The adv3Lite library doesn't keep track of
weight by default, but it's easy enough to modify Thing so it does.
Here's a first attempt (which you could add right at the end of your
existing code):

    modify Thing
        weight = 1
        
        getWeightWithin()
        {
            local totalWeight = 0;
            for (local item in contents)
                totalWeight += item.weight;
            
            return totalWeight;
        }
    ;

This adds a new weight property to the Thing class and defines the
default weight of every object as 1 (the unit can be whatever you
imagine it to be, absolute precision isn't required here in any case;
what we're really interested in is the rough relative weights of
different objects within the limitations of integer arithmetic). For the
sake of this exercise we'll leave the weight of the pebble as 1 (which
it now inherits from the modified Thing, so we don't need to state it
explicitly) and make the weight of both the rock and the skull 10.
(Note: adv3Lite in fact comes with a
[Weight](../../extensions/docs/weight.htm) extension which we could use
to implement this, but it will be more instructive for the sake of this
tutorial to do it from scratch; besides adv3Lite extensions are beyond
the scope of this tutorial).

    ++ goldSkull: Thing 'gold skull;; head'
        "It's the shape and size of a human skull, but made of solid gold; it must
        be worth a fortune. "
        
        weight = 10
    ;

    + smallRock: Thing 'small rock; round solid'
         "It's roughly round and looks pretty solid. "
        
        weight = 10
    ;

The next step is to arrange for the trap to be sprung when the total
weight of objects resting on the pedestal is less than the weight of the
skull:

    + pedestal: Fixture, Surface 'stone pedestal; smooth'
        "The smooth stone pedestal is artfully positioned to catch the sunlight at
        just this time of day. "
            
        notifyRemove(obj)
        {
            gMessageParams(obj);
            
            if(getWeightWithin() - obj.weight < goldSkull.weight)
            {
                "As {the subj obj} {leaves} the pedestal, a volley of poisonous
                arrows is shot from the walls! You try to dodge the arrows, but
                they take you by surprise!";  
                
                finishGameMsg(ftDeath, [finishOptionUndo]);  
            }
        }
    ;

Note how we specify this. The total weight of objects resting on top of
the pedestal just before *obj* is removed is given by the new
getWeightWithin() method we just defined on the modified Thing class. So
the weight remaining on the pedestal after obj (i.e. the object that's
being removed) is removed, is getWeightWithin() - obj.weight. The trap
is sprung if this is less than the weight of the gold skull. Note that
we haven't specified any numbers here (such as 10); we've kept the code
as general as we can so that if, for example, we later changed our mind
about the weight of the skull and decided it should be 20, everything
would still work in a logical manner.

Another point to note is the introduction of the gMessageParams(obj)
construct, and the subtle change of the start of the double-quoted
string to "As {the subj obj} {leaves} the pedestal..." These two changes
very much go together: {the subj obj} is a *message parameter
substitution*, something we'll be seeing quite a bit of later. What this
means is that when the game sees {the subj obj} (the message parameter)
it *substitutes* the name of the object *obj* that is being removed (so
this does much the same as the previous \<\<obj.theName\>\> that it
replaces). So what's the point of it? You'll note that it's now followed
by {leaves} rather than leaves. The subj in {the subj obj} tells the
game that *obj* is the subject of the verb that follows. By marking
leaves as {leaves} we indicate that this is the verb which has to agree
with obj. This means that if obj were something with a plural name, 'the
rocks', say, the game would output "As the rocks leave the pedestal"
rather than "As the rocks leaves the pedestal", but if it's singular,
'the rock', say, we get "As the rock leaves the pedestal." This kind of
subject-verb agreement is hard to achieve using the \<\<obj.theName\>\>
method but easy to achieve using message parameter substitution.

To make it work, we have to identify obj as a *parameter name* as well
as a *variable name*. That is what gMessageParams(obj) does for us: it
tells the game, "treat obj as a parameter that refers to the same object
that the obj variable does". At first this may seem very arcane, since,
after all, obj and obj appear identical! But in fact they are different
things in different contexts. In notifyRemove(obj) or obj.weight, obj is
a variable name referencing an object; in {the subj obj} obj is simply a
piece of text within a string. The difference is really that between obj
(a variable name) and 'obj' (a piece of text). We need the
gMessageParams(obj) statement to make the program recognize that the
string 'obj' refers to the variable obj in the special context of a
message parameter substitution like {the subj obj} within a string.

Don't worry if this isn't all entirely clear yet, as we'll be coming
back to message parameter substitutions, and they'll make more sense as
you get used to them. One last point to note about them right now,
though, is that putting braces round a verb like {leaves} doesn't work
for all verbs, but only those irregular verbs the library knows about
(which is more about two hundred of the common ones). It is possible for
your game to define additional verbs that can be understood in message
parameter substitutions, but that's not a subject for now.

We're still not done yet, however, since there is a logical error in the
way we've defined the getWeightWithin() method, as you may have already
spotted. To demonstrate what it is, we'll introduce another object into
the game, a knapsack worn by the player character. We can define it like
this:

    ++ knapsack: Wearable, Container 'knapsack; trusty old worn; bag sack'
        "Your trusty old knapsack may be getting a bit worn, but it's accompanied
        you on so many adventures you wouldn't be without it. "
        
        wornBy = me
    ;

We could have defined the knapsack as a Thing with isWearable = true and
contType = In, but we're sticking to our decision to use the library
classes for this kind of thing. Here Wearable contributes isWearable =
true and Container contributes contType = In. We still have to supply
wornBy = me, however, since a Wearable object isn't necessarily worn; it
might also be carried. In his case we want it to start out worn by the
player character, so we set wornBy = me. We also need to ensure that the
definition of the knapsack object follows directly after the definition
of the me object in our code, so that the knapsack forms part of the
player character's contents.

Try recompiling the game and playing it with the knapsack added. Go into
the cave, put the rock into the knapsack, and then put the knapsack onto
the pedestal. Now take the gold skull. You'll find the trap is still
sprung, even though the knapsack with the rock in it ought to weigh
enough to have prevented it. You've probably already worked out what the
problem is: getWeightWithin() calculates the total weight of an object's
contents by adding up the weights of each item in its contents list —
ignoring any further items they may happen to contain in turn. What it
should do is to add up the weight of every items in its contents, plus
the weight of the items *they* contain, and so on all the way down the
chain, plus the weight of the original object. Just a couple of small
changes should fix it:

    modify Thing
        weight = 1
        
        getWeightWithin()
        {
            local totalWeight = 0;
            for (local item in contents)
                totalWeight += item.getWeight;
            
            return totalWeight;
        }
        
        getWeight = weight + getWeightWithin()
    ;

At first sight this may look a little odd, since getWeightWithin() now
calls itself as part of its calculation. In fact this *recursion*, as
its called, is a perfectly legal and often useful programming technique,
provided it's handled with care. For example, if there was any danger
that getWeightWithin() might call itself on the same object that was
doing the calling (for example, that knapsack.getWeightWithin() might
call knapsack.getWeightWithin()) then we would indeed be in trouble, for
our code could then get itself into an infinite loop from which it would
never emerge and our game would hang. The golden rule of recursion is to
ensure that there's always some way to end it, but here we're safe since
each recursive call goes a step down the containment tree, and however
far the containment tree goes, it can never be infinite (unless we've
done something *really* weird in our game code) so we can be sure it'll
bottom out somewhere (specifically, when getWeightWithin() is called on
an item like the rock that has no contents, the for loop has nothing to
do, so there's no further recursion). Note that we've also added a
getWeight property, which is the total weight of a Thing (the weight of
the object itself plus the weight of everything that it contains) and
that we've defined this property as an expression, which is perfectly
legal in TADS 3.

By the same token we need to ensure that the weight of any item we
remove from the pedestal includes the weight of its contents, so we want
to use the getWeight property of the object being removed rather than
just its weight property:

    + pedestal: Fixture, Surface 'stone pedestal; smooth'
        "The smooth stone pedestal is artfully positioned to catch the sunlight at
        just this time of day. "
            
        notifyRemove(obj)
        {
            gMessageParams(obj);
            
            if(getWeightWithin() - obj.getWeight < goldSkull.weight)
            {
                "As {the subj obj} {leaves} the pedestal, a volley of poisonous
                arrows is shot from the walls! You try to dodge the arrows, but
                they take you by surprise!";  
                
                finishGameMsg(ftDeath, [finishOptionUndo]);  
            }
        }
    ;

If you compile and run the game again, you should find it runs as
expected.

## Throwing Stones

Although we've designed the game so that the way to get the gold skull
is to place the rock on the pedestal first, that's not the only solution
that might occur to the player. Another way to use the rock might be to
throw it at the skull to knock it off the pedestal while the player
character stands far enough away to avoid the volley of deadly arrows.
Whether or not we allow this solution, a well-designed game ought to
anticipate the attempt and provide an appropriate response. The
library's default response to throwing something at something else is to
have the missile strike the target and fall to the ground without
affecting anything else. That's probably an appropriate response to the
player throwing the pebble at the skull, but if the rock is thrown at
the skull, it really should dislodge it from the pedestal. Let's say
that the skull will be knocked off the pedestal if the object thrown at
it is at least half its weight, then if we want the rock-throwing
solution to succeed, we might write:

    ++ goldSkull: Thing 'gold skull;; head'
        "It's the shape and size of a human skull, but made of solid gold; it must
        be worth a fortune. "
        
        weight = 10
        
        iobjFor(ThrowAt)
        {
            action()
            {
                if(location != pedestal || gDobj.getWeight() < weight / 2)
                    inherited;
                else
                {
                    moveInto(cave);
                    gDobj.moveInto(cave);
                    "{The subj dobj} {strikes} the gold skull, sending both objects
                    tumbling to the floor. At the same time, a volley of poisonous
                    arrows is shot from the walls! Fortunately you're standing just
                    far enough away to avoid being hit. ";
                }
            }
        }
    ;

If, on the other hand, we don't want this solution to work (perhaps the
cave isn't big enough to allow the player character to stand far enough
away to avoid the trap), we can use the slightly simpler:

    ++ goldSkull: Thing 'gold skull;; head'
        "It's the shape and size of a human skull, but made of solid gold; it must
        be worth a fortune. "
        
        weight = 10
        
        iobjFor(ThrowAt)
        {
            action()
            {
                inherited;
                if(gDobj.getWeight() >= weight/2 && location == pedestal)
                    actionMoveInto(cave);
            }
        }
    ;

Okay, so let's take a closer look at what's going on here. The command
THROW ROCK AT SKULL consists of a verb (throw), two nouns (rock and
skull) and a preposition (at). This kind of action is said to have two
*objects*, the *direct object*, coming between the verb and the
preposition (in this case the rock) and the *indirect object*
immediately following the preposition (in this case the gold skull).
When we write a section of code that starts iobjFor(ThrowAt) we're
defining what happens to this object (in this case the gold skull) when
it's the *indirect object* of a ThrowAt action (or, in plainer English,
the target of a throw); remember, whenever you see 'iobj' think
'indirect object'.

There are several stages in the action processing cycle at which the
gold skull could respond to being the target of a throw, but in the
interests of keeping things as simple as possible we shan't go into them
all now. The stage we're interested in is the action() stage, which
means that the action has passed all the tests that might rule it out
(for example trying to throw something that's too heavy to pick up, or
throw something at a target that's too far away) and is now going ahead.
In the action() part we simply define what the action does (in this
case, what happens when something hits the gold skull).

One thing we need to know in writing this action part is what's just
been thrown at the gold skull, in other words what the direct object of
the ThrowAt command is. This is stored in the object property
libGlobal.curAction.getDobj(), but since that's rather a lot of typing
for something so commonly needed, the library lets us abbreviate it to
gDobj. (Technically, gDobj is a macro masquerading as a pseudo-global
variable, but you really don't need to worry about that right now unless
you were desperately anxious about what sort of thing gDobj could
possibly be in a language that doesn't have any global variables). You
could similarly use gIobj to get at the indirect object of the command
if you needed it (but here we know the indirect object must be the gold
skull, since that's where we're defining this iobjFor() code).

Remember that the inherited keyword means "at this point do what the
method we're inheriting from would have done"; in this context it thus
means "carry out the default ThrowAt handling" (which is to report that
the missile has struck the target and landed on the floor, and to move
the missile to the enclosing room).

Armed with those pieces of information we're now in a position to
examine how each version of the ThrowAt handling works. In the first
version above, which makes throwing the rock at the skull a successful
solution to the puzzle, we first check whether it's the case either that
the skull isn't on the pedestal any more, or that the missile being
thrown at it (gDobj, the direct object of the command) is less than half
the weight of the skull (since this is being defined on the goldSkull
object, weight unqualified by any other object name refers to the weight
of the skull). If either of these two conditions is met (the skull is no
longer on the pedestal or the missile being thrown at it is too light to
dislodge it), we carry out the inherited handling (the missile strikes
the skull and falls to the ground). Otherwise (if the missile is heavy
enough and the skull is on the pedestal), we move both the skull and the
missile to the cave room (representing the fact that they both end up on
the floor) and report what happens. Note the use of the message
parameter substitutions "{The subj dobj} {strikes}" at the begining of
this report. If it's the rock that's thrown this becomes "The small rock
strikes" before it's displayed to the player, but because it's been
written with message parameter substitutions it will name the correct
object whatever the player throws at the skull.

You may be wondering about the difference between gDobj and {The subj
dobj}, both of which have been used to refer to the direct object of
this command in this short piece of code. The difference is that {The
subj dobj} simply produces some text, the name of the direct object, and
marks it as the subject of the verb that's about to follow (that's what
the subj part is for), while gDobj provides a reference to the object
itself. We need to move the object to the floor, not it's name;
conversely we need to display the object's name, not the object. More
concretely, gDobj refers to the smallRock object while "{The subj dobj}"
expands into the string 'The small rock'.

The second example, where we don't allow throwing the rock as a
successful solution to the puzzle, is a bit simpler. We start by
carrying out the inherited handling in any case, since whatever happens
we want to report the missile striking the gold skull and then falling
to the floor. Then, if it's the case that the skull is on the pedestal
and the missile (i.e. the direct object) is at least half the weight of
the skull, we move the goldSkull object to the cave (here representing
the floor of the cave). Since we here do so using actionMoveInto(cave)
rather than just moveInto(cave) as we did in the first version, the
removal of the skull from the pedestal will trigger the pedestal's
notifyRemove(obj) method which, you may recall, reports the launching of
the poison arrows and the death of the player character. Conversely, we
used moveInto() rather than actionMoveInto() in the first version to
avoid precisely this happening.

Don't worry if you're thinking there's rather a lot to take in here, or
you're wondering how the heck you'd ever be able to work all this out
for yourself. If it's all new to you it's bound to seem a bit odd and
confusing at first. As you work through this tutorial this kind of thing
should gradually become more familiar to you and you'll gradually gain
confidence with it.

------------------------------------------------------------------------

*adv3Lite Library Tutorial*  
[Table of Contents](toc.htm) \| [Goldskull](goldskull.htm) \> Weightier
Matters  
[*Prev:* Improving the Game](improving.htm)     [*Next:* Everything in
its place](inplace.htm)    
