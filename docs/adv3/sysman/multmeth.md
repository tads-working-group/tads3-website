::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Multi-Methods\
[[*Prev:* Operator Overloading](opoverload.htm){.nav}     [*Next:*
Dynamic Object Creation](dynobj.htm){.nav}     ]{.navnp}
:::

::: main
# Multi-Methods

The usual way of calling a method in TADS is to write an expression like
\"x.foo(3)\", where x is an object and foo is a method. This invokes the
definition of foo that applies to the specific object x - foo can have
separate definitions for several objects, and the system figures out
which one to call at run-time for the given object x.

Even if x is a variable whose value changes each time the expression is
evaluated, the system still calls the right version of foo, because the
determination is made on the fly at the moment the call is made. The
compiler doesn\'t know in advance which version of x will be called -
this decision isn\'t made until the program is actually running.

This ability to figure out which version of a method to call based on a
value that\'s not known until run-time is known as \"polymorphism,\" and
it\'s one of the cornerstones of object-oriented programming. In
traditional OOP, polymorphism applies to one value at a time - the
version of foo to be invoked depends only on the value of x, even if the
method foo() has several other argument values. This is reflected in the
very syntax of the method call in TADS, as in many other OO languages,
in that \"x\" occupies a special place in the expression - before the
dot - where there\'s only room for one value.

As OO programming has evolved, though, people have come to realize that
\"single dispatch\" isn\'t the last word on polymorphism. In many cases,
it\'s useful to be able to write methods that vary according to
particular *combinations* of object types. This is called \"multiple
dispatch\": a call to a method is dispatched to the appropriate
definition based on the run-time types of multiple values, not just the
one special target-object value.

It\'s easy to come up with examples of general OO programming problems
where multiple dispatch is useful. A common example is calculating the
intersection of two shape objects in a graphics program. Implementing
this method efficiently requires custom versions for different pairs of
shapes: rectangle-rectangle and rectangle-circle would need different
methods, for instance, as would line-circle and line-rectangle. In an IF
context, multiple dispatch situations come up all the time, thanks to
commands that operate on multiple objects. For instance, you might want
to write one PutIn method that applies to a Thing plus a Container, and
a separate method for Liquid plus Vessel. You might even want to take
into account the actor performing the command, making for a three-object
selector: a Knight attacking a Monster with a Sword might invoke one
attackWith() routine, while a Person attacking a Rodent with a Stick
might do something rather different.

### Multiple dispatch vs. \"Visitor\"

If you\'re an experienced OO programmer, you might protest at this point
that traditional, single-dispatch OO has ways of dealing with this sort
of problem, such as the \"visitor\" pattern. You might ask why you\'d
need multiple dispatch at a language level when perfectly good design
patterns can accomplish the same ends. The answer is that the visitor
pattern and its ilk tend to be cumbersome and labor-intensive to set up,
whereas native multiple dispatch often makes the same tasks almost
trivial. It really amounts to the same reason that OOP became popular in
the first place: you *could* achieve the same effect with a clever
combination of simpler language features, but native language support
makes the technique easier to apply, more concise to write, and less
prone to error.

### Multiple dispatch vs. overloading

If you\'ve programmed in a statically-typed OO language like C++ or
Java, you\'ve probably encountered something known as function
overloading. Superficially, this looks almost exactly like multiple
dispatch - it\'s a way of defining several versions of the same function
that are distinguished by the types of their parameters. When you call a
function that has several versions, the compiler figures out which
version to call by matching the actual argument types to the declared
parameter types, and picking the best fit.

Static overloading *looks* a lot like multiple dispatch, but it\'s
important to understand the big difference between the two. Static
overloading is just that - *static*. That means the decision about which
version of the function to call is made by the compiler, *not* by the
running program. In contrast, with multiple dispatch, the decision
happens dynamically at run-time.

Consider the following C++ code:

::: code
    #include <stdio.h>

    class A { };
    class B: public A { };

    void foo(A *a) { printf("This is foo(A*)\n"); }
    void foo(B *b) { printf("This is foo(B*)\n"); }

    void main()
    {
        A *a = new B();
        foo(a);
    }
:::

