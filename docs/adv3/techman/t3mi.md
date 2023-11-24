![](topbar.jpg)

[Table of Contents](toc.htm) \| [Advanced Topics](advtop.htm) \>
Multiple Inheritance  
[*Prev:* Redefining Scope](t3scope.htm)     [*Next:* Using Nested Rooms
as Staging Locations](t3staging.htm)    

# Multiple Inheritance

*by Eric Eve*

The inheritance mechanism in TADS 3 (also described in the [System
Manual](../sysman/inherit.htm)) is not only extremely useful, but
essential to how the library works, and it's impossible to get very far
writing a game in TADS 3 without making use of it, not only through
defining objects belonging to classes that rely on the inheritance
mechanism, but through using the **inherited** keyword in your own code.

At first sight this may seem straightforward enough. Suppose class B is
derived from class A and that class A (but not class B) directly defines
the property (or method) foo(). One might then expect that calling
B.foo() would always invoke A.foo(). One might also expect that if,
conversely, B overrode foo() and used the keyword **inherited** in its
version of foo(), **inherited** would refer to A's version of foo.
Unfortunately it's not quite that simple. Suppose we have the following
object definition:

    bar: B, C
    ;

Where, as before, B derives from A, and A (but not B) directly defines
the method foo(). Now suppose our code invokes the method bar.foo(). It
may seem obvious that bar.foo() will use class A's foo() method, but
this may be incorrect. If C is also derived from A, and C (but not B)
overrides foo(), then bar.foo() would use C's foo() method, not A's.
Moreover if B and C are both derived from A and both override foo(), but
B's overridden foo() includes the **inherited** keyword, then when
bar.foo() is invoked, inherited in B.foo() will call C.foo(),not A.foo()
as one might at first expect.

If, on the other hand, C does not derive from A (but B does) or C does
not define or override foo(), then a call to bar.foo() will invoke
A.foo() in either of these cases. That is, in the event that C does not
override A.foo(), (either because it is not derived from A, or because
it does not define a foo() method, or both), then if B does not override
foo(), bar.foo() will use A.foo(), or if B does override foo() and
B.foo() uses the **inherited** keyword, then in this context the
inherited in B.foo() will invoke A.foo().

It follows that the precise reference of **inherited** is context
dependent. In particular suppose we have a definition like the
following:

    class B: A
       foo()
       {
           inherited();
           "B.foo() is now executing. ";
        }
    ;

This definition does not determine which class's foo() method will be
invoked at run-time by the call to inherited() within B.foo(). Under
some circumstances it may be A. Under others it may be a subclass of A
that overrides foo().

If you look at the definition of **inherited** in the 'Expressions and
Operators' page of the *System Manual*, you'll see that it does **not**
say "The inherited operator invokes the equivalent method from the
current class's superclass" but rather "The inherited operator invokes
the method that the currently executing method overrides". In other
words, inherited invokes the method (or property) that would have been
invoked if the current method (or property) had not been overridden on
the current class or object. Thus, in the above example, determining
which method is invoked by a call to bar.foo() when B does not override
foo is the same as determing which method is invoked, in the course of
executing bar.foo, by inherited within B.foo() when B does override foo.

Let's pause to consider the rationale of this, approaching it through
the conceptually simpler case of determining which class's definition of
foo is invoked by a call to bar.foo() when B does **not** define or
override foo(). Again, we shall start simply from this definition of
bar:

    bar: B, C
    ;

Now let's consider what we'd *expect* to happen in a couple of cases.

\(1\) Suppose foo is defined on B or one of its ancestor classes but not
on C or any of its ancestor classes. Then we'd surely expect bar.foo to
invoke the version of foo defined or overridden on B or inherited by B
from one of its ancestor classes, and this is in fact what happens.

\(2\) Suppose foo is not defined on B or on any of B's ancestor classes,
but is defined on C or inherited by C from one of C's ancestor classes.
Then we'd expect bar.foo() to invoke C's (overridden or inherited)
version of foo. Presumably, that was part of the point of including C in
bar's superclass list. And again, this is what happens.

