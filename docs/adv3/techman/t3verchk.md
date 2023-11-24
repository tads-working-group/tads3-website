![](topbar.jpg)

[Table of Contents](toc.htm) \| [TADS 3 In Depth](depth.htm) \> Verify,
Check, and When to Use Which  
[*Prev:* Action Results](t3res.htm)     [*Next:* How to Create
Verbs](t3verb.htm)    

# Verify, Check, and When to Use Which

*by Steve Breslin  
compiled from discussions on
[rec.arts.int-fiction](news:rec.arts.int-fiction)*

The TADS 3 command execution model gets the command's objects involved
in the execution process, via the dobjFor(verb) and iobjFor(verb) groups
of methods. Part of this process is to decide whether or not to allow
the command to proceed in the first place. The execution model offers
not just one but *two* distinct places for each object to make those
go/no-go decisions. One is the "verify" routine, and one is the "check"
routine.

Broadly speaking, both verify() and check() have the the same mandate,
namely to determine whether or not allow the command to proceed. But
they're not interchangeable; there are definite differences in their
effects. The distinction between the two is a bit subtle, and at times
it can be confusing. This article aims to clarify exactly what each one
is for, and to help you develop a sense of when to use which one.

## Strictly speaking

The verify() stage of action processing is designed to interrupt the
action processing only when there's a "logical" problem with the
command. Pouring a desk or eating a topic - such actions would be
illogical.

In contrast, the check() stage is for commands that *seem* logical
enough, but nonetheless won't work. In these cases, the action still
needs to be quashed, but not until after the parser has decided which
objects could logically be involved. For example, the player tries to
wear some jeans, but the jeans are too small. Maybe the player tries to
melt something with the match, but the match isn't producing enough
heat. In such cases, check() can interrupt the action, and explain the
failure.

## So why the two phases?

The benefit of having a check() stage separate from the verify() step is
not in making the verification stage purely logic-oriented, nor in
removing some of the conditional statements from the action stage. Such
cosmetic adjustments would hardly justify the added complication of the
check() stage.

The point of separating verify() and check() is that it lets the parser
ask the game if a command makes logical sense, *separately* from
determining if the command can actually be executed. It might seem
difficult to separate these two ideas, but the distinction isn't just
philosophical or cosmetic - there's a practical need for it. The
practical need is "disambiguation."

When the player types a command, the parser tries to figure out what the
command means by looking up the associations between words and objects.
Sometimes, a word or phrase might refer to multiple objects. When this
happens, the command is *ambiguous*.

For example, suppose a room contains two cardboard boxes, one white and
one black, and the player types OPEN BOX. Does the player want to open
the white box or the black box? One way of answering the question is to
ask the player to be more specific: "Which box did you mean?" But the
player will be annoyed if we ask this sort of question too often,
especially if a human listener wouldn't need to ask. For example, if the
white box is already open but the black box is closed, a human listener
would assume the player means OPEN BLACK BOX, since that's the only way
the command is useful.

The parser uses verify() to get this sort of information about what
ought to be obvious to the player. When there's enough information to
make the same kind of decision a human listener would, the parser can
successfully resolve the ambiguity without asking the player for help -
that is, the parser can *disambiguate* the command by itself.

check(), in contrast, is for enforcing conditions that *aren't* obvious
to the player, and thus can *not* be used to resolve ambiguous
references. For example, suppose we have our two boxes again, but this
time they're both closed. Furthermore, suppose that the white box is an
ordinary box, but the black box has been glued shut, so that it can't be
opened without some kind of tool.

Now, if the player types OPEN BOX, what does the player mean? The *game*
knows that OPEN BLACK BOX won't work - but *the player doesn't know this
until she tries it*. So from the player's perspective, OPEN BLACK BOX is
a perfectly logical command: the box is closed, and to all appearances
it's something that can normally be opened, so OPEN BLACK BOX makes
perfect sense. OPEN WHITE BOX likewise makes perfect sense. So it's
equally logical for the player to mean either one: the parser has to ask
the player which box she meant in this case. The parser can't assume
that the player meant OPEN WHITE BOX just because the game knows that
OPEN BLACK BOX won't work. If the parser did this, it could take the
player by surprise - the player might really have meant OPEN WHITE BOX,
and would be surprised if the parser interpreted the command to mean
something else.

The point of separating verify() and check(), then, is to let the parser
ask whether an action is logical, and then separately determine whether
the action is actually possible.

