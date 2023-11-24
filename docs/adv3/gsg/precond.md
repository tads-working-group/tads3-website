[![](topbar.jpg)](index.html)

[\[Main\]](index.html)  
*[\[Previous\]](action.htm)   [\[Next\]](remap.htm)*

### PreCond

There are certain necessary conditions that tend to recur commonly in IF
actions. In order to read the book or examine the chest, the objects in
question have to be visible. In order to hit the troll with the sword,
or move the nest with the stick, or unlock the chest with the gold key,
the sword, stick or key first have to be held. These common conditions
are encapsulated in TADS 3 as PreCondition objects, since they represent
the common preconditions of various types of a command.

  
The preCond property in dobjFor or iobjFor propertyset contains (or, if
it is a routine, returns) a list of the preconditions needed for the
object in question to be used in the action in question. For example, in
the case of reading the book and examining the chest you might define:  

[TABLE]

[TABLE]

[TABLE]

|     |     |
|-----|-----|
|     |     |

Whereas, in the case of hitting the troll or whatever, in the
appropriate iobjFor() section (for AttackWith, MoveWith, UnlockWith) you
might define:  

[TABLE]

[TABLE]

[TABLE]

|     |     |
|-----|-----|
|     |     |

The library already defines sensible default preconditions for most
actions, so you often don't need to worry about them. However, as your
own games become more sophisticated, you may want to adjust the
preconditions that apply to a particular action on a particular object.
For example, you may decide that a particular book needs to be held as
well as being visible in order to be read, so you might define:  

[TABLE]

|     |     |
|-----|-----|
|     |     |

redBook: Readable 'little red book\*books'   'red book'  
…  

[TABLE]

[TABLE]

[TABLE]

[TABLE]

[TABLE]

|     |     |
|-----|-----|
|     |     |

;  

[TABLE]

|     |     |
|-----|-----|
|     |     |

Like check() and verify() routines, preconditions can veto an action if
certain conditions aren't met. Unlike check() and verify(), however,
they can be used to change the game state to meet the precondition. For
example, the objHeld precondition will first check to see if the object
is already held; if it isn't, it will try to make the actor take the
object (via an implicit action, i.e. one that is reported as '(first
taking the book)' or whatever). If the implicit action succeeds, the
action is allowed to proceed (provided there's nothing else preventing
it). If not, the action is disallowed, with a message like '(first
trying to take the book)' that explains the reason for the failure (e.g.
"The book is out of reach."). Some preconditions, however simply test
whether the condition is met, and disallow the action if it isn't. For
example, an objVisible precondition makes no attempt to make an object
visible if it isn't (in the general case it's impossible to know what
implicit action, if any, could bring this about), it simply vetoes the
action if the object can't be seen by the actor.  
  
The library defines several preconditions, including objOpen, objClosed,
objUnlocked, touchObj, actorStanding, objAudible. For a complete list,
see the pre-conditions section of the "[TADS 3 Action
Results](../techman/t3res.htm#precond)" section of the *Technical
Manual*. It is also perfectly possible (and often useful) to define your
own, although that is beyond the scope of this guide. The best way to
get a full understanding of preconditions is to study the library file
precond.t.  
  

------------------------------------------------------------------------

*Getting Started in TADS 3*  
[\[Main\]](index.html)  
*[\[Previous\]](action.htm)   [\[Next\]](remap.htm)*
