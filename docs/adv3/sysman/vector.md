![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
Vector  
[*Prev:* TimeZone](timezone.htm)     [*Next:*
WeakRefLookupTable](wlookup.htm)    

# Vector

Vector is a subclass of [Collection](collect.htm) that provides an
ordered collection of elements, like [List](list.htm), but provides
"reference semantics," which means that you can modify the elements of a
Vector directly.

To use the Vector class, you should \#include \<systype.h\> or \#include
\<vector.h\> in your source files.

## Which should I use: List or Vector?

The List and Vector classes are very similar; both of these classes
allow you to manage collections of values as a group. The differences
between the classes are a little subtle, but they're important.

Lists offer two unique features. First, List is an intrinsic T3 VM
datatype, which makes it the "universal" collection type; some functions
and methods require list values, and won't accept other collection
types. Second, Lists use "value semantics," so you never have to worry
about the effects of changing a list value to which other parts of your
program might be retaining references.

Vectors use "reference semantics," which are sometimes trickier to work
with than a List's value semantics, but offer advantages in some
situations. Reference semantics also make Vectors more efficient when
you're performing an iterative process that involves repeated updates to
a collection's elements: if you use a List for such a process, each
update to an element would create a new list value, whereas changes to a
Vector's elements simply change the existing Vector object, rather than
creating a new Vector.

In general, you can decide which type of collection to use based on what
you're going to do with it:

- If you're storing a value that will be used by many parts of your
  program, such as in an object property, and the value won't be changed
  frequently, List is a good choice. Because of a list's value
  semantics, the different parts of the code that refer to the same list
  won't have to coordinate their activities if they make local changes
  to the list.
- If you'll be updating the elements of a collection frequently, you
  should use a Vector. Using a Vector rather than a List avoids the
  overhead of creating a new copy of the collection every time you
  update one of its members.
- If you're dynamically building a collection through an iterative
  process that involves repeated changes to the collection (additions of
  new elements, removal of elements, or updates to existing element
  values), you should use a Vector.

## Creating a Vector

To create a Vector, you use the new operator. The constructor can be
called with several different argument formats.

The simplest way to call the constructor is with no arguments. This
creates an empty Vector (one with no elements, and a length() of zero)
and a default "initial allocation size" (we'll explain what that means
shortly).

    local x = new Vector();

You can also use a single integer argument to specify an initial
allocation size. This still creates an empty vector - its length() will
be zero - but it allows you to control how much memory is initially
allocated for the Vector.

    // create an empty Vector with an initial allocation of 10 elements
    x = new Vector(10);

Next, you can create a Vector and fill it in with a given number of
elements already present, populated with nil values. To do this, pass
two integer values. The first is the initial allocation length, as
above, and the second is the number of slots to fill in with nil values.
It's exactly as though you called append(nil) that many times after
creating the Vector.

    // create a Vector with 10 slots allocated, and with 5 slots initially
    // filled in with nil - so x.length() is 5
    x = new Vector(10, 5);

You can also create a Vector as a copy of a List or another Vector. To
do this, pass in the source object as the single argument. This creates
a new Vector object and copies all of the elements from the source
object. The new Vector will have the same length() as the source object,
and an initial allocation equal to the length of the source object.

    // create a Vector with the same elements as a list
    x = new Vector([1, 2, 3]);

Finally, you can create a copy of a List or Vector, and also specify the
initial allocation length. This is useful if you want to leave room in
the initial allocation for adding more elements.

    // create a copy of the list, but allocate 10 elements initially
    x = new Vector(10, [1, 2, 3]);

Note that if the initial allocation you specify in this kind of call is
smaller than what's required to copy the source object, the constructor
will obviously have to ignore that value and allocate enough space to
hold the initial values.

### The initial allocation

The constructor gives you the option to set the "initial allocation"
size for the Vector. What is this? Well, let's first look at what it
isn't.

First, it's *not* the initial number of elements in the Vector; that's
determined by the other arguments. For example, new Vector(100) creates
an empty vector, even though you've specified a fairly large initial
allocation:

    x = new Vector(100);
    say(x.length());  // displays "0"

Second, the initial allocation is *not* the maximum size that the Vector
can ever attain. No matter what initial allocation size you set, a
Vector can grow to any length. The system will simply keep allocating
more memory as needed when you add more elements.

    x = new Vector(1);
    x.append(1);
    x.append(2);
    x.append(3);
    say(x.length());  // displays "3"

Note that it's perfectly legal to add three elements to this Vector,
even though it was created with room for only one item. A Vector always
expands as needed.

So if the initial allocation size doesn't set the initial number of
elements in the vector, and it doesn't set a maximum size, what good is
it? And does it even matter what the value is? The answer is that
setting affects the memory efficiency of the vector. When you first
create the vector, the system internally allocates the number of slots
you specify in the initial allocation size; these slots are marked as
"not yet in use," because the vector contains no elements at this point,
but they're available for future use when you add elements. When you add
elements, the Vector puts them into these reserved slots, which is a
very fast operation. If you add more elements than there are reserved
slots, the Vector must allocate more memory, which takes a little more
time.

If you make the initial allocation size too small, the system will have
to allocate more memory for the Vector, possibly more than once, as you
add new elements. If you make the initial allocation too large, the
vector will take up more memory than it will ever actually need.

Don't worry about this too much, though. The Vector object manages its
memory automatically, so it's not a big deal if the initial size is too
high or too low. The additional work of allocating more memory isn't
huge. The initial size parameter is provided only so that you can
fine-tune your program's performance in cases where you have a pretty
good idea in advance of how large a vector will be; in cases where you
don't have any way of knowing, you can just pick a number that seems in
the ballpark for a typical case, or omit it entirely and use the default
size.

## Vector operators

The + operator adds new elements to the end of a Vector. If the operand
on the right side of the + is a list or another Vector, its elements are
individually added to the vector; otherwise, the value on the right side
of the + is added as a single new element. Note that this operator
always creates a new Vector to store the result; the original vector's
value is unchanged.

The - operator removes elements from the Vector. If the operand on the
right side of the - is a list or Vector, each element of the list of
Vector is individually removed from the Vector on the left of the -. If
the operand on the right side of the - is not a list or vector, each
element of the vector whose value equals the right operand is deleted
from the vector on the left. Note that the - operator always creates a
new Vector to store the result.

The indexing operator \[ \] can be used to get and set elements of the
array using an integer index, just as with a List. If you assign an
element of the vector past the current length of the vector, the vector
is automatically extended to include the necessary number of elements;
new elements between the last existing element and the element at the
requested index are set to nil. If you try to retrieve a vector element
with an index higher than any existing element, a run-time exception
("index out of range") is thrown.

A Vector can be used with the == or != operators to compare a Vector to
another value. A Vector is equal to another Vector or List if the other
Vector or List has the same number of elements, and each element of the
Vector equals the corresponding element of the other Vector or List,
using the same rules as the == operator to compare the elements.

Note: Because the == test is defined recursively, if a Vector contains a
reference to itself, either directly or indirectly through another
Vector, the == test can recurse infinitely. The Vector class avoids this
infinite recursion by limiting the depth of recursion in an equality
comparison to 256 levels. If this recursion depth is exceeded, the ==
test throws an exception ("maximum equality test/hash recursion depth
exceeded"). This same exception will result, for the same reason, if a
Vector with a self-reference is used as a key in a LookupTable. The
recursion depth exception can occur even if a Vector contains no
self-references, if it simply contains such a complex series of
references that it exceeds the maximum depth. Note that this limit does
not have anything to do with the number of elements in any Vector;
rather, it pertains to the depth of the references from one Vector to
another. So, if you create Vectors A, B, C, D, ..., and set A\[1\] = B,
B\[1\] = C, C\[1\] = D, and so on for more than 256 vectors, then
comparing A to another vector could exceed the maximum depth.

### String conversions

A Vector value can be converted to a string using the
[toString()](tadsgen.htm#toString) function. A Vector can also be used
in a context where a non-string value is implicitly converted to a
string, such as in the [tadsSay()](tadsio.htm#tadsSay) function or in a
string concatenation (that is, on the right-hand side of a "+" operator
where the left-hand side is a string).

The string conversion of a Vector consists of the Vector's elements,
each itself first converted to a string if necessary, concatenated
together, with commas separating elements. For example, toString(new
Vector(\[1, 2, 3\])) yields the string '1,2,3'.

## Vector methods

Vector is a subclass of [Collection](collect.htm), so the Collection
methods are available on a Vector object. In addition to the Collection
methods, Vector provides many methods of its own, shown below.

append(*val*)

Appends the value *val* to the end of the vector, increasing the
vector's length by one. This method has almost the same effect as the +
operator, except for the treatment if *val* is a list: this method
simply appends a list value as a single new element, whereas the +
operator appends each element of the list value as a separate new
element. In addition, unlike the + operator, this method modifies the
Vector object, rather than creating a new Vector to store the result.
Returns self.

appendAll(*val*)

This works like append(*val*), except that if *val* is a List or Vector,
each element of *val* is individually appended to the target Vector.
This method works like the + operator, except that this method modifies
the Vector, rather than creating a new Vector to store the result.
Returns self.

appendUnique(*val*)

Appends the elements of the list or Vector *val* to this vector; the
vector is modified so that it consists only of the unique elements of
the combination. On return, any given value will appear in the vector
will appear only once. Like append() and appendAll(), this modifies the
Vector directly.

applyAll(*func*)

For each element of the vector, this method invokes the callback
function *func*, passing the current element as the single argument,
then replaces the vector element with the return value from the
callback. This method does not create a new Vector; rather, it modifies
the original Vector. This method returns self as the result value.

This method is useful for transforming the elements of a vector by
applying a modifier function. For example, if we have a vector of
numbers, we could use this method to multiply each number in the vector
by two:

    x.applyAll({x: x*2});

This method is also handy for performing complex initializations on a
new Vector. For example, here's a function that creates a new vector and
initializes it with the first *n* Fibonacci numbers. Because we're
simply initializing the new vector, note that the callback function
doesn't make any reference to the original element value, but it must
still declare a parameter for the argument value so that the arguments
passed from applyAll() match the declaration.

    createFibonacciVector(n)
    {
      local f0 = 0, f1 = 1;
      return new Vector(n, n).applyAll(function(x)
        { local ret = f0; f0 = f1; f1 += ret; return ret; });
    }

Note that we specify the value *n* twice in the constructor to
explicitly set the initial size of the vector to *n* nil elements. This
is important because a newly-created vector normally doesn't contain any
elements, regardless of the initial allocation setting; by explicitly
using the initial length argument *n*, we ensure that applyAll() will
visit *n* elements.

copyFrom(*source*, *sourceStart*, *destStart*, *count*)

Copies values from a list or from another list or vector into this
Vector. This function doesn't create a new Vector, but simply modifies
entries in the self vector. *source* is the source of the values; it
must be either a vector or a list. *sourceStart* is an index into
source, and specifies the first element of source that is to be copied.
*destStart* is an index into the self vector, and specifies the first
element of the vector that is to be modified. *count* is the number of
elements to modify. The method copies elements from *source* into the
self vector, one at a time, until it reaches the last element of source,
or has copied the number of elements specified by count.

If either starting index is negative, it counts backwards from the last
element of its vector: -1 is the last element, -2 is the second to last,
and so on.

Calling this method is equivalent to writing a code fragment like this:

    for (local i = 0 ; i < count ; ++i)
      dest[destStart + i] = source[sourceStart + i];

If necessary, the method expands the self vector to make room for the
added elements.

The copyFrom() method simply returns self; this is convenient for
expressions like this:

    x = new Vector(20).copyFrom(lst, 3, 2, 5);

countOf(*val*)

Returns the number of elements in the vector whose values equal *val*.

countWhich(*cond*)

Returns the number of elements in the vector for which the callback
function *cond* returns a non-false value (anything but nil or 0). For
each element in the Vector, the method invokes *cond*, passing the
element as the argument to the callback. If *cond* returns anything but
nil or 0, the method counts the element. After invoking *cond* for each
element, the method returns the number of elements for which *cond*
returned a non-false value.

fillValue(*value*, *start*?, *count*?)

Fills elements of this Vector with *value*. If only *value* is
specified, this method simply stores *value* in every element of the
self vector. If *start* is specified, it gives the starting index; the
method fills values starting with *start*, to the end of the Vector. If
both *start* and *count* are specified, count gives the maximum number
of elements to fill.

If *start* isn't specified, the default starting index is 1. If *start*
is negative, it counts from the end of the vector: -1 is the last
element, -2 is the second to last, and so on.

If *count* isn't specified, the default count is self.length() -
*start* + 1, or 0 if that yields a negative value. In other words, the
default *count* is chosen to fill to the end of the existing elements of
the Vector. Note that this is the actual populated length of the Vector,
*not* the initial allocation size: new Vector(10).fillValue('x') yields
a vector with zero elements filled in, not 10, because a Vector created
this way is initially empty - the 10 is merely the initial allocation
size hint, not the initial filled length.

This method is equivalent to writing a code fragment like this:

    for (local i = 0 ; i < count ; ++i)
      dest[start + i] = value;

Calling fillValue() is easier than writing this code fragment, though,
and considerably faster because it is implemented as native code.

This method returns self, which allows for expressions like this:

    x = new Vector(20).fillValue('A', 1, 20);

forEach(*func*)

Invokes the callback function (*func*)(*value*) for each element, in
order from first to last, passing the value of one element as *value* to
the callback on each invocation. The callback function takes one
argument giving the value of the current element, and returns no value.
This method returns no value. This method is a convenient means of
executing some code for each element of the vector.

forEachAssoc(*func*)

Invokes the callback function (*func*)(*index*, *value*) for each
element, in order from first to last, passing each element's index and
value to the function *func*. The callback function returns no value.
This method returns no value. This method is the same as forEach(),
except that this method provides the callback with the index as well as
the value for each element it visits.

generate(*func*, *n*)

Creates a new Vector containing *n* elements by invoking the callback
function *func* once for each element, and using the return value as the
element value. This is a class method that you call on the Vector class
directly, as in Vector.generate(f, 10).

*func* is a callback function, which can be a regular function or an
anonymous function. *func* can take zero or one argument. The
one-argument form is invoked with the index of the current element as
the argument on each call.

generate() is convenient for creating a Vector of items based on a
formula. For example, this creates a Vector of the first ten positive
even integers:

    local e = Vector.generate({i: i*2}, 10);

getUnique()

Returns a new vector consisting of the unique elements of the original
vector. For each value in the original vector, the value will appear in
the new vector only once. The order of the elements in the new vector is
that of the first appearances of the unique elements of the original
vector. For example, if the original vector's elements are, in order, 1,
5, 2, 5, 3, 5, 4, 5, this method will return a new vector whose elements
are, in order, 1, 5, 2, 3, 4. Note that the size of the new vector is
just large enough to hold only the unique elements, so the new vector
might be smaller than the original vector.

indexOf(*val*)

Finds the first element of the vector whose value equals *val*, and
returns the index of the element. Returns nil if none of the vector's
elements equals *val*.

indexOfMax(*func*?)

If *func* is omitted, returns the index of the element with the maximum
value, comparing values to one another as though using the \> operator.

If *func* is specified, it must be a function pointer. The method calls
*func*() for each element in the vector, passing the element's value as
the function argument. The function must return a value. The result of
indexOfMax in this case is the index of the element for which *func*()
returned the maximum value.

For example, if v is a vector containing string values as elements,
v.indexOfMax({x: x.length()}) returns the index of the longest string.

indexOfMin(*func*?)

If *func* is omitted, returns the index of the element with the minimum
value, comparing values to one another as though using the \< operator.

If *func* is specified, it must be a function pointer. The method calls
*func*() for each element in the vector, passing the element's value as
the function argument. The function must return a value. The result of
indexOfMin in this case is the index of the element for which *func*()
returned the minimum value.

For example, if lst is a vector containing string values as elements,
v.indexOfMin({x: x.length()}) returns the index of the shortest string.

indexWhich(*cond*)

Finds the first element for which the given condition is true. The
method iterates through the elements of the vector, starting at the
first element and proceeding in order, and applies the callback function
*cond* to each element. The callback takes one argument, which is the
value of the vector element, and returns a condition result value. For
each element, if the callback function returns a non-false value (i.e.,
any value except nil or zero), the method immediately stops the
iteration and returns the index of that element. If the callback returns
a false value (nil or zero) for every element of the vector, the method
returns nil.

insertAt(*startingIndex*, *val*, ...)

Inserts one or more values into the vector at the giving starting index.
The size of the vector is increased to accommodate the new elements.
Note that, if any of the values are lists or other collections, they are
simply inserted as single elements; this contrasts with the + operator,
which adds each element of a list as a separate element of the vector.

If *startingIndex* is negative, it counts from the end of the vector: -1
is the last element, -2 is the second to last, etc. The special value 0
means to insert after the last element. If *startingIndex* is positive,
it must be in the range from 1 to one higher than the length of the
vector. If the starting index value is 1, the new elements are inserted
before the first existing element of the vector. If the starting index
is one higher than the length of the vector, the new elements are
appended after the last existing element of the vector. If the starting
index is out of this valid range, the method throws an error ("index out
of range").

Returns the self object.

join(*sep*?)

Returns a string made by concatenating the elements of the vector
together in index order. If *sep* is provided, it's a string that's
interposed between elements as a separator. If *sep* is omitted, the
elements are concatenated with no separation.

Each element is converted to a string using the usual automatic
conversions before it's concatenated. If an element can't be converted
to string, the method throws an error.

lastIndexOf(*val*)

Returns the index of the last element in the vector whose value equals
*val*. If none of the elements in the vector matches the given value,
the method returns nil.

lastIndexWhich(*cond*)

Finds the last element for which the given condition is true. This
method is similar to indexWhich(*cond*), but scans the vector in reverse
order, starting with the last element and working backwards. Returns the
index of the matching element, or nil if the condition returns false for
every element.

lastValWhich(*cond*)

Finds the last element for which the given condition is true, and
returns the element's value. This method is similar to
lastIndexWhich(*cond*), but returns the value of the matching element
rather than its index. Returns nil if no matching element is found.

length()

Returns an integer giving the number of elements in the vector. This is
the number of elements actually stored in the vector, and is unrelated
to the initial allocation size specified when the vector was created.

mapAll(*func*)

Creates a new vector consisting of the results of applying the callback
function *func* to each element of the original vector. This method is
similar to applyAll(*func*), but rather than modifying the elements of
the original vector, this method creates a new vector, and leaves the
elements of the original vector unchanged. The return value is the new
vector.

maxVal(*func*?)

If *func* is omitted, returns the maximum of the element values in the
vector, comparing values to one another as though using the \> operator.

If *func* is specified, it must be a function pointer. The method calls
*func*() for each element in the vector, passing the element's value as
the function argument. The function must return a value. The result of
maxVal in this case is the value of the element that maximizes *func*.
Note that the **element value** is returned, *not* the return value of
*func*.

For example, if v is a vector containing string values, v.maxVal({x:
x.length()}) returns the longest string element.

minVal(*func*?)

If *func* is omitted, returns minimum of the element values in the
vector, comparing values to one another as though using the \< operator.

If *func* is specified, it must be a function pointer. The method calls
*func*() for each element in the vector, passing the element's value as
the function argument. The function must return a value. The result of
minVal in this case is the element value that minimizes *func* Note that
the **element value** is returned, *not* the return value of *func*.

For example, if v is a vector containing string values, v.minVal({x:
x.length()}) returns the shortest string element.

prepend(*val*)

Inserts the value *val* before the first element of the vector,
increasing the vector's length by one. This method is similar to
append(*val*), but inserts the new element at the start of the vector
rather than at the end. Returns self.

removeElement(*val*)

Deletes one or more elements from the vector; each vector element whose
value equals *val* is removed from the vector. This reduces the length
of the vector by the number of elements removed. If there is no element
of the vector whose value equals *val*, the vector is unchanged. Returns
self.

removeElementAt(*index*)

Deletes one element from the vector at the given index. This reduces the
length of the vector by one. The *index* value must refer to an existing
element of the vector, or the method throws an error ("index out of
range"). Returns self.

If *index* is negative, it counts from the end of the vector: -1 is the
last element, -2 is the second to last, and so on.

removeRange(*startingIndex*, *endingIndex*)

Deletes elements from the vector from *startingIndex* through and
including *endingIndex*. If *startingIndex* equals *endingIndex*, this
method simply deletes one element. This reduces the length of the vector
by the number of elements removed.

Either index (or both) can be negative. A negative index counts from the
end of the vector: -1 is the last element, -2 is the second to last,
etc. To delete the last two elements, for example, you can use
vec.removeRange(-2, -1).

Both *startingIndex* and *endingIndex* must refer to existing elements
of the vector, and the ending index must be greater than or equal to the
starting index; if these conditions don't hold, the method throws an
error ("index out of range").

Returns the self object.

setLength(*newLength*)

Sets the number of elements of the vector to *newLength*. If *newLength*
is smaller than the number of elements currently in the vector, this
discards elements at the end of the vector. If *newLength* is larger
than the current size, this adds new elements and sets their values to
nil. Returns the self object.

sort(*descending*?, *comparisonFunction*?)

Re-orders the elements of the vector into sorted order. By default, this
method sorts the elements of the vector into ascending order, but you
can reverse this ordering by specifying true for the *descending*
argument.

The optional *comparisonFunction* can be used to specify the ordering of
the result. If this argument is not specified (or is nil), the method
will sort the elements according to the standard system ordering of
values; hence, the elements must be of comparable types (such as all
integers or all strings). By specifying a comparison function, you can
provide your own special ordering, and you can also sort values that
have no system-defined order, such as object values.

The *comparisonFunction* works the same way as the for the
[List](list.htm) class's sort() method.

splice(*idx*, *del*, ...)

Splices elements into the vector, by replacing a given range of elements
with a set of new elements. *idx* is the starting index for the splice,
and *del* is the number of items to delete. The remaining arguments are
values to be inserted in place of the items deleted. The method first
deletes *del* elements from the list starting at *idx*, then inserts the
remaining arguments as new elements at the same index. The effect is to
replace the *del* elements starting at *idx* with the new list of
elements. The number of new elements can be different from the number of
elements deleted.

If *idx* is negative, it counts from the end of the vector: -1 is the
last element, -2 is the second to last, and so on. If *idx* is zero, the
new elements are inserted after the existing last element.

To insert elements without deleting any existing elements, pass 0 for
*del*. To delete elements without inserting any new elements in their
place, simply omit any additional arguments.

This method modifies the vector in place, and returns self.

You can get the same effect as this method using a combination of
removeRange() and insertAt(). splice() is clearer and more concise for
cases where you want to replace a range with new values. It's also a
little more efficient, because it minimizes the number of copy
operations needed to move elements around in the vector to open and/or
close gaps as the size of the vector changes.

subset(*func*)

Creates and returns a new vector containing the elements of this vector
for which the callback function *func* returns a non-false value (i.e.,
any value other than nil or 0). For each element of the source vector,
this method invokes the callback function, passing the value of the
current element as the callback function's single argument. If the
callback returns nil or 0, the method omits the element from the result;
otherwise, the method includes the element in the result vector. The new
vector's elements will be in the same order as the selected elements
from the source vector.

This method does not modify the original vector.

This example uses a short-form anonymous function to create to create a
new vector that contains only the elements from an original vector whose
values are greater than 10.

    y = x.subset({x: x > 10});

toList(*start*?, *count*?)

Creates and returns a new list value based on the vector. With no
arguments, the new list has the same number of elements as the original
vector, and each element of the list is a copy of the corresponding
element of the vector. If *start* is specified, it gives the starting
index in the vector for the list; elements of the vector before start
are not included in the list. If *count* is specified, it indicates the
number of elements of the vector, starting at start, to copy into the
list.

This method is useful when you need to pass a value to a routine that
requires a list value. Vectors cannot always be passed to routines
requiring list values, so you can use this routine to create a list with
the same values as the vector.

This method does not modify the vector.

valWhich(*cond*)

Returns the value of the first element for which the callback function
*cond* returns a non-false value (i.e., any value other than nil or 0).
The method applies the callback to each element of the vector, starting
with the first, and calls the function for each element in turn until
*cond* returns a non-false value. Returns nil if the callback returns a
false value for every element. This function is almost the same as
indexWhich(*cond*), but returns the value of the first element for which
*cond* returns non-false rather than the index of the element. Returns
nil if no matching value is found.

## Reference Semantics

The most important distinction between lists and vectors, and the
primary reason to use vectors rather than lists in certain situations,
is that vectors use "reference" semantics, while lists use "value"
semantics.

The difference is that a list's value can never change, but an vector's
value can change.

When you do something that modifies a list, such as assigning a value to
an element of the list, the operation does not change the list. Instead,
it creates a new list that reflects the change, leaving the original
list unmodified. TADS automatically updates the variable that contained
the list being indexed so that it contains the newly-created list.

In contrast, when you assign a new value to an element of an vector, the
vector's value is changed. No new vector object is created.

This might seem like a very obscure difference, but it has two important
practical effects. The first is that operations that modify vectors are
much cheaper to execute, because they don't result in creating new
objects; this means that operations involving a large number of element
changes will run faster with vectors than with lists.

The second practical difference is that, whenever you change a vector,
the change is visible everywhere the vector is referenced. In contrast,
when you change a list, the change is visible only to the code that made
the change.

Consider this example:

    local a = [1, 2, 3];
    local b = a;

    a[2] = 100;
    tadsSay(b[2]);

What will this example display? At the beginning of the code, we set a
to a list, and then we set b to the value in a, so b refers to the same
list. So far we have only one object, and both a and b refer to this
single object. We next assign a new value, 100, to the second element of
a. As we've seen, this cannot change the list that a refers to, because
lists can never change; so, what we're doing is creating a new list,
copying each element from the original list to the new list, but
changing the second element to reflect the assignment. This new list is
then assigned to a, so a and b now refer to different lists. So, when we
display the second element of b, we see the value "2" displayed, because
b still refers to the original, unmodified list.

Now, consider the same example with an vector:

    local a = new Vector(10, [1, 2, 3]);
    local b = a;

    a[2] = 100;
    tadsSay(b[2]);

This code looks almost identical, but it displays a different result
than the list version. We start out by creating a new vector object and
assigning it to a, and then we assign the same value to b. Next, we
assign 100 to the second element of a. Unlike lists, vectors can be
changed, so this assignment simply replaces the value in the vector
object's second element. No new vector object is created, so a and b
still refer to the same object. So, when we display b\[2\] in this
example, we see the modified value.

Here's a more interesting example:

    f1()
    {
      local a = new Vector(3);

      getInfo(a);
      "Thanks, <<a[1]>>!  This information will allow us to send
      you specially targeted advertising based on your credit
      history! ";
    }

    getInfo(x)
    {
      "Please enter your name: "; x[1] = input();
      "Please enter your age: "; x[2] = toInteger(input());
      "Please enter your social security number: "; x[3] = input();
    }

This is something we couldn't have done with lists: assigning elements
of x in getInfo() wouldn't have affected the caller's copy of the list,
so the routine wouldn't be able to pass back information this way using
lists.

Note that, when you explicitly create a copy of a vector, the new copy
is not affected by any changes to the original:

    x = new Vector(10, [1, 2, 3, 4, 5]);
    y = new Vector(10, x);

    x[3] = 100;
    tadsSay(y[3]);

This example displays the value "3" (not "100"), because x and y refer
to separate objects. Changing a value in the vector to which x refers
has no effect on the vector to which y refers.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
Vector  
[*Prev:* TimeZone](timezone.htm)     [*Next:*
WeakRefLookupTable](wlookup.htm)    
