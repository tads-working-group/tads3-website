::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> TadsObject\
[[*Prev:* StringComparator](strcomp.htm){.nav}     [*Next:*
TemporaryFile](tempfile.htm){.nav}     ]{.navnp}
:::

::: main
# TadsObject

The objects and classes that you define in your program are of intrinsic
class TadsObject. Everything that has \"object\" as its superclass is
really a subclass of intrinsic class TadsObject.

For example:

::: code
    class Item: object;
    myObj: object;
:::

Both Item and myObj are of intrinsic class TadsObject.

## TadsObject methods

TadsObject is a subclass of the root intrinsic class, Object, so all of
the methods that Object defines are inherited by TadsObject instances as
well. In addition to the Object methods, TadsObject provides its own
methods, described below.

[createClone()]{.code}

::: fdef
Creates a new object that is an identical copy of this object. The new
object will have the same superclasses as the original, and the
identical set of properties defined in the original.

No constructor is called in creating the new object, since the object is
explicitly initialized by this method to have the exact property values
of the original.

The clone is a \"shallow\" copy of the original, which means that the
clone refers to all of the same objects as the original. For example, if
a property of the original points to a Vector, the corresponding
property of the clone points to the same Vector, not a copy of the
Vector.
:::

[createInstance(\...)]{.code}

::: fdef
Creates a new instance of the target object. This method\'s arguments
are passed directly to the constructor, if any, of the new object; this
method doesn\'t make any other use of the arguments. The method creates
the object, invokes the new object\'s constructor, then returns the new
object.

This method can be especially useful in static methods defined in base
classes that are further subclassed, because it essentially allows a
parameterized \"new\" operator. For example, suppose we had a base
class, Coin, which you subclass into several types: GoldCoin,
SilverCoin, CopperCoin. For each of these classes, you want to provide a
method that creates a new instance of that kind of coin. Using the
[new]{.code} operator, you\'d have to write a separate method in each
subclass:

::: code
    class Coin: object;
    class GoldCoin: Coin
      createCoin() { return new GoldCoin(); }
    ;
    class SilverCoin: Coin
      createCoin() { return new SilverCoin(); }
    ;
    class CopperCoin: Coin
      createCoin() { return new CopperCoin(); }
    ;
:::

This gets increasingly tedious as we add new subclasses. What we\'d
really like to do is something like this:

::: code
    class Coin: object
      createCoin() { return new self(); } // illegal!
    ;
:::

This would let all the subclasses inherit this one implementation, which
would create the appropriate kind of object depending on the subclass on
which the method was invoked. We can\'t write exactly this code, though,
because the [new]{.code} operator doesn\'t allow a variable like
[self]{.code} to be used as its argument.

So, it\'s [createInstance()]{.code} to the rescue. This method lets us
do exactly what we\'d like: create an instance of the current class,
writing the code only once in the base class. Using
[createInstance(),]{.code} we can rewrite the method to get the effect
we want:

::: code
    class Coin: object
      createCoin() { return createInstance(); }
    ;
:::
:::

[createInstanceOf(\...)]{.code}

::: fdef
Creates a new instance based on multiple superclasses. This is a static
(class-level) method, so you can call it directly on TadsObject. With no
arguments, this simply creates a basic TadsObject instance; this is
equivalent to the [createInstance()]{.code} method.

The arguments give the superclasses, in \"dominance\" order. The
superclasses appear in the argument list in the same order in which
they\'d appear in an object definition: the first argument corresponds
to the leftmost superclass in an ordinary object definition. Each
argument is either a class or a list. If an argument is a list, the
first element of the list must be a class, and the remainder of the
elements are the arguments to pass to that class\'s constructor. If an
argument is simply a class (not a list), then the constructor for this
superclass is not invoked at all.

For example, suppose we had the following class definitions:

::: code
    class A: object
      construct(a, b) { ... }
    ;

    class B: object
      construct(a, b, c) { ... }
    ;

    class C: object
      construct() { ... }
    ;

    class D: A, B, C
      construct(x, y)
      {
        inherited A(x, y);
        inherited C();

      }
    ;
:::

Now, suppose that we had never actually defined class D, but we want to
create an instance dynamically as though it class D had been defined. We
could obtain this effect like so:

::: code
    local d = TadsObject.createInstanceOf([A, x, y], B, [C]);
:::

