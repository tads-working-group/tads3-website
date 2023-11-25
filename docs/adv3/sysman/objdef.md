::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Object Definitions\
[[*Prev:* The Object Inheritance Model](inherit.htm){.nav}     [*Next:*
Inline Objects](inlineobj.htm){.nav}     ]{.navnp}
:::

::: main
# Object Definitions

Objects are the main data structures in a TADS program.

An object is a collection of values, called properties, and functions,
called methods. Each property and each method has a property name, which
is a symbol that you can use to refer to that property or method.

An object also has one or more superclasses, also known as base classes.
An object with a given superclass is said to be a subclass of the
superclass. In object-oriented programming in general, classes are used
to create a taxonomy of the various types of things that the program
works with; a superclass corresponds to a more general category in the
taxonomy, and a subclass is a specialization of its superclass. For
example, if we were creating a taxonomy for furniture, we might have a
general base class called Furniture, a specialized subclass of Furniture
called Chair, and an even more specialized subclass of Chair called
Recliner. In TADS, this relationship between a generalized superclass
and its specialized subclass is expressed through property inheritance.
A TADS object inherits all of the properties and methods of its
superclasses, as though the object defined them itself; but by the same
token, any property or method that the object actually does define
itself overrides the inherited version. So when you define a subclass,
the subclass is automatically just like its superclass (so a Chair
starts off behaving just like any other piece of Furniture), but can
also define its own specializations (overriding properties) that define
the ways it differs from the base class. Inheritance means that you
don\'t have to define the same basic features common to every piece of
furniture in every subclass, since they all inherit the basic
definitions from the base class; you only have to define the special
features that work differently in each subclass.

An object can be either static or dynamic. A static object is one
that\'s defined directly in your program\'s source code; it exists
throughout execution of the program. A dynamic object is one that\'s
created on the fly while the program runs, using the [new]{.code}
operator. A dynamic object it comes into existence when the [new]{.code}
expression is executed, and exists only as long as it\'s reachable,
meaning that an active local variable or a property of another object
contains a reference to the object. Once a dynamic object is no longer
referenced anywhere, TADS automatically deletes the object (through a
process called [garbage collection](gc.htm)).

Most TADS programs define lots of static objects, for things like rooms
and the items found within the game world. An object doesn\'t
necessarily have to represent a particular item in the game world,
though; objects can also be used for components of items, or for
abstract programming entities.

## Basic object definition syntax

The most general way to define an object is like this:

::: syntax
    objectName : class1 [ , class2 ... ] 
       propName = value
       methodName ( arg1 [ , arg2 ... ]  ) { methodBody }
    ;
:::

The first line names the object, and defines its superclass list. An
object must always have at least one superclass, but you can use the
special class name \"object\" if you want a generic object that is not
based on another object that your program defines. Note, however, that
if you use \"object\" as the superclass, it must be the only superclass.

If you specify more than one superclass, the order of the classes
determines the inheritance order. The first (left-most) superclass has
precedence for inheritance, so any properties or methods that it defines
effectively override the same properties and methods defined in
subsequent superclasses.

Alternatively, you can write the same thing in a slightly different way,
by enclosing the list of properties in braces:

::: syntax
    objectName : class1 [ , class2 ... ] 
    {
       propName = value
       methodName ( arg1 [ , arg2 ... ]  ) { methodBody }
    }
:::

When you use this alternative syntax, you must place the entire property
list within the braces. A semicolon is not required at the end of the
object definition using this syntax, because the closing brace
unambiguously ends the definition. (It\'s legal to add a semicolon after
the closing brace, though, because a semicolon by itself is always
acceptable as an empty top-level statement.) You may optionally place a
semicolon after each property definition; the compiler simply ignores
any such semicolons, because it knows the property list doesn\'t end
until the closing brace.

The two object definition formats - with braces or without - are
identical in meaning; they differ only in appearance. You can use either
format for any object; the compiler automatically recognizes which form
you\'re using for each object.

The language allows the two formats purely for your convenience. Because
of the wide range of objects and classes that adventure game programs
tend to define, many objects tend to look better in one format or the
other. Some authors might find that small objects composed mostly of
data look less cluttered and more compact without the braces, while
larger objects with lots of code benefit from the more visually
structured appearance of the brace format. Other authors might simply
prefer the brace format in all cases because it\'s similar to Java and
C++ notation.

## Replacing and modifying objects

When you\'re using a library in your program, it\'s often useful to be
able to replace an object defined in the library with a definition of
your own. For example, the library might provide a default
implementation for an object that you want to replace with a custom
version, or you might simply want to replace that part of the library\'s
functionality with a different approach entirely.

You can replace an object or class using the [replace]{.code} keyword.
You put this keyword immediately before your new object definition; the
object definition is otherwise the same as a normal object definition.
For example:

