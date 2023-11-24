![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Language](langsec.htm) \> Dynamic
Object Creation  
[*Prev:* Multi-Methods](multmeth.htm)     [*Next:* Garbage Collection
and Finalization](gc.htm)    

# Dynamic Object Creation

Most TADS games define a large number of "static" objects that encode
the game world: the locations, characters, and items that make up the
game. We call these objects "static" because they exist throughout the
program's execution.

It is often useful to create objects dynamically as well. The main
reason you'd want to create an object dynamically, rather than define it
statically, is that you don't know in advance that you'll need the
object at all - or, more typically, you don't know exactly how many
instances of the object you'll need. For example, suppose your game
includes a pool of water, and you want the player to be able to fill any
container with water from the pool. If you could only define objects
statically, you'd have to pre-define a sufficient number of "quantity of
water" objects to cover each possible container, and you'd have to add
new static objects every time you modified your game to add new
containers. You'd also have to work out a scheme to keep track of which
objects were already in some container, so that you could find an
appropriate unused object when the player filled a new container. With
dynamic objects, though, you need only define a class for "quantity of
water," and then dynamically create a new instance of this class each
time the user fills a new container.

## Creating an Object

To create a new object dynamically, you use the "new" operator with the
name of the class:

    local x = new QuantityOfWater;

This creates a new object of the given class, returning a reference to
the new object. You can now use the new object just like any other.

Dynamic objects don't have names, so you must refer to them through
variables or properties. In the example above, we stored the new object
reference in a local variable. If we wanted to call the "sdesc" method
to display the object's description, we'd call the method on the local
variable:

    x.sdesc;

## Constructors

When you create a new object with the "new" operator, the system
automatically calls the method "construct" in the new object immediately
after creating it. You can define this method just like any other.

    class QuantityOfWater: Item
      construct()
      {
        volume_ = 5;
      }
    ;

The construct method can optionally take arguments. If you define a
construct method with arguments, you must pass the arguments to the
"new" operator. For example:

    class QuantityOfWater: Item
      construct(vol)
      {
        volume_ = vol;
      }
    ;

    myFunc()
    {
      local x = new QuantityOfWater(3);
    }

If you're familiar with C++ or Java, you should take note of some
important features of TADS constructors that differ from those of C++
and Java:

- In C++ and Java, a constructor always implicitly calls its base class
  constructor, as though a call to the base class constructor with no
  arguments had appeared as the first line of code of the constructor.
  (C++ and Java also allow explicit invocation of the base class
  constructor, which overrides the implicit call.) TADS does not
  implicitly call the base class constructor when an object defines its
  own constructor, although you can explicitly invoke the base class
  constructor using the normal "inherited" syntax.
- In C++ and Java, the name of a constructor is the same as the name of
  its class. TADS constructors are always called "construct."
- C++ and Java both provide "overloading," which allows multiple methods
  of the same name (and hence multiple constructors) to be defined as
  long as they have different argument lists. TADS does not offer an
  overloading mechanism. You can, however, use variable argument lists
  with TADS constructors to achieve a similar effect.

## Implicit Constructors

If you define an object or class with more than one superclass, and the
object does not define a construct method, the compiler automatically
generates an "implicit" constructor for the object. The implicit
constructor simply inherits each of the superclass constructors, in the
same order in which the superclasses are listed in the object
definition. The arguments passed to each base class constructor are the
same as the arguments passed to the object's constructor.

For example, suppose you define a class like this:

    class MultiClass: Class1, Class2
    ;

This class does not define an explicit constructor - in other words, it
has no construct method defined in the class. Because of this, the
compiler automatically generates an implicit constructor for the object;
the implicit constructor is equivalent to this:

    construct([args])
    {
      inherited Class1.construct(args...);
      inherited Class2.construct(args...);
    }

The compiler only generates an implicit constructor for objects and
classes with multiple superclasses and no explicit construct method.

## Object Deletion

The T3 VM peforms "automatic garbage collection." This means that the VM
periodically scans memory to determine which objects are still in use,
and which aren't, and automatically deletes the ones that aren't. An
object is deleted only when it's no longer possible for anything in the
program - any local variable, any object property, etc - to refer to the
object. In the absence of any way for the program to refer to the
object, the object can never be used again, so there's no reason to keep
it in memory.

The garbage collector is essentially invisible to the program. The VM
automatically runs the garbage collector from time to time; the program
doesn't have to do anything to cause this to happen.

In some cases you might wish to be notified when a particular object is
about to be deleted. To satisfy this need, TADS 3 includes a
"finalization" mechanism that calls a method, called a "finalizer," when
an object is about to be deleted. Refer to the [garbage
collection](gc.htm) section for details on finalization.

## Notes for TADS 2 users

TADS 2's delete operator doesn't exist in TADS 3. There's no
equivalent - you simply don't ever have to delete objects manually in
TADS 3.

In TADS 2, it was necessary to notify the system that an object was no
longer needed by explicitly "deleting" the object, which released the
memory that the object was using, allowing the system to re-use the
memory for other objects. This type of manual memory management seems
straightforward - if you allocate an object, you must eventually delete
it - but in practice proves to be very prone to errors. In particular,
two types of errors frequently occur with manual memory management:
leaks and dangling references. A "leak" occurs when you simply never get
around to deleting an object that you created; a program that leaks
memory will eventually consume all available system memory with objects
that should have been deleted, and is unable to continue running due to
the artificial memory shortage. A "dangling reference" is the opposite
problem: this occurs when you delete an object before you were actually
done using it, which can happen when one piece of code isn't aware that
another piece of code is still using the same object. A dangling
reference can cause all sorts of problems, especially if the system
reallocates the supposedly free memory for another purpose. To get
manual memory management right, you have to delete objects at exactly
the right time - not too early and not too late. It is a surprisingly
daunting task.

TADS 3's automatic garbage collection eliminates these potential
problems by eliminating the need to delete objects manually. The
automatic garbage collector will never create a dangling reference,
because it will never delete an object which is referenced anywhere in
your program. The garbage collector also ensures that there are no leaks
due to unreachable objects, because it automatically deletes objects
after they become unreachable (this is, in fact, the only time that the
garbage collector deletes an object, because deleting a reachable object
would create a dangling reference - indeed, this is the definition of a
dangling reference).

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Language](langsec.htm) \> Dynamic
Object Creation  
[*Prev:* Multi-Methods](multmeth.htm)     [*Next:* Garbage Collection
and Finalization](gc.htm)    
