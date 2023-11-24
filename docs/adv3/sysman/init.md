![](topbar.jpg)

[Table of Contents](toc.htm) \| [The System Library](lib.htm) \> Program
Initialization  
[*Prev:* The System Library](lib.htm)     [*Next:* Basic
Tokenizer](tok.htm)    

# Program Initialization

The system library provides a generic, modular initialization mechanism
that lets you write snippets of start-up code that the library
automatically invokes at the appropriate time.

There are two phases of initialization: *pre-initialization*, which runs
during the compilation process to allow the program to do any
time-consuming preparation of static data structures, saving start-up
time when users run the program; and *run-time initialization*, which
lets the program set up the initial UI environment and attach to
external system resources.

## Pre-initialization

When you compile your program, after the linker finishes building the
.t3 file, the compiler runs the "preinit" phase. This step involves
running the program in a stripped-down version of the interpreter (which
works the same as the full interpreter, except that it omits most of the
user interface intrinsics). During this step, the system sets a special
internal flag that tells you that pre-initialization is under way.

The point of the preinit phase is to let you set up your program's
objects and other data structures in their initial states. Since this
step happens during compilation, you can get any time-consuming set-up
work out of the way here, before users ever see your program - users
won't have to wait for the work to be repeated each time they run the
program, since it's taken care of in advance.

### PreinitObject

The best way to write preinit code is to define PreinitObject instances.

PreinitObject is a class defined in the system library. During the
preinit phase, the system finds every object of type PreinitObject and
calls its execute() method.

    myInitObj: PreinitObject
       execute()
       {
          // do some initialization work...
       }
    ;

You can use PreinitObject as a mix-in class, combining it with other
classes in an object's list of superclasses. This lets you define an
object's initialization code directly with the object.

You can define any number of PreinitObject instances. This lets you
modularize your initialization code - you can create a new object each
time you have a different item you need to initialize.

By default, the order in which the library initializes PreinitObject
instances is arbitrary. However, an object's initialization code might
in some cases depend upon another object having been initialized first.
In these cases, an object can define the execBeforeMe property to a list
of the objects that must be initialized before it is; the library will
ensure that all of the listed objects are initialized first. In
addition, an object can define the execAfterMe property list to a list
of the objects that must be initialized after it is.

For example, to define an object that cannot be initialized until after
another object, called "myLibInit", has been initialized, we would write
this:

    myInitObj: PreinitObject
      execute() { /* my initialization code */ }
      execBeforeMe = [myLibInit]
    ;

### Deferred preinit in debug builds

Note that if when you compile in "debug" mode, the compiler defers
preinit until you run the program normally. It does this so that you
have a chance to step through the preinit process using the debugger. If
the compiler ran preinit even in a debug build, there'd be no way for
you to step through the process in the debugger, since the whole process
would already have come and gone by the time you got into the debugger.

Note that preinit does still occur even in debug builds - it just gets
deferred until you run the program, rather than running during
compilation. This doesn't change anything except the timing. In
particular, everything still happens in the same order. You don't have
to worry about writing conditional code to deal with any differences; as
far as your program is concerned, it shouldn't matter.

There's one small additional detail worth mentioning: the link between
the debug build mode and the timing of the pre-initialization step is
only the default, and you can override it if you want using a compiler
option. The t3make option "-nopre" tells the compiler not to run
pre-initialization (thereby deferring it until run-time), even for a
non-debug build; the "-pre" option tells the compiler to run
pre-initialization as part of the compilation process, even for a debug
build.

### Preinit and Restart

The system library's start-up code includes a framework for handling
"restarting." It's traditional in text adventures to include a RESTART
command that starts the game over from the beginning (and to offer the
option to restart when the player encounters a dead end in the story).
The VM itself provides a low-level function that resets all of the
non-transient objects in the game to their initial states, just as they
were when the game was first loaded into the interpreter, but that only
goes so far; to start the action over from the beginning, we still need
to jump back to the game's entrypoint and start running it from the
beginning. The default start-up code helps with this by providing a
"catch" handler for a special exception class, RestartSignal. You can
throw this signal from anywhere within the game, and the default
start-up code will catch it, reset objects to their initial state, and
start running the game over from the beginning.

