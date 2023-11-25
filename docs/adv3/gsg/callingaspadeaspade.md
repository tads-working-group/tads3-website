::: topbar
[![](topbar.jpg){border="0"}](index.html)
:::

::: main
[\[Main\]](index.html)\
*[\[Previous\]](buryingtheboots.htm)   [\[Next\]](lettherebelight.htm)*

## Calling a Spade a Spade

Clearly leaving the spade conveniently leaning against the wall of the
cave is a bit too obvious, even for a simple tutorial game such as this.
It obviously needs to start life somewhere else, and in fact we\'ve
already indicated where that somewhere else must be, since we\'ve
already described the charcoal burner as wielding a spade. To obtain the
spade, therefore, Heidi needs to ask Joe for it.

\
This may be achieved by first of all adding a suitable AskForTopic to
the list of TopicEntries in the burnerTalking InConversationState. Here
again this is an exercise you might like to try for yourself before
turning over the page to see how this guide does it. An
AskForTopic works just like the other types of TopicEntry we\'ve seen,
except that it responds to **ask for whatever** instead of, say, **ask
about whatever**. You\'ll need to make sure that your new AskForTopic
responds specifically to a request for the spade, and that it results
not only in Joe saying Heidi can take it, but in Heidi actually
acquiring it. You\'ll also need to handle the case where the player
issues an **ask for spade** command when Heidi already has the spade.
And, of course, you\'ll need to make some appropriate adjustments to the
spade object itself, so that it starts out being carried by Joe rather
than leaning against the wall of the cave.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