Now, this discussion raises another question. We can see why we need to
separate verify() and check(), but why do we need to separate check()
and action()? In other words, why not just check the "possibleness"
conditions - the box being glued shut, for example - during the action()
phase?

The main reason to separate check() from action() comes into play with
two-object commands, such as PUT X IN Y. In these cases, we might have
action() handlers for both the direct and indirect objects. The order of
execution for the action handlers depends on the verb - for PUT X IN Y,
we run the indirect object handler first, but for some verbs it's the
other way around. Now, if we did all of our checking in one or the other
action handler, we might run into a slight problem: what if the action
handler that runs second needs to block the command?

The separate check() phase solves this problem. We run the check()
handlers for both objects *before* we run *either* action() handler.
This ensures that either object can cancel the command before any part
of the command has been carried out.

This means that it's important to remember that check(), like verify(),
shouldn't actually carry out any part of the command. In particular,
these routines shouldn't make any changes to "game state" - they
shouldn't move any objects around, change properties, etc. All game
state changes should be put off until the action() phase, when we know
that we've passed all of our tests and that the action is allowed to
proceed.

## Thinking about this from disambiguation: an extended example

Without recourse to a potentially confusing philosophical distinction
between logical and illogical, we can understand the use of the check()
stage as one which enables us to make extra adjustments to interactive
disambiguation questions. (Interactive disambiguation questions are the
questions which the game generates when the player makes an ambiguous
command: "Which fan do you mean? The....")

*An object which fails in the check() phase is favored over an object
which fails in the verify() phase, as far as disambiguation is
concerned.* In fact, during disambiguation, the parser doesn't even call
the check() method. The parser calls the verify() method to narrow down
the field, and then might have to ask the player to choose from the
remaining objects, but the parser doesn't call check() at all until
after the objects have been chosen.

For example, we have three fans, one which is a fixed ceiling fan, which
can be turned on and off, one which is a takeable oscillating fan, but
which can only be taken when it is off, and one which is a hand-fan, a
stylized pingpong paddle if you will. First we'll discuss verify() by
itself, and then we'll discuss verify() in combination with check().

### Good use of verify()

Say the player types:

    >turn fan on

We definitely want to exclude the hand-fan, since it's obvious that the
hand-fan can't be turned on or off, so this exclusion goes in the
verify. So we might get the following disambiguation question:

    >turn fan on
    Which fan do you mean, the oscillating fan, or the ceiling fan?

Now let's say that one of these fans is already on -- we would want to
eliminate this option also, or else we're effectively asking: "Which fan
do you mean, the fan that's already on, or the fan that is off?" The
verify() stage is designed to eliminate the obviously silly
interpretation of the command when there are other good options.

So if the ceiling fan is on, and the oscillating fan is off, we want
something like this:

    >turn fan on
    (the oscillating fan)
    Done.

Now let's think about the case in which all three fans fail the verify()
stage: the hand-fan obviously cannot be turned on, the other two are
already on, so they can't be turned on either. If the player types:

    >turn fan on

-- we need to ask which fan is intended, so that we can print the
appropriate failure message. So when all three fail the verify() stage,
a disambiguation question like this is asked:

    >turn fan on
    Which fan do you mean, the hand-held fan, the oscillating fan,
    or the ceiling fan?

All of these will fail, of course, but they'll fail for different
reasons, so we need to ask which the player meant before we explain why
what the player is trying to do isn't going to work.

### Combining verify() and check()

So far we have an example of how verify() is used. Let's continue with
this example to explore how check() is used in combination with verify()
to make the intended disambiguation messages. We'll change the verb from
"turn on" to "take".

The ceiling fan cannot be taken ever, since it's attached to the
ceiling. The oscillating fan can be taken when it's off. The hand-held
fan can be taken at any time. Let's say the oscillating fan is off:

    >take fan

It's pretty clear what we want here:

    >take fan
    Which fan do you mean, the oscillating fan, or the hand-held fan?

Note that the ceiling fan isn't an option, since it can't be taken: it
has failed the verify() stage. The two good options are offered in
interactive disambiguation.

Now what if the oscillating fan is on:

    >take fan

What do we want here? The answer to this question determines whether or
not we want the oscillating fan's takeable-condition to be in check() or
verify(). Is it obvious to the player that the oscillating fan cannot be
taken when it is on? If not, we want this:

    >take fan
    Which fan do you mean, the oscillating fan, or the hand-held fan?