As part of restarting the game, the system library automatically invokes
the pre-initialization step, if necessary. It's necessary if
pre-initialization ran when you first loaded the game into the
interpreter. This means that each PreinitObject will be executed again
immediately after each restart if it ran on the initial load. Likewise,
the start-up initialization will run again, so each InitObject will be
executed.

Note that pre-initialization will occur on each restart if and only if
it occurs when you initially load the game, and that happens if and only
if pre-initialization didn't run during compilation. That means that if
you build the game in debug mode, or if you explicitly defer
pre-initialization to run-time, then pre-initialization will happen at
initial load and at each restart.

### Derived information

The most common type of task to perform during pre-initialization is
setting up "derived" property settings. A derived setting is one that
can be determined entirely from some other information; the new setting
thus doesn't actually contain any new information, but just stores the
original information in a different format.

Derived settings might seem pointless: why would you want to store the
same information twice? Indeed, storing derived information is the
source of a great many programming errors, since related pieces of
information can get "out of sync" with one other if one is not careful
to update all of the pieces every time any of the pieces changes.
Despite this, it's often difficult to find another way of doing
something, so derived data show up all the time in practical programming
situations.

A good text-adventure example of derived information is the way object
location information is stored. The typical game programmer assigns a
location to each object in the game; we might do this with a "location"
property:

    book: Item
      location = bookcase
    ;

Clearly, if some code in your program were handed a reference to this
"book" object, and you wanted to know the object that contained the
book, you'd just evaluate the object's location property:

    objCont = obj.location;

Now, what if you were handed a reference to the "bookcase" object, and
you wanted to find out what objects the bookcase contains?

One solution would be to check each object that you think might appear
in the bookcase:

    booklist = [];
    if (book.location == bookcase) booklist += book;
    if (bookEnd.location == bookcase) booklist += bookEnd;

Apart from being incredibly tedious, this is a terribly inflexible way
to program. If you added one more object to your game, you'd have to add
a line to this code. And just imagine how bad it would be if you wanted
to find out what the bookcase contains in more than one place in your
program.

A more flexible, and less tedious, solution would be to use the
firstObj() and nextObj() functions to iterate over all of the objects in
the game:

    booklist = [];
    for (local obj = firstObj() ; obj != nil ; obj = nextObj(obj))
    {
       if (obj.location == bookcase)
       booklist += obj.location;
    }

You clearly wouldn't want to write that too many times, but it's not so
bad to write it once and put it in a function. Better yet, you could
make this a method of a low-level class, and rather than asking whether
the location is "bookcase" you could ask if it's "self", and thus you'd
have a method you could call on any object to produce a list of its
contents.

The only problem with this approach is performance. If we had to run
through all of the objects in the game every time we wanted to know
what's in a container, our game would become slower and slower as it
grows. It is reasonable to expect that we would want to know the
contents of an object frequently, too, so this code would be a good
candidate for optimization.

Performance is probably the primary reason that derived information
shows up so frequently in real-world programming. We will often
construct a data structure that represents some information in a manner
that is very efficient for some particular use, but is terrible for
other uses - our "location" property above is a good example. When we
encounter another way that we will frequently use the same data, and
this other way can't make efficient use of the original data structure,
we often find that the best approach is to create another parallel data
structure that contains the same information in a different form.

So, how could we make it more efficient to find the contents of a
container? The easiest way would be to store a "contents" list for each
container. So, if asked to list the contents of an object, we'd simply
get its "contents" property, and we'd be done. There'd be no need to
look at any object's "location" property, since the "contents" property
would give us all of the information we need.

One problem with this approach is that it would make a lot of extra work
if we had to type in both the "location" and the "contents" properties
for every object:

    book: Item
      location = bookcase
    ;

    bookcase: Container, FixedItem
      location = library
      contents = [book, bookEnd]
    ;

Not only would it be tedious to type in a "contents" list for every
object, but it would be prone to errors, especially as we added objects
to the game.

The solution we're coming to is probably obvious by this point. Rather
than forcing the programmer to type in both a "location" and a
"contents" property, we could observe that both properties actually
contain the same information in different forms, and hence we could
automatically derive one from the other, and store the results. The
programmer would only have to type in one of them. The easier of the
two, for the programmer, would seem to be "location", so let's make
"contents" be the derived property. During program initialization, we'd
go through all of the objects in the game and construct each objects
"contents" list, using the same code we wrote earlier.

