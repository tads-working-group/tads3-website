::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Operator Overloading\
[[*Prev:* Inline Objects](inlineobj.htm){.nav}     [*Next:*
Multi-Methods](multmeth.htm){.nav}     ]{.navnp}
:::

::: main
# Operator Overloading

TADS lets you define custom meanings for many of the \"algebraic\"
operators when applied to regular objects. This is known as
*overloading* an operator, because it assigns a meaning to the operator
when it\'s used with a datatype outside of its usual domain.

Note that the term is *overloading*, not *overriding*, and there\'s an
important difference between the two. Overriding would mean you\'re
changing the existing meaning of an operator; TADS **doesn\'t** let you
do this. For example, you can\'t change the meaning of \"+\" as it
applies to integer values, because the TADS virtual machine has a
built-in definition for that operator on that combination of types.
Overloading, in contrast, is the extension of an operator to a new type
that it normally doesn\'t work with, so it\'s not superseding anything
that\'s already built into the system.

If you\'re not familiar with operator overloading from other programming
languages, and you want an overview of what it\'s good for, you can skip
ahead to the section on [uses](#uses).

## How operators are applied

Before we talk about how to overload an operator, we have to know
*where* to put the overload. To determine that, it\'s important to
understand how TADS applies operators to values.

TADS is a dynamically typed language: the datatype of a variable or
expression isn\'t declared in the source code, but is determined based
on the actual values being used at the moment the expression is
executed. As such, the exact meaning of an operator can\'t be known
until operator is carried out on live data. Many operators have meanings
that vary according to the types of the values they\'re applied to. For
example, [+]{.code} can mean integer addition, string concatenation, or
list appending.

Each time an operator is executed, its meaning is determined by looking
at a specific one of its operands. (An operand is a value that an
operator is applied to. In [3 + 4]{.code}, the operator is [+]{.code}
and the operands are [3]{.code} and [4]{.code}.) The choice of which
operand controls the meaning is fixed for each operator: it\'s always
the same, no matter what types are involved.

-   A **unary** operator is one that applies to a single operand value,
    such as [-3]{.code} or [\~x]{.code}. A unary operator\'s meaning is
    determined by the type of its single operand.
-   A **binary** operator is one that applies to two values, such as
    [1 + 7]{.code} or [lst\[i\]]{.code}. All of the overloadable binary
    operators use the **left** operand as the controlling operand. For
    example, [\'hello\' + 7]{.code} is interpreted as a string
    concatenation, because the left operand is a string.
-   A **ternary** operator applies to three values. The only
    overloadable ternary operator is [x\[y\] = z]{.code}, and the type
    of this operator is determined by the leftmost operand [x]{.code}.

So, each time an operator is evaluated, TADS first fully evaluates each
operand to get the actual, live value of that sub-expression. It then
looks at the datatype of the value for the controlling operand.

If this is one of the primitive types, such as integer or nil, TADS
simply carries out its built-in definition of the operator for that
type. There\'s no way to change this through operator overloading; [3 +
4]{.code} will always yield 7.

If the controlling operand is an object value, and it\'s an object of
one of the intrinsic class types (String, List, LookupTable, etc.), the
machine checks to see if that class defines a meaning for the operator.
For example, String defines [+]{.code} as concatenation, and List
defines [\[\]]{.code} as indexing the list. If there\'s a built-in
meaning for the operator, TADS carries out that meaning. As with the
primitive types, there\'s no way to change this through operator
overloading.

If the controlling operand is an object value, and the object doesn\'t
have a built-in meaning for the operator, *this* is where operator
overloading kicks in. TADS checks to see if the object defines or
inherits an [operator]{.code} method for this specific operator. If so,
TADS invokes the method, and uses the return value of the method as the
operator result.

If there\'s no built-in definition for the operator, and there\'s no
corresponding [operator]{.code} method defined by the controlling
operand value, TADS gives up and throws a run-time error to signal that
the operator isn\'t valid for that combination of types.

## Defining an overloaded operator

An overloaded operator is a special kind of method. You define it
alongside ordinary properties and methods when you define a class or
object. An overload method uses a special name that starts with the
keyword [operator]{.code}, followed by the operator to be overloaded,
followed by an ordinary argument list and method body.

For example, to overload the [+]{.code} operator for a class, you\'d
define a method called \"[operator +]{.code}\":

::: code
    class ScopeList: object
       operator +(x)
       {
         local l = new ScopeList();
         l.scope = scope;
         l.scope += x;
         return l;
       }

       scope = []
    ;
:::

An [operator]{.code} method is always invoked on the controlling operand
of the operator. This is the [self]{.code} value for the method. The
remaining operands are passed as arguments to the method. This means
that the number of arguments is always one less than the number of
operands.

That\'s why the [operator +]{.code} we defined in the example above only
takes one argument. Since the controlling operand of a binary operator
is the left operand, the expression [a + b]{.code} effectively becomes a
call to [a.operator +(b)]{.code}. (That\'s not real syntax, though: you
can\'t use [operator+]{.code} to make a call to the method. To call the
method you have to use the algebraic syntax, [a + b]{.code}.)

Apart from the special naming syntax, an operator overload method is
written just like an ordinary method. It\'s fine to trigger side effects
(such as displaying text on the screen), call other methods and
functions as normal, and call [inherited]{.code} and [delegated]{.code}
as usual. Note, though, that the [operator]{.code} syntax can\'t be used
as a method name in a regular method call or in an [inherited]{.code} or
[delegated]{.code}, so you can\'t straightforwardly have class Sub\'s
[operator +]{.code} method inherit, say, class Base\'s [operator
\*]{.code} method.