::: code
    replace class LibClass: object
       prop1 = 10
    ;
:::

[replace]{.code} effectively deletes the original object and replaces it
with your new definition. You can change everything about the object,
including its superclasses.

While [replace]{.code} is useful, it\'s even more frequently the case
that you want to supplement a library class or object, instead of
replacing it. For example, you might want to add some new methods to the
library class, or you might want to override one or two of the existing
methods with new versions. For this, you use the [modify]{.code}
keyword. Unlike [replace]{.code}, the [modify]{.code} keyword doesn\'t
let you change the superclass list: the modified object will have the
same superclasses as the original. So, when you use [modify]{.code}, you
don\'t include a new superclass list in the definition; instead, you
jump directly to the properties and methods that you wish to override.

::: code
    modify LibClass
      test(x) { return x*2; }
    ;
:::

When you use [modify]{.code}, the compiler doesn\'t delete the original
object. Instead, it takes the symbol name away from the original, and
gives it to your new object instead. The old object is kept around
exactly as it was, but without its name. Your new object is set up so
that it\'s a subclass of the original (now nameless) object. This means
that you can use [inherited]{.code} to inherit the original library
implementation of any method you override:

::: code
    modify LibClass
      test(x) { return inherited(x) * 2; }
    ;
:::

In some cases, you might not want this inheritance behavior: you might
want instead to replace the original class\'s method rather than just
overriding it, so that you can inherit directly from the original
class\'s superclass. For these situations, you can use the
[replace]{.code} keyword on the *method* definition in the modifier
object:

::: code
    modify LibClass
      replace test(x) { return inherited(x) * 2; }
    ;
:::

The difference between this example and the previous one is that the
[inherited(x)]{.code} in the first example invokes the original LibClass
version of the [test()]{.code} method, whereas the [inherited(x)]{.code}
in the second version invokes the version that the original LibClass
itself inherited from its superclass.

The **order** of [modify]{.code} and [replace]{.code} definitions is
important. This is because you can repeatedly modify or replace the same
object - you can apply a [modify]{.code} to an object that\'s already
been modified, and then apply yet another [modify]{.code} to the same
object later, as many times as you want. So the only way that the
compiler can sort out which version is the \"final\" version of the
object is to put the [modify]{.code} and [replace]{.code} definitions in
some kind of well-defined order.

The order that the compiler uses to apply [modify]{.code} and
[replace]{.code} definitions is simply the order in which the
definitions appear in the source code. Within a single file, each
[modify]{.code} affects the nearest previous definition of the same
object within the file. You can also modify and replace objects defined
in other files, in which case the order of the operations is determined
by the order of the modules in the project (.t3m) file list.

An important consequence of the ordering rule is that a [modify]{.code}
or [replace]{.code} can never precede the base definition of the object
being modified. The compiler will display an error if it encounters a
[modify]{.code} or [replace]{.code} before the base definition of the
object.

## Property sets

In some situations, you\'ll need to define a group of related properties
and methods that share some common root name, and possibly some common
parameters as well. This situation sometimes occurs, for example, when
you\'re using a library that defines a naming convention for the methods
that your code provides to handle the individual processing steps for an
event: all of the methods pertain to different phases of the same event,
so the library gives all of the methods a common portion to their names
to help make it clear that they\'re related.