This creates a new instance with superclasses A, B, and C, in that
dominance order. During construction of the new object, we will inherit
A\'s constructor, passing [(x,y)]{.code} as arguments, and we\'ll
inherit C\'s constructor with no arguments. Note that we pass a list
containing C alone; this indicates that we do want to call the
constructor, since the argument is passed as a list rather than as
simply the object C, but that we have no arguments to send to C\'s
constructor. Note also that we don\'t invoke B\'s constructor at all,
since B is specified without being wrapped in a list.

Note that if constructors are invoked at all, they can only be called in
the same order in which they appear in the superclass list.
:::

[createTransientInstance(\...)]{.code}

::: fdef
This works like [createInstance()]{.code}, except that the new instance
is transient.
:::

[createTransientInstanceOf(\...)]{.code}

::: fdef
This works like [createInstanceOf()]{.code}, except that the new
instance is transient.
:::

[getMethod(*prop*)]{.code}

::: fdef
Gets a function pointer to one of the object\'s methods. *prop* is a
property pointer value giving the property of the object to retrieve. If
this property contains a method, [getMethod()]{.code} returns a function
pointer to the method\'s code. If the property contains a self-printing
string, the return value is an ordinary string value with the text of
the printed string. If the property is any other type of data, or is
undefined, the result is [nil]{.code}.