\(3\) Suppose foo is defined or overridden on both B and C. Then we'd
expect bar.foo() to use B.foo(), since a method defined on an earlier
class in this list effectively overrides one defined later. Indeed, this
follows from what the Object Definition section of the *System Manual*
tells us, namely "If you specify more than one superclass, the order of
the classes determines the inheritance order. The first (left-most)
superclass has precedence for inheritance, so any properties or methods
that it defines effectively override the same properties and methods
defined in subsequent superclasses." And again, this is what in fact
actually happens.

\(4\) Finally suppose B inherits foo() from A without overriding it, and
C also inherits or overrides foo(). You might suppose that this was
effectively the same as case 3 above, and that since class B has
precedence over class C in the class list (since it comes before it) the
version of foo() inherited by B will prevail, with the result that
bar.foo() will invoke A.foo() (i.e. the version of foo() that B inherits
from A), but *this is not necessarily the case*. In particular, it is
not the case if C.foo() overrides A.foo(), or if C.foo() inherits a
version of foo() that overrides A.foo(). If neither of these conditions
is met, then bar.foo() will indeed invoke A.foo(), otherwise, if C.foo()
directly or indirectly overrides A.foo(), then bar.foo() will invoke
C.foo(), not A.foo().

It is probably this last case that seems the least intuitive and the
most potentially confusing. The rationale behind it is that if C.foo()
overrides A.foo() (either directly or through an intermediary class in
the class hierarchy), C's foo() method is more specialized than A's, so
that if C appears in a superclass list, it's probably the behaviour of
C.foo() we want rather than that of A.foo(), even if C appears later in
the class list than a class that inherits (but does override) A.foo() -
presumably the whole point of including C rather than A in the
superclass list is that we wanted C's specialization of A, not just A
itself. To anticipate an example we'll return to [below](#conv), if A is
AgendaItem, B is DelayedAgendaItem and C is ConvAgendaItem, then the
fact that we added ConvAgendaItem to the class list presumably means we
want something it provides beyond what DelayedAgendaItem already
inherits from AgendaItem, so that in this contect it makes better sense
for **inherited** in DelayedAgendaItem.isReady to refer to
ConvAgendaItem.isReady than to AgendaItem.isReady.

Bear in mind that it is possible to override this behaviour if it isn't
what we want. If we wanted **inherited** in B.foo() *always* to
reference A.foo() no matter what the context, we could add the classname
A after the inherited keyword to ensure this result:

    class B: A
       foo()
       {
           inherited A();
           "B.foo() is now executing. ";
        }
    ;

Indeed, there doubtless are cases where this is necessary to get the
result we actually want, but it's probably a minority of cases. In
practice, it usually turns out that the default mechanism described
above does what is most useful. This mechanism is the rule summarized
rather densely (originally in the TADS 2 manual, and subsequently quoted
in *Getting Started in TADS 3*) as "the inherited property in the case
of multiple inheritance is that property of the earliest (leftmost)
superclass in the object's superclass list that is not overridden by a
subsequent superclass." Another way of putting this is to say that "The
first (left-most) superclass has precedence for inheritance, so any
properties or methods that it defines effectively override the same
properties and methods defined in subsequent superclasses, except that
an ancestor class does not override a method or property on any of its
descendent classes."