The difference between what we were doing earlier and what we're
proposing now is that, this time, we plan to store the derived
information. Each time we construct a list of objects that an object
contains, we'll store the list in the "contents" property for the
object. So, without adding any typing, we'll end up with the same
"contents" declaration that we made manually for "bookcase" above. We'll
construct this contents list once, during program initialization, for
every object in the game.

There's another detail we must attend to: each time we change an
object's location, we must at the same time change the "contents"
property of its original container and of its new container. The best
way to do this is to define a method that moves an object to a new
container, and updates all of the necessary properties. We could call
this method "moveInto":

    moveInto(newLocation)
    {
       /* remove myself from the old location's contents */
       if (location != nil)
          location.contents -= self;

       /* add myself to the new location's contents */
       if (newLocation != nil)
          newLocation.contents += self;

       /* update my location property */
       location = newLocation;
    }

As long as we're always careful to move objects by calling their
moveInto() method, and we never update any object's "location" or
"contents" properties directly, all of the properties will remain
coordinated.

Many programmers who work with object-oriented languages develop a habit
of using "accessor" and "mutator" methods when accessing an object's
properties, rather than evaluating the object's properties directly. An
"accessor" is simply a method that returns the value of a property, and
a "mutator" is a method that assigns a new value to a property. The
advantage of using accessors and mutators as a matter of course becomes
clear when we consider our moveInto() example above: these methods help
keep all of the internal book-keeping code for an object in one place,
so that outside code doesn't have to worry about it.

## Run-time initialization

The library also defines a class called InitObject, which works the same
way as PreinitObject, but is used during normal program start-up rather
than pre-initialization. Just before the standard start-up code calls
your main() routine, it invokes the execute() method on each instance of
InitObject.

As with PreinitObject's, you can use the execBeforeMe and execAfterMe
properties in your InitObject instances to control the order of
initialization.

The reason for a separate run-time initialization mechanism is that
there are some kinds of initializations that can't be done in advance,
because they depend on the actual run-time environment. For example, you
might want to do something special that depends on the version of the
interpreter that's being used, or you might want to customize something
based on the run-time operating system. You might want to do something
in the user interface, such as create some banner windows.

### Low-level preinit

After linking is complete, when not compiling for debugging, t3make
calls the main entrypoint function (\_main), just as it would for normal
execution. However, the system sets a special internal flag that
indicates that it's performing pre-initialization rather than a normal
run of the program. You can access this flag via the
t3GetVMPreinitMode() function in the "t3vm" function set; this function
returns true if pre-initialization is taking place, nil during normal
execution.

Note that the difference between the debug and non-debug build modes
does not mean that you have to write your code differently for the two
modes. Pre-initialization runs in both types of builds, and runs in the
same sequence in both types of builds; as far as your program is
concerned, there's no difference at all. The only difference is where
the pre-initialization step is carried out. Here's a summary of the
sequence of events in the two cases:

Normal (non-debug) builds:

- Compiler:
  - Compiles program
  - Runs pre-initialization
- Interpreter:
  - Executes the main program

Debug builds:

- Compiler:
  - Compiles program
- Interpreter:
  - Runs pre-initialization
  - Executes the main program

In both cases, the sequence of events that your program sees is the
same: compile, pre-initialize, run.

## Notes for TADS 2 Users

With TADS 2, pre-initialization was accomplished via a user-defined
function called preinit(). The TADS 2 compiler called this after
completing compilation to give the game a chance to do its compile-time
setup work.

TADS 3 doesn't use the preinit() function, but it has a corresponding
mechanism. Instead of putting all of your your pre-initialization code
in a single function, you can create any number of PreinitObject
objects, each with its own bit of code. This lets you create nicely
modular initialization code, with each initializer grouped with the
object definitions it pertains to.

Similarly, the TADS 2 init() function is replaced in TADS 3 with
InitObject objects, which make it easy to write modular run-time
initialization code.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The System Library](lib.htm) \> Program
Initialization  
[*Prev:* The System Library](lib.htm)     [*Next:* Basic
Tokenizer](tok.htm)    
