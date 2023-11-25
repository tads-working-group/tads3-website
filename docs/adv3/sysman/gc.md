::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Garbage Collection and Finalization\
[[*Prev:* Dynamic Object Creation](dynobj.htm){.nav}     [*Next:*
Expressions and Operators](expr.htm){.nav}     ]{.navnp}
:::

::: main
# Automatic Garbage Collection and Finalization

In languages like C and C++, the program is required to manage the
object \"lifecycle,\" from allocating memory for objects to deleting
them when they\'re no longer needed. TADS 3 lets you create objects
dynamically, but eliminates the need for you to manage their memory
after that point by introducing automatic \"garbage collection.\"

The T3 VM automatically keeps track of which objects can still be used
and which have become inaccessible, and from time to time deletes the
inaccessible objects, making the memory they were using available for
re-use. (We refer to inaccessible objects as \"garbage,\" because
they\'re just taking up memory without being of any further use to the
program; and we refer to the process of recognizing and deleting these
inaccessible objects as \"garbage collection.\")

For the most part, the garbage collector is invisible, so you can ignore
it when writing your program. However, in some cases you might wish to
be notified when the garbage collector is about to delete one of your
objects. When you want such notification, you can use a \"finalizer.\"

A finalizer is a special method, whose name is always
[finalize()]{.code}; this method takes no arguments. When the garbage
collector determines that an object has become unreachable, it checks to
see if the object has a [finalize()]{.code} method. If the object does
not have a [finalize()]{.code} method, the garbage collector can simply
delete the object at any subsequent time. If the object does have a
[finalize()]{.code} method, the garbage collector marks the object as
\"finalizable.\" Once an object is marked finalizable, the garbage
collector can call the object\'s [finalize()]{.code} method at any
subsequent time. Once this method returns, the garbage collector marks
the object as \"finalized.\" Once the object is marked as finalized, the
garbage collector re-considers the object\'s reachability; at any
subsequent time that the garbage collector determines that the object is
unreachable, the collector can delete the object.

Note that the garbage collector must determine that an object with a
[finalize()]{.code} method is unreachable twice before it can actually
delete the object: the object must become unreachable once before the
[finalize()]{.code} method can be called, and then must either remain
unreachable or once again become unreachable before it can be deleted.
The reason for the second reachability check is that the
[finalize()]{.code} method could potentially make the object reachable
again. Consider this example:

::: code
    MyGlobals: object
      finalizedList = []
    ;

    class MyClass: object
      finalize()
      {
        MyGlobals.finalizedList += self;
      }
    ;
:::

When an instance of [MyClass]{.code} becomes unreachable, the garbage
collector will at some point call the instance\'s [finalize()]{.code}
method, which adds a reference to the instance to
[MyGlobals.finalizedList]{.code}. Since [MyGlobals]{.code} is a named
object, it\'s always reachable, hence anything that
[MyGlobals.finalizedList]{.code} refers to is reachable - this means
that the instance being finalized once again becomes reachable. So, the
garbage collector cannot actually delete this object until the reference
is removed from [MyGlobals.finalizedList]{.code}, at which point the
instance once again becomes unreachable (assuming it hasn\'t been
referenced anywhere else in the meantime).

The garbage collector calls an object\'s finalizer only once, even if
the object becomes reachable again while it\'s being finalized. The
single finalizer call is enforced by the state transitions: an object is
initially unfinalized; after the garbage collector first notices that it
is unreachable it becomes finalizable; after the garbage collector calls
the finalizer the object becomes finalized. Once an object is finalized,
it is deleted as soon as the collector notices that the object is
unreachable. The garbage collector can only call the finalizer on a
finalizable object, and once the finalizer is called the object becomes
finalized; it cannot return to the finalizable state from the finalized
state.

Note that the garbage collector does not run continuously, but only at
certain times; exactly when the collector will run is unpredictable,
because it depends on what memory operations the program performs, but
it\'s also not usually important, since the program can largely ignore
the collector\'s operation. Because of the unpredictable timing of
garbage collection, the timeline descriptions above are intentionally a
little vague; the only thing that\'s certain is the order of events, not
their exact timing. So, an object might be finalized very quickly after
it becomes unreachable, or it might sit in memory for a long time before
the garbage collector gets around to finalizing the object.

Note also that you can explicitly invoke the garbage collector with the
[t3RunGC()]{.code} function in the [t3vm function set](t3vm.htm).

## firstObj()/nextObj()

The [[firstObj()]{.code}](tadsgen.htm#firstObj) and
[[nextObj()]{.code}](tadsgen.htm#nextObj) functions let you visit all of
the objects currently in memory. This can have the sometimes surprising
effect of retrieving objects that aren\'t currently reachable by any
other means. Unreachable objects are only removed when the garbage
collector runs, which only happens intermittently. Between runs,
\"dead\" objects remain in memory, and TADS doesn\'t even know they\'re
dead, because that determination is only made when the garbage collector
runs. As a result, [firstObj()]{.code} and [nextObj()]{.code} simply
visit all objects currently in memory, whether they\'re reachable or
not.

If you want to ensure that existing dead objects are removed from memory
before visiting objects with [firstObj()]{.code} and [nextObj()]{.code},
you can call [[t3RunGC()]{.code}](t3vm.htm#t3RunGC) just before your
object loop. This will ensure that any objects that are unreachable when
the loop is about to start will be removed from memory and thus excluded
from the object loop. This won\'t absolutely guarantee that you won\'t
retrieve any dead objects, though, since other objects could become
newly unreachable in the course of the loop itself.

## Implementation Details

For those interested in academic details, the T3 VM implementation in
TADS 3 uses a synchronous tracing garbage collector.

A tracing collector traverses the entire set of accessible objects,
starting with the \"root set.\" The root set is the set of objects that
are directly reachable to the program, such as local variables and
static objects defined in the source code. The garbage collector marks
each root set object as reachable, then marks as reachable each object
to which a root set object refers, then marks as reachable each object
to which those objects refer, and so on. This process continues until
the collector has marked every object that can be reached directly or
indirectly through references from root set objects. Any objects not
marked during this tracing process are unreachable, and hence can be
deleted.

A synchronous collector runs in the same thread as the rest of the
program, meaning that other operations halt while the collector runs.

It\'s possible in principle for the TADS garbage collector to in the
background while waiting for input through the user interface, such as
reading a command line or awaiting a mouse click. The VM is blocked
waiting for the UI anyway in these cases, so running the garbage
collector during UI waits is consistent with the synchronous design. The
advantage of this approach is that UI waits are generally idle times for
the CPU, so we\'re essentially using \"free\" CPU time. It\'s up to
individual VMs to take advantage of this, and whether they do or not
makes no difference to the program.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Garbage Collection and Finalization\
[[*Prev:* Dynamic Object Creation](dynobj.htm){.nav}     [*Next:*
Expressions and Operators](expr.htm){.nav}     ]{.navnp}
:::