The method should return a value to be used as the result of the
operator expression. If there\'s no explicit [return]{.code} statement,
the compiler will supply [nil]{.code} as the default return value, as it
does for any other method.

## Overloadable operators

The following operators are overloadable:

Operator

Type

Expression Syntax

Definition Syntax

[+]{.code}

binary

[a + b]{.code}

[operator +(b)]{.code}

[negate]{.code}

unary

[-a]{.code}

[operator negate()]{.code}

[-]{.code}

binary

[a - b]{.code}

[operator -(b)]{.code}

[\*]{.code}

binary

[a \* b]{.code}

[operator \*(b)]{.code}

[/]{.code}

binary

[a / b]{.code}

[operator /(b)]{.code}

[%]{.code}

binary

[a % b]{.code}

[operator %(b)]{.code}

[\^]{.code}

binary

[a \^ b]{.code}

[operator \^(b)]{.code}

[\<\<]{.code}

binary

[a \<\< b]{.code}

[operator \<\<(b)]{.code}

[\>\>\>]{.code}

binary

[a \>\>\> b]{.code}

[operator \>\>\>(b)]{.code}

[\>\>]{.code}

binary

[a \>\> b]{.code}

[operator \>\>(b)]{.code}

[\~]{.code}

unary

[\~a]{.code}

[operator \~()]{.code}

[\|]{.code}

binary

[a \| b]{.code}

[operator \|(b)]{.code}

[&]{.code}

binary

[a & b]{.code}

[operator &(b)]{.code}

[\[\]]{.code}

binary

[a\[b\]]{.code}

[operator \[\](b)]{.code}

[\[\]=]{.code}

ternary

[a\[b\] = c]{.code}

[operator \[\]=(b, c)]{.code}

You can only overload the operators listed above. Notably, you can\'t
overload any of the comparison operators ([==]{.code}, [!=]{.code},
[\<]{.code}, [\<=]{.code}, [\>]{.code}, [\>=]{.code}), the logical
operators ([&&]{.code} and [\|\|]{.code}), the \"if-nil\" operator
([??]{.code}), or the conditional operator ([? :]{.code}). You also
can\'t overload the regular assignment operator ([=]{.code}), but you
*can* override the index-and-assign operator, [\[\]=]{.code}.

The compound assignment operators, such as [+=]{.code} and [-=]{.code},
also can\'t be separately overloaded. However, when these operators are
executed, the system actually handles them as though they were written
out as separate steps, so the non-assignment part will still invoke your
overload. For example, the code [a += b]{.code} will invoke [a.operator
+(b)]{.code} to compute the value to assign to [a]{.code}. The same
applies to the increment and decrement operators, [++]{.code} and
[\--]{.code}. The compiler decomposes [a++]{.code} into [a =
a+1]{.code}, so while you can\'t overload [++]{.code} separately, you
can still intervene in such an expression by overloading [+]{.code}.

