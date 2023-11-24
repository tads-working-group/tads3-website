![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
WeakRefLookupTable  
[*Prev:* Vector](vector.htm)     [*Next:* The System Library](lib.htm)
   

# WeakRefLookupTable

WeakRefLookupTable is a subclass of [LookupTable](lookup.htm). It
behaves the same as the regular LookupTable class, and has the same
methods; the only difference is that the values in a weak-reference
table are only "weakly" referenced. (The keys are still "strongly"
referenced; only the values are weak references.)

A "weak reference" is a reference that **doesn't** prevent the garbage
collector from removing the referenced object from memory. On each scan
of memory, the garbage collector deletes each object it finds that is
not referenced at all, and each object that is referenced exclusively
through weak references. This means that if an object is referenced only
as a value stored in a WeakRefLookupTable, the garbage collector can
delete the object. Whenever the garbage collector deletes an object that
is stored as a value in a WeakRefLookupTable, the WeakRefLookupTable
automatically deletes that key/value pair.

Weak references have their uses, especially in situations where you want
to create a secondary access path to a set of objects for performance
reasons, such as an index or a cache. These cases are relatively rare,
though, so don't feel that you need to go out of your way to find places
to use this intrinsic class. If you can't think of a reason to use this
class, just ignore it and use the base LookupTable class.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
WeakRefLookupTable  
[*Prev:* Vector](vector.htm)     [*Next:* The System Library](lib.htm)
   