If you run this code, you\'ll find that the function invoked is
foo(A\*). At first glance, this might look wrong - the object we\'re
passing to foo() is of class B, not of class A, so shouldn\'t foo(B\*)
be invoked? But foo(A\*) actually is the right result. The reason is
that the compiler has to decide *at compile-time* which foo() to call,
and to do this it can only consider the *declared* type of the
parameter. In this case, \"a\" happens to contain an object of class B,
but \"a\" is *declared* as holding an object of class A. It\'s legal for
it to contain a B instead, since B is a subclass of A, but the compiler
can\'t assume anything beyond the declared type. So, the compiler has to
decide to call to foo(A\*), at which point it\'s set in stone - no
matter what \"a\" happens to contain at run-time, the decision about
which foo() to call has already been made.

That\'s how it would work in C++ or Java. In a multiple dispatch system,
in contrast, the system would wait until the program was running to make
the final decision. That way, the proper version of foo() would be
called based on the actual argument value.

## Multiple dispatch in TADS

As of version 3.0.17, TADS provides multiple dispatch directly in the
language. Multiple dispatch is handled via something called
\"multi-methods.\" A multi-method is similar in syntax to an ordinary,
stand-alone function (the kind that\'s defined separately from any
objects), but unlike an ordinary function, a multi-method has typed
parameters - \"typed\" in the sense of having specific datatypes
associated with the parameters. Also unlike a regular function, a
multi-method can have more than one definition for the same function
name. When you call the function, the system figures out which version
to invoke by matching the actual argument values to the definition with
the corresponding parameter types.

The new multi-method feature does not involve an T3 VM changes, so using
multi-methods in your program won\'t force users to install an updated
VM version. The multi-method system is implemented entirely in the
compiler and in the system library.

## Defining a multi-method

A multi-method definition looks similar to an ordinary function
definition. The difference is that one or more of the parameters include
type specifications. The type name is simply the name of a class, and
it\'s written just before the parameter\'s variable name. The formal
syntax is:

::: syntax
    funcName ( [ type1 ]  param1 [ , ... ]  ) [ multimethod ] 
    {
        methodCode
    }
:::

Each type specification (*type1* and so on) is the name of a class. You
can use intrinsic class names to match special types: String for
strings, List for list, and so on.

Each parameter name (*param1*, etc.) is simply a local variable name,
just like in a regular function.

Note that the type names are optional - if you omit the type name from a
parameter, it simply means that the parameter will accept *any* type of
value, including values like integers, true, nil, etc. You can freely
mix typed and untyped parameters, so you can have some parameters that
only accept specific types and others that accept any value.

The types are optional, but if you don\'t use *any* types in the
definition, the compiler assumes you\'re defining an ordinary function
rather than a multi-method. That\'s a problem if you really do want the
function to be a multi-method, because you can\'t define the same name
as both a multi-method and an ordinary function - a given name has to be
exclusively one or the other. In other words, this is illegal:

::: code
    foo(Thing x) { ... }
    foo(x) { ... }
:::

This is illegal because you\'ve defined foo() as both a multi-method
(the first line) and as an ordinary function (the second line).

This is where the [multimethod]{.code} qualifier shown in the syntax
diagram comes in. This qualifier tells the compiler that, whatever it
might infer from the presence or absence of parameter types, you intend
to define a multi-method rather than an ordinary function. To fix the
code above, then, we\'d change the second line to this:

::: code
    foo(x) multimethod { ... }
:::

Now the two foo\'s can happily coexist, since they\'re both
multi-methods.

Note that when at least one parameter has a type, the
[multimethod]{.code} qualifier isn\'t needed, since a function is
automatically a multi-method if it has any typed parameters. However,
the [multimethod]{.code} qualifier does no harm in these cases, so
you\'re free to include it if you prefer. Note also that
[multimethod]{.code}\'s opposite number doesn\'t exist - there\'s no
qualifier that says \"this is *not* a multi-method.\" This is because
there\'s no situation where it would be useful; when there are no typed
parameters, \"not a multi-method\" is the default assumption anyway; and
when types are present, it wouldn\'t be possible to treat the definition
as an ordinary function, since type specifiers aren\'t allowed there.

## An example definition

Here\'s an example of defining a multi-method:

::: code
    putIn(Thing obj, Container cont)
    {
       // ...
    }
:::