Note that a double-quoted string that contains embedded
(\"interpolated\") expressions with [\<\< \>\>]{.code} is really a
function. This means that if you call [getMethod()]{.code} on a property
containing a string with embedded expressions, you\'ll get back a
function pointer result rather than a string expression.

When the returned value is a function, it can be called like an ordinary
function. You wouldn\'t normally do this, though, because the call would
have a [nil]{.code} value for [self]{.code}, which means that the method
would trigger a run-time error if it tried to access any properties or
other methods of [self]{.code}. Instead, the main use for the returned
function pointer would be to assign the function as a different method
of the same object, or as a method of another object, using
[setMethod()]{.code}.

Note that [getMethod()]{.code} can also return an anonymous function
object. Methods originally defined in the source code will always be
returned as regular function pointers (of type TypeFuncPtr). An
anonymous function will be returned only for a method that was
explicitly set to an anonymous functions via [setMethod()]{.code}. In
this case, the same anonymous function object that was passed to
[setMethod()]{.code} will be returned from [getMethod()]{.code}.

(Ordinary methods are also \"anonymous\" functions in that they\'re not
named. But these aren\'t what we normally call anonymous function
objects, which are the type of object created with the [function]{.code}
syntax.)
:::

[]{#setMethod}

[setMethod(*prop*, *func*)]{.code}

::: fdef
Assigns the function *func* as a method of the object, using the
property *prop*.

*prop* is the property pointer to assign. This specifies the property
that will be used for the newly assigned method. Any previous method or
data value for this property will be replaced with the new function.

*func* can be:

-   A regular (named) function pointer, which becomes a method with the
    same arguments as the function. The function itself isn\'t changed
    by this; you can also still call it directly as an ordinary
    function.
-   A [floating method](proccode.htm#floatingMethods) pointer, which
    becomes a method with the same arguments.
-   An anonymous function, which becomes a method with the same
    arguments as the anonymous function. The anonymous function itself
    isn\'t changed in any way by this; you can still call it directly,
    too.
-   An anonymous method, which becomes a method with the same arguments
    as the anonymous method.
-   A [DynamicFunc](dynfunc.htm), which becomes a method with the same
    arguments as the dynamically compiled code.
-   A single-quoted string value, which will be displayed on evaluating
    the property, as though it had been initially defined as a
    double-quoted string property of the object.
-   Any value retrieved by a call to [getMethod()]{.code}, on this
    object or any other object.

After calling this method, invoking *prop* on this object will result in
calling the function *func* as though it had always been a method of the
object. [self]{.code} will be set, and the method can use
[inherited]{.code} to inherit from this object\'s class structure.

It\'s important to note how the naming works. The new method is callable
under the name *prop* - **not** under the name of the function that was
used to create it. For example:

::: code
    method foo(x) { return x*x; }
    obj: object;

    main(args)
    {
      obj.setMethod(&square, foo);
      local x = obj.square(10);
    }
:::

The name of the new method is [square]{.code}, *not* [foo]{.code}.
[foo]{.code} is still just a floating method; the new, full-fledged
method is established under the property name, not the function name.

The method relationship created by [setMethod()]{.code} is
non-exclusive. You\'re free to use [setMethod()]{.code} to assign the
same function pointer (or other value) as a method of multiple objects
at once. The value doesn\'t lose its regular meaning, either: as we said
above, if you supply a function pointer to [setMethod()]{.code}, you can
still call the same function as an ordinary function, too.

Note that when you define an ordinary function, the compiler doesn\'t
let you refer to [self]{.code} or any other method context variables
(such as [targetprop]{.code} or [definingobj]{.code}) within the
function body, since these variables normally aren\'t valid in a
function. This also means that you can\'t define a function that uses
[inherited]{.code} or [delegated]{.code}. There are two ways of dealing
with this:

-   First, you can define a method of one object, and \"move\" it to a
    different object: use [getMethod()]{.code} to retrieve the method
    information from the original object, and pass the result to
    [setMethod()]{.code} to add the method to the other object.
    [self]{.code} and the other method context variables are dynamic, so
    they\'ll automatically reflect the new object context when you call
    the moved version of the method. (This doesn\'t really move the
    method; it really just copies it. You can still call it in the old
    object as well, where it will still reflect its original context.)
    This is a good approach when you need the same method functionality
    in an ordinary object anyway, since you can simply copy it as needed
    to new objects.
-   Second, you can use the [method]{.code} syntax to define a [floating
    method](proccode.htm#floatingMethods), which is really just an
    ordinary function that *does* have access to [self]{.code},
    [targetprop]{.code}, and the others, and that can use
    [inherited]{.code} and [delegated]{.code}. This is a good approach
    when the function\'s only purpose is to be plugged into objects via
    [setMethod()]{.code}, since it avoids creating a dummy template
    object just to define a method.

When you use an anonymous function with [setMethod()]{.code}, you should
keep in mind that [self]{.code} and the other method context variables
are shared with the scope where the function was defined. Consider this
example:

::: code
    obj1: object
       init()
       {
           obj2.setMethod(&a, { x: self.prop = x; });
       }
    ;
    obj2: object
       prop = nil
    ;

    main(args)
    {
        obj1.init();
        obj2.a(100);
    }
:::

Here we\'ve set up a new method for [obj2]{.code}, named [a]{.code}. We
then invoke the new method. The question is: what\'s the value of
[obj2.prop]{.code} when we\'re done? At first glance you might think it
should be 100, since the newly created method sets [self.prop]{.code} to
the argument value, and the new method is part of [obj2]{.code}, ergo we
must be setting [obj2.prop]{.code} to 100. But that\'s not what happens:
the value of [obj2.prop]{.code} is [nil]{.code} when we\'re done.

The reason is the little detail we mentioned about how an anonymous
function shares its method context with its lexically enclosing scope.
Because the anonymous function was created within the confines of
[obj1.init]{.code}, the [self]{.code} in effect at the moment of the
function\'s creation was [obj1]{.code}. And this is the [self]{.code}
that the function will use forever, no matter how many times it\'s
invoked. It\'s in the nature of an anonymous function: it shares
everything with its lexically enclosing scope, including [self]{.code}.

In this example, though, that\'s not the effect we\'re after. We\'d like
instead to create a method that assigns a value to the property
[prop]{.code} of whatever object we attach the method to. In other
words, we want to create a real live method, not a function that\'s
stuck to someone else\'s method context.

The way to do this is to replace the anonymous function with an
anonymous method. An anonymous method *isn\'t* stuck to the method
context that was in effect when it was created, but instead uses the
live context whenever it\'s called. This is an easy change to make: we
just need to use the [method]{.code} syntax to define the anonymous
method.

::: code
    obj2.setMethod(&a, method(x) { self.prop = x; });
:::

With this change, running the program will indeed set [obj2.prop]{.code}
to 100.
:::

[setSuperclassList(*lst*)]{.code}

::: fdef
Sets the object\'s superclasses to the values in *lst*, which must be a
list (or [list-like object](opoverload.htm#listlike)) containing
objects. The object\'s superclass list is replaced with the given
superclass list. The objects in *lst* must all be TadsObject objects,
with one exception: lst is allowed to be [\[TadsObject\]]{.code} (that
is, a single-element list containing the TadsObject class itself), in
which case the object becomes a root TadsObject object.
:::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> TadsObject\
[[*Prev:* StringComparator](strcomp.htm){.nav}     [*Next:*
TemporaryFile](tempfile.htm){.nav}     ]{.navnp}
:::