This is how we do it here:\
\
++ AskForTopic @spade\
   topicResponse\
   {\
      \"\<q\>Could I borrow your spade, please?\</q\> you ask.\<.p\>\
      \<q\>All right then,\</q\> he agrees a little reluctantly, handing you the \
       spade, \<q\>but make sure you bring it back.\</q\>\";\
      spade.moveInto(gActor);      \
   }\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

If you compile the game (yet again) and try all this out, you\'ll find
that there\'s still a problem: even after Joe hands the spade over he\'s
described as still leaning on it (while he\'s talking) or still using it
(when he goes back to work). But this problem turns out to be an
opportunity to show how to give Joe a slightly wider range of behaviour.
The approach we\'ll take is to give him another pair of ActorStates
which define what he does when he\'s without his spade. We\'ll assume
that once he\'s handed over his spade he\'s particularly anxious to get
it back, and won\'t discuss anything until it\'s been returned. The
implementation relies on switching ActorStates as Joe gives the spade to
Heidi and as Heidi gives it back again. The two new ActorStates may be
defined as follows:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

+ burnerFretting : InConversationState\
  specialDesc = \"{The burner/he} is standing talking to you with his\
   hands on his hips. \"\
  stateDesc = \"He\'s standing talking to you with his hands on his hips. \"\
  nextState = burnerWaiting\
;\
\
++ burnerWaiting : ConversationReadyState\
  specialDesc = \"{The burner/he} is walking round the fire, frowning as\
   he keeps instinctively reaching for the spade that isn\'t there. \"\
  stateDesc = \"He\'s walking round the fire. \"  \
;\
\
+++ HelloTopic\
   \"\<q\>Hello, there.\</q\> you say.\<.p\>\
    \<q\>Hello, young lady - have you brought my spade?\</q\> he asks. \"\
;\
\
+++ ByeTopic\
    \"\<q\>Bye, then.\</q\> you say.\<.p\>\
    \<q\>Don\'t be too long with that spade - be sure to bring it right \
      back!\</q\> he admonishes you. \"\
;\
\
++ GiveShowTopic @spade\
  topicResponse\
  {\
    \"\<q\>Here\'s your spade then,\</q\> you say, handing it over.\<.p\>\
    \<q\>Ah, thanks!\</q\> he replies taking it with evident relief. \";\
    spade.moveInto(burner);\
    burner.setCurState(burnerTalking);\
  }\
;\
\
++ AskForTopic @spade\
  \"He doesn\'t have the spade. \"\
  isConversational = nil\
;\
\
++ AskTellTopic @spade\
  \"\<q\>This seems a very sturdy spade,\</q\> you remark.\\b\
   \<q\>It is \-- look after it well, I need it for my work!\</q\>\
    {the burner/he} replies. \"\
;\
\
+++ AltTopic\
  \"\<q\>I seem to have left your spade somewhere,\</q\> you confess.\\b\
  \<q\>I hope you can find it then!\</q\> {the burner/he} remarks \
   anxiously. \"\
  isActive = (!spade.isIn(burner.location))\
;\
\
\
++ DefaultAskTellTopic\
  \"\<q\>We can talk about that when I\'ve got my spade back,\</q\>\
      he tells you. \"\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

There\'s only a couple of points to note here. The first is that we
include an AskForTopic to handle the case where the player asks for the
spade again when Joe\'s already handed it over; since Joe will always be
in the burnerFretting state when he doesn\'t have his spade, we simply
include this AskForTopic as one of the TopicEntries in that state. In
this case, instead of having Joe respond we simply display a message
indicating that Joe is spadeless (we add an appropriate AskTellTopic and
AltTopic to handle the case in which Heidi talks about the spade while
Joe is in this state). We then add isConversational = nil to the
definition of the topic to show that this is not a conversational
interchange, so no greeting protocols will be initiated by the player
character asking Joe for the spade while he\'s in this in state.\
\
The second is that for all this to work as expected it is, of course,
necessary to relocate the spade from the cave to the burner in your
code.\
\
The third is the explicit definition of nextState = burnerWaiting in the
burnerFretting state; this is necessary because we change from one
InConversationState to another in mid-conversation, and without the
explicit definition of nextState (which defines which ActorState the
Actor is to switch to when the conversation is terminated from that
InConversationState) the program becomes a bit confused by the
mid-conversation switch of states. For the same reason we now need to
add nextState = burnerWorking to the definition of burnerTalking. The
other point worth noting is the use of setCurState(state) to change the
actor\'s current actor state (don\'t simply write something like
burner.curState = burnerTalking;). We need to use the same method in our
handling of AskFor to get Joe to switch into his burnerFretting state.
Add the following line immediately after spade.moveInto(gActor); in the
topicResponse method of the first AskForTopic @spade:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -------------------------------------------
                                      getActor().setCurState(burnerFretting); \

  ----------------------------------- -------------------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Everything should now work fine, but there is one more refinement we can
add, not because the game really needs it, but because it allows us to
try out an aspect of TADS 3 NPC programming we haven\'t seen yet. So
far, the player has taken all the initiative in starting a conversation;
in TADS 3 it\'s possible to make an NPC initiate a conversation. In this
game, we\'ll make Joe so anxious to get his spade back that every time
Heidi walks into his clearing he\'ll ask for it (until he gets it back),
without waiting for her to address him first. We do this using his
initiateConversation(state, \'name\') method, where state is the name of
the ActorState (normally an InConversationState) we want him to switch
into, and \'name\' is the name of a Conversation Node we want activated
(as the NPC\'s way of initiating the conversation). Within the
Conversation Node we define an npcGreetingMsg (we could use an
npcGreetingList instead) to display what Joe does and says to start the
conversation. We can also use an npcContinueMsg (or npcContinueList) to
contain Joe\'s further prompting if the player fails to respond with a
conversational command (to create the impression that Joe does really
want a reply). In this case, we\'ll have Joe pose a question that
requires a simple yes or no answer, which we can deal with using a
YesTopic and a NoTopic (rather than having to define any SpecialTopics
or whatever). The new ConvNode and its associated topics then look like
this:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

+ ConvNode \'burner-spade\'\
  npcGreetingMsg = \"\<.p\>He looks up at your approach, and walks\
   away from the fire to meet you. \<q\>Have you finished with my spade\
   yet?\</q\> he enquires anxiously.\<.p\>\"\
  npcContinueMsg = \"\<q\>What about my spade? Have you finished with it \
   yet?\</q\> {the burner/he} repeats anxiously. \"\
;\
\
++ YesTopic\
   \"\<q\>Yes, I have.\</q\> you reply.\<.p\>\
   \<q\>Can I have it back then, please?\</q\> he asks. \"\
;\
\
++ NoTopic\
   \"\<q\>Not quite; can I borrow it a bit longer?\</q\> you ask.\<.p\>\
   \<q\>Very well, then.\</q\> he conceded grudgingly, \<q\>But I need it\
   to get on with my job, so please be quick about it.\</q\>\"\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The reason we start the npcGreetingMsg with the pronoun \'he\' rather
than {The burner/he} is that in the only context in which this message
will ever be displayed, the player will just have read \"Joe Black/The
charcoal burner is walking round the fire, frowning as he keeps
instinctively reaching for the spade that isn\'t there\", so the
burner\'s name doesn\'t need repeating immediately afterwards.\
\
All that remains is to decide where to insert the call to
initiateConversation. The obvious candidate would be in the
afterTravel(traveler, connector) method of burnerWaiting, since this
will be called after the Player Character travels to Joe\'s location:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

afterTravel(traveler, connector)\
{\
    getActor().initiateConversation(burnerFretting, \'burner-spade\');\
}\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Note the use of getActor() to get the Actor the current state belongs
to. We could just as well have used burner.initiateConversation here,
but there may be cases where getActor would be preferable (for example
if one were defining a custom TopicEntry class for use in a number of
different actors).\
\
At this point it might be worth playing the game through to check that
everything works properly and the game is still winnable. In the next
chapter we\'ll add some more complications.\
\

------------------------------------------------------------------------

*Getting Started in TADS 3*\
[\[Main\]](index.html)\
*[\[Previous\]](buryingtheboots.htm)   [\[Next\]](lettherebelight.htm)*
:::