Below we shall introduce a straightforward [algorithm](#algorithm) for
determining the order of precedence in situations of multiple
inheritance, but first let's look at a few more examples.

## An Abstract Example

Suppose we have the following class hierarchy:

                        object
                        /     \
                       A       C
                      /  \      \
                     B    D      E

Suppose further that these classes are defined thus:

    class A: object
      hello() { "Hello from class A! "; }
      foo = "\nA foo" 
    ;

    class B: A
      hello()
      {
         inherited;     
         "Hello from class B! ";
      }  
    ;

    class C: object
      hello()
      {
         inherited;     
         "Hello from class C! ";
      }
      foo = "\nC foo"
    ; 

    class D: A
      hello()
      {
         inherited;     
         "Hello from class D! ";
      }
      foo = "\nD foo"
    ;

    class E: C
      hello()
      {
         inherited;     
         "Hello from class E! ";
      }
      foo = "\nE foo"
    ;

And that we then add the following code to allow us to experiment with
these classes:

    testBC: B, C;
    testCB: C, B;
    testBD: B, D;
    testBE: B, E;

    DefineIAction(Test)
      execAction()
      {
         "First testBC:\n";
         testBC.hello(); testBC.foo();
         
         "<.p>Then testCB:\n";
         testCB.hello(); testCB.foo();
         
         "<.p>Then testBD:\n";
         testBD.hello(); testBD.foo();
         
         "<.p>And finally testBE:\n";
         testBE.hello(); testBE.foo();
      }
    ;

    VerbRule(Test)
      'test'
      :TestAction
      verbPhrase = 'test/testing'  
    ;

The response to the command TEST will be:

First testBC:  
Hello from class A! Hello from class B!  
A foo

Then testCB:  
Hello from class A! Hello from class B! Hello from class C!  
C foo

Then testBD:  
Hello from class A! Hello from class D! Hello from class B!  
D foo

And finally testBE:  
Hello from class A! Hello from class B!  
A foo

Let's look at how this output relates to the principles we explored in
the previous section. We'll start by considering what happens when
**testBC.foo()** is invoked. B does not itself define foo(), but it does
inherit A.foo(). C defines foo(), but C.foo() is not derived from, and
hence does not override A.foo(), so it's A.foo() that is invoked here.
For similar reasons, when inherited is called in B.hello(), it's
A.hello() that's invoked. C does define a hello() method, but it's not
derived from A.hello(), so A.hello() can take precedence.

When **testCB.foo()** is called, we simply get C.foo(), since C defines
foo() for itself and comes first in the class list, so there's no need
to look further for the foo method we need. When testCB.hello() is
invoked, however, the situation is more complicated. Once again this
will invoke C.hello(), since C defines its own hello() method, but
C.hello() contains a call to inherited. Remember, in this situation
inherited calls what testCB.hello() would call if C didn't provide its
own definition of hello(). If C.hello() didn't exist, the only version
of hello() available to be called on testCB is that provided by B, so
that's the one that's called. B.hello() also contains a call to
inherited, which is the method that would have been called if B didn't
define hello for itself. In this case, that could only be A.hello(),
which B inherits from A. So what we end up with here is A.hello() called
from B.hello() called from C.hello().

When **testBD.foo()** is called, B does not define or override A.foo(),
but merely inherits it. D, on the other hand, does override the foo it
would otherwise inherit from A. So while B.foo would normally take
precedence, since B appears in the class list before D, B.foo is simply
the inherited A.foo, which is not allowed to take precedence over D.foo
since D.foo overrides A.foo, so in this case it's D.foo that wins out.
When testBD.hello() is called, B does supply its own version of
B.hello(), so that's the one that's used. But B.hello() calls inherited,
which is the method that would be invoked by testBD.hello() if B.hello()
were not defined. Once again the choice is between A.hello() inherited
by B from A and D.hello() defined on D. Since D inherits from A and
D.hello() overrides A.hello(), D.hello() cannot be overridden by
A.hello(), so it's D.hello() that's used. On the other hand, when
inherited is encountered in D.hello(), it can only refer to A.hello(),
with the result that what we end up seeing is A.hello() called from
D.hello() called from B.hello().

Finally, **testBE** works the same as testBC, since E derives from C but
not A.

It would no doubt be possible to construct far more complex examples
than this, but these should suffice to illustrate the principle (while
more complex examples might only confuse). Anyway, the method of
analysis employed above rapidly becomes too unwieldy to use on more
complex cases, so we'll next introduce an algorithm to simplify it.
After discussing this algorithm, we'll move on from these rather
abstract examples to a pair of concrete involving classes defined in the
TADS 3 library; [the second](#complex) of these will turn out to be
quite complicated enough!

## A Simplifying Algorithm

The kind of reasoning we have just gone through is all very well, but
rapidly becomes more confusing to construct and harder to follow the
more complicated the class hierarchy involved. Moreover, it's not the
way the TADS 3 VM actually works. The TADS 3 VM reduces the problem to a
linear ordering of priorities, and so can we. The trick is to find a
means of reducing a set of inheritance relationships into a single list
ordered by precedence. The algorithm actually employed by the VM is one
a human being could follow, but it may not be the easiest way a human
being could do it, so here we'll present a slightly different procedure
for producing the same result.

In essence, it's a matter of following a two-step process:

1.  Create a recursively expanded superclass list of the object in
    question, with the classes listed in order of inheritance.
2.  Remove all duplicate elements from the list, leaving only their
    rightmost (i.e. last) occurrence.

Stated thus this procedure is probably less than immediately clear. Two
further steps may aid understanding: (1) a broad description of what it
does, and (2) some worked examples showing how to carry it out.

What it does is to arrange an object's (or class's) superclass list in
order such that:

1.  The order of declaration of ancestor classes on the object and it
    superclasses is preserved except that
2.  No ancestor class is allowed to take precedence over any of its
    descendent classes.

The first step achieves the first of these goals, while the second step
achieves the second. The result is equivalant to the definition we gave
above, namely "The first (left-most) superclass has precedence for
inheritance, so any properties or methods that it defines effectively
override the same properties and methods defined in subsequent
superclasses, except that an ancestor class does not override a method
or property on any of its descendent classes."

Now let us unpack the procedure to show how to carry it out. The first
step is to create "a recursively expanded superclass list of the object
in question, with the classes listed in order of inheritance." The
simplest way to follow this is probably to create a sideways superclass
tree diagram. To do this, start with the object we're interested in,
list its superclasses below it in a column to the right of it, with each
superclass's superclass listed below and to the right of them, thus:

    testBC
            B
                A
            C

(Note that we have excluded the ultimate ancestor **object** from this
procedure, since normally we'll never need to trace inheritance back
that far, and because in any case we can always be sure that the
algorithm will always end up placing **object** at the very end of the
list).

To complete step 1, we now simply construct a list by reading the above
tree diagram from top to bottom:

    testBC, B, A, C

In this case, there are no duplicates, so there is nothing for Step 2 to
do. This tells us testBC first inherits foo from B, which, since it
neither defines nor overrides it, simply inherits it from A. It's
therefor A.foo that executes. Similarly testBC.hello() invokes
B.hello(), B being the first class in the list to define hello(), and
then that **inherited** in B.hello() invokes A.hello(), A being the next
class in our list.

Now let's try it with testCB:

    testCB
           C
           B
               A

This time, the list we construct by reading from top to bottom is:

    testBC, C, B, A

Again there are no duplicates to delete, so nothing for Step 2 to do.
testBC.foo will invoke C.foo. textBC.hello() will invoke C.hello(),
which via **inherited** invokes B.hello(), which in turn via
**inherited** invokes A.hello().

Finally, let's try testBD. Here, the superclass tree diagram looks like
this:

    testBD
            B
                A
            D
                A

So reading down the diagram generates this list:

    testBD, B, A, D, A

This time, A appears twice, so there is something for Step 2 to do. We
delete all the duplicate As (all one of them) leaving only the last:

    testBD, B, D, A

So now, testBD.foo will invoke D.foo, and testBD.hello() invokes
B.hello, whose **inherited** invokes D.foo(), whose **inherited** in
turn invokes A.foo().

testBE may be left as an exercise for the reader.

## Some Real Examples

### (1) A Delayed Conversation Agenda Item

Suppose we want to combine the functionality of DelayedAgendaItem and
ConvAgendaItem, that is we want an AgendaItem which is invoked after a
certain length of time, but only when there's a gap in the conversation
and the player character is still present to be addressed. We could
define:

    + delayedConv: DelayedAgendaItem, ConvAgendaItem
      invokeItem()
      {
           "Right! Bob suddenly barks. ";
            isDone = true;
       }
    ;

But will this work as we want it to, or will ConvAgendaItem.isReady be
bypassed? The question really hinges on what the isReady property of
delayedConv will do.

DelayedAgendaItem is defined in the library as:

    class DelayedAgendaItem: AgendaItem
        isReady = (Schedulable.gameClockTime >= readyTime && inherited())
     
        readyTime = 0
     
        setDelay(turns)
         {    
             readyTime = Schedulable.gameClockTime + turns;
     
             return self;
         }
    ;

While ConvAgendaItem is defined as:

    class ConvAgendaItem: AgendaItem
         isReady = (!getActor().conversedThisTurn()
                    && getActor().canTalkTo(otherActor)
                    && inherited()) 
     
         otherActor = (gPlayerChar)
    ;

There's clearly no conflict here between the definitions of readyTime,
setDelay() or otherActor, the only issue is what delayedConv.isReady
will do. Note that on both DelayedAgendaItem and ConvAgendaItem isReady
invokes the inherited property.

Well, to begin with, delayedConv.isReady must clearly refer in this
context to DelayedConvAgendaItem.isReady, since DelayedConvAgenda comes
first in the class list and explicitly defines (or rather, overrides)
this property. So the next question is what the inherited keyword in the
definition of DelayedAgendaItem.isReady will refer to in this particular
context. The possible candidates are AgendaItem.isReady and
ConvAgendaItem.isReady. The rule is that the leftmost property takes
preference unless it would involve a base class overriding a property
that one of its subclasses overrides. But ConvAgendaItem does override
AgendaItem.isReady, so in this case the inherited within
DelayedAgendaItem.isReady will reference ConvAgendaItem.isReady rather
than its base class's AgendaItem.isReady. ConvAgendaItem.isReady in turn
includes the inherited keyword, but in this case it can only refer to
AgendaItem.isReady, since there's nothing else for it to refer to. So
delayedConvAgenda.isReady turns out to be equivalent to:

    isReady = (Schedulable.gameClockTime >= readyTime 
         && (!getActor().conversedThisTurn()
                    && getActor().canTalkTo(otherActor)
                    && true ))

This is indeed precisely what we'd want from a DelayedConvAgendaItem, so
combining DelayedAgendaItem and ConvAgendaItem in the superclass list of
the same object indeed combines the functionality of these two
subclasses of AgendaItem, just as we might have hoped.

Again, it would probably be easier to have arrived at this result using
the [algorithm](#algorithm) (i.e. procedure) described in the previous
section. The relevant superclass tree diagrams are already provided for
us in the *TADS 3 Library Reference Manual*, but we'll reproduce them
below:

    delayedConv
                 DelayedAgendaItem
                                     AgendaItem
                 ConvAgendaItem
                                     AgendaItem

Reading from top to bottom, we once again produce our fully expanded
superclass list:

    delayedConv, DelayedAgendaItem, AgendaItem, ConvAgendaItem, AgendaItem

Finally, in Step 2 we delete any duplicates (in this case, the first
occurrence of AgendaItem) leaving only their last instances:

    delayedConv, DelayedAgendaItem, ConvAgendaItem, AgendaItem

This produces the same result we had before, probably more reliably and
simply than by trying to reason our way through the inheritance tree. In
such a simple case we could probably carry out all the steps in our
head, especially once the procedure becomes more familiar. We'll finish
with a rather more complex example, where some resort to pen and paper
would almost certainly be essential.

### (2) Lockable Door

For our second example we'll pose the question why the first of these
two object definitions works properly whereas the second does not:

    (1)
    + myDoor: Lockable, Door 'door' 'door'
    ;

    (2)
    + myDoor: Door, Lockable 'door' 'door'
    ;

The obvious difference you'll soon discover between these two is that
whereas with (1) the door starts out locked, with (2) it doesn't,
however hard you try explicitly defining initiallyLocked = true (there
may indeed be other problems with (2), but we'll focus on this one for
now).

In this case the class hierarchy involved is rather more complex than
any we've attempted to deal with so far:

                           object
                          /      \
                  Linkable       VocabObject
                 /   |    \              \
         Lockable    |     \            Thing
                     |      \          /     \
                     |       \      Travel    NonPortable
                     |        \   Connector    /       
                     |         \      /    Fixture
                     |          \    /    /
                     |           \  /    /
           Basic Openable         Passage                       
           /           \           |
         Openable       \       ThroughPassage
                \        \      / 
                 \       BasicDoor
                  \     /           
                   Door              
               
                                                   

A look at the library code will reveal that the place where Lockable
uses initiallyLocked to initialize the locked status of the door is in
its initializeThing method:

    class Lockable: Linkable
        
         initiallyLocked = true
         
         initializeThing()
         {
             /* inherit the default handling */
             inherited();
             
             /* if we're the master, set our initial state */
             if (masterObject == self)
                 isLocked_ = initiallyLocked;
         }
          
    ;

Linkable also has a definition of initializeThing:

    Linkable: object
       initializeThing()
       {
             
        inherited();
                        
        if (masterObject != self && masterObject.masterObject == self)
        {             
          masterObject = self;
        }
       }
    ;

Door does not define its own initializeThing method, but could
potentially inherit one either via BasicDoor from BasicOpenable:

    BasicOpenable: Linkable
     initializeThing()
         {         
             inherited();
     
             if (masterObject == self)
                 isOpen_ = initiallyOpen;
         }
    ;

Or else via BasicDoor from Passage:

    Passage: Linkable, Fixture, TravelConnector
       initializeThing()
         {
             inherited();
              
             if (masterObject != self)
             {
                 otherSide = masterObject;
                 masterObject.initMasterObject(self);
             }
         }
    ;

So what happens in this complex case? One way to find out is to set a
breakpoint in the debugger and try tracing it through. If we start with
case (1) and put the breakpoint on the first statement (inherited) in
Lockable.initializeThing() we find the following. The call to inherited
in Lockable.initializeThing() invokes BasicOpenable.initializeThing(),
the first line of which is also an inherited statement. This new
inherited statement invokes Passage.initializeThing(), the first line of
which is yet another inherited statement. This third inherited statement
invokes Linkable.initializeThing, which yet again starts with an
inherited statement. This inherited statement finally calls
Thing.initializeThing(), which at last doesn't contain an inherited
statement. Stepping on through the code then takes us to the end of
Thing.initializeThing() and then back on up the call stack till we
eventually arrive back at Lockable.initializeThing().

This *is* a complex case, but can we work out what's happening here?

The only realistic way to attempt it is to use the
[algorithm](#algorithm) described above. This is greatly simplified for
us by the fact that the *Library Reference Manual* already provides us
with superclass tree diagrams in the format we need for all classes
defined in the TADS 3 library, so we can simply look up the relevant
classes in the library and write out our expanded superclass lists by
reading down their superclass tree diagrams.

The list for Lockable is then simply:

    Lockable, Linkable

That for Door is rather longer:

    Door, Openable, BasicOpenable, Linkable, BasicDoor, BasicOpenable,
    Linkable, ThroughPassage, Passage, Linkable, Fixture, NonPortable, Thing, 
    VocabObject,TravelConnector, Thing, VocabObject

We can now assemble the complete list for myDoor:

    myDoor, Lockable, Linkable, Door, Openable, BasicOpenable, 
    Linkable, BasicDoor, BasicOpenable, Linkable, ThroughPassage, 
    Passage, Linkable, Fixture, NonPortable, Thing, 
    VocabObject,TravelConnector, Thing, VocabObject

The second step is to remove all duplicates, of which there are several,
leaving only the rightmost instance of each class:

    myDoor, Lockable, Linkable, Door, Openable, BasicOpenable, 
    Linkable, BasicDoor, BasicOpenable, Linkable, ThroughPassage, 
    Passage, Linkable, Fixture, NonPortable, Thing, 
    VocabObject,TravelConnector, Thing, VocabObject

So that the list reduces to:

    myDoor, Lockable, Door, Openable, BasicDoor, 
    BasicOpenable, ThroughPassage, Passage, Linkable, 
    Fixture, NonPortable, TravelConnector, Thing, VocabObject

Finally, to work out what happens when myDoor.initializeThing() is
invoked, it will help to identify which classes in the above list define
or override initializeThing(), and which of the initializeThing()
methods include an **inherited** which will call the next class's
initializeThing() method. Again, this is information that may be gleaned
quite readily from the *Library Reference Manual*; the easiest way to go
about it may be to look up initializeThing() in the index of all
identifiers.

Here we show the result of doing this by showing all classes in the list
that define or override initializeThing() underlined, and all those
whose initializeThing() uses the **inherited** keyword in bold:

    myDoor, Lockable, Door, Openable, BasicDoor, 
    BasicOpenable, ThroughPassage, Passage, Linkable, 
    Fixture, NonPortable, TravelConnector, Thing, VocabObject

This tells us that myDoor.initializeThing() should invoke
Lockable.initializeThing(), which will invoke
BasicOpenable.initializeThing(), which will in turn invoke
Passage.initializeThing(), which will in turn invoke
Linkable.initializeThing(), which will finally invoke
Thing.initializeThing(), which is indeed what is shown to happen by
tracing the calls through the Workbench debugger.

Now let's consider case (2), which had myDoor defined thus:

    + myDoor: Door, Lockable 'door' 'door'
    ;

It would be almost impossible to work out in advance what will happen in
this case by some process of abstract reasoning, or trying mentally to
predict how execution will work through the inheritance tree, so instead
we need to reduce the classes involved to a linear list using our
algorithm. For step 1, we can simply reassemble the list we assembled
last time in a slightly different order, moving Lockable to a position
after all of Door's superclasses:

    myDoor, Door, Openable, BasicOpenable, Linkable, 
    BasicDoor, BasicOpenable, Linkable, ThroughPassage, Passage, 
    Linkable, Fixture, NonPortable, Thing, VocabObject,
    TravelConnector, Thing, VocabObject, Lockable, Linkable.

Then, as before, we carry out the second step of deleting duplicates
from the list, leaving only the rightmost instance of each class (note
that this may result in different instances being deleted than in the
previous case):

    myDoor, Door, Openable, BasicOpenable, Linkable, 
    BasicDoor, BasicOpenable, Linkable, ThroughPassage, Passage, 
    Linkable, Fixture, NonPortable, Thing, VocabObject,
    TravelConnector, Thing, VocabObject, Lockable, Linkable.

This list then reduces to:

    myDoor, Door, Openable, BasicDoor, BasicOpenable, 
    ThroughPassage, Passage, Fixture, NonPortable, TravelConnector, 
    Thing, VocabObject, Lockable, Linkable.

This now gives the order of inheritance. Once again to work out what
happens when myDoor.initializeThing() is invoked it will be helpful to
identify those classes in the list that define or override
initializeThing(). Once again, those that define (or override) this
method are shown underlined, while those whose initializeThing() method
include **inherited** are shown in bold:

    myDoor, Door, Openable, BasicDoor, BasicOpenable, 
    ThroughPassage, Passage, Fixture, NonPortable, TravelConnector, 
    Thing, VocabObject, Lockable, Linkable.

This tells us that myDoor.initializeThing() will first call
BasicOpenable.initializeThing(), since BasicOpenable is the first
(leftmost) class that defines (or overrides) an initializeThing()
method. To find out what the **inherited** in
BasicOpenable.initializeThing() calls, find the next class in the list
that defines (or overrides) initializeThing(). This turns out to be
Passage. Passage.initializeThing() again includes a call to
**inherited**, so to find out what *that* invokes, find the next class
in the list that defines initializeThing(), which turns out to be Thing.
This is where the trail ends, since when Thing.initializeThing() is
invoked, it does *not* contain any call to **inherited**.

This outcome may well strike you as rather counter-intuitive; it would
not be at all easy to predict in advance of trying it (or without going
through the type of exercise we've just gone through) which classes'
initializeThing() methods would end up being invoked here, but you can
verify that this is in fact what does happen by stepping it through the
Workbench debugger. The upshot is that by placing Lockable in the
superclass list after Door, not only do we prevent Lockable from
initializing myDoor.isLocked\_ properly, we also prevent it from
initializing myDoor.masterObject properly, which is what
Linkable.initializeThing() would have done had it not be blocked by the
misplacement of Lockable in myDoor's superclass list. This illustrates
why mix-in classes that don't inherit from Thing should be placed before
Thing-derived classes in a superclass list. If the overall object is
Thing-derived it's usually desirable, if not essential, that the order
of precedence of its base classes should end with Thing, VocabObject.
This will only happen if all non-Thing derived classes are placed
*before* the Thing-derived ones.

This is admittedly a highly complex example, so don't worry if you don't
feel you entirely understand it, especially first time round. You'll
seldom need to have to work out something this convoluted for yourself
when dealing with multiple inheritance; for the most part you can simply
rely on the library to do its job. When you modify or define your own
classes, or use **inherited** on objects you define, you're most
unlikely to need to reckon with anything half so complicated as this,
provided that you make sure always to list library classes in the right
order from the outset, which generally means placing non-Thing derived
mix-in classes before Thing-derived classes when they appear in the same
superclass list. It is, however, no bad thing to be aware of some of the
underlying complexities here, in case you do encounter a situation where
things are not working as you expected them to and you need to work out
why.

If this isn't all entirely clear yet, you might like to check out the
article on the [Object Inheritance Model](../sysman/inherit.htm) in the
*System Manual*, which takes a complementary approach to explaining it
all.

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](toc.htm) \| [Advanced Topics](advtop.htm) \>
Multiple Inheritance  
[*Prev:* Redefining Scope](t3scope.htm)     [*Next:* Using Nested Rooms
as Staging Locations](t3staging.htm)    
