::: topbar
[![](topbar.jpg){border="0"}](index.html)
:::

::: main
[\[Main\]](index.html)\
*[\[Previous\]](handlingcashtransactions.htm)
  [\[Next\]](countingthecash.htm)*

# Chapter 8 - Finishing Off

## Filling in Some Gaps

### a. Atmosphere Strings

We have now taken the *Further Adventures of Heidi* about as far as
it\'s worth taking them for the purposes of this Guide. It would be
perfectly possible to go on adding in some further obstacles between
Heidi and that ring (perhaps the oars could be hidden in a less obvious
place, or the pound coins more widely dispersed), but it would become
increasingly difficult to devise something that introduced a new feature
of the library in a worthwhile way, and it might be better to leave such
extensions as an exercise to any readers who wants to practice what they
have learnt. Instead, we shall look at a few ways in which the library
can help lend a bit more atmosphere to the game we\'ve already created.\
\
For the first example, consider the forest through which Heidi keeps
passing. As it stands, the only other living creature she ever
encounters there is Joe the charcoal burner; but one would expect a real
forest to have all sorts of life in it. It\'s not worth creating lots of
animal objects to represent the living forest, but we can use the
atmosphereStrings property to simulate its presence. Rather than coding
a separate atmosphereStrings for each room we consider to be part of the
forest, it will be quicker and easier to define our own ForestRoom class
that encapsulates this behaviour:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