This creates a function called putIn() that takes two parameters: the
first is a Thing, and the second is a Container. As with an ordinary
function, the argument values when the putIn() is called are assigned to
local variables called \"obj\" and \"cont\", respectively.

The function defined above will *only* ever be called when the actual
argument values match the types specified in the parameter list. If you
call putIn() with some other types, the system will either find another
version of the function that matches the other types, or it will throw
an exception to indicate that there\'s no acceptable version of the
function that matches the invocation. This means that you can safely
assume that \"obj\" is always a Thing, and \"cont\" is always a
Container, when writing the code within this function.

Because a multi-method is identified by both its name and its typed
parameters, you can define any number of additional multi-methods with
the same name, as long as each new version can be distinguished from the
others by its parameter types. For example, we could define a second
multi-method called putIn() like so:

::: code
    putIn(Thing obj, Surface cont)
    {
       // ...
    }
:::

This version will be invoked when putIn() is called with a second
argument value that\'s a Surface instead of a Container.

## Calling a multi-method

Calling a multi-method is exactly like calling an ordinary function. You
simply write the function name followed by the list of parameters in
parentheses:

::: code
    putIn(blueBook, cardboardBox);
:::

When this line of code is executed, TADS evaluates the arguments,
determines their types, and finds the appropriate version of the
multi-method to call by matching the argument types against the possible
parameter types.

You can use function pointers to multi-methods the same way as with
ordinary functions:

::: code
    local x = putIn;
    x(blueBook, cardboardBox);
:::

As with any other call to a multi-method, the system waits until you
actually use the function pointer to call the function to determine
which version to invoke.

(For the technically inclined, here\'s what\'s going on internally: when
you use \"putIn\" without an argument list to get a pointer to the
multi-method, what you actually get is a pointer to a \"stub\" function
that represents the entire collection of multi-methods named putIn. When
you use the function pointer to call the function, you\'re calling that
stub function, which in turn does precisely the same work that would
occur if you called putIn directly with an argument list. The result is
that you reach the correct version of putIn based on the argument
values.)

It\'s also possible to get a pointer to a *particular version* of a
multi-method - that is, the specific function that would be invoked for
a given set of arguments. The library provides a function for this
purpose, getMultiMethodPointer():

::: code
    local y = getMultiMethodPointer(putIn, blueBook, cardboardBox);
    y(redBook, woodenCrate);
:::

