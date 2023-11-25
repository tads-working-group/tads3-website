::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> Object\
[[*Prev:* LookupTable](lookup.htm){.nav}     [*Next:*
RexPattern](rexpat.htm){.nav}     ]{.navnp}
:::

::: main
# Object

Every object in a running program, including objects your program
defines via \"object\" and \"class\" definitions and instances of
intrinsic classes, ultimately derives from the intrinsic class Object.

You can never instantiate Object directly, since this is an \"abstract\"
class. However, since every object is a subclass of Object, every object
in the system inherits the methods defined by Object.

## Object methods

The Object class defines a number of methods. Since all objects are
subclasses of Object, all objects inherit these methods. Most of these
methods are related to the the relationships between objects and
classes.

[getSuperclassList()]{.code}

::: fdef
Returns a list containing the immediate superclasses of the object. The
list contains only the object\'s direct superclasses, which are the
superclasses that were explicitly listed in the object\'s declaration
for static objects, or the class used with the [new]{.code} operator for
dynamic objects. This function returns an empty list for an object with
no superclass. For an object with more than one direct superclass, the
list contains the superclasses in the same order in which they were
specified in the object\'s declaration.

For example, consider these definitions:

::: code
    class A: object;
    class B: object;
    class C: B;
    myObj: C, A;
:::

The result of [myObj.getSuperclassList()]{.code} will be the list [\[C,
A\]]{.code}. Note that class B is not included in the list, because it
is not a direct superclass of myObj, but is a superclass only indirectly
through class C.
:::

[getPropList()]{.code}

::: fdef
Returns a list of the properties directly defined by this object. Each
entry in the list is a property pointer value. The returned list
contains only properties directly defined by the object; inherited
properties are not included, but may be obtained by explicitly
traversing the superclass list and calling this method on each
superclass.
:::

[]{#getPropParams}

[getPropParams(*prop*)]{.code}

::: fdef
Returns information on the parameters taken by the given property or
method of this object. The return value is a list with three elements:

-   \[1\] is the minimum number of arguments taken by the method;
-   \[2\] is the number of additional optional arguments taken by the
    method;
-   \[3\] is true if the method accepts any number of additional
    arguments, [nil]{.code} if not.

The second element gives the number of optional arguments; only
intrinsic methods will ever yield a non-zero value for this element,
because regular methods cannot specify optional arguments. For example,
the [substring()]{.code} method of the String intrinsic class can take
either one or two arguments, so its return list is [\[1, 1,
nil\]]{.code}, indicating that the function takes a minimum of one
argument, can take one additional optional argument, but does not take
an unlimited varying argument list after those arguments.

If the third element is [true]{.code}, it indicates that the method was
defined with the \"\...\" varying argument list notation.

If the specified property is not defined for the object, the method
returns [\[0, 0, nil\]]{.code}, because it\'s valid to invoke the
property with no arguments in this case.
:::

[isClass()]{.code}

::: fdef
Returns [true]{.code} if the object was declared as a \"class\",
[nil]{.code} otherwise.
:::

[isTransient()]{.code}

::: fdef
Returns [true]{.code} if the object is transient, [nil]{.code}
otherwise. A transient object is one that was created with [new
transient]{.code} *[classname]{.code}*, or with a class-specific method
that creates transient instances (such as
[TadsObject.createTransientInstance()]{.code} or
[TadsObject.createTransientInstanceOf()]{.code}).
:::

[ofKind(*cls*)]{.code}

::: fdef
Determines if the object is an instance of the class *cls*, or an
instance of any subclass of *cls*. Returns [true]{.code} if so,
[nil]{.code} if not. This method always returns true if *cls* is Object,
since every object ultimately derives from the Object intrinsic class.
:::

[propDefined(*prop*, *flags*?)]{.code}

::: fdef
Determines if the object defines or inherits the property *prop* (a
property pointer value - specify this by applying an ampersand prefix
([&]{.code}) to a property name), according to the *flags* value. If
*flags* is not specified, a default value of [PropDefAny]{.code} is
used. The valid *flags* values are:

-   [PropDefAny]{.code} - the function returns [true]{.code} if the
    object defines or inherits the property.
-   [PropDefDirectly]{.code} - the function returns [true]{.code} only
    if the object directly defines the property; if it inherits the
    property from a superclass, the function returns [nil]{.code}.
-   [PropDefInherits]{.code} - the function returns [true]{.code} only
    if the object inherits the property from a superclass; if it defines
    the property directly, or doesn\'t define or inherit the property at
    all, the function returns [nil]{.code}.
-   [PropDefGetClass]{.code} - the function returns the superclass
    object from which the property is inherited, or this object if the
    object defines the property directly. If the object doesn\'t define
    or inherit the property, the function returns [nil]{.code}.
:::

[propInherited(*prop*, *origTargetObj*, *definingObj*, *flags*?)]{.code}

::: fdef
Determines if the object inherits the property *prop* (a property
pointer value). *origTargetObj* is the \"original target object,\" which
is the object on which the method was originally invoked; that is, it\'s
the object on the left-hand side of the [.]{.code} operator in the
expression that originally invoked the method. *definingObj* is the
\"defining object,\" which is the object defining the method which will
be inheriting the superclass implementation.

The return value depends on the value of the *flags* argument:

-   [PropDefAny]{.code} - the function returns [true]{.code} if the
    object inherits the property, [nil]{.code} otherwise.
-   [PropDefGetClass]{.code} - the function returns the class object
    from which the property is inherited, or [nil]{.code} if the
    property is not inherited.

This method is most useful for determining if the currently active
method will invoke an inherited version of the method if it uses the
inherited operator; this is done by passing [targetprop]{.code} for the
*prop* parameter, [targetobj]{.code} for the *origTargetObj* parameter,
and [definingobj]{.code} for the *definingObj* parameter. When a class
is designed as a \"mix in\" (which means that the class is designed to
be used with multiple inheritance as one of several base classes, and
adds some isolated functionality that is \"mixed\" with the
functionality of the other base classes), it sometimes useful to be able
to check to see if the method is inherited from any other base classes
involved in multiple inheritance. This method allows the caller to
determine exactly what inherited will do.