class ForestRoom : OutdoorRoom\
   atmosphereList : ShuffledEventList\
   { \
     \[\
       \'A fox dashes across your path.\\n\',\
       \'A clutch of rabbits dash back among the trees.\\n\',\
       \'A deer suddenly leaps out from the trees, then darts back off into\
         the forest.\\n\',\
       \'There is a rustling in the undergrowth.\\n\',\
       \'There is a sudden flapping of wings as a pair of birds take flight \
         off to the left.\\n\'\
     \]\
     eventPercent = 90\
     eventReduceAfter = 6\
     eventReduceTo = 50\
   }\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Defining a ShuffledEventList as a nested object should be familiar by
now. The Room class has a built-in Room daemon that will call the
doScript method of atmosphereList; in other words, all we have to worry
about is defining the list for eventList, (a property defined in the
template for the EventList class, so we don\'t need to name it
explicitly), and they\'ll automatically be displayed. We can, however,
exercise some control over the frequency with which they\'re displayed,
and that\'s what the three properties eventPercent, eventReduceAfter,
and eventReduceTo are for. As we have set it up, the messages we have
defined will first be displayed 90% of the time, but after 6 turns this
will fall to 50%. There is no need to define these properties at all; if
none of them is overridden, then one of the messages in the list will be
displayed each time the player character is in a room of class
ForestRoom; if only the first is overridden, then that message frequency
will be maintained throughout the game. The purpose of these properties
is we can only define a finite number of strings, and after the player
has seen them the first couple of times their appeal may start to wear a
little thin; reducing their frequency may therefore help towards
increasing the longevity of their positive contribution to the playing
experience.\
\
The three rooms that might best be redefined as belonging to the
ForestRoom class are forest, clearing, and forestPath; you could also
add define fireClearing to be of class ForestRoom, but in practice
you\'ll probably find that the atmosphere strings tend to get in the way
of the conversation with Joe.\

### b. Sensory Emanations

However, there is a different kind of atmospheric upgrade we could apply
to the fireClearing. We have a fire billowing forth smoke, and so far we
have smoke that makes its presence known to the nostrils only when the
player explicitly chooses to smell it. In such a situation one might
expect Heidi\'s nostrils to be assaulted by the smell of smoke whether
she makes an active attempt to sniff it or not. We can simulate this by
locating an Odor object directly inside our smoke object (having removed
the smellDesc property from smoke), thus:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

++ Odor \'acrid smoky smell/whiff/pong\' \'smell of smoke\'\
  sourceDesc = \"The smoke from the fire smells acrid and makes you cough. \"  \
  descWithSource = \"The smoke smells strongly of charred wood.\"\
  hereWithSource = \"You catch a whiff of the smoke from the fire. \"\
  displaySchedule = \[2, 4, 6\]\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The hereWithSource message is displayed as part of the room description,
and then at intervals defined in the displaySchedule list (in this case
first after two turns, then after four turns, and finally every six
turns; if we wanted to switch the smell messages off altogether we could
end this list with nil). This both stops the message from becoming too
intrusive and repetitive, and also models the way in which human senses
tend to take note of the environment. The property sourceDesc contains
what will be displayed if you the player smells the object from which
the smell emanates, in this case the smoke (i.e. it will be displayed in
response to **smell smoke**), while the descWithSource property contains
what will be displayed if the player refers directly to the Odor object,
e.g. with **x smell** or **smell smoky whiff**. There are also
descWithoutSource and hereWithoutSource properties that would contain
messages to be displayed in the event of the source of the odour, in
this case the smoke, being obscured from the player character; but since
in this case the smoke from the fire is all too visible we don\'t need
to define these properties (if, however, one had, for example, a dead
rat concealed in a sandwich box, one could then use these two properties
to contain messages appropriate to the situation before the player opens
the box and discovers the source of the offensive odour; whether and
where to include \"You smell a rat\" I leave to the discretion of the
reader).\
\
If you want to vary the message displayed according to the schedule, you
can override hereWithSource (and/or hereWithoutSource if appropriate)
with a method that checks the displayCount property (which is reset to 1
each time after the object comes within sensory range after it has left
it (in this case, each time you return to the fire clearing after having
been somewhere else). For example:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

hereWithSource\
{\
   switch (displayCount)\
   {\
       case 1:\
           \"You catch a whiff of the smoke from the fire. \";\
        break;\
       case 2:\
           \"You catch another whiff of smoke from the fire. \";\
            break;\
      default:\
           \"You catch yet another whiff of smoke from that wretched fire. \";\
    }\
}\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

An alternative, if you were not concerned about restarting the list
every time the object came into scope, would be to define the
hereWithSource method to call the doScript method of an EventList object
(which could be a nested object attached to the custom property of your
Odor).\
\
Note that you can also define a Noise object in much the same way as the
Odor object is defined here (there are a couple of examples in
sample.t). Perhaps, for example, the fire is making a crackling sound -
once again the implementation can be left as an exercise for the
interested reader (begin by defining
++Noise \'crackling sound/noise\' \'crackling sound\' directly after the
fire object, and then follow precisely the same format as used for the
Odor object, making the obviously necessary adjustments to refer to
sounds instead of smells).\
\

### c. Settling the Score

The maximum score you can obtain by winning the game is 7. Clearly we
need to know how to adjust the maximum score; this is done by adding the
following to the gameMain object, (which you may already have done if
you copied the startup code from the start of chapter 3).\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      maxScore = 7 \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The whole gameMain object for Heidi should look like this:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

gameMain: GameMainDef\
     initialPlayerChar = me\
     showIntro()\
     {\
       \"Welcome to the Further Adventures of Heidi!\\b\";\
     }\
     showGoodbye()\
     {\
       \"\<.p\>Thanks for playing!\\b\";\
     }\
     maxScore = 7     \
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The other routines do what they say: showIntro() shows the introductory
text for the game (which you can make more elaborate if you wish), while
showGoodBye() shows a terminating message when the game ends.\
\
Of course, you may think that there should be more opportunities for
gaining points. In that case you can add more addToScore calls at the
appropriate places, being careful to ensure than they can only be called
once (or use the addToScoreOnce method on new Achievement objects), and
then adjust gameMain.maxScore accordingly.\
\

### d. Destination Names

If at the start of the game you type the command **east** followed by
the command **exits** you\'ll see the response:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

   Obvious exits lead south; west, back to the in front of a cottage;
and northeast.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

This is less than ideal; \"back to the in front of a cottage\" is not
exactly elegant. And you\'d get much the same thing if you tried, for
example, to go north from this location and the game helpfully tried to
display the valid exits. What\'s happening, of course, is that the game
is using the name we gave to the first room (\"In Front of a Cottage\"),
converting it to lower case, and then displaying that as a description
of where the path west leads back to from the forest. In this case,
though, we\'d prefer to see something like \"back to the front of the
cottage\". Well, that\'s what TADS 3 provides the destName property for.
In order to fix the problem with the exit listing, all we need to do is
to add the line:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -------------------------------------------
                                      destName = \'the front of the cottage\' \

  ----------------------------------- -------------------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

to the definition of outsideCottage. In fact, you may recall when we
first introduced the Room template, it contained a convenient slot for
destName (because the need to change destName from the default is quite
common). So instead of adding the above line, we could simply change the
start of the definition of outsideCottage to:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

outsideCottage : OutdoorRoom \'In front of a cottage\' \
   \'the front of the cottage\' \
   \"You stand just outside a cottage; the forest stretches east.\
   A short path leads round the cottage to the northwest. \"\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Clearly, this is not the only place in the *Further Adventures of Heidi*
where we need to do this. Another example would be the topOfTree room:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

topOfTree : OutdoorRoom \'At the top of the tree\' \'the top of the tree\'\
       \"You cling precariously to the trunk, next to a firm,\
            narrow branch. \"\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The principle should (hopefully) now be clear enough, so I\'ll leave it
as an exercise to the reader to check down the other rooms that need a
destName adding (some of them will be fine as they are) and to add
destNames as appropriate. You can then compare your efforts with those
in the heidi.t file that should have come with this guide.\
\

### e. Stopping Sally\'s Misbehaviour

Sally is actually a pretty well-behaved shopkeeper most of the time, but
there is a particular set of circumstances under which her behaviour -
or at least the way it\'s reported - can become a little odd. If Heidi
enters the shop, rings the bell, and leaves immediately (**ring bell**
followed by **north**), the player will still see the message about the
shopkeeper entering the shop, and the shopkeeper will still start a
conversation, even though her customer is not actually there. Although
the player may be unlikely to enter this sequence of commands, we really
ought to try to anticipate *anything* the player might type, and so we
do need to fix this bug.\
\
The easiest way to go about it is to stop the daemon code actually
executing unless Heidi is in the shop. We can do that by rewriting the
shopkeeper\'s daemon method thus:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

daemon\
 {\
   if(gPlayerChar.isIn(insideShop))\
   {\
     moveIntoForTravel(insideShop);\
     \"{The shopkeeper/she} comes through the door and \
         stands behind the counter.\<.p\>\";\
     daemonID.removeEvent();\
     daemonID = nil;   \
     initiateConversation(sallyTalking, \'sally-1\');\
   }\
 }\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

This will work reasonably well; since the daemon has been set up to
execute on the second turn, once the bell is rung, the daemon will keep
checking every second turn to see whether Heidi is inside the shop, and
if she is, will then move the shopkeeper into the shop and start the
conversation. Thus if Heidi leaves the shop immediately after ringing
the bell, the shopkeeper won\'t move or start talking until Heidi
returns. It is theoretically possible that Heidi could keep missing the
shopkeeper by entering the shop on the odd turns and leaving again
immediately, but it\'s unlikely that a player who\'s interested in
having Heidi meet the shopkeeper would actually keep making that
sequence of moves.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Nonetheless, this solution is not quite ideal. Probably what ought to
happen is that the shopkeeper should come into the shop on the second
turn after the bell is rung regardless of whether Heidi remains in the
shop or not, but her movement into the shop should only be reported if
Heidi is in the shop to see it. We can achieve this quite
straightforwardly by employing a SenseDaemon in place of the plain
Daemon. To do this, find the shopkeeper\'s notifySoundEvent method and
change the line:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- --------------------------------------------
                                      daemonID = new Daemon(self, &daemon, 2); \

  ----------------------------------- --------------------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      to read: \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- --------------------------------------------------------------
                                      daemonID = new SenseDaemon(self, &daemon, 2, self, sight); \

  ----------------------------------- --------------------------------------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

A SenseDaemon is a special kind of Daemon that executes as normal except
that it only displays anything if the player character can sense a
particular object (the source) with a particular sense. The last two
parameters of the call to new SenseDaemon are the *source* and the
*sense* involved. In this case the source is the shopkeeper (which can
be referred to here as self since we are setting up this SenseDaemon in
a method of the shopkeeper object) and the sense is sight. The effect of
this is (if we revert to the older definition of the
shopkeeper.daemon method) is that the shopkeeper will move on the second
turn after the bell is rung, but will only be reported as moving if
Heidi is there to see it.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

There\'s still one thing left to fix; although it\'s okay for Sally to
come into the shop in response to the bell regardless of whether Heidi
stays there to meet her or not, she should only start talking to Heidi
if Heidi has indeed remained in the shop. We could use the test
if(gPlayerChar.isIn(insideShop)) as before, but we could also employ a
different test. In this case, since what we\'re really testing is
whether Sally *can* talk to Heidi, it would be reasonable to use her
canTalkTo method. The relevant part of the revised shopkeeper code then
becomes:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

shopkeeper : Person, SoundObserver \'young shopkeeper/woman\' \'young shopkeeper\'\
 @backRoom\
 \"The shopkeeper is a jolly woman with rosy cheeks and \
    fluffy blonde curls. \"\
 isHer = true\
 properName = \'Sally\'\
 notifySoundEvent(event, source, info)\
 {\
   if(event == bellRing && daemonID == nil && isIn(backRoom))\
      daemonID = new SenseDaemon(self, &daemon, 2, self, sight);\
     \
   else if(isIn(insideShop) && event == bellRing)\
     \"\<q\>All right, all right, here I am!\</q\> says \
          {the shopkeeper/she}.\<.p\>\";\
  \
 }\
 daemonID = nil\
 daemon\
 {   \
    moveIntoForTravel(insideShop);\
    \"{The shopkeeper/she} comes through the door and \
       stands behind the counter.\<.p\>\";\
    daemonID.removeEvent();\
    daemonID = nil;   \
    if(canTalkTo(gPlayerChar))\
      initiateConversation(sallyTalking, \'sally-1\');   \
 }\
\
... // continue as before\
;\
\

### f. Finishing the Boat

There\'s just a couple of problems with our implementation of the boat,
which we might like to fix now.\
\
First of all, if the player enters the command **row the boat** when
Heidi is in the garden, the game will reply with \"You can\'t row
that.\", which is not entirely true. We need to provide a more
appropriate response here. Again this is something you can probably work
out how to do yourself by now, so have a go at it before reading on.\
\
The second problem is a bit more subtle. Suppose that after issuing the
command **row the boat** when Heidi is in the garden, the player types
**enter it** followed by **row it**. The game will now respond with
\"The word \'it\' doesn\'t refer to anything right now.\" You can
probably work out why: the parser thinks that \'it\' refers to the
object we used to implement the *outside* of the boat, but once Heidi\'s
entered the boat, that object is no longer in scope. We can cure this by
using the getFacets property. This holds a list of other objects that
we, the game author, consider to be facets of the same object, so that
once we\'ve referred to any of the objects representing the boat, the
pronoun \'it\' can refer to any of its facets currently in scope. So,
for example, if we give the name rowBoat to the previously anonymous
Fixture we placed in insideBoat to act as the target of a **row**
command, we can now define getFacets = \[rowBoat\] on the boat object,
and conversely getFacets = \[boat\] on the rowBoat object, and having
referred to one, we can freely use \'it\' to refer to the other.\
\
The definition of the boat then becomes:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

boat : Heavy, Enterable -\> insideBoat \'rowing boat/dinghy\' \'rowing boat\'\
  @cottageGarden\
  \"It\'s a small rowing boat. \"\
  specialDesc = \"A small rowing boat floats on the stream, \
      just by the bank. \"\
  useSpecialDesc { return true; }\
  dobjFor(Board) asDobjFor(Enter)\
  dobjFor(Row)\
  {\
   verify()\
   {\
    illogicalNow(\'You need to be aboard the boat before you can row it. \');\
   }\
  }\
  getFacets = \[rowBoat\]\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Notice the use of the illogicalNow() macro for handling **row boat**
when Heidi is standing on the bank. It is illogical to try to row a boat
when we\'re not in it, but it is not illogical to try to row a boat
under all circumstances, so even under these circumstances **row boat**
is less illogical than, say, **row sky** or **row stream**.\
\

### g. Other Suggestions - including an MultiInstance

There are also a several other things you could add that don\'t involve
anything we have not already seen, including various Decoration (or,
where appropriate, Distant) objects to deal with things mentioned in
various room descriptions but not otherwise implemented, and various
additional NoTravelMessages or FakeConnectors to deal more elegantly
with the boundaries of our game world (e.g., the village mentioned in
the description of the jetty location should perhaps be implemented as a
Distant object in that room, and one or two FakeConnectors should be
added to the meadow to explain why the only way Heidi can leave it is
back across the stream). Since these involve nothing new, the reader can
try them for him or herself.\
\
But one new thing of this type does suggest itself, and that is putting
some trees in the forest, since allowing the player to experience the
following would be less than optimal:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

**Deep in the Forest\
**\
Through the deep foliage you glimpse a building to the west. A track
leads to the northeast, and a path leads south.\
\
There is a rustling in the undergrowth.\
\
\>**x trees**\
The word \"trees\" is not necessary in this story.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

If one is in a forest, one can reasonably expect to find trees, but
rather than defining a different \"trees\" decoration object in all
forest locations, we can simply use an MultiInstance to place our
\'trees\' object in every ForestRoom:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

MultiInstance   \
   instanceObject : Decoration { \'pine tree\*trees\*pines\' \'pine trees\'\
   \"The forest is full of tall, fast-growing pines, although the\

  ----------------------------------- -----------------------------------
                                          occasional oak, \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

    beach and sycamore can occasionally be seen among them. \"\
   isPlural = true \
   }  \
   initialLocationClass = ForestRoom\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The slight complication here is that we have to define the
instanceObject as a nested object within the MultiInstance object. We
define it to be of class Decoration since the only interaction the
player will have with the trees is to look at them. The effect of this
code is that the game will create an instance of the \'pine trees\'
Decoration object in every location of the ForestRoom class. The
MultiInstance class saves us the bother of having to do this by hand.\
\
We could have implemented these trees as a MultiLoc, and in this
particular game there would have been no functional difference. Strictly
speaking, though, MultiInstance is the more correct class to use here.
The main use for a MultiLoc is for a single physical object that exists
in more than one location by virtue of being situated at the border of
two or more rooms. For example, a large town square with a fountain at
its centre might be implemented as four rooms, with the central fountain
being a MultiLoc that appears in each. It is physically the same
fountain whether it is viewed from, say, the northeast or the southeast
corner of the square, and if the Player Character throws a coin into the
fountain from the northeast corner of the square, he or she should then
be able to retrieve it from the fountain even after moving to another
part of the square, since it remains the same physical fountain. A
MultiLoc may also be used for a Distant object, such as a far-off
mountain range or the moon, that is visible from a number of different
locations, since once again it is the same physical object that is being
represented (provided it appears identical from all the locations in
question).\
\
But in this case, we are not trying to implement the same clump of trees
visible from all parts of the forest, but the fact that there are trees,
albeit numerically different trees, in all parts of the forest. Since
all these trees are functionally identical (apart from the sycamore tree
in the clearing that we have implemented separately) we can use
MultiInstance as a short-cut to creating them all over the forest.
Although in this game it makes no practical difference to the player
whether we use a MultiLoc or a MultiInstance, in general it may. If, for
example, Heidi were exploring the forest by night, then MultiLoc trees
illuminated in one room would appear illuminated in all rooms (since
they represent the same physical object). This would mean that if Heidi
dropped her torch/flashlight at one spot in the forest and then moved to
another part of the forest without any illumination, she\'d be in a
totally dark room but still be able to examine the trees, which is
probably not what we\'d want. Using MultiInstance ensures that we do
note get this sort of unwanted behaviour.\
\
You might think that a problem here would be that if the player types
**examine tree** while Heidi is in the sycamore tree clearing, the
parser will ask, \"Which tree do you mean, the pine trees or the
tree?\". But in fact the library automatically takes care of this by
giving a Decoration object a lower \'logical rank\' than a normal
object; that means that if two objects are in scope which might match
the same vocabulary, one of them being a Decoration object and the other
not, the other will be chosen in response to an **examine** command. So
in this case when the player types **examine tree** the parser will
assume that it is the sycamore tree that is meant, without troubling the
player with a disambiguation request. For a fuller discussion of
\'logical rank\' see the discussion of [verify](verify.htm) above (and
the section on \'Action Results\' in the *Technical Manual*).\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

One more thing you might like to consider is letting the player know
that you have defined a couple of custom verbs (although in this case
it\'s arguably superfluous). You can do that by overriding the
customVerbs property of InstructionsAction, thus:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

modify InstructionsAction\
  customVerbs = \[\'ROW THE BOAT\', \'CROSS STREAM\', \'RING THE BELL\' \]\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Then, when players type an **instructions** command**,** your custom
verbs will be included in the list of game verbs the instructions text
tells them about.\
\

------------------------------------------------------------------------

*Getting Started in TADS 3*\
[\[Main\]](index.html)\
*[\[Previous\]](handlingcashtransactions.htm)
  [\[Next\]](countingthecash.htm)*
:::