You\'ve probably noticed the odd man out in the table, \"operator
negate\". This is unary negation operator, which in actual expressions
is just a minus sign \"[-]{.code}\". Now, the minus sign is also used as
the two-operand subtraction operator. The language gets away with
reusing the same symbol for \"negative a\" and \"a minus b\" in
expressions because it\'s always clear from context which is which. But
with operator overloading, there\'s no such context in one important
situation, which is getting a property pointer: does
\"[&operator-]{.code}\" mean \"operator minus\" or \"operator negate\"?
TADS solves this problem by defining \"[operator -]{.code}\" solely as
the subtraction operator, and renaming the negation operator to
\"[operator negate]{.code}\".

The indexing operator\'s method syntax might also look odd, because
you\'d normally write the argument to [\[\]]{.code} inside the brackets.
But the correct syntax is as shown in the table, with the argument in
parentheses after the brackets. This makes the method syntax consistent
for all of the different operators.

The index-and-assign operator is worth mentioning because it might not
be obvious what the return value from this method would mean. The
primary function of the operator is to assign a value to the indexed
element. So should it simply return the assigned value? No: it should
actually return the *container* value. In many cases, this is simply
[self]{.code}, but not always. Some types create a new object when any
change is made to their contents. That\'s how List works, for example.
When you assign to a list element, a new list is created to reflect the
update, leaving the original list object unchanged. This is required
because a list is immutable . For this case, the [\[\]=]{.code} operator
method returns the newly created container object (the new List object
in the List example). If your [operator \[\]=]{.code} method modifies
the object\'s own contents directly, way Vector and LookupTable do, you
should simply return [self]{.code}, since the \"new\" container
reflecting the changes is simply the original container, [self]{.code}.

## Property pointers to overload methods

You can\'t call an operator overload method by name (you can call it
only through the actual operator syntax), but you *can* get a pointer an
overload property. Use the [&]{.code} operator as normal, and simply use
the same name as the method definition uses. For example:

::: code
    if (obj.propDefined(&operator -))
       "- is defined for 'obj'\n";
:::

## [List-like objects]{#listlike}

One of the consequences of being able to overload operators is that you
can create custom objects that mimic the built-in List type. Not only
can you use these as though they were lists in your own code, but you
can also pass them to most system functions and methods that require
List arguments.

For the purposes of **system** functions and methods, a list-like object
is defined as an object that provides the following:

-   An [operator \[\]]{.code} overload method
-   A [length()]{.code} method taking zero arguments

Most intrinsic functions and methods will interpret an object providing
these methods as list-like. The \"\...\" argument expansion operator
also recognizes this interface.

An object that meets this definition **must** return an integer value
from its [length()]{.code} method. The system will invoke it expecting
to get an element count as the result, so a non-integer return value
will trigger a type conversion error.

Note that if you plan to use a custom object as though it were a list in
your own functions and methods, you might also want to include the
Collection method [createIterator()]{.code}. This method is required for
an object to be used with the [foreach]{.code} or [for..in]{.code}
statements. This isn\'t required for system functions that take List
arguments, because those callers only expect the basic List-style
interface. But by adding [createIterator()]{.code}, you can ensure that
your object behaves like a generic Collection for places where you own
code might use it with [foreach]{.code} or [for..in]{.code}.

You might also want to define [operator \[\]=]{.code}, since if you\'re
passing it to code written to expect true List values, the code might
assign element values.

## Intrinsic classes

It\'s legal to add overloaded operators for intrinsic classes. The
syntax is the same as for a regular operator overload method, and goes
in a [modify]{.code} definition for the intrinsic class, the same as for
any other intrinsic class extensions.

You can *add* an operator to an intrinsic class, but you can\'t override
an operator that\'s already defined. In other words, you can only add
operators that the intrinsic class doesn\'t define internally. For
example, you can\'t override [operator +]{.code} for String, because
String defines [+]{.code} as the concatenation operator.

If you attempt to override an operator on an intrinsic class that\'s
already defined by the built-in class, the compiler will accept the
definition without a complaint, but the method will never be called at
run-time. The virtual machine always looks first for a native definition
for an operator, and only looks for an overloaded operator method if the
native method doesn\'t exist. This is the same way that all intrinsic
class methods work, actually: you can\'t override String.length()
either, because a native version is given priority over an extension in
a [modify]{.code} definition.

## Limitations

