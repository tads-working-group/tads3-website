![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Core Library](core.htm) \> Topics  
[*Prev:*Multilocs](multiloc.htm)     [*Next:* Beginnings](beginning.htm)
   

# Topics

Virtually all the classes we have encountered so far are for
implementing physical objects that appear in the game world, such as
rooms, door, keys and things. Under certain circumstances, though, such
as conversation, or thinking about things, or looking things up, we may
need to refer to abstractions such as democracy, or the weather, or
quantum mechanics. Under the same circumstances we may also want to
refer to people or objects that aren't actually implemented in our game,
such as Napoleon Bonaparte, or the planet Jupiter, or even Aunt Maude's
necklace if it's simply a topic of conversation and never makes a
physical appearance in the game. For these purposes we can define a
Topic:

    tBonaparte: Topic 'Napoleon[n] Bonaparte';
    tJupiter: Topic 'Jupiter';
    tNecklace: Topic '() Aunt Maude\'s necklace';

Note that the property we are defining in the Topic template is the
[vocab](thing.htm#vocab) property, which works in precisely the same way
as it does for Thing (both Thing and Topic inherit the way vocab works
from LMentionable). Amongst other things this means that by defining
this property we are also defining the name property of the Topic (and
with it, theName, aName, etc.). In the adv3Lite library these properties
can sometimes be useful, as we shall see. It is therefore a good idea to
define the vocab property of a Topic in just the same way as you would a
Thing.

Note also that we gave each of our Topic objects a name beginning with
t. We don't have to do this, but it can be useful to employ some such
convention (other authors sometimes use 'top' rather than just 't') to
readily distinguish Topics from objects representing Things.

We have yet to encounter a situation where a Topic is actually useful,
since the parts of the library that actually make use of Topics are all
in the optional modules. Topic itself needs to be in the core library,
however, so that the parser understands how to deal with a Topic, and so
that actions that work with Topics can be defined in the core modules
action.t and actions.t. There's a couple of general points it's useful
to know about how the core library deals with Topics, since these apply
throughout the library:

- A Topic is considered in scope for a command that expects a topic if
  the topic is known to the player character (i.e., if its isFamiliar
  property is true).
- When the parser is looking for a Topic, it may also match a Thing
  (this makes sense since the player may want to talk or think about
  game objects as well as abstract concepts or things that aren't in the
  game). A Thing is likewise in scope for matching as a Topic when the
  player character knows about it.

By default, all Topics start out familiar. This is probably the more
common case, since the kinds of thing implemented as Topics tend to be
the kinds of thing people will have heard of (the weather, democracy or
Napoleon Bonaparte for example). But it may not always be the case; the
player character may not know of Aunt Maude's necklace, for example,
until someone mentions it in conversation. In that case we would want to
start out with the tNecklace object having its familiar property set to
nil. The quick way to do that is through the Topic template, for which
the second, optional, element, defined with an @ sign, defines the value
of the familiar property:

    tNecklace: Topic '() Aunt Maude\'s necklace' @nil;

------------------------------------------------------------------------

*adv3Lite Library Manual*  
[Table of Contents](toc.htm) \| [The Core Library](core.htm) \> Topics  
[*Prev:* MultiLocs](multiloc.htm)     [*Next:*
Beginnings](beginning.htm)    