The compiler provides a short-hand syntax that makes it easier to define
sets of properties with related names. The propertyset keyword
introduces a group of property definitions, and specifies a pattern
string that defines the naming convention. A propertyset pattern string
looks like a regular symbol name enclosed in single quotes, except that
it contains a single asterisk (\"\*\"), which specifies where the
non-common part of the name goes. Everything else in the string is the
common part of the names of the properties in the set.

For example, suppose you\'re using a library that defines a set of
method calls that process mouse clicks. All of the mouse click methods
have a common root name of \"onMouse,\" but then add a suffix for the
individual method: onMouseDown, onMouseMove, onMouseUp. For this set of
names, the pattern string would be \'onMouse\*\' - the asterisk at the
end tells the compiler that the only part that differs from one property
to another is at the end of the string.

After the propertyset keyword and the pattern string, you place a set of
otherwise normal property definitions, enclosed in a set of braces to
mark the bounds of the set. So, the general syntax for a property set
is:

::: syntax
    propertyset 'pattern'
    {
       propertyList
    }
:::

Optionally, you can include a parameter list after the pattern. The
parameter list is a set of common formal parameters that each method in
the set will have, in addition to any parameters the individual methods
define. Like the name pattern, the parameter list uses an asterisk
(\"\*\") to indicate where the added parameters of each method go in the
list.

::: syntax
    propertyset 'pattern' ( params, *, params )  { propertyList }
:::

This all goes within an object definition - you can put a property set
anywhere a single property could go, and property sets can be
intermingled with regular property definitions (so regular properties
can come before and after a property set).

Here\'s an example, using the mouse events we proposed above:

::: code
    class myWindow: myWidget
      x = 0
      y = 0
      width = 0
      height = 0
      propertyset 'onMouse*'
      {
        Down(x, y, clicks) { ... }
        Move(x, y) { ... }
        Up(x, y) { ... }
      }
    ;
:::

The property set syntax is essentially a textual substitution facility,
in that the compiler actually translates the properties within the
property set to their full names based no the pattern string. So, the
definition of Down in the example above is exactly the same as though it
had been made outside of the property set with a name of onMouseDown.

Property sets can also specify common parameters to the methods defined
within. In the example above, each method has the same first two
parameters, x and y, so we can further reduce the amount of typing by
putting these common parameters in the propertyset definition:

::: code
    propertyset 'onMouse*' (x, y, *)
    {
       Down(clicks) { ... }
       Move { ... }
       Up { ... }
    }
:::

The propertyset definition specifies that every item defined within has
x and y as the first two parameters, and that any additional parameters
go after the two common parameters. So, the line that reads
\"Down(clicks)\" actually defines \"onMouseDown(x, y, clicks)\" after
the propertyset definition is expanded.

You can put a propertyset definition inside another propertyset
definition. Note, though, that the fully-expanded property names within
a propertyset must be legal symbol names - in particular, they must fit
within the 40-character limit for a TADS identifier.

## Static property initialization

Most property initializations contain simple compile-time constants,
such as numbers or strings. However, it is sometimes useful to be able
to initialize a property to a value that isn\'t a constant, but which
you want computed once and stored. For example, you might want to use
the \"new\" operator to create an object and store a reference to it in
a property, but you want to do this just once when the program starts
running. These types of initializations are called \"static,\" because
they don\'t change after the program starts running.

The language provides a simple way to specify non-constant static
initializations. In a property definition, place the keyword \"static\"
just before the value to be computed:

::: code
    desk: object
       topSurface = static new Surface()
    ;
:::

You can place any expression after the \"static\" keyword.

The compiler evaluates all of the static initializer expressions just
before running [pre-initialization](libpre.htm). The compiler evaluates
each static initializer just once, and stores the result value in the
property. When the property is evaluated at run-time, the expression is
not re-evaluated - the whole point is that the value is computed once
and stored.

Note that static initializers only run when pre-initialization runs. So,
if you compile your program for debugging, the compiler won\'t execute
the static initializers, but will leave them for evaluation at the start
of normal execution.

The order in which the compiler executes the static initializers is
arbitrary; however, where there are dependencies among static
initializers, the compiler automatically performs the initializations in
the order required to resolve the dependencies correctly.

For the technically inclined, the technique the compiler uses to resolve
dependency ordering correctly is fairly simple. The compiler effectively
re-writes each static initializer like so:

::: code
    prop = { self.prop = expr; return self.prop; }
:::

So, if the expression references another property with a static
initializer, it doesn\'t matter whether or not that initializer has been
executed yet. If it has, evaluating the property simply retrieves the
value that was already computed and stored in the property. If it
hasn\'t, though, evaluating the property not only evaluates the static
initializer expression, but stores the resulting value in the property;
so, when the compiler does get around to invoking that other static
initializer, it finds the property has already been initialized, so the
extra invocation has no effect.

You might note that static initializers are purely a syntactic
convenience, since you can do anything a static initializer can do using
the more general pre-initialization mechanism instead. However, there is
one practical difference worth noting: the code that is generated to
execute the expression of a static initializer is not included in the
image file. The compiler knows that a static initializer expression is
only needed during the compilation phase, so it can eliminate the code
generated for the expression when producing the image file. The compiler
can\'t make the same assumption about pre-initialization code, since the
same code could be invoked again during normal execution.

## Anonymous objects

In many cases, you will not have any need to give an object a name when
you define it. The compiler accommodates these cases with the
\"anonymous object\" syntax.

To define an object with no name, simply start the definition with the
class list. Everything else about the object definition is the same as
for a named object. For example:

::: code
    Item sdesc = "red box" ;
    Readable { sdesc = "book" }
:::

Because an anonymous object doesn\'t have a symbol that you can use to
refer to the object, you must use some other mechanism to manipulate the
object. For example, you can use the firstObj() and nextObj() functions,
since iterations with these functions include anonymous objects.

## Nested objects

In addition to defining regular properties and methods, you can define a
property as a \"nested\" object. This syntax allows you to define one
object within another, and at the same time initialize a property of the
outer object to refer to the inner object. For example:

::: code
    bottomOfStairs: Room
       name = "Bottom of Stairs"
       desc = "This dark, narrow chamber is just large enough
               to enclose the rusted iron staircase that spirals upwards,
               its top lost in the dusty murk above."
       up: MsgConnector
       {
          desc = "You force yourself to climb the hundreds of stairs..."
          destination = topOfStairs
       }
    ;
:::

This example defines, in addition to the object bottomOfStairs, a
separate object of class MsgConnector whose properties desc and
destination are initialized as shown. The MsgConnector instance has no
name, but evaluating bottomOfStairs.up will yield a reference to the
object.

Whatever it looks like, bottomOfStairs.up is a perfectly normal
property - it\'s not the name of an object, but is simply a property
that contains a reference to an object.

The example above is almost the same as this:

::: code
    bottomOfStairs: Room
       name = "Bottom of Stairs"
       desc = "This dark, narrow chamber is just large enough
               to enclose the rusted iron staircase that spirals upwards,
               its top lost in the dusty murk above."
       up = connector123
    ;

    connector123: MsgConnector
       desc = "You force yourself to climb the hundreds of stairs..."
       destination = topOfStairs
    ;
:::

The only difference between the first example and the second is that the
MsgConnector object in the second example has a name (\"connector123\"),
whereas the MsgConnector the first example is anonymous. Otherwise, the
two examples are equivalent.

The nested object syntax is purely a convenience feature. You can always
write an equivalent set of object definitions without using any nesting,
simply by defining each nested object as a separate, named object.
Nesting is sometimes a more compact notation, though, and is especially
useful when defining small \"helper\" objects.

Note that the nested object\'s property list must be enclosed in braces.
You can use template properties in a nested object; these may appear
immediately before or immediately after the object\'s opening brace,
just as in a regular object definition.

### Finding the enclosing object

The compiler automatically defines the property lexicalParent in each
nested object as a reference to the lexically enclosing object. For
example, consider the following object definition:

::: code
    outer: object
       desc = "This is 'outer'"
       inner: object
       {
         desc = "This is 'inner' - enclosing: <<lexicalParent.desc>>"
       }
    ;
:::

If we evaluate outer.inner.desc, we\'ll see the following displayed:

::: code
    This is 'inner' - enclosing: This is 'outer'
:::

Note that lexicalParent is defined as a property of each nested object.
This makes it possible for a class specifically designed for
instantiation as nested objects to determine the lexically enclosing
object for each of its instances.

## Inline objects

The static object definitions we\'ve seen so all go outside of any
function or method code. You can also define objects directly within
expressions, using the [inline object](inlineobj.htm) syntax. Inline
objects are especially useful when you need to create a small ad hoc
object to serve as an argument to a function.

## Class definition syntax

You can define a class instead of an object by adding the keyword
\"class\" before the object name:

::: syntax
    class className : superclass1 [ , superclass2 ... ] 
        propertiesAndMethods
    ;
:::

A class definition is otherwise syntactically identical to an ordinary
object definition. In particular, you can define properties and methods
for the class just like you can for an object.

Classes behave very much like objects, with a few important differences:

-   Classes are not included by default in iterations using the
    firstObj() and nextObj() functions in the [tads-gen intrinsic
    function set](tadsgen.htm). (You can, however, use flags to indicate
    that you want *only* classes instead of objects, or that you want
    *both* classes *and* ordinary objects.)
-   The compiler does not include classes when building dictionary
    entries based on vocabulary property definitions.
-   The compiler doesn\'t count classes in the [+]{.code} location
    hierarchy. This means that you can freely define new classes in the
    midst of a hierarchy of objects defined with the [+]{.code} syntax,
    without breaking up the location hierarchy. The compiler knows to
    leave [class]{.code} objects out of the [+]{.code} depth counting.

You can tell at run-time whether a given object is a class or a regular
object by calling the object\'s [isClass()]{.code} method.

## Contained objects

Most TADS games have some sort of \"containment\" model that relates
objects to one another in a location hierarchy. In these models, each
object has a container, and containers may in turn be inside other
containers.

The TADS 3 compiler can keep track of a simple containment hierarchy
that gives each object a single container. This is an optional feature,
so games that use more complex containment models than the compiler
provides do not have to use this feature; however, games that use a
single-container location model can take advantage of the compiler\'s
location tracking mechanism to simplify object definitions.

To use the compiler\'s location tracking, you must first tell the
compiler which property you are using to specify an object\'s container.
This is called the \"+ property\" or \"plus property,\" because the
object syntax for a contained object uses plus signs. To define the plus
property, use this statement:

::: code
    + property locationProp ;
:::

This statement must occur as a top-level statement, outside of any
object or function definitions, and must precede any objects that make
use of the containment syntax. If you are using this feature, you should
put this statement at the start of your source files. This statement has
compilation unit scope, so you\'ll have to put a copy of this statement
at the top of each source file if you\'re using separate compilation.
(If you\'re using the adv3 library, note that the standard library
header \"adv3.h\" includes a definition like this for you.)

Once you specify the plus property, you can define objects using the
\"+\" notation: before each object definition, you can insert one or
more plus signs to indicate that the object\'s location in the
containment tree. An object with no \"+\" signs has no implicit
container; an object with one \"+\" sign is implicitly contained by the
most recent object with no \"+\" signs; an object with two \"+\" signs
is implicitly contained by the most recent object with one \"+\" sign;
and so on.

The inner workings of the \"+\" property are simple: whenever you use
one or more \"+\" signs to define an object, the compiler automatically
initializes that object\'s \"+\" property to the implied container.

For example:

::: code
    // define the '+' property
    // (we need this only once per source file)
    + property location;

    iceCave: Room
       sdesc = "Ice Cave"
    ;

    + nastyKnife: Item
       sdesc = "nasty knife"
    ;

    + rustyKnife: Item
       sdesc = "rusty knife"
    ;
:::

We start by specifying that \"location\" is the \"+\" property. We then
define the object iceCave with no \"+\" signs, which specifies no
implicit setting for its location property. Next, we define the object
nastyKnife using one \"+\" sign: this indicates that nastyKnife.location
is initialized to iceCave, because iceCave is the most recent object
defined with no \"+\" signs. Finally, we defined rustyKnife with one
\"+\" sign; again, this object\'s location is initialized to iceCave,
because it\'s still the last object with no \"+\" signs.

You can use the \"+\" syntax to any depth. Here\'s an example with
several levels of containers:

::: code
    + property location;

    office: Room
       sdesc = "Office"
    ;

    + desk: Surface
       sdesc = "desk"
    ;

    ++ fileBox: Container
       sdesc = "file box"
    ;

    +++ greenFile: Container
       sdesc = "green file folder"
    ;

    ++++ letter: Readable
       sdesc = "letter"
    ;

    ++++ memo: Readable
       sdesc = "memo"
    ;

    +++ redFile: Container
       sdesc = "red file folder"
    ;

    ++ pen: Item
       sdesc = "pen"
    ;

    + chair: Chair
       sdesc = "chair"
    ;
:::

The desk and chair are located directly in the office, the file box and
pen are on the desk, the green and red files are in the file box, and
the letter and memo are in the green file. Each object except office has
a location property set to its container.

### Anonymous contained objects

You can combine the anonymous object syntax and the contained object
syntax for an especially concise way of defining objects. We could
rewrite the example above much more compactly:

::: code
    office: Room
       sdesc = "Office"
    ;

    + Surface sdesc = "desk" ;

    ++ Container sdesc = "file box" ;

    +++ Container sdesc = "green file folder" ;
    ++++ Readable sdesc = "letter" ;
    ++++ Readable sdesc = "memo" ;

    +++ Container sdesc = "red file folder" ;

    ++ Item sdesc = "pen" ;

    + Chair sdesc = "chair" ;
:::

## sourceTextOrder

The compiler automatically adds the property sourceTextOrder to each
non-class object, and sets the property to an integer giving the
relative order of the object definition in its source file. The
sourceTextOrder value is guaranteed to increase monotonically throughout
a source file.

This property is useful because it lets you reliably determine the order
of objects in a source file. There\'s no other way to do this; for
example, you can\'t count on object loops, using firstObj() and
nextObj(), to iterate over the game\'s objects in any particular order.
It\'s often useful to be able to construct a run-time data structure
(such as a list or a tree) so that the objects appear in the same order
as they did in the source file, and sourceTextOrder is the way to do
this.

The sourceTextOrder value is only useful for determining the relative
order of objects in a single source module. The compiler resets the
counter at the start of each new source file, so it\'s not meaningful to
compare this property for objects defined in different modules.

## [sourceTextGroup]{#sourceTextGroup}

The compiler can optionally add another property to each object that
gives you information on which module defined the object. If you compile
with the \"-Gstg\" option, *or* use the directive
`#pragma sourceTextGroup(on)`, the compiler adds the property
sourceTextGroup to each non-class object, and sets the property to refer
to an anonymous object. One such anonymous object is created per source
module, so you can tell that two objects were defined in the same source
module when the two objects have the same sourceTextGroup value.

The anonymous object itself has two properties, which the compiler
automatically sets when creating the object. The first is
sourceTextGroupName: this is set to a string giving the name of the
defining module, as it appeared in the compiler command line, makefile
(.t3m), or library (.tl) file. The second is sourceTextGroupOrder: this
is an integer giving the relative order of the defining module among all
of the modules in the overall program.

You can use sourceTextGroup in conjunction with sourceTextOrder to
establish the order of source-file appearance for objects throughout the
entire program. For a given object x,
x.sourceTextGroup.sourceTextGroupOrder gives you the position of the
defining module among all of the modules making up the program;
x.sourceTextOrder then gives you the relative order of x within its own
source module.

## Object templates

In addition to the generic property list syntax, the TADS compiler
provides an alternative property definition syntax using object
templates. (These have nothing to do with what C++ calls templates,
which are parameterized types.) An object template lets you define an
object\'s properties positionally, rather than by naming each property
explicitly in the object definition. Templates provide a concise syntax
for defining properties that you use frequently.

To define objects using templates, you must first define the templates
themselves. You define a template using the object template statement:

::: syntax
    objectName template [ item1 [ , item2 ... ]  ]  ;
:::

You can also define a template that is specific to instances of a class
and all of its subclasses (including subclasses of subclasses, to any
depth):

::: syntax
    className template [ item1 [ , item2 ... ]  ]  ;
:::

Each item in the list is a placeholder for a property; it specifies the
name of the property to assign to the position, and how you will write
the property value. Each item in a template can be written in one of
these formats:

-   As a single-quoted string
-   As a double-quoted string
-   As a list
-   As an operator character followed by a value, where the operator is
    one of these: + - \* / % -\> & ! \~ ,
-   The inherited keyword

Each item is written as an example of how you will supply the item\'s
value in each object, with the item\'s property name taking the place of
the actual value. For a single-quoted string, write the property name in
single quotes; for a double-quoted string, write the property name in
double quotes; for a list, write the property name in square brackets;
and when you use an operator, write the operator and then the property
name.

An item can be made optional by adding a question mark (\"?\")
immediately after the item. When the template definition is matched to
an object definition, the compiler will allow an optional item to be
omitted. The \"?\" symbol applies only to the immediately preceding
item; there\'s no grouping syntax that would allow a single \"?\" to
apply to multiple items. If you want to make multiple items optional,
you must put a question mark after each optional item.

Two or more alternatives can be given for a single item by separating
the alternatives with the vertical bar (\"\|\") symbol. Exactly one of
the alternative template items will be matched to an object definition.
The \"\|\" symbol applies only to the directly adjacent items; there\'s
no syntax for grouping alternatives involving multiple items. A group of
alternatives can be optional, but only as a group: if any item in an
alternative group is marked as optional, then the entire group is
optional.

If one of the items in the template list is the keyword inherited, it
indicates that the template \"inherits\" the templates of its
superclasses, and that the superclass items are to appear at the same
point in the template as the inherited keyword. The effect is exactly
the same as if you had defined a set of templates with each superclass
template substituted for the inherited keyword in the new template, plus
one extra definition with nothing substituted for inherited. To
illustrate, suppose that you make the following definitions:

::: code
    class A: object;
    class B: A;

    A template 'name';
    A template 'name' "desc";
    B template 'author' inherited;
:::

The last template, for class B, is identical to defining each possible
inherited template explicitly. In other words, you could replace the
last line above with the following:

::: code
    B template 'author';
    B template 'author' 'name';
    B template 'author' 'name' "desc";
:::

The inherited keyword can appear at any point in the item list;
superclass template items are substituted at the point at which
inherited appears. This provides flexibility so that you can inherit the
items from the superclass templates at the beginning, end, or in the
middle of the new template\'s item list.

### Template examples

As an example of using templates, here\'s a template definition that
specifies three properties: the first is the location, which is marked
with an \"at\" sign; the second is the short description in double
quotes; and the third is the long description in double quotes.

::: code
    object template @location "sdesc" "ldesc";
:::

Once you define a template, you can use it in object definitions. To use
a template, simply put the data definitions for the template\'s items
before the object definition\'s normal property list, immediately after
the object\'s class list. For example, to use the template above, we
could write this:

::: code
    poemBook: Book @schoolDesk "poem book" 
       "It's a book of poems. "
       readPoem(num)
       {
          if (num == 1) ; // etc
       }
       poem1 = "The first poem is by someone named Wadswurth. "
    ;
:::

Note that you don\'t have to put any properties after the template data
for the object, but if you do, you define them using exactly the same
syntax that you use for a non-template object.

Here\'s an example of a template with an optional item:

::: code
    Thing template 'name' "desc"? ;

    cardTable: Thing 'card table';
    lamp: Thing 'lamp' "It's a fairly ordinary desk lamp. ";
:::

The single template matches both object definitions, because the
\"desc\" item can be omitted or included as desired.

An example using alternation:

::: code
    Message template 'name' "messageText" | [messageList];

    Message 'one' "This is message one.";
    Message 'two' ['Message 2a.', 'Message 2b.', 'Message 2c.'];
:::

In this example, the second item in the template can either be a
double-quoted string, or it can be a list. (The contents of the list
don\'t matter to the template.)

### How the compiler selects templates

Templates don\'t have names. The compiler figures out which template you
want to use purely based on the superclass and on types of the values in
the object definition. For the Book example above, the compiler sees
that you want to use template data consisting of a value with the \"@\"
symbol followed by two double-quoted strings; the compiler scans its
list of templates and comes up with the template we defined earlier.
This means that you must take care not to define two identical
templates, because the compiler will not be able to tell them apart. If
you do define identical templates, then the compiler will \"break the
tie\" by using the one defined earliest in the source file.

Note that using optional and alternative items can sometimes create
duplicate templates that aren\'t obviously duplicates. For example,
consider these templates:

::: code
    Thing template 'vocab' 'name'?;
    Thing template 'vocab' 'name' 'desc'?;

    Thing 'book' 'It\'s a dusty old tome. ';
:::

In this case, it\'s pretty clear to a human reader that the object
definition meant to use the second template - but the compiler will pick
the first, because it matches just as well and it occurs earlier in the
source file.

Another situation where templates can be ambiguous in form is multiple
inheritance. For example:

::: code
    A template 'name';
    B template 'desc';

    myObj: B, A 'this is myObj!';
:::

In this case, the object inherits a matching template from each of its
superclasses. In this case, though, the compiler has a better way of
choosing among the templates than just using the source file order: it
uses the superclass inheritance order. So, even though A\'s template is
defined before B\'s, the fact that myObj inherits from B first, then
from A, means that B\'s template is chosen over A\'s. So in this case,
myObj.desc is the property that\'s set to the string \'this is myObj!\'.

### Template inheritance

You can use template inheritance to include superclass templates as
continuations of templates for more specialized classes. For example,
suppose we wanted to define a couple of basic templates for our Thing
class, like so:

::: code
    Thing template 'name';
    Thing template 'name' "desc";
:::

These two templates allow us to define any Thing instance with a name,
and optionally with a description. Now, suppose we define Book as a
subclass of Thing, and we want to allow Book instances to define an
additional property giving the author of the book. Since Book is a
Thing, we still want each Book to be able to define the basic Thing
properties. The obvious way to do this would be to create a template for
Book with only the author property, plus another with the author and
name, and another with the author, name, and description:

::: code
    Book template 'author';
    Book template 'author' 'name';
    Book template 'author' 'name' "desc";
:::

If we had more than two Thing templates, though, this would become
tedious. It would also create a maintenance problem: if we ever wanted
to add more Thing templates or change the existing Thing templates,
we\'d have to remember to make the corresponding changes to the Book
templates as well.

Fortunately, the compiler offers a better way to define the extended
Book templates: template inheritance. If you want a template for a
subclass - Book, in this case - to include the templates of its
superclasses in addition to its own templates, you can simply add the
inherited keyword at the point in the template where you want the
inherited templates to go.

For our Book template, we\'d use template inheritance like so:

::: code
    Book template 'author' inherited;
:::

This single statement is exactly equivalent to the three we gave
earlier, but it\'s obviously a lot less work to type this definition,
and the definition automatically adjusts to any changes you make to the
Thing templates.

### Templates and object definition syntax variations

If you use braces around your property list, you can put the template
properties either immediately before or immediately after the open
brace:

::: code
    // template properties can go outside the braces...
    book1: Book @shelf "red book"
    {
       ldesc = "It's a red book."
    }

    // ...or immediately after an open brace
    book2: Book
    {
       @shelf "blue book"
       ldesc = "It's a blue book."
    }
:::

You can use templates with anonymous objects, as well as with objects
that use the \"+\" containment specification syntax:

::: code
    + Container "back-pack" "It's a green back-pack. " ;
    ++ Item "puzzle cube" "You haven't seen one of these in year. ";
:::

### Scope and placement of template definitions

The scope of a template is limited to a single compilation unit. If you
are separating your program into several source files, each file must
separately define the templates it uses. The easiest way to define
templates in several files is to put the \"object template\" statements
into a header file, and then include the header in each file; this way,
you only have to write the templates once, and if you modify them later,
you only need to make changes in one place.

Object template statements must appear as top-level statements, outside
of any function or object definitions. A template can only be used after
it has been defined, so you should normally define your templates near
the start of each source file. Typically, games and libraries should
define the templates they use in a header file so that all source
modules can include the same template definitions.

### Templates and dictionary properties

You cannot use a [dictionary property](dict.htm) in an object template.
Dictionary properties are excluded because of the special syntax they
use (a dictionary property can have its value set to a list of
single-quoted strings, without any grouping brackets for the list). If
you could use a dictionary property in a template, it would be possible
to create ambiguous templates, because the compiler might not be able to
tell if a single-quoted string were meant to be another entry in the
same property list or a separate property in the template.
[]{#transient}

## Persistent and transient objects

The T3 VM has a built-in subsystem that can save a snapshot of the state
of all of the objects in the system, and later restore the same set of
objects. This type of saving and restoring is referred to as
\"persistence,\" because it lets a set of objects outlive a particular
VM session; one could save a set of objects to a file on the computer\'s
hard disk, exit the program, turn off the computer, and return later -
even weeks or months later - and restore the state of the objects just
as they were when they were saved.

The VM provides two other mechanisms related to saving and restoring.
First, the VM is capable of \"restarting\" the program, which resets all
of the objects in the program to their initial state, as they were when
the program was initially loaded. Second, the VM can save multiple
in-memory snapshots of the program, called \"savepoints,\" and then roll
back changes since a snapshot; this is called the \"undo\" mechanism,
because it allows changes made since a given point in time to be
reversed.

Taken together, these four features - save, restore, undo, restart - are
called the \"persistence\" mechanisms of the T3 VM.

The persistence mechanisms are all completely automatic. To save the
current state, for example, the program simply calls a function
(saveGame(), in the [tads-gen function set](tadsgen.htm)), providing the
name of a file; the VM automatically creates a file with the given name
and writes the state of all of the objects in the system to the file. To
restore the same state later, the program calls another function
(restoreGame()), providing the name of the file previously saved.

In some cases, it is desirable to prevent an object from being saved,
restored, undone, or reset. For example, if an object is used to keep
track of some part of the user interface, you probably wouldn\'t want to
save and restore the object, because you wouldn\'t want the user
interface\'s state to be affected by a Restore operation. When an object
isn\'t part of the persistent state of the program, the object is called
\"transient.\"

Transient objects are extremely useful for certain tasks because they
\"survive\" the restore, undo, and restart operations. For example, if
you\'ve played the Infocom game *Planetfall*, you might remember that
Floyd the robot makes little remarks when you save a game or undo. You
could implement even more elaborate behavior of this kind by using a
transient object to keep track of how many times the player has
performed these operations. Since a transient object isn\'t overwritten
by a restore or undo, you can use it to keep track of the whole history
of the session. You could also use a transient object to keep track of
option settings that affect the overall session, so that the settings
aren\'t lost by being reset to the saved version if the user should
restore a saved game. Another use might be a session timer that
remembers how long the program has been running, irrespective of
restores and undos.

The terminology - \"transient\" and \"persistent\" - can be confusing
unless you have the right perspective. If you think in terms of the
running program, the terminology seems backwards: transient objects seem
more permanent than the persistent ones, because they survive operations
like Restore and Restart. Instead, think about persistence in terms of
saving data to a hard disk: persistent objects can be saved and
restored, but transient objects are fleeting, lasting only as long as
the VM is running.

By default, every object is persistent. This means that the VM
automatically saves, restores, resets, and undoes every object, unless
you specify otherwise.

To make an object transient, you use the \"transient\" keyword in TADS.
This keyword can be used in two different ways.

First, when you\'re defining an object directly in your source code, you
can preface the object definition with the \"transient\" keyword. The
object definition is otherwise exactly like any other. For example:

::: code
    transient mainOutputStream: OutputStream
       // etc
    ;
:::

Second, when you\'re creating an object dynamically, you can place the
\"transient\" keyword immediately after the \"new\" operator:

::: code
    local x = new transient Vector(10);
:::

In addition, the [TadsObject](tadsobj.htm) intrinsic class provides the
createTransientInstance() method to create a transient instance of a
class.

Note that transient objects won\'t be reset by the low-level
restartGame() function, but they will be affected by the regular
initialization steps if you\'re using the [default startup
code]{hef="startup.htm"}. The startup code doesn\'t pay any attention to
transient-ness when running the initialization steps - in particular, it
will execute InitObject and (if necessary) PreinitObject instances
regardless of whether they\'re persistent or transient.

Some intrinsic class types are inherently transient. For example, a
[[StackFrameDesc]{.code}](framedesc.htm) object is always transient. For
such objects you don\'t have to specify [new transient]{.code} when you
create them; they\'ll just be naturally transient because of the way
they\'re implemented within the system.

### Interactions between transient and persistent objects

For the most part, you don\'t have to worry about whether an object is
transient or persistent for ordinary use. The two kinds of objects work
the same way most of the time; the differences only appear during
restore, undo, and restart operations.

When you save a game, the system simply omits any transient objects from
the saved state. But what happens if you have a persistent object that
refers to a transient object through one of its properties? In this
case, the system simply saves a [nil]{.code} value for the property that
points to the transient object, because the transient object itself
isn\'t stored in the file. When you restore the game, the persistent
object will be restored, and the property that contained the transient
object reference will be [nil]{.code}.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Object Definitions\
[[*Prev:* The Object Inheritance Model](inherit.htm){.nav}     [*Next:*
Inline Objects](inlineobj.htm){.nav}     ]{.navnp}
:::