The difference between this and the earlier example (\"x = putIn\") is
that getMultiMethodPointer() returns a pointer to the specific version
of the multi-method that matches the given arguments, whereas using just
the name of the multi-method returns a pointer to the overall
multi-method. When you call the function using the pointer returned from
getMultiMethodPointer(), the system does *not* look again at the
argument types to determine what to call - you\'ve already chosen a
particular version of the function, so the system simply calls that
particular version without re-examining the arguments. This can be
useful, but be careful - since you\'re bypassing the type-checking that
normally occurs when you invoke a multi-method, you could easily pass in
arguments with the wrong types, which could cause run-time errors (or,
perhaps worse, subtle logical errors) in your program.

## Multi-methods and inheritance

So far we\'ve talked about multi-methods almost as though they were
separate from object oriented programming. But OOP is central to TADS,
so perhaps it won\'t be too surprising that multi-methods work nicely
with the TADS object system. In fact, multi-methods really are just an
extension of the TADS OOP model from the traditional single-dispatch
model to multiple dispatch.

The easiest way to see how multi-methods work with OOP is to define a
multi-method that takes only one parameter, and then define some
variations that take class types that are related by inheritance:

::: code
    lookAt(Thing obj) {  }
    lookAt(Container obj) {  }
    lookAt(SingleContainer obj) { }
:::

In the Adv3 library, Container is a subclass of Thing, and
SingleContainer is a subclass of Container.

It\'s probably fairly obvious what happens when we call lookAt() with an
argument of type Thing, Container, SingleContainer: we invoke the
version that matches the class type of the argument.

But what happens when we call this function with, say, a
StretchyContainer? There\'s no definition of lookAt for this class.
However, StretchyContainer is a subclass of Container, and in OOP dogma,
an object that\'s a subclass of Container *is* a Container as well. So
what happens is that we call the Container version of the function.

Now, you might wonder why this doesn\'t create confusion about
SingleContainer. SingleContainer is a Container subclass, just like
StretchyContainer - so doesn\'t that mean there are *two* versions of
lookAt() that match SingleContainer now? In fact, aren\'t there *three*
matching versions, given that Container is also a Thing, and thus so is
SingleContainer? The answer is that yes, SingleContainer *can* match all
three versions of lookAt, but no, this doesn\'t create any confusion.
The reason there\'s no confusion is that the object inheritance model
kicks in to resolve the situation. Given a choice of multi-methods that
match an argument\'s class, we\'ll always pick the *overriding* subclass
that matches - overriding in the same way that a method on a subclass
would override the same method on a superclass.

There\'s an important implication of using object inheritance to resolve
multi-methods: multi-methods with a single typed parameter are
equivalent to regular methods defined on the corresponding objects. In
other words, we could have written our three lookAt() functions above as
ordinary object methods, thus:

::: code
    Thing: object
       newLookAt() { }
    ;
    Container: Thing
       newLookAt() { }
    ;
    SingleContainer: Container
       newLookAt() { }
    ;
:::

(We\'re obviously simplifying this a lot from what\'s in the real Adv3
library - we just care about the basic structure here.) So now, if we
write [x.newLookAt()]{.code}, we get the same effect as calling
[lookAt(x)]{.code} - we dispatch to the version defined for the closest
match to [x]{.code}\'s class in the inheritance structure.

So, to summarize, a multi-method with one typed parameter is basically
just an alternative syntax for writing a regular method.

This equivalency is helpful because it makes it easier to understand
what happens when you have more than one typed parameter. The
multi-method system applies the same logic to each typed parameter,
choosing the one that\'s the best fit to the object according to its
class inheritance. It also makes it easier to understand what happens in
a multiple-inheritance situation: when a class has multiple
superclasses, the multi-method binding uses the exact same rules that
are used to determine the method overriding order.

(For the technically inclined, the implementation actually uses the
regular class inheritance system directly. During initialization, the
library adds a special property to each class mentioned in a given slot
in a given multi-method parameter list. This property contains the
binding information for that class in that slot of that function. When
calling a multi-method, the library evaluates the appropriate special
property on each argument in turn and uses the result to determine which
function to call. The property lookup is no different from any other
property lookup, so it obeys the standard inheritance and overriding
rules. This design guarantees the equivalency between the overriding
order for multi-methods and that for ordinary methods, since they
actually use the same underlying mechanism.)

## Invoking a base version

We\'ve seen that one multi-method can \"override\" another, just like a
regular method in a subclass can override its base class version.

In regular methods, it\'s common for an overriding method in a subclass
to add just a little bit of specialization to its base class. It does
everything the base class does, but adds a little something extra. This
happens so often that TADS has special syntax to help out, by letting
the subclass method invoke its base class version as a subroutine,
rather than repeating its whole contents - namely, the
[inherited]{.code} operator.

::: code
    class Thing: object
       examine()
       {
           "It looks like an ordinary <<name>> to me. ";
       }
       name = 'something'
    ;

    class Container: object
       examine()
       {
           inherited();    // CALL THE VERSION WE'RE OVERRIDING AS A SUBROUTINE
           listContents();
       }
       listContents()
       {
           // show contents listing here...
       }
    ;
:::

Multi-methods can override one another, so the analogous situation can
arise, where an overriding multi-method wants to invoke a multi-method
that it overrides, as a subroutine. TADS offers support for this, using
syntax that\'s very similar to the [inherited]{.code} syntax for
ordinary methods.

When used in a multi-method, the [inherited]{.code} operator calls the
next more general form of the current function. That is, the version of
the multi-method that\'s effectively overridden by the current version.

The [inherited]{.code} operator chooses the function to call by asking
this question: which function would have been called if the current
function (the one containing the [inherited]{.code} call) had never been
defined? The system looks at the argument list specified in the
[inherited]{.code} operator to make this determination; it finds the
next function after the current function (\"after\" in terms of class
inheritance order) that matches the types in the argument list.

There\'s also an extended [inherited]{.code} syntax that lets you call a
*specific* inherited version of the function. You do this by adding a
type list in angle brackets between [inherited]{.code} and the argument
list:

::: syntax
    inherited < type1 [ , ... ] > ( argument1 [ , ... ]  )
:::

Each type specifier (*type1* and so on) is the name of a class or
object, just like in a multi-method definition. You can also use the
special symbol [\*]{.code} (asterisk) for a slot that has no type
specifier in the original definition, and you can use [\...]{.code} at
the end of the list to indicate that you\'re calling a version with
variable arguments.

For example:

::: code
    lookAt(SingleContainer obj)
    {
       return inherited<Container>(obj);
    }
:::

This calls the version of the function defined as [lookAt(Container
x)]{.code}, regardless of what other versions might also exist.

As with regular method inheritance, the [inherited]{.code} operator
behaves like an ordinary function call: it evaluates the arguments,
invokes the inherited multi-method, and yields as its value the return
value of the invoked function. You can use the multi-method version of
[inherited]{.code} as part of a larger expression, just as you can with
the regular [inherited]{.code}.

The compiler resolves [inherited\<\>]{.code} calls statically. Since you
specify the exact type list for the function to be invoked, the compiler
knows which version of the function to call. This means that this
version has no run-time overhead; it\'s just like an ordinary function
call in terms of its run-time performance.

The multi-method version of [inherited]{.code} *without* a type list
determines which function to call dynamically, at run time, which makes
it a little slower than [inherited\<\>]{.code} with a type list.
(Internally, this is implemented by calling a library function,
\_multiMethodCallInherited(). We recommend using [inherited]{.code}
rather than calling this function directly, since the function could
conceivably change in future releases.)

### Dynamic vs. static inheritance

As described above, when you use the [inherited]{.code} operator without
an explicit type list (in angle brackets), the system automatically
chooses which inherited function to call. The mechanism that we
described for making the selection is actually one of two modes that you
can select.

The default mode, which we described above, is the \"dynamic\" mode. In
dynamic mode, the system chooses which function to call by looking at
the **actual argument values** specified in the [inherited]{.code} call.
The system finds the matching function using the same process that it
used to resolve the original call to the multi-method, except this time
it pretends that the current (calling) function was never defined, so
that it can find the next matching function in inheritance order.

The dynamic mode is so named because it chooses the target function at
run-time, according to the actual argument values. This means that a
particular [inherited]{.code} call could end up calling different
functions for different argument values. The selection can\'t be made
until the [inherited]{.code} operator is actually executed, since we
can\'t know the actual argument values until that moment.

The other inheritance mode is the \"static\" mode. In static mode, the
system chooses which function to call by looking only at the **formal
parameters** to the current function. The formal parameters are the
parameters and types specified in the function\'s definition. In static
mode, the system finds the function to call for [inherited]{.code} by
looking for the next matching function (ignoring the current function)
for the formal parameter list to the current function.

Because the static mode chooses the target function based entirely on
the definition of the current function, the target function never
changes at run-time - it doesn\'t depend on anything that could vary
during execution. This means that the target function can be chosen at
compile-time (more specifically, at pre-init time).

**Which mode should you use?** The basic trade-off is that the dynamic
mode is more costly in terms of run-time performance, but it\'s arguably
more intuitive in its behavior. The dynamic mode has to determine which
function to call on the fly, whereas the static mode can figure and
cache the target function during pre-init; so the dynamic mode requires
more work (and thus more time) on every [inherited]{.code} call. The
benefit of the dynamic mode is that it\'s more consistent with the
regular [inherited]{.code} operator for object methods: the regular
[inherited]{.code} uses the actual [self]{.code} value to make its
determination, and the dynamic multi-method [inherited]{.code} uses the
actual argument values to make its selection. Most people will therefore
find the dynamic mode more intuitive, which is why we made it the
default.

Apart from the performance difference, the static mode has one other
potential benefit: it\'s more predictable. In static mode, a given
[inherited]{.code} call can only go to one target function, which you
can determine by inspecting the code - there\'s no need to take into
account the actual argument values because the selection depends only on
the definition of the calling function. For some applications, this
predictability might be more important than consistency with the regular
[inherited]{.code} behavior.

**How to select static mode:** The mode selection is controlled by a
#define symbol, MULTMETH_STATIC_INHERITED. If this symbol is defined
when the library module multmeth.t is compiled, the static mode is
selected; otherwise the dynamic mode is used. The symbol is **not**
defined by default, so the dynamic method is the default selection. To
select static mode, add -D MULTMETH_STATIC_INHERITED to your compiler
command line. (If you\'re using Workbench for Windows, simply add
MULTMETH_STATIC_INHERITED to your #define list in the Project & Build
Settings dialog, on the Compiler \| Defines page.)

**Historical note:** when the [inherited]{.code} operator for
multi-methods debuted, in version 3.0.18, it used the static mode. This
was quickly changed, though: the dynamic mode was introduced a short
time later, in the 3.0.18.1 patch release, and was made the default
because of its better consistency with the conventional
[inherited]{.code} operator\'s behavior.

## Limitations

There are a few limitations and caveats to be aware of when using the
multi-method facility.

**Performance:** Multi-methods are slower than regular method calls.
Part of this is inherent in the greater complexity of the task - other
things being equal, calling a multi-method with three typed parameters
obviously requires three times the work of a regular method call, which
only has to look at the inheritance structure of a single object. But
other things aren\'t entirely equal; calling a multi-method requires
running a small amount of library code, whereas calling a regular method
is a native operation handled entirely by the VM.

This doesn\'t mean that the mere mention of multi-methods will slow your
program to a crawl; it just means that you should be aware of the extra
overhead involved in calling them. For example, avoid calling a
multi-method in a loop that will be repeated many times; try instead to
structure the code so that the loop is inside the multi-method, so that
you only have to call it once.

**Asymmetrical parameters:** If you define a multi-method of the form
[foo(A a, B b)]{.code}, calls like [foo(B, A)]{.code} won\'t match,
because the order of the arguments matters in finding a type match. For
problems where you want to match the parameters in any order, you\'ll
have to explicitly define variations for the different possible orders,
and have them call the main version.

**No \"self\":** Since multi-methods are syntactically like regular
functions, and aren\'t associated with any object, there\'s no \"self\"
object available. Instead, you have the parameter variables that serve
the same purpose. Since there\'s no \"self\", though, there\'s no
implicit target object for property evaluations and method calls -
you\'ll have to refer to the parameter objects explicitly (with the
parameter variable names) on each use.