You can only overload the operators specifically listed earlier. Other
operators aren\'t eligible for overloading.

You can\'t change the syntax or precedence of an operator. For example,
you can\'t redefine [\<\<]{.code} as a unary operator, or change
[\[\]]{.code} from a postfix to a prefix, or give [+]{.code} higher
precedence than [\*]{.code}.

There\'s no way to create new operators.

It\'s not possible to override an operator that\'s defined for a system
type. For example, you can\'t redefine [\[\]]{.code} for a List, or
[+]{.code} for a String.

There\'s no way to override operators on primitive (non-object) types,
such as integers.

propDefined(), propType(), getPropList(), and getPropParams() don\'t
work for the built-in operators of intrinsic classes, such as [operator
+]{.code} for a String or [operator \[\]]{.code} for a List. They\'ll
simply act as though you\'re talking about an undefined method. For
example, [\'x\'.propDefined(&operator +)]{.code} will return nil, even
though [+]{.code} certainly does work with strings. The VM-defined
operators of intrinsic classes are essentially built in, so there\'s no
equivalent of an [operator]{.code} method represented in the type
system. For the same reason, you can\'t inherit from or delegate to a
built-in operator of an intrinsic class.

## [Typical uses]{#uses}

Operator overloading has been a feature of mainstream programming
languages since the 1960s; modern examples include C++ and Python. Over
the years, some common patterns of usage have emerged, as well as some
pitfalls.

The original use case, which motivated the first implementations, was
custom numeric types. The canonical example is complex numbers, but
there are also vectors (in the mathematical sense), tensors, etc. An
extended numeric type is a natural fit for the algebraic operators,
since that\'s exactly the notation that mathematicians have always used
for them. The ability to define the standard operators on new numeric
types lets you create types that can be used almost as though they were
native. Using algebraic operators can make it easier to write code using
the types than if you had to use function calls, and can make the code
not only more concise to write, but easier to understand when read.

The second common use is for creating types that aren\'t numerical in
nature, but where some of the algebraic operators still have intuitive
meanings. The String and List classes are built-in examples: in both
cases, the [+]{.code} operator has a fairly intuitive meaning, even
though it doesn\'t involve arithmetic addition. As with numeric types,
operator definitions can make custom object types easier to use and make
code at once more concise and clearer.

The second-and-a-half use is for creating your own custom objects that
mimic built-in objects that use operators. For example, you could create
a special \"Scope List\" class that represents the set of objects in
scope, but which can be used as though it were an ordinary list by code
that doesn\'t need to access its special features. You could do this by
defining the [+]{.code} and [\[\]]{.code} (indexing) operators on the
object to act the same way they do with a regular List object.

The third use is simply to make code more concise, by using operators
for frequently called methods instead of spelling out method names. This
is only subtly different from the second case; the distinction we\'re
drawing is that you can define an operator on an object even when there
*isn\'t* an obvious, intuitive meaning that\'s somehow analogous to the
usual arithmetic meaning of the operator. In these cases you don\'t
define operators for their clarity, but only for their concision. For
example, the C++ standard libraries redefine [\>\>]{.code} and
[\<\<]{.code} on file stream objects as \"read\" and \"write\"
operators. This has nothing to do with the ordinary arithmetic meaning
of the operators, so in that sense it\'s a completely arbitrary
reassignment of the operators, but it at least has a sort of visual
logic to it.

This third use of overloading is somewhat controversial. Among C++
developers, it\'s taken for granted and largely accepted, because the
language\'s inventor embedded the idea in the standard C++ libraries
from the beginning. However, the criticism is that it hurts code clarity
by arbitrarily redefining what an operator does, to such an extent that
a reader would never guess the meaning of the code just by looking at
it. Most people would intuitively know what [+]{.code} does when applied
to a String or List, but unless you\'ve read the C++ I/O documentation,
you\'d probably never guess that [\<\<]{.code} can sometimes write to
the console. (In fact, the TADS VM source code itself, which is written
in C++, is largely free of overloaded operators out of just these
concerns.) If you\'re writing an extension or library that other people
will use, it\'s probably best to use this sort of overloading sparingly.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Operator Overloading\
[[*Prev:* Inline Objects](inlineobj.htm){.nav}     [*Next:*
Multi-Methods](multmeth.htm){.nav}     ]{.navnp}
:::
