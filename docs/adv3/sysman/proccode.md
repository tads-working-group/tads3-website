::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Procedural Code\
[[*Prev:* Expressions and Operators](expr.htm){.nav}     [*Next:*
Optional Parameters](optparams.htm){.nav}     ]{.navnp}
:::

::: main
# Procedural Code

TADS 3 lets you do a lot \"declaratively,\" meaning that you just define
objects, their attributes, and their relationships to one another, and
the system and library take care of the details of running the game.
That\'s great as far as it goes, but no one has ever developed a system
that can do *everything* declaratively (though some have tried). For the
things you can\'t do declaratively, TADS 3 provides a powerful
\"procedural\" language, which lets you write step-by-step instructions
for the computer to follow.

## Quick index

-   [Functions and methods](#functionsAndMethods)\
    -   [Defining a function](#funcdef)
    -   [Optional arguments](#optArgs)
    -   [Named arguments](#namedArgs)
    -   [Replacing or modifying a function](#funcModRep)
    -   [Defining a method](#methdef)
    -   [Short-hand method definitions](#shortMeth)
    -   [Floating methods](#floatingMethods)
    -   [Varying argument lists](#varargs)
    -   [Varying-argument calls](#varargsCall)
-   [External declarations](#externDecl)
-   [Property name declarations](#propdecl)
-   [Procedural statements](#statement)
    -   [Code blocks](#blocks)
    -   [Statement labels](#labels)
    -   [Empty statements](#emptystm)
    -   [Local variable declarations](#local)
    -   [Expression statements](#exprstm)
    -   [Double-quoted string statement](#dqstm)
    -   [return](#return)
    -   [if](#if)
    -   [for](#for)
        -   [C-style [for]{.code} loops](#cfor)
        -   [for..in](#forIn)
        -   [for..in range](#forInRange)
        -   [Combining the [for]{.code} syntax types](#combinedFor)
    -   [foreach](#foreach)
    -   [while](#while)
    -   [do\...while](#dowhile)
    -   [switch](#switch)
        -   [[break]{.code} must be explicit](#caseBreaks)
        -   [[switch]{.code} indentation styles](#indentStyle)
    -   [goto](#goto)
    -   [break](#break)
    -   [continue](#continue)
    -   [throw](#throw)
    -   [try](#try)
-   [Notes for TADS 2 users](#tads2)

## [Functions and methods]{#functionsAndMethods}

There are two places where procedural code can appear. The first is in
\"functions,\" and the second is in \"methods.\"

A function is a body of procedural instructions that\'s all grouped up
and given a name. Functions are so named because they resemble in form
what mathematicians call functions: a function takes a set of input
values, which we call parameters, and produces an output value as its
result. For example, in mathematics, the \"square root\" function takes
a number as its argument, and yields the square root of the number as
its result. Now, in mathematics, there are other requirements that must
be met before you can truly call something a function, but for our
purposes a function is this just basic \"black box\" that takes a set of
inputs and produces a result value.

A method is almost the same as a function, but has the additional
quality that it\'s associated with a particular object or class. This
grouping of procedural code as part of an object is a defining feature
of Object-Oriented Programming. It\'s proved to be a very useful
organizational tool, because it encourages programmers to think about
how a problem breaks down into data structures, and then provides a way
to group each data structure with the parts of the code that operate on
it.

### [Defining a function]{#funcdef}

A function definition has this form:

::: syntax
    functionName ( [ paramName [ , paramName ... ]  ]  )
    {
       functionBody
    }
:::

Note that the parentheses for the parameter list are always required. If
you want to define a function that doesn\'t take any parameters, just
use empty parentheses after the function name.

The parameter names act like local variables defined just inside the
function body\'s open-brace. This means that you can\'t define a local
variable with the same name in the function\'s outermost code block.
(It\'s legal to reuse a parameter\'s name for a local within a nested
block, though, for the same reason you can define a new local in a
nested block with the same name as a local in an outer block.)

The function body consists of a series of procedural statements. When
the function is invoked, the VM starts at the first (topmost) procedural
statement in the function body, and proceeds through them sequentially
until the function returns to its caller via an explicit [return]{.code}
statement, throws an error, or \"falls off the end\" (that is, the
sequential execution point reaches the function body\'s closing brace).
Falling off the end is equivalent to returning [nil]{.code}, so it\'s as
though there were a [return nil;]{.code} statement just before the
function body\'s closing brace.

A function definition can only appear in \"top-level\" code - that is,
outside of any object, class, or function definition. If you use this
syntax within an object or class definition, the compiler will think you
want to define a method.

Function names are global. A symbol that\'s used as the name of a
function cannot be used to name anything else with global scope (such as
properties, objects, classes, enums).

To call a function, you write the function name followed by its
arguments, enclosed in parentheses. This syntax constitutes a
*function-call expression*, and you can use it anywhere an expression
can go, including within a larger expression.

For example, here\'s a complete program that defines two functions:
[main()]{.code}, which is the main entrypoint function that every
program must provide, and [cube()]{.code}, which raises a given number
to the third power and returns the result. The [main()]{.code} function
uses [cube()]{.code} to calculate a few cubed values, displays them, and
exits.

::: code
    #include "tads.h"

    main(args)
    {
      local c1 = cube(1), c2 = cube(2), c3 = cube(3);
      local cc3 = cube(c3);

      "1 cubed = <<c1>>, 2 cubed = <<c2>>, 3 cubed = <<c3>>\n";
      "3 cubed cubed <<cc3>>\n";
    }

    cube(n)
    {
      return n * n * n;
    }
:::

### [Optional arguments]{#optArgs}

In some cases, it\'s convenient to be able to declare a function or
method parameter as optional. This means that a caller can provide an
argument value for the parameter, but doesn\'t have to: a caller can
simply omit the argument entirely if it wants to use the default value
for the parameter.

The syntax for optional parameters is simple. Just place a
\"[?]{.code}\" after the name of a parameter:

::: code
    stringToInt(str, radix?)
    {
      // ...
    }
:::

This lets callers call the function with or without the \"radix\"
parameter:

::: code
    x = stringToInt('12345');
    y = stringToInt('3F7A', 16);
:::

When only one argument is supplied, it\'s assigned to \"str\", because
that parameter is required, and the optional \"radix\" parameter is set
to the default value [nil]{.code}. When two arguments are supplied, the
first is assigned to \"str\" and the second to \"radix\".

For this particular example, it would be even better to be able to
define a specific default value for the \"radix\" argument. Fortunately,
there\'s syntax for this: rather than using the \"[?]{.code}\" suffix,
instead write \"[=]{.code} *expression*\", where *expression* gives the
default value to be applied:

::: code
    stringToInt(str, radix = 10)
    {
      // ...
    }
:::

This says that the \"radix\" parameter should be set to 10 whenever a
caller doesn\'t supply a second argument value. When the caller *does*
provide two arguments, the caller\'s value overrides the default value.

For more information, including a couple of subtleties that are worth
knowing about, see the [optional parameters section](optparams.htm).

### [Named arguments]{#namedArgs}

The usual way of passing arguments, as described above, is
**positional**: the first value listed in the caller\'s argument list is
assigned to the first variable name in the callee\'s parameter list, the
caller\'s second value goes to the callee\'s second parameter name, and
so on.

There\'s another way, which we call **named arguments**. Instead of
assigning values to parameter names by position, the caller actually
specifies the name to use for each value. The values are then assigned
to variables with the same names in the callee, regardless of the order
of the values.

The caller and callee **both** have to agree on this protocol. When
defining a function, you specify that it takes named argument values by
putting a colon after each parameter name:

::: code
    diff(a:, b:)
    {
       return a - b;
    }
:::

The caller invokes this function with similar syntax: for each named
parameter, we must write the name, a colon, and then the value to use
for that parameter:

::: code
    local x = diff(a: 5, b: 3);
:::

Because the parameters are named, the caller can list them in a
different order from the callee. So we can rewrite the call above as
follows, and we\'ll get exactly the same result:

::: code
    local x = diff(b: 3, a: 5);
:::

You can freely mix positional and named parameters in the same function
definition. Parameters with the colon suffix will be named, and those
without will be positional. The caller must specify the positional
parameters in the same order as in the function definition, but the
named parameters can be mixed into the list in any order.

For full details on named parameters and why (and when) you\'d want to
use them, see the [named arguments chapter](namedargs.htm).

### [Replacing or modifying a function]{#funcModRep}

When using a library, it\'s sometimes useful to be able to replace a
function that the library provides with your own definition. The
[replace]{.code} keyword lets you do this. To use this feature, just
write [replace]{.code} in front of your function definition:

::: code
    replace someFunc(a, b)
    {
       // new code for the function...
    }
:::

[replace]{.code} completely discards the original library definition of
the function, and replaces it with your new definition; it\'s as though
the library version were never defined.

Sometimes you want to augment a library function rather than replace it
entirely. For example, you might want to add some special-case handling
for one or two particular parameter values, but fall back on the
original library definition for everything else. In these cases, you can
\"modify\" a function. This replaces the original function with your new
version, but it also keeps the original function around; the old
function loses the right to use the name, but its code is still present.
Whenever any code calls the function by name, your new version will be
invoked.

To reach the original version of the function, you use a special
keyword, [replaced]{.code}, within your new version of the function.
This is the only place where [replaced]{.code} works - you can only
reach the old function from within your new version. [replaced]{.code}
looks syntactically like a function call: you write, for example,
[replaced(7, \'a\')]{.code} to invoke the original function.

Here\'s an example:

::: code
    getName(val)
    {
      switch(dataType(val))
      {
      case TypeObject:
        return val.name;

      default:
        return 'unknown';
      }
    }

    modify getName(val)
    {
      if (dataType(val) == TypeSString)
        return '\'' + val + '\'';
      else
        return replaced(val);
    }
:::

Note how the modified function refers back to the original version: we
add handling for string values, which the original definition didn\'t
provide, but simply invoke the original version of the function for any
other type. The call to [replaced(val)]{.code} invokes the previous
definition of the function, which we\'re replacing.

Once a function is redefined using modify, it\'s no longer possible to
invoke the old definition of the function directly by name. The only way
to reach the old definition is via the [replaced]{.code} keyword, and
that can only be used within the new definition of the function.
However, note that you can obtain a pointer to the old function, and
then invoke the old function through that pointer outside the bounds of
the redefinition. To get the pointer, use the [replaced]{.code} keyword
without an argument list.

### [Defining a method]{#methdef}

A method definition looks just like a function definition syntactically.
The only difference is the placement within the source code. Whereas a
function is declared at the top level of the program, outside of all
objects, a method is declared within an object. For example:

::: code
    class MyClass: object
      getOwner()
      {
        // code goes here...
      }
    ;
:::

In most respects, a method acts very much like a function. The
difference is that a method is associated with the class or object in
which it\'s defined. The method can only be invoked through the defining
object or class, or it can be reached by \"inheritance\" - that is,
through a descendant in the class hierarchy (that is, a subclass of this
object or class, a subclass of a subclass, etc., or an instance of the
class). To call a method, then, you have to name not only the method
itself but also the object it\'s associated with. You do that with the
\"dot\" operator ([.]{.code}), like this:

::: code
    local x = MyClass.getOwner();
:::

Within the method, you can use the [self]{.code} pseudo-variable to
determine which object was used to invoke the method. Now, it might seem
that this information is redundant, since the method is by its very
nature already associated with a particular object or class. But as we
just mentioned, you can reach the method through the defining
object/class *or* through a subclass or instance of the defining object.
For example, consider this code:

::: code
    local x = new MyClass();
    local y = x.getOwner();
:::

This creates an instance of the class, then calls the method on the
instance object, not on the class itself. If you looked at [self]{.code}
within the method in this case, it would contain the instance object,
not MyClass itself.

One of the key principles behind object-oriented programming is that
code related to an object should be grouped with the object, by defining
the code using methods. So one thing you tend to see a lot of in
well-designed OO code is one method of an object calling another method
of the same object. In other words, you tend to see a lot of
[self.xxx()]{.code} calls within method code. This is so common that
TADS 3 has a convenient short-hand notation for just this case: when
calling a method or property of [self]{.code} within a method, you can
omit the [self.]{.code} prefix entirely, and just write the method call
as though it were a function call. For example:

::: code
    class MyClass
      isOwned()
      {
        // check some conditions, and return true or nil...
      }
      getOwner()
      {
        if (isOwned())
          // do something...
      }
    ;
:::

In this example, the call to [isOwned()]{.code} within
[getOwner()]{.code} is *not* a function call, even though it looks like
one at first glance. Rather, it\'s a method call, and behaves exactly as
though we\'d written [self.isOwned()]{.code}.

### [Short-hand method definitions]{#shortMeth}

In addition to the standard function-like syntax for defining a method,
there are a couple of short-hand formats that are more convenient for
simple methods.

First, if a method take no parameters, you can omit the parameter list.
This is especially handy for one-liner methods, where the whole body of
the method fits on one line:

::: code
    class MyClass
      getOwner { // etc }
    ;
:::

Second, if a method takes no parameters, and the only thing it does is
evaluate an expression and return the result, you can write the method
almost as though it were a property definition, like this:

::: code
    class MyClass
      getOwner = (myOwner != nil ? myOwner.actualOwner(self) : nil)
:::

That has exactly the same meaning as if [getOwner()]{.code} had been
defined like this:

::: code
      getOwner()
      {
        return myOwner != nil ? myOwner.actualOwner(self) : nil;
      }
:::

These short-hand formats are syntactic variations only - they don\'t
make any difference in the behavior, size, or speed of the generated
code. The short-hand syntax might make your *source* code look smaller,
but it won\'t make your *compiled* code any smaller or any faster,
because the compiler generates the same byte-code in any case. These
syntax variations are for your coding convenience; they\'re not
performance optimizations.

### [Floating methods]{#floatingMethods}

Another way of defining a method is to define it *without* an associated
object definition. This is called a \"floating\" method, since it\'s not
attached to any object definition.

The syntax for a floating method is almost the same as for a function.
The only difference is that you substitute the keyword [method]{.code}
for [function]{.code}:

::: code
    method getTopLoc()
    {
       return location == nil ? self : location;
    }
:::

Even though this looks like a function, you can use [self]{.code}, and
access properties of [self]{.code} (such as [location]{.code}, in this
example). You can also access all of the other method context
pseudo-variables ([definingobj]{.code}, [targetobj]{.code}, and
[targetprop]{.code}), and you can use [inherited]{.code} and
[delegated]{.code}. None of these things are allowed in an ordinary
function, since there\'s no method context in an ordinary function.

A floating method actually *is* a function. If you look at
[dataType(getTopLoc)]{.code}, you\'ll see that it\'s
[TypeFuncPtr]{.code}. You *can* call it like a regular function, without
an object:

::: code
    local t = getTopLoc();
:::

However, if the method accesses [self]{.code} or other method context
variables, calling it this way will cause a run-time error. That\'s what
would happen in our example, since it references a property of
[self]{.code}. The problem is that a function call doesn\'t have a
method context, so references to method context variables won\'t work
the way they do when a method is running.

So if it\'s not really callable as a function, and it\'s not callable as
a method because it\'s not associated with any object, what exactly is
it good for? The answer, of course, is adoption.

Floating methods are intended to be associated with objects
*eventually*, even though they\'re not initially. Their purpose is to
let you define a method that\'s not *initially* attached to any object,
but only so that you can attach it dynamically, at run-time, as an
actual method of one or more objects. You do this using
[TadsObject.setMethod()]{.code}, which you can find more about
[here](tadsobj.htm#setMethod).

### [Varying argument lists]{#varargs}

A function or method can be defined as taking a varying number of
parameters. That is, rather than specifying an exact number of arguments
that the caller must supply, you can define the function or method so
that it lets the *caller* decide how many arguments to supply; the
function or method determines how many were actually passed at run-time.
(This is sometimes called a \"varargs\" function, for \"varying
arguments.\") To define this type of function or method, you use an
ellipsis, [\...]{.code}, in place of the last parameter name. For
example:

::: code
    printf(fmt, ...) { }
    {
      // code goes here...
    }
:::

When you define a function/method that takes varying parameters, callers
must supply *at least* the named parameters, and may then supply any
number (including zero) of additional arguments. The first argument
value (starting at the left) that the caller supplies is assigned to the
first named parameter in the function\'s or methods\' parameter list,
the second argument value is assigned to the second named parameter, and
so on. You can retrieve the unnamed extra parameters using the
[getArg()]{.code} intrinsic function, and you can determine the total
number of arguments using the [argcount]{.code} pseudo-variable.
[getArg(n)]{.code} returns the *n*th argument value, where *n* ranges
from 1 to [argcount]{.code}.

It\'s equally valid to use an ellipsis as the *entire* parameter list,
if you want to accept zero or more arguments:

::: code
    printStuff(...)
    {
      // code goes here...
    }
:::

Since there are no named arguments, the caller doesn\'t have to supply
any arguments at all, and you must access all of the arguments via
[getArg()]{.code}.

You can alternatively give the varying part of the parameter list a
name, indicating to the compiler that you want the extra arguments to be
bundled up into a list and made accessible as a local variable. To do
this, replace the ellispis ([\...]{.code}) with a parameter name, but
enclose the parameter name in square brackets:

::: code
    printf(fmt, [lst])
    {
       foreach (local x in lst)
         // do something...
    }
:::

This is exactly like the earlier [printf(fmt, \...)]{.code} declaration,
but it creates a list from the extra parameters and stores it in the
local variable [lst]{.code}.

The \"varying list\" syntax is essentially equivalent functionally to
the ellipsis syntax, but many people find it cleaner-looking and easier
to use, since it lets you operate on the varying arguments using the
language\'s standard list features. However, note that it\'s slightly
less efficient, because the VM has to go to a little extra trouble to
create the list for you. For most functions and methods, the cleaner and
easier coding is well worth the slight performance cost; but for a
performance-critical function (one that\'s called very frequently, for
example), you might get better execution speed with the ellipsis style.

### [Varying-argument calls]{#varargsCall}

In addition to being able to *receive* varying arguments as a list, you
can *send* a list value to a function or method, as though the list were
a series of individual argument values. To do this, place an ellipsis
after the list argument value in the function or method call\'s argument
list:

::: code
    local lst = [1, 2, 3];
    formatStr('x[%d, %d] = %d', lst...);
:::

Rather than passing two arguments to [formatStr()]{.code} (i.e., a
string and a four-element list), this passes four arguments (a string,
the integer 1, the integer 2, and the integer 3), as though all four had
been passed as separate arguments - in other words, the call is
identical to this:

::: code
    formatStr('x[%d, %d] = %d', 1, 2, 3);
:::

This notation allows you to call a function that takes a variable
argument list, using a list to provide the varying argument values. This
makes it possible to layer calls to functions and methods with variable
argument lists, since an intermediate function can itself take a
variable argument list and later pass the same arguments to another
variable argument function.

## [External declarations]{#externDecl}

When you build your program, the compiler scans all of the source files
in your project for symbol names before it does anything else. This
means that you can define a function or an object in one source file,
and freely refer to it from another source file; and similarly, you can
freely refer to functions and objects that are not defined until later
in the same source file. The compiler\'s pre-scan of the entire source
ensures that it knows how symbols are used throughout the program. This
eliminates most of the \"external\" and \"forward\" declaration overhead
that many other programming languages force you to use.

In a few rare cases, though, you might actually need to explicitly
define external symbols. This happens only when you\'re compiling part
of a program in isolation, and won\'t combine the compiled object files
with the rest of the program until later. The most likely situation
where this would happen is in creating a library, where you want to
distribute the library in compiled form rather than as source files.

To define a function or object as external, you use the [extern]{.code}
statement. This statement can be used to define functions, objects, and
classes. The syntax is:

::: syntax
    extern function functionName ( [ param [ , param ... ]  ]  ) ;
    extern object objectName ;
    extern class className ;
:::

These statements must be placed in \"top level\" code, outside of all
object or function definitions.

## [Property name declarations]{#propdecl}

For the most part, the compiler automatically determines the type of
each symbol used throughout the program - object name, function name,
class name, property name, enum, etc. The compiler recognizes a symbol
as a property name when the symbol is used to define a property or
method of an object:

::: code
    class MyClass: object
       name = 'my class'
       weight = 10
       getOwner() { return owner; }
    ;
:::

The compiler will automatically infer from this code that [name]{.code},
[weight]{.code}, and [getOwner()]{.code} are property names, since
they\'re used to explicitly define properties and methods of MyClass.

In some cases, you won\'t have occasion to define a value for a
particular property as part of an object definition anywhere in the
program, but you still want to use the name as a property name. For
these situations, the compiler lets you explicitly declare a symbol as
being a property name. The syntax is:

::: syntax
    property propName [ , propName ... ]  ;
:::

This statement declares each listed symbol as a property. It must be
placed in \"top level\" code, outside of all object or function
definitions.

Here\'s an example:

::: code
    property name, weight, getOwner;
:::

Note that you can define method names as well as property names. A
method name is identical to a property name in terms of the symbol type,
so there\'s no difference in the declaration syntax.

## [Procedural statements]{#statements}

Within a function or method body, you can write a series of procedural
steps, called \"statements.\" A procedural statement is a single program
instruction.

Every statement starts with a \"keyword\" that indicates what action
should be carried out when the statement is executed. Actually, make
that *almost* every statement; there are a couple of exceptions. An
\"expression\" statement simply consists of an expression to evaluate,
with no introductory keyword. Also, there\'s such a thing as an
\"empty\" statement, which contains nothing at all except for the final
semicolon that all statements require. (An empty statement does nothing
at all - which sounds useless, but it actually is useful in some cases
as a placeholder, to fill in a spot that syntactically requires a
statement but for which you have no actual work to do.)

Most statements have some extra information after the keyword, giving
the specifics about what to do in the course of carrying out the
statement.

All statements end with a semicolon ([;]{.code}).

The interpreter carries out a function or method by executing its
statements, one at a time, starting at the first. In the simplest case,
execution steps sequentially through the statements in the function
until reaching the last one. Usually, though, it\'s not quite this
simple, because some statements \"jump\" to another point in the
function. The [if]{.code} statement, for example, jumps to one point if
a given condition is true, and a different point if the condition is
false. The [for]{.code} statement sets up a loop, where a group of
statements is repeatedly executed as long as a condition is true.

### [Code blocks]{#blocks}

A \"code block\" is a group of statements enclosed in braces ([{
}]{.code}). Code blocks are important for two reasons:

First, grouping statements with braces turns the group into what\'s
effectively a single statement. In almost any place where a single
statement is required, you can substitute a code block for the single
statement. This is how you write a [for]{.code} loop with several
statements in the loop body, for example.

A group of statements enclosed in braces acts syntactically like a
complete statement - *including* the obligatory semicolon that ends
every statement. That means that when you use a brace group in a slot
designed for a single statement, you **must not** add a semicolon after
the closing brace. For example:

::: code
    // WRONG!!!  The extra semicolon is redundant
    if (x == 1)
      { someFunc(1); };

    // Right
    if (x == 1)
      { someFunc(1); }
:::

Second, code blocks define the \"scope\" of local variables. A local
variable defined within a given code block exists only within that
block - that is, only as far as the next closing brace, not counting the
closing braces of nested code blocks.

::: code
    myFunc(x)
    {
      local a;

      if (x == 1)
      {
        local b;

        // local a is still valid here, since we're only nested -
        // symbols in scope within a given code block are in scope
        // within any blocks nested within
      }
      // local b is now out of scope, since we've ended the code
      // block where it was defined

      // local a is still in scope, of course, since we're still in
      // its code block
    }
    // now local a is out of scope, too, since we've ended its block
:::

### [Statement labels]{#labels}

A statement can be given a \"label.\" This is a symbol that you can use
to refer to the labeled statement, such as in [goto]{.code} or
[break]{.code} statements.

Statement labels have function/method scope. That is, a label is visible
within the *entire* function or method in which it\'s defined, but is
not visible outside the function or method. Even if a label is defined
within a nested code block, it\'s still visible throughout the entire
function.

You label a statement by writing the label, followed by a colon,
followed by the statement itself. For example, this function contains an
[if]{.code} statement labeled \"[stm1]{.code}\":

::: code
    myFunc(x)
    {
    stm1:
      if (x > 1)
      {
        --x;
        goto stm1;
      }
    }
:::

A statement label **must** be followed by a statement. While this might
seem obvious, there\'s a common situation where you might accidentally
write a label without a statement:

::: code
    myFunc(x)
    {
      if (x == 1)
      {
        // do some work...

        // check for errors
        if (errorOccurred())
          goto done;

        // do some more work...

      done:  // WRONG!!! there's no statement for this label!
      }
    }
:::

In this example, what we\'d like to do is to jump to the end of the
[if]{.code} block if an error has occurred at a certain point, to bypass
the remaining work we were going to do. The problem is that we\'ve
written our label just before the closing brace of the [if]{.code}
block. A closing brace doesn\'t constitute a statement, so it\'s illegal
to put a label here. Fortunately, this is easily solved: all we have to
do is add an empty statement after the label:

::: code
      done: ;  // this is fine, since we have a statement for the label now
:::

### [Empty statements]{#emptystm}

The \"empty statement\" consists of merely a semicolon:

::: code
    ;
:::

When executed, an empty statement has no effect.

Despite their meaninglessness at run-time, empty statements are useful
in certain situations. One use is to supply the required statement for a
label at the end of a code block. Another is to provide an empty loop
body for a [for]{.code} or other looping statement:

::: code
    for (i = 1 ; i < 10 ; handle(i++)) ;
:::

In this example, everything the loop needs to do is written within the
[for]{.code} statement itself, so we don\'t need anything in the loop
body. But the syntax of the [for]{.code} statement requires us to supply
*something* as the loop body regardless, so we can use an empty
statement to fill the syntactic need without adding any run-time
overhead.

### [local]{#local}

The [local]{.code} statement defines one or more local variables, and
optionally assigns initial values to them.

::: syntax
    local varName [ = expression ]  [ , ... ]  ;
:::

Local variables are in scope from the [local]{.code} statement to the
end of the enclosing code block. A local is **not** in scope before the
[local]{.code} statement that defines it (\"before\" meaning earlier in
the source text), and it goes out of scope at the closing brace of its
enclosing code block.

It\'s legal to define a local variable in a nested code block with the
same name as a variable in the enclosing code block. For example:

::: code
    myFunc(x)
    {
      local a = 7;

      if (x == 1)
      {
        local a = x;
      }

      return a;
    }
:::

This function as written always returns 7, because the local variable
named [a]{.code} that\'s definfed within the [if]{.code} statement\'s
code block is a different variable from the [a]{.code} defined within
the function\'s main code block. The two [a]{.code}\'s share the same
name, but they\'re nonetheless distinct variables: so assigning
[x]{.code} to the \"inner\" [a]{.code} has no effect on the \"outer\"
[a]{.code}.

When you define a local variable in a nested block with the same name as
a local defined in an enclosing block, the variable in the nested block
\"hides\" the one in the enclosing block as long as it\'s in scope.
There\'s no way to refer to the hidden variable from within the nested
block in this case.

If no initializer is supplied for a variable, the local variable is
initialized to nil at entry to the function or method containing the
[local]{.code} statement. If an initializer is supplied, the expression
is evaluated when the [local]{.code} statement is executed, and the
value is assigned to the local variable.

Each initializer expression applies to one variable only. For example:

::: code
    local a, b, c = 7;
:::

This initializes [c]{.code} to 7, and leaves [a]{.code} and [b]{.code}
with the default [nil]{.code} value.

[local]{.code} statements that include initializers count as executable
statements. This means that they\'re executed as they\'re encountered,
just like any other statement. This is important to keep in mind when
writing a loop:

::: code
    for (i = 0 ; i < 10 ; ++i)
    {
      local j = 7;

      if (i < j)
        ++j;
    }
:::

The important thing to note here is that [j]{.code} is re-initialized to
7 *every time through the loop*.

If a [local]{.code} statement doesn\'t include an initializer for a
variable, that variable is initialized to [nil]{.code} at entry to the
function or method, but is **not** reset to [nil]{.code} each time the
[local]{.code} statement is executed. In fact, a [local]{.code}
statement without an initializer doesn\'t have any run-time effect,
other than to reserve space for the local variable when the function or
method is entered.

### [Expression statements]{#exprstm}

An expression, all by itself, counts as a statement.

::: syntax
    expression ;
:::

Expression statements are typically the most numerous type of statement
in a program, because they\'re the main way to call functions and
methods, assign values to variables, invoke intrinsic functions, and so
on.

When you write an expression as a statement, it\'s virtually always to
invoke the side effects of the expression. It\'s pointless to write an
expression statement where the expression has no side effects:

::: code
    x + 2;  // a pointless statement!
:::

That does nothing meaningful: it adds 2 to x, but since the expression
doesn\'t do anything with the result, the result is simply discarded.

So, typically, an expression statement includes something with side
effects:

-   a function call
-   a method call
-   assigning a value to a variable
-   incrementing or decrementing a variable with [++]{.code} or
    [\--]{.code}

Here are some examples:

::: code
    myFunc(7);
    x = x + 3;
    myObj.weight *= 2;
:::

### [Double-quoted string statement]{#dqstm}

A double-quoted string, written by itself as a statement, displays the
string. (More precisely, it calls the default display function, which
the default startup sets to [tadsSay()]{.code}, with the string\'s text
as the argument.) For example:

::: code
    "Hello, world!\n";
:::

In addition to displaying fixed text, double-quoted strings can display
embedded variables and expressions. You embed an expression within a
double-quoted string by enclosing the expression within [\<\<
\>\>]{.code} marks within the string:

::: code
    "x = <<x>>, y*5 = <<y*5>>\n";
:::

The compiler treats this as though it were a series of statements like
this:

::: code
    {
      "x = ";
      tadsSay(x);
      ", y*5 = ";
      tadsSay(y*5);
      "\n";
    }
:::

Embedded expressions are evaluated each time they\'re encountered. The
expressions within a string are evaluated in the order in which they
appear in the string. Expression values are displayed according to their
datatype:

-   **string:** the text of the string is displayed
-   **integer:** the decimal representation of the number is displayed
-   **BigNumber:** the number is displayed using the default formatting
-   **nil:** nothing is displayed
-   **all other types:** a run-time error (\"invalid type\") is
    generated

For more on embedded expressions, see the section on [string
literals](strlit.htm#embeddings).

### [return]{#return}

The [return]{.code} statement exits the current function or method and
resumes execution in the caller. Optionally, the statement can specify
an expression to evaluate as the return value of the function or method.

::: syntax
    return [ expression ]  ;
:::

If an expression is specified, it\'s evaluated when the [return]{.code}
statement is executed, and the result is returned to the caller as the
result value of the current function or method. If no expression is
specified, the default return value of [nil]{.code} is used.

When a [return]{.code} statement is executed, the VM first executes the
[finally]{.code} clause of each enclosing [try]{.code} statement,
working from the innermost outward. It then exits the function and
resumes execution in the caller.

### [if]{#if}

The [if]{.code} statement executes a statement if a given condition is
true, and can optionally execute a different statement if the given
condition is false.

::: syntax
    if ( conditionExpression )
      thenPart
    [ else
      elsePart ] 
:::

Each of [thenPart]{.synPar} and [elsePart]{.synPar} are single
statements, or code blocks enclosed in braces.

The [if]{.code} statement first evaluates the condition expression.
Then:

-   If the result is anything except 0 or [nil]{.code}, the
    [truePart]{.synPar} is executed, then execution jumps to the next
    statement after the entire [if]{.code}.
-   Otherwise:
    -   If an [else]{.code} clause is specified, the [elsePart]{.synPar}
        is executed, then execution resumes at the next statement.
    -   If there\'s no [else]{.code} clause, execution jumps directly to
        the next statement.

Since TADS uses a C-like syntax, it inherits a sometimes
counterintuitive quirk of C that affects nested [if]{.code} statements.
Consider the following:

::: code
    if (a == 1)
      if (b == 2)
        doSomething(a, b);
    else
      somethingElse(a, b);
:::

Based on the indentation, the person who wrote this code seemed to be
thinking that the [somethingElse()]{.code} line would be reached if [a
!= 1]{.code}. But that isn\'t the case: look more closely and you\'ll
see that the [else]{.code} actually attaches to the *second*
[if]{.code}. An [else]{.code} always goes with the nearest possible
preceding [if]{.code}. So this code will simply do nothing if [a !=
1]{.code}.

To fix this, we have to add some braces to make the grouping explicit:

::: code
    if (a == 1)
    {
      if (b == 2)
        doSomething(a, b);
    }
    else
      somethingElse(a, b);
:::

This makes it impossible for the [else]{.code} to attach to the second
[if]{.code}, because the [if]{.code} is tucked away inside the nested
code block and therefore out of consideration back in the main code
block.

### [for]{#for}

The [for]{.code} statement is a flexible and powerful looping construct
that lets you construct almost any kind of loop.

TADS has three different kinds of [for]{.code} loops: the standard C
[for]{.code} loop, which is very similar to its counterpart in C++; the
[for..in]{.code} loop, which works exactly like
[[foreach]{.code}](#foreach); and the \"range\" loop, which makes it
easy to write a loop over a range of integer values.

#### [C-style [for]{.code} loops]{#cfor}

The basic [for]{.code} loop in TADS is almost identical to the {\[for}}
loop in C, C++, Javascript, and most other C-like languages. It has this
basic syntax:

::: syntax
    for ( [ initializer ]  ; [ condition ]  ; [ updater ]  )
      loopBody
:::

The [initializer]{.synPar} is either an ordinary expression, or a list
of local variable declarations, or a mix of both:

::: syntax
    ( expression | local varName = expression )  [ , ... ] 
:::

Note the difference from ordinary [local]{.code} statements: the
initializer expression is *required* for a local variable defined here.

Local variables defined in a [for]{.code} statement are only in scope
within the [for]{.code} loop. They\'re in scope within all of the
expressions that are part of the [for]{.code} statement itself (the
initializer, condition, and updater expressions), and they\'re in scope
within the body of the loop. The [for]{.code} statement has its own new
nested scope that starts just before the [for]{.code} and ends at the
end of its loop body; the locals exist within this nested scope.

In practice, the expressions within the [initializer]{.synPar} section
are almost always assignment expressions. The point is to initialize the
variables used within the loop to their starting values for the loop.

The [condition]{.synPar} and [updater]{.synPar} are ordinary
expressions, and the [loopBody]{.synPar} is a single statement, or a
block of statements enclosed in braces.

The C-style [for]{.code} statement executes as follows:

-   1\. Evaluate each element of the [initializer]{.synPar} list,
    starting from the left.
-   2\. If there\'s a [condition]{.synPar}, evaluate it. If result is 0
    or [nil]{.code}, we\'re done with the [for]{.code}, so jump to the
    next statement after the loop body. Otherwise, proceed to step 3. If
    there\'s no [condition]{.synPar}, proceed to step 3.
-   3\. Execute [loopBody]{.synPar} once.
-   4\. Evaluate [updater]{.synPar}, if specified.
-   5\. Go to step 2.

An important feature of this procedure is that the [condition]{.synPar}
expression is evaluated *before the first iteration*. That means that if
the condition is false (i.e., 0 or [nil]{.code}) before the first
iteration, the loop body is never executed. Therefore, it\'s possible
for a [for]{.code} loop to iterate zero times.

Another feature to note is that the [updater]{.synPar} expression is
evaluated *after each iteration*, before the [condition]{.synPar} is
re-tested.

C-style [for]{.code} statements are extremely flexible. The statement
doesn\'t do anything implicitly - it doesn\'t increment any variables
automatically, or anything else. This is a departure from many
programming languages, where similar looping constructs implicitly
increment a variable on each iteration. With the [for]{.code} statement,
you have to explicitly say what you want to do on each iteration.
Although that\'s a little more work, the benefit is that you can do
exactly what you want, no matter how unusual: if you want to increment a
variable by the *n*th Fibonacci number each time through, you can easily
do that.

Note that each of the expression parts - the [initializer]{.synPar}, the
[condition]{.synPar}, and the [updater]{.synPar} - are allowed to be
completely empty. You still have to write all of the semicolons, but
it\'s legal to write *only* the semicolons. This is a valid loop:

::: code
    for (;;)
    {
      // do some work...
    }
:::

Because there\'s no [condition]{.synPar} expression, this statement will
loop forever, unless there\'s a statement within the loop that exits the
loop or the entire function (such as [break]{.code}, [goto]{.code},
[return]{.code}, or [throw]{.code}).

Here\'s a more typical example of a [for]{.code} loop.

::: code
    for (local i = 1 ; i <= lst.length() ; ++i)
    {
      "lst[<<i>>] = <<lst[i]>>\n";
    }
:::

This loop goes through a list, displaying each element. It uses the
counter variable [i]{.code} (defined as local to the loop): it starts by
setting [i]{.code} to 1, and continues looping as long as [i]{.code} is
less than or equal to the length of the list; each time through the
loop, it increments [i]{.code}, to move to the next list element.

You could speed up this example a little bit by saving the length of the
list in another loop local variable. This takes advantage of the ability
to use more than one [local]{.code} clause in a [for]{.code}
initializer.

::: code
    for (local i = 1, local len = lst.length() ; i <= len ; ++i) ...
:::

That works the same as our original example, but runs a little faster,
because it doesn\'t have to call [lst.length()]{.code} every time
through the loop.

#### [for..in]{#forIn}

The [for]{.code} statement can alternatively iterate over the elements
of a collection. The syntax for this is exactly the same as for the
[[foreach]{.code}](#foreach) statement, other than using [for]{.code} in
place of [foreach]{.code}:

::: syntax
    for ( [ local ]  loopVar in expression )
       loopBody
:::

For..in loops are new in TADS 3.1; in older versions, only the
[foreach]{.code} statement accepted this syntax. The [for]{.code} syntax
was added for two reasons. First, it simplifies the language\'s syntax:
you don\'t have to remember to use a different statement keyword for
collection loops. Second, it lets you [combine](#combinedFor) the
collection syntax with the standard C-style [for]{.code} syntax, so that
you can add other variables (counters, sums, etc.) to a collection loop.

#### [for..in range]{#forInRange}

The third type of [for]{.code} loop iterates over a range of integers.
This is by far the most common type of [for]{.code} loop, so TADS
provides this special syntax to make the meaning a little clearer.

The syntax for an integer range loop is:

::: syntax
    for ( [ local ]  loopVar in fromExpr .. toExpr [ step stepExpr ]  )
       loopBody
:::

As with other [for]{.code} loops, the [local]{.code} keyword lets you
define a new local variable for the loop\'s control variable, with its
scope limited to the loop. If you don\'t use [local]{.code}, the loop
variable can be any local variable defined before the [for]{.code}.

*fromExpr*, *toExpr*, and the optional *stepExpr* are expressions that
evaluate to integer values. If there\'s no [step]{.code} clause, the
default step value is 1.

The integer range loop is executed as follows:

-   1\. *fromExpr* is evaluated, and the result is assigned to
    *loopVar*.
-   2\. *toExpr* and (if it\'s present) *stepExpr* are evaluated, in
    that order, and the results are stored in temporary memory
    locations.
-   3\. *loopVar* is compared to the value of *toExpr* calculated in
    step 2. If the saved *stepExpr* is positive, we exit the loop if
    *loopVar* is the result is \"greater than\". If *stepExpr* was
    negative, we exit if the result is \"less than\". Otherwise we
    continue to step 4.
-   4\. Execute the loop body one time.
-   5\. Add the *stepExpr* value calculated in step 2 to *loopVar*.
-   6\. Go to step 3.

In step 3, note how the loop exits if the loop\'s control variable goes
*beyond* the *toExpr* limit, where the direction of \"beyond\" depends
on whether the step increment is positive or negative. If the step is
positive, we\'re looping from a lower value to a higher value, so we
stop when the loop variable is greater than the \"to\" limit. Likewise,
if the step is negative, we\'re going from a higher value to a lower
value, so we stop when the loop variable is less than the \"to\" limit.

Take special note of how *toExpr* and *stepExpr* are used in the loop.
They\'re only evaluated *once*, at the start of the loop (in step 2).
This is important, because it means that if any of these values change
during the loop, it doesn\'t affect the loop boundaries. The original
values at the start of the loop determine the loop\'s limits. Consider
this example:

::: code
    local lst = ['a', 'b', 'c'];
    for (local i in 1..lst.length())
       lst += lst[i];
:::

Each time through this loop, we append a new element to the end of the
list. This means that [lst.length()]{.code} increases by 1 on each
iteration. If we re-evaluated [lst.length()]{.code} each time through,
this loop would never end - both [i]{.code} and [lst.length()]{.code}
are incremented by 1 each time through, so [i]{.code} would never catch
up with [lst.length()]{.code}. But we *don\'t* re-evaluate
[lst.length()]{.code} each time through; instead, the original value is
calculated at the start of the loop, and that value is used to determine
when the loop ends, no matter what happens once we start going through
the loop. So the loop in this example runs only three times, then exits.

The single evaluation of *toExpr* and *stepExpr* is also good for
efficiency. With traditional C-style loops, it\'s common to write
something like this:

::: code
    for (local i = 1, local len = lst.length() ; i <= len ; ++i) ...
:::

The point of creating the extra local [len]{.code} is to speed up the
code a little by avoiding a call to [lst.length()]{.code} every time
through the loop. The [for..in]{.code} syntax is equally efficient,
because it does the same thing. It just saves you the trouble of coding
the extra step by hand, and makes the code easier to read.

#### [Combining [for]{.code}, [for..in]{.code}, and [for..in range]{.code}]{#combinedFor}

So far, we\'ve presented the [for]{.code} statement as though it had
three separate syntax options: the standard C-style [for]{.code}, the
collection loop with [for (x in y)]{.code}, and the integer range loop
with [for (i in a..b)]{.code}. These aren\'t actually separate statement
types, though - they\'re simply special cases of the standard
[for]{.code}, which encompasses all three loop styles. The really
interesting thing is that you can combine all three types in a single
loop. For example:

::: code
    for (local i = 1, local ele in lst ; ; ++i)
       "lst[<<i>>] = <<lst[i]>>\n";
:::

That kind of loop is cumbersome to write with [foreach]{.code}, since
there\'s no way to include an extra counter variable with the collection
loop. [for]{.code}\'s ability to combine the loop styles makes for
shorter code that\'s often clearer, since the extra variables involved
in the loop can be coded right into the [for]{.code} structure.

The key to combining the three types of [for]{.code} loops is that [x in
y]{.code} and [i in a..b]{.code} are really just syntax options for the
\"initializer\" clause of the C-style [for]{.code} statement. You can
freely mix these with one another and with ordinary initializer
expressions.

When you use [x in y]{.code} or [i in a..b]{.code} in an initializer,
the condition and updater clauses of the [for]{.code} become optional.
You can omit them entirely, including the semicolons that separate the
three clauses. The [for (x in y)]{.code} and [for (i in a..b)]{.code}
statements we saw earlier, then, are nothing special: they\'re just the
simplest [for]{.code} statements with the respective initializer types.
The reason that the condition and updater clauses are optional when
using an \"in\" clause is that an \"in\" clause supplies its own
implicit condition and updater - so if you have nothing else to add to
those parts, the compiler lets you leave them out entirely, to keep the
code uncluttered.

Here\'s the full sequence of events when processing a hybrid loop that
contains regular initializers, conditions, and updaters, as well as
[in]{.code} clauses:

-   1\. For each initializer, in order of appearance:
    -   If it\'s an ordinary expression, evaluate it.
    -   If it\'s an [x in y]{.code} clause, evaluate the *collection*
        expression, then call the [createIterator()]{.code} method on
        the result. Store the method result in a temporary memory
        location (\"the iterator\").
    -   If it\'s an [i in a..b]{.code} clause, evaluate the *fromExpr*,
        and assign the result to the control variable. Then, evaluate
        *toExpr* and (if present) *stepExpr*, and store the results in
        temporary memory locations.
-   2\. For each [in]{.code} clause among the initializers, in order of
    appearance:
    -   For an [x in y]{.code} clause, call the
        [isNextAvailable()]{.code} method on the iterator. If it returns
        [nil]{.code}, exit the loop. Otherwise call the iterator\'s
        [getNext()]{.code} method and store the result in the clause\'s
        *loopVar*.
    -   For an [i in a..b]{.code} clause, compare the clause\'s
        *loopVar* to the saved value of *toExpr* from step 1. If it\'s
        \"beyond\" the *toExpr* value (greater than *toExpr* if the step
        value is positive, less than *toExpr* if the step value is
        negative), exit the loop.
-   3\. If there\'s a *condition* expression, evaluate it. If the result
    is [0]{.code} or [nil]{.code}, exit the loop.
-   4\. Execute the loop body once.
-   5\. If there\'s an *updater* expression, evaluate it.
-   6\. For each [i in a..b]{.code} clause (in the order of the
    initializers), add the saved value of *stepExpr* from step 1 to
    *loopVar*.
-   7\. Go to step 2.

In a nutshell, this works just like the standard C [for]{.code} loop,
except for two additions. First, **before** the explicit *condition*
expression is tested, [x in y]{.code} and [i in a..b]{.code} clauses are
tested, and the loop terminates if any of them are finished. Second,
**after** the explicit *updater* expression is executed, [i in
a..b]{.code} loop control variables are incremented by their step
values. The explicit *updater* is executed first so that it can refer to
the current values of the [in]{.code} control variables, from the loop
iteration that just finished, if desired.

### [foreach]{#foreach}

The [foreach]{.code} statement iterates over a Collection object\'s
contents. It executes a statement (or group of statements) once for each
element of a Collection.

::: syntax
    foreach ( loopVar in expression )
      loopBody
:::

[loopVar]{.synPar} can take one of two forms: it can be any \"lvalue\"
(see the [expressions](expr.htm#commonEles) section for details), such
as a local variable, an object property, or an indexed lvalue; or it can
be of this form:

::: syntax
    local localName
:::

The [local]{.code} syntax defines a new local variable, scoped to the
[foreach]{.code} statement. (This works the same way as it does with the
[for]{.code} statement.) If the [local]{.code} keyword is not specified,
the local variable with the given name from the enclosing scope is used.

The [expression]{.synPar} is any expression, but when evaluated it must
yield a Collection object - a list, a Vector, or a LookupTable.

The [loopBody]{.synPar} is a single statement, or a group of statements
enclosed in braces.

The statement first evaluates the [expression]{.synPar}. This must yield
a Collection object; if not, a run-time error results. The statement
then iterates over the elements of the collection, one at a time. For
each element of the collection, the statement sets the looping variable
[loopVar]{.synPar} to the current element, and executes the
[loopBody]{.synPar} once.

For a mutable object like a Vector or a HashTable, [foreach]{.code}
automatically creates a \"safe\" copy of the object at the beginning of
the iteration, and uses the safe copy throughout the iteration. This
ensures that the loop executes exactly once for each element of the
collection *as it was at the start of the loop*, even if the loop body
makes changes to the collection. This makes it safe to make arbitrary
changes to the collection in the loop body. For example, you can insert
new element into a Vector, or delete existing elements. Changes you make
from within the loop body will not affect the iteration.

The order of the iteration depends on the type of the collection. For
lists and Vectors, the iteration is in ascending index order. For
LookupTables, the order is arbitrary.

The \"element\" value that\'s assigned to the looping variable on each
iteration depends on the type of collection. For a list or a Vector,
it\'s simply the element value. For a LookupTable, it\'s the *value* at
a given key, *not* the key itself.

Example:

::: code
    foreach (local ele in lst)
      "<<ele>>... ";
:::

This simply runs through a collection and displays each element.
Assuming [lst]{.code} is a list, the elements are displayed in ascending
index order.

Here\'s an example that takes advantage of the \"snapshot\" feature -
the safe copy that [foreach]{.code} creates before beginning the
iteration.

::: code
    local i = 1;
    local vec = new Vector(10).fillValue(nil, 1, 10).applyAll({x: i++});

    foreach (local x in vec)
    {
      vec.applyAll({v: v+1});
      "<<x>>\n";
    }
:::

The first two lines create a Vector and initialize its elements to the
integers 1 through 10, using the [applyAll()]{.code} method of the
Vector. The [foreach]{.code} body modifies the entire Vector, by adding
1 to each element, then prints out the current value. At first glance,
we might expect the values displayed to be something like this: 1, 3, 5,
7, 9, \...; we might expect this because of the [applyAll()]{.code} call
updates every element of the Vector on every iteration of the loop. This
isn\'t what happens, though: because the [foreach]{.code} iterates a
copy of the Vector, we actually print out the original contents of the
Vector: 1, 2, 3, 4, and so on. After we\'re finished with the iteration,
though, if we look at the Vector, we\'ll find it modified as we\'d
expect. In addition, even within the loop, if we were to refer directly
to the Vector through the variable [vec]{.code}, we\'d find it modified
as we\'d expect - the snapshot pertains only the iteration variable, and
doesn\'t \"freeze\" the Vector itself. To see this, consider this more
complex example:

::: code
    local i = 1;
    local vec = new Vector(10).fillValue(0, 1, 10).applyAll({x: i++});

    i = 1;
    foreach (local x in vec)
    {
      vec.applyAll({v: v+1});
      "x = <<x>>, vec[<<i>>] = <<vec[i]>>\n";
      ++i;
    }
:::

This would display the following, showing that the vector has been
modified - and the modifications are visible within the loop - even
though the modifications are not visible to the iteration variable:

::: code
    x = 1, vec[1] = 2
    x = 2, vec[2] = 4
    x = 3, vec[3] = 6
    x = 4, vec[4] = 8
    x = 5, vec[5] = 10
    x = 6, vec[6] = 12
    x = 7, vec[7] = 14
    x = 8, vec[8] = 16
    x = 9, vec[9] = 18
    x = 10, vec[10] = 20
:::

Although we\'ve belabored this snapshot behavior as though it were some
pitfall you must take care to avoid, the snapshot actually simplifies
things greatly for most common situations. The snapshot relieves you
from having to worry about how the iteration will proceed. Even if
you\'re making changes to the contents of the collection during the
loop, you can be confident that the updates will have no effect on the
iteration. The snapshot feature makes it easy to iterate over
collections without having to worry about the details of how changes
would affect the order of the elements, or the number of elements, or
anything else.

For those who are curious, here are the gory, internal details on how
[foreach]{.code} actually executes. It first evaluates the
[expression]{.synPar}, then calls the [createIterator()]{.code} method
on the resulting value. It stores this value in a temporary variable,
which we\'ll call *I*. It then loops as follows: call
*I*[.isNextAvailable()]{.code}; if this is [nil]{.code}, exit the loop;
otherwise call *I*[.getNext()]{.code}, and assign the result to the
looping variable [loopVar]{.synPar}, then execute the loop body once,
then go to the top of the loop.

### [while]{#while}

The [while]{.code} statement sets up a simple loop that repeats as long
as a condition is true.

::: syntax
    while ( conditionExpression )
       loopBody
:::

The [conditionExpression]{.synPar} is any expression, and the
[loopBody]{.synPar} is a single statement or a group of statements
enclosed in braces.

A [while]{.code} statement is executed as follows:

-   1\. Evaluate the condition expression. If the result is 0 or
    [nil]{.code}, exit the loop, by jumping to the next statement after
    the loop body. Otherwise, proceed to step 2.
-   2\. Execute the loop body once.
-   3\. Go to step 1.

The condition expression is evaluated before every iteration of the
loop - even before the first iteration, which means that the loop can
execute zero times, if the condition is initially false.

Here\'s an example:

::: code
    local iter = coll.createIterator();
    while (iter.isNextAvail())
    {
      local ele = iter.getNext();
      "The next element is: <<ele>>\n";
    }
:::

### [do\...while]{#dowhile}

The [do]{.code}\...[while]{.code} statement sets up a loop similar to a
[while]{.code} loop, but with the important difference that the loop
condition is tested *after* each iteration, rather than at the
beginning. This means that a [do]{.code}\...[while]{.code} loop always
executes *at least once*, since the loop condition isn\'t tested until
after the first iteration.

::: syntax
    do
      loopBody
    while ( conditionExpression ) ;
:::

The [conditionExpression]{.synPar} is any expression, and the
[loopBody]{.synPar} is one statement or a group of statements enclosed
in braces.

A [do]{.code}\...[while]{.code} loop is executed as follows:

-   1\. Execute the loop body once.
-   2\. Evaluate the condition expression. If the result is 0 or nil,
    exit the loop by jumping to the next statement after the
    [do]{.code}\...[while]{.code}. Otherwise, go to step 1.

Here\'s an example:

::: code
    local x = 'a';
    do
    {
        "x = <<a>>\n";
        x += 'a';
    } while (a.length() < 10);
:::

### [switch]{#switch}

The [switch]{.code} statement selects one of several code branches,
depending on the value of an expression. [switch]{.code} is similar to a
series of [if]{.code}\...[else if]{.code}\...[else if]{.code}\...
statements, but has some advantages and restrictions over that approach.

::: syntax
    switch ( controlExpression )
    {
      case value1 :
        caseBody1

      case value2 :
        caseBody2

      default :
        defaultBody
    }
:::

The [controlExpression]{.synPar} is any expression. This is used to
select which \"branch\" of the [switch]{.code} to execute.

[value1]{.synPar} and subsequent values are called the \"case labels.\"
These are **constant** expressions - that is, they must be integers,
enums, object names, string constants, property IDs, function names,
BigNumber constants, or lists containing only constant expressions.
These values can be expressions, as long as the expression can be fully
computed and reduced to a constant value at compile time. For example,
you can use a value like [1+2\*3]{.code}, since the compiler can
directly compute the integer value of this expression; but you can\'t
use a value like [a+1]{.code}, where [a]{.code} is a local variable,
because the value of a local variable can\'t be determined until the
program is actually running. You can use any mix of types among the case
labels - that is, each case label can be of a different datatype.

The [caseBody]{.synPar} elements, and the [defaultBody]{.synPar}, each
consist of zero or more statements. Note that it\'s legal for a case or
default body to be empty, so it\'s legal for several [case]{.code}
labels to appear consecutively.

A [switch]{.code} must have at least one [case]{.code} *or*.
[default]{.code} label, and can have at most one [default]{.code} label.
Any number of [case]{.code} labels can appear - including zero, provided
there\'s a [default]{.code} to meet the required minimum of one label
overall. So, for example, a [switch]{.code} that contains only a
[default]{.code} label is legal, as is a [switch]{.code} with one
[case]{.code} label, or with five [case]{.code} labels, or with
[five]{.code} case labels and a [default]{.code}. A completely empty
[switch]{.code} is illegal, as is a [switch]{.code} with more than one
[default]{.code} label.

A [switch]{.code} statement is executed as follows. First, the
[controlExpression]{.synPar} is evaluated. The result is then compared
to each case label value, one at a time, in the order in which the
labels appear in the source code. The comparison is done according to
the same rules as the [==]{.code} operator. At the first match,
execution jumps to the first [caseBody]{.synPar} statement following the
matching label. If no matches are found among the case labels, and
there\'s a [default]{.code} label, execution jumps to the first
[defaultBody]{.synPar} statement. If no matches are found among the case
labels, and there\'s no [default]{.code} label, execution jumps to the
next statement after the entire [switch]{.code} body.

Note that the [default]{.code} can go anywhere in the [switch]{.code}
without changing the behavior of the [switch]{.code}. We always search
*all* of the value labels first, and only jump to the [default]{.code}
label if we can\'t find a match. So you can even put the
[default]{.code} label first if you want - it won\'t change anything,
since the value labels are always checked first, no matter where the
[default]{.code} appears.

[Warning! [break]{.code} must be explicit!]{#caseBreaks}

It\'s very important to note that a [case]{.code} label **does not**
interrupt the flow of execution after a match has been found. In other
words, the case bodies are **not** like [if]{.code}\...[else]{.code}
branches, where execution leaves the overall statement when you reach
the end of the branch. Instead, they\'re like [goto]{.code} labels,
where they just drop you into a linear sequence of code at a particular
point - and once you\'re there, you\'ll by default just keep going all
the way to the end of the [switch]{.code}, even if you encounter other
[case]{.code} labels along the way.

This is a feature of C that\'s inherited by most C-like languages,
including TADS, and it catches a lot of people off-guard. Many
procedural languages outside the C-like family have similar
\"selection\" statements that *do* work like multi-branch if-then-else
trees, and to most people that\'s the obvious, intuitive way of doing
things. This is probably one of the most counterintuitive aspects of C,
and a common pitfall for new C (and Java and TADS) programmers.

Fortunately, you *can* make each case block a self-contained little
branch, just like an [if]{.code}\...[else]{.code} - it\'s just that you
have to do so *explicitly*. The way you do this is by adding a
[break]{.code} statement at the end of each case body.

Here\'s an example:

::: code
    switch (obj.color)
    {
    case red:
      lambda = 700;
      break;

    case orange:
      lambda = 600;
      break;

    case yellow:
      lambda = 575;
      break;

    default:
      lambda = 0;
      break;
    }
:::

Here, we\'ve made each case body a self-contained branch by putting a
[break]{.code} statement at the end. A [break]{.code} within a
[switch]{.code} body jumps to the next statement after the end of the
[switch]{.code}, so for each color case, we\'ll just set the wavelength
variable and leave the [switch]{.code}.

Note that we\'ve even put a [break]{.code} at the very end, as the last
statement of the [default]{.code} body. There\'s no subtle magic behind
this - it\'s presence changes nothing, exactly as you\'d expect, since
if we left it out we\'d still fall out of the end of the overall
[switch]{.code} body at that same point anyway. So why did we bother to
write the [break]{.code} there? There are a few reasons. One is that
it\'s a good habit to just automatically end each case branch with a
[break]{.code}, since if you get into that habit you\'re less likely to
miss one accidentally when it matters. Another is that it makes the code
look a little more consistent, since each branch has the same form:
[case]{.code}, code, [break]{.code}. Perhaps the most important reason
is that it\'s a little insurance in case we add another case label below
the [default]{.code} later on - at that point we might forget that
there\'s a case above that we didn\'t [break]{.code} out of, so adding
the [break]{.code} now ensures that we won\'t miss it then.

You might wonder how the designers of C ever came up with the crazy
\"fall-through\" feature in the first place. It\'s probably a result of
C\'s design as a thinly disguised version of assembly language. In
assembler, labels are just targets for \"goto\" jumps. The use of the
label-like syntax for the cases suggests that C\'s designers conceived
of \"switch\" as a fancy \"goto\". If you think of the case labels as
just \"goto\" targets, then, it makes a kind of sense that execution
just plows on through them rather than leaving the switch at the end of
a case.

The fall-through behavior is handy for one thing, though. It lets you
easily share the same case body among multiple labels:

::: code
    switch (x)
    {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
      "x is from 1 to 5\n";
      break;

    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
      "x is from 6 to 10\n";
      break;
    }
:::

This code works because the empty case bodies (for cases 1, 2, 3, etc.)
all \"fall through\" to the next executable statement, even though there
are intervening case labels.

On some occasions, it\'s also convenient to take advantage of the
fall-through feature with actual executable code.

::: code
    switch (x)
    {
    case 1:
      "one...";

    case 2:
      "x is one or two\n";
      break;
    }
:::

In this case, we\'re *intentionally* falling through from the \"1\" case
to the \"2\" case. There\'s a little extra code we want to execute in
the \"1\" case, but then we want to proceed to the common handling for 1
and 2. When you write code like this, it\'s not a bad idea to comment
that the fall-through is intentional - if you don\'t, and you come back
to this code after a couple of weeks, you might forget what you had in
mind and mistakenly think you forgot a [break]{.code}, and mistakenly
fix a non-mistake! So, something like this is a good idea:

::: code
    case 1:
      "one...";
      // FALL THROUGH...

    case 2:
      // etc...
:::

[A note on indentation styles]{#indentStyle}

There are basically two ways to indent [switch]{.code} bodies. Some
people like to indent the case labels one level in from the
[switch]{.code}, and then indent the statements in the case bodies one
level further:

::: code
    switch (x)
    {
      case 1:
        "One!";
        break;

      case 2:
        "Two!";
        break;

      default:
        "A million!";
        break;
    }
:::

Other people, your author included, prefer to put the labels at the same
level as the [switch]{.code}:

::: code
    switch (x)
    {
    case 1:
      "One!";
      break;

    case 2:
      // etc
    }
:::

Both styles are common. I prefer the second because it makes for
slightly less indenting overall, which can be helpful in complex
functions; and because it treats the case labels consistently with
ordinary statement (\"goto\") labels, which I like to \"outdent\" from
the code they\'re labeling.

### [goto]{#goto}

The [goto]{.code} statement transfers the execution position directly to
a labeled statement.

::: syntax
    goto label ;
:::

The [label]{.synPar} is the name of a statement label defined elsewhere
within the same function or method. The target label can be within an
enclosing code block, since statement labels are visible within the
entire containing function or method.

When a [goto]{.code} statement is executed, the VM first executes the
[finally]{.code} clause of each enclosing [try]{.code} statement,
working from the innermost outward. It then jumps directly to the
statement immediately following the target label.

Almost anyone who\'s had any exposure to programming in any language has
received the standard warnings about how bad [goto]{.code} is. This is
generally true: [goto]{.code} is to be avoided. The problem with
[goto]{.code} is that it makes it extremely difficult to grasp the flow
of execution through a piece of code by making arbitrary jumps. The sort
of nested conditional and iteration structures that modern languages
offer ([if]{.code}\...[else]{.code}, [for]{.code}, [while]{.code}, and
so on) are much easier to comprehend at a glance, since their visual
structure on the page maps fairly directly to their code flow.
[goto]{.code} tends to ruin that clean visual structure by scribbling
arbitrary transfer vectors all over the page.

Even so, in C and C++, [goto]{.code} is occasionally the clearest way to
accomplish a task. The alternative is sometimes to create a network of
extra flags that shepherd the execution point out of a series of nested
loops and into a subsequent cleanup section. However, the ability in
TADS 3 to use labeled targets in [break]{.code} and [continue]{.code}
statements largely eliminates even this type of situation, so justified
uses of [goto]{.code} in TADS 3 programs are rare indeed.

### [break]{#break}

The [break]{.code} statement exits a given statement, transferring
control to the next statement after the given statement.

::: syntax
    break [ label ]  ;
:::

[break]{.code} comes in two forms: with and without a target label.

When no label is specified, [break]{.code} applies to the nearest
enclosing [for]{.code}, [while]{.code}, [do]{.code}\...[while]{.code},
or [switch]{.code} statement. There must be an enclosing statement of
one of these types in the current function or method; if there isn\'t, a
compiler error results. Controls transfers to the statement immediately
after the end of the loop or [switch]{.code} body.

When a label is specified, the [break]{.code} applies to the labeled
statement, which must enclose the [break]{.code}. If the labeled
statement doesn\'t enclose the [break]{.code}, a compiler error results.
If the target statement is a loop, control transfers to the statement
following the loop body. If the target is a compound statement (a group
of statements enclosed in braces), control transfers to the next
statement after the block\'s closing brace.

Targeted [break]{.code} statements are especially useful when you want
to break out of a loop from within a nested [switch]{.code}:

::: code
    scanLoop:
      for (i = 1 ; i < 10 ; ++i)
      {
        switch(val[i])
        {
        case '+':
          ++sum;
          break;

        case '-':
          --sum;
          break;

        case 'eof':
          break scanLoop;
        }
      }
:::

The label is necessary in this case because the [break]{.code} would, by
default, only go as far as exiting the [switch]{.code}. By specifying
the label, you can break all the way out of the enclosing [for]{.code}
loop.

Targeted break statements are also useful for breaking out of nested
loops:

::: code
    matchLoop:
      for (i = 1 ; i <= val.length() ; ++i)
      {
        for (j = 1 ; j < i ; ++j)
        {
          if (val[i] == val[j])
            break matchLoop;
        }
      }
:::

A labeled [break]{.code} can break out of *any* block of code - it
doesn\'t have to be a loop or a [switch]{.code}. For example:

::: code
    section1:
      {
        if (a == 1)
        {
          if (b == 2)
          {
            if (c == 3)
              break section1;

            // do some work...
          }

          // do something else...
        }

        // do some more stuff...
      }
      // that 'break section1' comes directly here
:::

This is sometimes handy for error handling and the like, since it lets
you bypass a whole chunk of code by jumping directly out of the entire
labeled block.

### [continue]{#continue}

The [continue]{.code} statement bypasses the remainder of a loop body,
and jumps directly to the start of the next iteration of the loop.

::: syntax
    continue [ label ]  ;
:::

If no label is specified, the [continue]{.code} implicitly refers to the
nearest enclosing [for]{.code}, [while]{.code}, or [do\...while]{.code}
loop.

If a label is specified, the label must be associated with an enclosing
[for]{.code}, [foreach]{.code}, [while]{.code}, or [do]{.code}
statement. The target statement of the [continue]{.code} is the labeled
loop in this case.

Note that, in contrast to [break]{.code}, a [continue]{.code}
statement\'s label **must** be associated with a loop of some kind
([for]{.code}, [foreach]{.code}, [while]{.code}, or
[do\...while]{.code}).

[continue]{.code} transfers control to the \"next iteration\" of the
targeted loop statement. The exact point depends on the type of that
loop:

-   If it\'s a [for]{.code} loop, control transfers to the \"updater\"
    expression. That is, immediately after the [continue]{.code} is
    executed, the [for]{.code} evaluates its \"updater\" expression,
    then then evaluates its \"condition\" expression and uses the result
    to determine whether or not to perform another iteration of the loop
    body.
-   If it\'s a [foreach]{.code} loop, the next element of the Collection
    is fetched into the iteration variable, and control is transferred
    back to the top of the loop body (unless the Collection has been
    exhausted, in which case the loop terminates as normal).
-   If it\'s a [while]{.code} or [do]{.code}\...[while]{.code} loop,
    control transfers to the condition evaluation. That is, immediately
    after the [continue]{.code} statement, the loop evaluates its
    condition expression, and uses the result to determine whether or
    not to perform another iteration of the loop body.

Here\'s an example:

::: code
    for (local i = 0 ; i < 10 ; ++i)
    {
      "i = <<i>>\n";
      if (i < 5)
        continue;

      "*** i is at least 5!\n";
    }
:::

### [throw]{#throw}

The [throw]{.code} statement \"throws an exception.\" That is, given an
Exception object, the statement transfers control to the nearest
enclosing [catch]{.code} handler for that class of Exception.

::: syntax
    throw expression ;
:::

The [expression]{.synPar} is most often of the form [new E()]{.code},
where [E]{.code} is some Exception subclass. However, any expression
that yields an Exception instance is valid here, and it\'s frequently
useful to use [throw]{.code} with a local variable that contains a
previously caught Exception instance, or simply a static Exception
instance.

Refer to the section on [exception handling](except.htm) for more
details on [try]{.code} and [throw]{.code}.

### [try]{#try}

The [try]{.code} statement sets up an exception handler for the duration
of the enclosed block of code, which is referred to as the code
\"protected\" by the [try]{.code}. This allows you to catch and handle
selected exceptions that are thrown from within the protected code, or
from any code that it calls via function and method calls.

::: syntax
    try
    {
      protectedCode
    }
    catch ( exceptionClass exceptionLocal )
    {
      handlerCode
    }
    catch ( exceptionClass exceptionLocal )
    {
      handlerCode
    }
    finally
    {
      finallyCode
    }
:::

The [protectedCode]{.synPar} consists of any number of statements. This
is the code that the [try]{.code} protects: if a handled exception is
thrown from within this code or any other functions or methods it calls,
control is transfered to the first statement of the body of the first
[catch]{.code} clause whose [exceptionClass]{.synPar} equals or is a
superclass of the thrown exception.

A [try]{.code} can have zero or more [catch]{.code} clauses.

Within each [catch]{.code} clause, the [exceptionClass]{.synPar} is the
name of an Exception subclass, indicating which type of exception(s)
this clause handles. The [exceptionLocal]{.synPar} is a symbol that will
be defined as a new local variable, which is scoped to the
[catch]{.code} clause. (That is, the variable will be visible only
within that [catch]{.code} clause, and hides any variable of the same
name that\'s defined in any enclosing scope.) The [handlerCode]{.synPar}
is any number of statements; this block of code comprises the handler
for the specified exception.

The [finally]{.code} clause is optional. If it\'s present, only one is
allowed, and it must follow all of the [catch]{.code} clauses. The
[finallyCode]{.synPar} consists of any number of statements; this block
of code comprises the \"finally\" handler for the protected code.

When an exception occurs within the protected code, the VM searches the
[try]{.code} statement for a [catch]{.code} handler that \"matches\" the
exception actually thrown. A handler matches the thrown exception is the
exception equals the [exceptionClass]{.synPar} named in the handler, or
the thrown exception is a subclass of the named class. The VM searches
the [catch]{.code} clauses in order, starting at the first (top)
handler:

-   If the VM finds a matching [catch]{.code} handler, it stores a
    reference to the thrown exception in the [exceptionLocal]{.synPar}
    local variable named in that [catch]{.code} clause, then transfers
    control to the first statement of the [handlerCode]{.synPar} of that
    [catch]{.code} clause. At this point, the VM considers the exception
    completely handled.
-   If the VM fails to find a matching [catch]{.code} handler after
    searching all of the [catch]{.code} clauses, it \"re-throws\" the
    exception. This means that it looks for the next enclosing
    [try]{.code} block within the enclosing method, and failing that
    looks for the next enclosing block in the calling method, and that
    method\'s caller, and so on. Upon finding the enclosing
    [try]{.code}, the VM repeats the [catch]{.code} search with the new
    [try]{.code}.

The [finally]{.code} block, if specified, contains code that will be
executed when control transfers out of the protected [try]{.code} code,
*no matter how that transfer occurs.* Control can transfer out of the
protected [try]{.code} code due to:

-   A [goto]{.code} that targets a label outside of the protected code
-   A [break]{.code} that leaves the protected code
-   A [continue]{.code} that resumes a loop enclosing the protected code
-   A [return]{.code} from within the protected code
-   A [throw]{.code} from within the protected code
-   Simply \"falling off the end\" of the protected code

If a [catch]{.code} handler catches an exception thrown within the
protected code, the [finally]{.code} clause will *still* run - as
promised, it *always* runs when control exits the [try]{.code}, no
matter how. In this case, the [finally]{.code} clause will run when
control transfers *out* of the [catch]{.code} handler. Control can
transfer out of the [catch]{.code} handler in any of the ways listed
above for the main protected code; the [finally]{.code} will be invoked
at that time for any of those modes of egress.

For more details on [try]{.code} and [throw]{.code}, refer to the
section on [exception handling](except.htm).

## [Notes for TADS 2 users]{#tads2}

TADS 2 users should note some important syntax changes from the old
language:

-   The TADS 2 function definition syntax is no longer supported.
    Instead, TADS 3 uses a syntax that\'s much like Java\'s or C\'s.
    This makes the language more internally consistent.
-   Method definitions are also slightly different from TADS 2\'s
    syntax. In particular, the [=]{.code} (equals sign) that came
    between a method\'s parameter list and its body is no longer
    allowed. This makes method definitions look much more like they do
    in Java and C++.

TADS 3 lifts a number of restrictions that TADS 2 imposed. Some of the
more important ones:

-   In TADS 3, forward function declarations are never required. The
    compiler processes the entire program\'s source code before
    resolving symbols, so it looks ahead by itself and requires no
    explicit forward declarations.
-   TADS 3 lets you use empty parentheses to call a method that takes no
    parameters. This is exactly equivalent to calling the method with no
    argument list (that is, no parentheses) at all.
-   You can define local variables anywhere in a code block in TADS 3.
    That is, a [local]{.code} statement can go anywhere a regular
    executable statement can go. The TADS 2 restriction, that
    [local]{.code} statements could only go at the top of a code block,
    no longer applies.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Procedural Code\
[[*Prev:* Expressions and Operators](expr.htm){.nav}     [*Next:*
Optional Parameters](optparams.htm){.nav}     ]{.navnp}
:::