The above is produced when the fan.isOn condition goes in check(). If we
instead put this condition in verify(), we will get this:

    >take fan
    (the hand-held fan)
    Taken.

If we want to eliminate the oscillating fan during object resolution,
then we put the condition in verify(), so that the game will know that
it's supposed to assume the player is referring to the hand-held fan
when the oscillating fan is on. We should only do this if it should be
obvious to the player that the oscillating fan cannot be taken when it's
on. (Making too many assumptions about what the player means can spoil
puzzles sometimes, and is somewhat intrusive generally speaking. In this
sense, "logical" means "what's logical or obvious *to the player*." The
verify() stage being a logic test should be understood in this spirit.)

We can make one other consideration: let's say that the hand-held fan is
directly contained by the player character. The oscillating fan is on,
and standing on the desk, and the ceiling fan is circling overhead. How
do we want to handle this:

    >take fan

Deciding this will also help us determine whether or not we want the
fan.isOn condition to be in check() or verify(). If it's not obvious
that the oscillating fan cannot be taken, we want the following:

    >take fan
    (the oscillating fan)
    You try to take it, but it's too awkward to grab while it's oscillating.
    Maybe you should turn it off first.

But if we want the following:

    >take fan
    Which fan do you mean, the ceiling fan [which cannot be taken], the
    hand-held fan [which you already have], or the oscillating fan [which
    cannot be taken because it's on]?

-- then we should put the oscillating fan's isOn condition in verify().
Whether you want to assume that the player means the oscillating fan in
this case is up to you; the "logic" will be different between games,
based on the context, how obvious the situation is to the player, and
based on the game author's sense of taste in deciding what player
knowledge should or should not be assumed.

*The point is that you should choose where the condition goes based on
what you want to see in the disambiguation phase.*

Of course, you don't need three fans to make up your mind about where
the code should go, but you can imagine other objects in your game that
could be competing with your object, to help you determine where the
code should go from a stylistic point of view.

From a goal-oriented perspective, it all comes down to the practical
implications of putting a condition in one place or another, and often
there are no practical consequences, in fact, to the distinction between
check() and verify(); but you can imagine disambiguation conflicts to
insure you're using the right style in principle.

## check() and beforeAction()

Traditionally, the library ran the "before" notifiers - beforeAction and
roomBeforeAction - *before* the check() phase. Starting with version
3.0.15.1 of the library, however, you can optionally enable a new,
alternative ordering that runs the check() phase first.

To enable the alternative ordering, set gameMain.beforeRunsBeforeCheck
to nil. By default, this property is set to true, which tells the
library to use the traditional ordering - "before" first - this ensures
that existing code will work as it always has.

The reason you might want to use the alternative ordering is that it
lets you consider a command to be more or less "committed" by the time
the "before" handlers are reached. In other words, the "before" handlers
can assume that the command will run to completion. The reason they can
make this assumption is that they know that they're running after the
check() phase. If the action makes it as far as the "before" handlers at
all, the check() phase will have already judged the command to be
acceptable as far as the check() tests are concerned.

So, when we get past the check() stage, we know that a viable action is
under way. Any objects which want to interfere with that action can then
do so with beforeAction(). This means that check() can interrupt an
action before other objects, say NPC's, have a chance to react to it. So
a good use of check() can avoid sequences like this:

    >ask stu about chair
    As you are about to speak, Mary kicks you under the table. Glaring at
    her, you redirect your question to Dave.
    The large chair isn't something you need to be asking about.

In the above example, Mary's response was a beforeAction(), and the line
about the large chair being an unimportant topic was mistakenly placed
in the action phase rather than the check() phase. By failing the
command before the action phase, we could have avoided printing Mary's
beforeAction() message. So if we want to tell the player that the chair
is an unimportant topic before Mary becomes involved, we need to use the
check() phase.

It is important to remember, therefore, that check() really is another
verification phase, and not a preliminary action phase. Only if a
command passes check() should a change in game state be made. In other
words, some initial conditional statements should be part of the action
stage. The check() stage should not perform preliminary checks which
determine which action methods are called.

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](toc.htm) \| [TADS 3 In Depth](depth.htm) \> Verify,
Check, and When to Use Which  
[*Prev:* Action Results](t3res.htm)     [*Next:* How to Create
Verbs](t3verb.htm)    