Note that the inheritance order is deterministic (i.e., it will always
be the same for a given situation), and that it depends on the full
class tree of the original target object. For example, suppose we have a
set of class definitions like this:

::: code
    class A: object  x() { "A.x\n"; inherited(); }
    class B: object  x() { "B.x\n"; inherited(); }

    class C: B, A    x() { "C.x\n"; inherited(); }
:::

Now suppose we run some code like so:

::: code
    new B().x();
    new C().x();
:::

The first line will simply display \"B.x\". B inherits directly from
TadsObject, so when B.x() calls [inherited()]{.code}, it will find no
definition of [x()]{.code} in any base class (since TadsObject doesn\'t
define it), so inherited() will do nothing.

The second line, however, will display this:

::: code
    C.x
    B.x
    A.x
:::

So, even though the call to [inherited()]{.code} in [B.x()]{.code} went
straight to TadsObject when [B.x()]{.code} was invoked from the first
line above, the same call to inherited() in [B.x()]{.code} proceeds to
[A.x()]{.code} when invoked from the second line above. The difference
is that C inherits from both B and A. B is the first superclass, so the
call to [inherited()]{.code} in [C.x()]{.code} proceeds to
[B.x(]{.code}). But C also inherits from A, and the superclass order is
defined so that A comes after B in C\'s superclass list. So, the call to
[inherited()]{.code} in [B.x()]{.code} proceeds to [A.x()]{.code} this
time, since that\'s the next superclass in inheritance order for the
original target object.
:::

[propType(*prop*)]{.code}

::: fdef
Returns the datatype of the given property of the given object, or
[nil]{.code} if the object does not define or inherit the property. This
function does not evaluate the property, but merely determines its type.
The return value is one of the [TYPE_xxx]{.code} values (see the
[reflection](reflect.htm) section for the list).
:::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> Object\
[[*Prev:* LookupTable](lookup.htm){.nav}     [*Next:*
RexPattern](rexpat.htm){.nav}     ]{.navnp}
:::