**Ambiguity:** It\'s possible to create a set of multi-methods that\'s
ambiguous, without receiving any warnings from the compiler or library.
If you define two or more methods with the same name and exact same list
of parameters, the library will catch this conflict during
pre-initialization and flag an error. However, there are other cases
where two methods have different parameter lists, but are nonetheless
ambiguous, where you won\'t receive any warnings. For example, suppose
that we have a class A, and a subclass of A called B, and we define

::: code
    foo(A a, B b) { }
    foo(B b, A a) { }
:::

Now, if we call this with [foo(B, B)]{.code}, note that either version
is an equally good match - the first version is a better match to the
second argument than the second version is, but the second is a better
match to the first argument. The strict theoretical view would be that
the compiler should catch this and flag it as an error; the ambiguity is
at best a possible point of confusion, and at worst a sign that the
programmer made an error in structuring the code.

However, the TADS implementation is not strict about this type of
ambiguity. Instead, TADS has a rule to resolve the ambiguity: arguments
are resolved individually in left-to-right order, and the first, best
resolution in left-to-right order wins. In this example, this means that
[foo(B, B)]{.code} resolves to the second definition: we first try to
find the best resolution to first argument in isolation, which gives us
the second definition, then we look at all [foo(B, \...)]{.code} options
and find that the second option is again the best.

**No pointer type differentiation:** There\'s no way to distinguish a
pointer to a multi-method from a pointer to an ordinary function. This
is because multi-methods are implemented using ordinary functions; a
pointer to a multi-method is simply a pointer to the ordinary function
that implements it. It\'s hard to think of an example where you\'d
actually need to distinguish the two, but if such a case did ever arise,
there\'s no straightforward solution. (One possibility would be to use
the multi-method registry table that the library builds during
initialization - although this would require accessing internal library
data structures, and there\'s no guarantee that those structures won\'t
change in future updates.)
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Multi-Methods\
[[*Prev:* Operator Overloading](opoverload.htm){.nav}     [*Next:*
Dynamic Object Creation](dynobj.htm){.nav}     ]{.navnp}
:::
