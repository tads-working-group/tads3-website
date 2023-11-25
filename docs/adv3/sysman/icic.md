::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> IntrinsicClass\
[[*Prev:* HTTPServer](httpsrv.htm){.nav}     [*Next:*
Iterator](iter.htm){.nav}     ]{.navnp}
:::

::: main
# IntrinsicClass

Each intrinsic class that a program uses is represented by an instance
of the intrinsic class IntrinsicClass. If you didn\'t major in college
in computer science, don\'t worry if contemplating the circularity of
this notion induces a slight spinning sensation; the IntrinsicClass
intrinsic class has only a couple of practical applications, which are
pretty straightforward.

Each time you use the [intrinsic class]{.code} statement to define an
intrinsic class, the compiler implicitly creates an instance of
IntrinsicClass to represent the intrinsic class. (Actually, *you*
probably won\'t ever use the [intrinsic class]{.code} statement; you\'ll
probably just [#include]{.code} system header files that use it.) The
compiler gives this instance the same name as the class. For example,
consider the following statement:

::: code
    intrinsic class BigNumber 'bignumber' { }
:::

This defines an intrinsic class called BigNumber. It also creates an
object of intrinsic class IntrinsicClass, and calls the object
BigNumber.

## Using IntrinsicClass instances

IntrinsicClass objects exist simply to serve as identifiers for the
classes of the built-in object types, such as String, List, Vector,
LookupTable, and so on. There are two main situations where it\'s
important to have this kind of identifiers:

-   with the ofKind() method
-   with the getSuperclassList() method

## The ofKind() method

ofKind() returns [true]{.code} if the argument is the IntrinsicClass
object representing the intrinsic class of the first argument. For
example:

::: code
    local x = new BigNumber('100');
      
    tadsSay(x.ofKind(BigNumber) ? 'yes' : 'no'); "; ";
    tadsSay(x.ofKind(Dictionary) ? 'yes' : 'no'); "\n";
:::

This will display \"yes; no\", because the object is an instance of the
BigNumber intrinsic class, and is not an instance of the Dictionary
intrinsic class.

## The getSuperclassList() method

getSuperclassList() returns a list of the immediate superclasses of a
given object. If the object is an instance of an intrinsic class, the
list will have one element, which is the IntrinsicClass object
representing the intrinsic class. For example:

::: code
    x = new BigNumber('100');
    y = x.getSuperclassList();
:::

The value of [y]{.code} will be [\[BigNumber\]]{.code}.

Most intrinsic classes derive from an \"abstract\" intrinsic class
called Object, so, for example, [BigNumber.getSuperclassList()]{.code}
will return [\[Object\]]{.code}. Object itself has no superclass, so
[Object.getSuperclassList()]{.code} will return an empty list.

## IntrinsicClass methods

[isIntrinsicClass(*val*)]{.code}

::: fdef
Returns [true]{.code} if *val* is an IntrinsicClass object, [nil]{.code}
if not.

This is a class method, so you call this method directly on
IntrinsicClass itself:

::: code
    if (IntrinsicClass.isIntrinsicClass(x))
      "x is an intrinsic class instance!\n";
:::

At first glance, this method might seem redundant with [ofKind()]{.code}
and [getSuperclassList()]{.code}. It\'s not, though: those methods
don\'t let you determine if you\'re dealing with an IntrinsicClass
object, because they instead yield information about the *inheritance*
structure for the intrinsic types. IntrinsicClass is used only for the
*representation* of these objects, and isn\'t involved in the
inheritance structure.

For example, [\[1,2,3\].getSuperclassList()]{.code} yields
[\[List\]]{.code}, and [List.getSuperclassList()]{.code} yields
[\[Object\]]{.code}. Since [Object]{.code} is the root object,
[Object.getSuperclassList()]{.code} yields an empty list. In order for
the type system to be internally consistent, [ofKind()]{.code} must
report information that\'s consistent with [getSuperclassList()]{.code},
so [List.ofKind(IntrinsicClass)]{.code} must return [nil]{.code}:
IntrinsicClass isn\'t anywhere in [List]{.code}\'s superclass tree, so
[List]{.code} must not be of kind [IntrinsicClass]{.code}.

That\'s why [isIntrinsicClass()]{.code} is needed. It\'s occasionally
useful to know when you\'re dealing with an intrinsic class
representation object, and the normal means of class relationship
testing don\'t work for this test.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> IntrinsicClass\
[[*Prev:* HTTPServer](httpsrv.htm){.nav}     [*Next:*
Iterator](iter.htm){.nav}     ]{.navnp}
:::
:::
