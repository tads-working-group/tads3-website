::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Reflection\
[[*Prev:* Capturing Calls to Undefined Methods](undef.htm){.nav}    
[*Next:* Extending Intrinsic Classes](icext.htm){.nav}     ]{.navnp}
:::

::: main
# Reflection

The term \"Reflection\" refers to a set of services in a programming
language that let a running program dynamically inspect its own
structure. This can include access to things like the call stack,
variable datatypes, object structures, and the compiler symbol table.
Part of this is the ability to look at the instantaneous run-time
conditions of the program, and part is relating that status back to the
program\'s original source code. Reflection is so named because it
(metaphorically) lets the program hold a mirror up to itself.

Reflection features vary considerably from one programming language to
another. Compiled languages like C and C++ generally offer little or no
reflection capability, while modern scripting languages such as
Javascript let the program see almost everything about its own
structure. TADS 3 is between the two extremes, but closer to the dynamic
end of the spectrum. TADS 3 programs are compiled, which makes the
representation of a running program quite different from the original
source code; however, the TADS compilation process preserves a great
deal of information about the original source code structure, and makes
this information available through the reflection system.

## Fundamental-type codes

Certain reflection functions return or accept \"type code\" values.
These are integer values that represent the fundamental system types in
these contexts.

The system header file [\<systype.h\>]{.code} defines macro symbols for
the types:

TypeNil

nil

TypeTrue

true

TypeObject

object reference

TypeProp

property ID

TypeInt

integer

TypeSString

single-quoted string

TypeDString

double-quoted string

TypeList

list

TypeCode

executable code (i.e., a method)

TypeFuncPtr

pointer to function

TypeNativeCode

native code (i.e., an intrinsic class method)

TypeEnum

enumerator

TypeBifPtr

pointer to built-in function

Note that List and String objects will be represented with the TypeList
and TypeSString codes, respectively; even though they\'re actually
object references, the reflection services treat them as primitive
types. Other object types, such as BigNumber, Vector, LookupTable, etc.,
will be reported as TypeObject; you can use the Object class-sensing
methods to determine specifically which type of object you\'re working
with.

An anonymous function can be represented as either TypeFuncPtr or
TypeObject. This depends on whether or not the function refers to any of
the local variables from the enclosing scope where the function is
defined. (This includes [self]{.code} and the other method context
pseudo-variables.) If the anonymous function does refer to any variables
from the enclosing scope, it\'s represented as an object, which contains
the context information tying the function to the local scope in effect
when the function was created. If the function doesn\'t reference
anything in its enclosing scope, no context information is required, so
the function is represented as a simple static function pointer.

## Determining a value\'s type

The TADS language does not require (or allow) you to specify at
compile-time the type of data that a variable or property can hold. When
a program is running, a variable or property can hold any kind of value,
and you can change the type it stores at any time simply by assigning it
a new value. In this sense, the TADS language is not \"statically
typed\": there is no compile-time type associated with a variable or
property value.

However, the language is strongly typed - but at run-time rather than at
compile-time. Each value has a specific type, and the type of a value
itself can never change (even though its container can change type when
you store a new value in it). In addition, the system does not allow you
to perform arbitrary conversions between types; you can never use an
integer as though it were an object reference, for example.

You can access the type of any value using the [dataType()]{.code}
intrinsic function. This function returns a code that indicates the
\"primitive\" (built-in) type of the value. The primitive types are the
basic types built in to the language: true, nil, integer, string, list,
object reference, function pointer, property ID, enumerator.

If the primitive type of a value is object reference, you can learn more
about the type by inspecting the class relationships of the object. At
the simplest level, you can determine if the object is related by
inheritance to a particular class using the [ofKind()]{.code} method on
the object. If you need more general information, you can use the
[getSuperclassList()]{.code} method to obtain a list of all of the
direct superclasses of the object.

### dataTypeXlat()

The standard library adds another function, [dataTypeXlat()]{.code},
that provides a slightly higher-level version of [dataType()]{.code}.
The two functions are almost the same, except for how they treat
anonymous functions and dynamic functions.

An anonymous function is technically an object of intrinsic class
AnonFuncPtr, and [dataType()]{.code} doesn\'t make any attempt to hide
this fact: it returns TypeObject. The same goes for DynamicFunc objects.

However, for most practical purposes, anonymous and dynamic function
objects are interchangeable with regular function pointers; in practice,
you end up using all function types the same way. This sometimes makes
it slightly inconvenient that [dataType()]{.code} returns TypeObject for
anonymous and dynamic functions, vs. TypeFuncPtr for regular function
pointers. This is where [dataTypeXlat()]{.code} comes in. This function
returns TypeFuncPtr for anonymous function objects and dynamic function
objects, just as it does for a regular function pointer. So wh en
you\'re interested in determining whether a particular value is
*effectively* a function, meaning it can be invoked as though it were a
function, [dataTypeXlat()]{.code} makes it easier to find out.

For all other types, dataType() and dataTypeXlat() return the same
results.

## Determining a property\'s definition

The [dataType()]{.code} function can be used with any value, but
sometimes it is useful to obtain the type of a particular property
definition for a particular object without evaluating the property. If
an object\'s property is defined as a method, evaluating the property
will call the method; sometimes it is necessary to learn whether or not
the property is defined as a method without actually calling the method.
For these cases, you can use the [propType()]{.code} method, which
obtains the type of data defined for a property without actually
evaluating the property.

You can determine if an object defines a property at all using the
[propDefined()]{.code} method. This method also lets you determine
whether the object defines the method directly or inherits it from a
superclass, and when the method is inherited, to identify the superclass
from which the object inherits the method.

## Enumerating active objects

You can enumerate all of the objects in the running program using the
[firstObj()]{.code} and [nextObj()]{.code} intrinsic functions. These
functions let you iterate through the set of all objects in the program,
including objects statically defined in the compiler and those
dynamically allocated during execution.

::: code
    for (local o = firstObj(Thing) ; o != nil ; o = nextObj(o, Thing))
      "<<o.name>>\n";
:::

## Retrieving function and method interfaces

You can dynamically determine how many arguments a given function or
method takes.

For a function, use [getFuncParams()](tadsgen.htm#getFuncParams):

::: code
    // get parameter information on function main()
    local p = getFuncParams(&main);
:::

For a method, use the [getPropParams](objic.htm#getPropParams) method of
the containing object:

::: code
    // get the method parameters for book.lookAround()
    local p = book.getPropParams(&lookAround);
:::

## Accessing named arguments

You can get a list of all of the [named arguments](namedargs.htm)
currently in effect by calling [t3GetNamedArgList()]{.code}. This
function returns a list of strings, where each string is the name of a
currently active named argument.

You can retrieve the value of a named argument given its name via
[t3GetNamedArg()]{.code}.

(These functions are part of the [t3vm](t3vm.htm) set.)

## Accessing compiler symbols: the [reflectionServices]{.code} object

TADS 3 lets a running program access the global symbols that were
defined during compilation. This powerful capability makes it possible
to interpret strings into object references, properties, and function
references, so that you can do things such as call a property of an
object given the name of the property as a string.

The system library provides an optional module that you can include in
your program for a simple interface to the compiler symbols. To use
these services, simply include the module reflect.t in your build Note
that this is designed to be a separately-compiled module, so **do not**
[#include]{.code} it from your source modules - instead, simply add it
to your project (.t3m) file. If you\'re not using a project file, just
add it to your t3make command line:

::: cmdline
    t3make myProg.t reflect.t
:::

Note that, by default, reflect.t does not include support for the
BigNumber intrinsic class. However, you can enable BigNumber support by
defining the symbol [REFLECT_BIGNUM]{.code}, using the [-D]{.code}
option in your project file or on the t3make command line.

::: cmdline
    t3make -DREFLECT_BIGNUM myProg.t reflect.t
:::

The [reflectionServices]{.code} object provides the high-level compiler
symbols interface. The methods of this object are discussed below.

### formatStackFrame

[formatStackFrame(fr, includeSourcePos)]{.code} returns a string with a
formatted representation of the stack frame fr, which must be an object
of class [T3StackInfo]{.code} (the type of object in the list returned
by the intrinsic function [t3GetStackTrace()]{.code}). If
[includeSourcePos]{.code} is [true]{.code}, and source information is
available for the frame, the return value includes a printable
representation of the source position\'s filename and line number. The
return values look like this:

::: code
    myObj.prop1('abc', 123) myProg.t, line 52
:::

### valToSymbol

[valToSymbol(val)]{.code} converts the value val to a symbolic or string
representation, as appropriate. If the value is an integer, string,
BigNumber, list, [true]{.code}, or [nil]{.code}, the return value is a
string representation of the value appropriate to the type (in the case
of [true]{.code} and [nil]{.code}, the strings \'true\' and \'nil\' are
returned, respectively). If the value is an object, property ID,
function pointer, or enumerator, the return value is a string giving the
symbolic name of the value, if available, or a string showing the type
without a symbol (such as \"(obj)\" or \"(prop)\").

## Low-level compiler symbol services

This section discusses the low-level compiler symbol services. These
services are built into the VM. In most cases, you should use the
high-level services provided by the [reflectionServices]{.code} object,
since that interface is easier to use and provides substantially the
same capabilities.

The interpreter provides the program with the global symbols via a
LookupTable object. Each entry in the table has a compiler symbol as its
key, and the symbol\'s definition as its value. For example, each named
object defined in the program has an entry in the table with the
compile-time name of the object as the key, and a reference to the
object as its value. In addition, the table includes all of the
properties, functions, enumerators, and intrinsic classes.

To obtain a reference to the symbol table, use the
[t3GetGlobalSymbols()]{.code} intrinsic function. This function returns
the LookupTable object, if it\'s available, or [nil]{.code} if not.

Note that the global symbol table is available from
[t3GetGlobalSymbols()]{.code} only under certain conditions:

-   The global symbols are available during pre-initialization when
    building a program.
-   The symbols are available during a normal interpreter session if the
    program was compiled with debugging symbols.

At other times, the symbol table isn\'t available, so
[t3GetGlobalSymbls()]{.code} returns [nil]{.code}. In particular, this
is the case during normal execution (after preinit) of a program
compiled for release, since the compiler omits the symbol table
information from release builds to reduce the size of the image file.

Note that you can use the global symbol table during normal execution of
a program compiled for release, if you want. To do this, simply obtain a
reference to the symbol table in pre-initialization code, and then store
the reference in a property of a statically-defined object. When the
compiler builds the final image file, it will automatically keep the
symbol table because of the reference stored in the program. Here\'s an
example:

::: code
    #include <t3.h>
    #include <lookup.h>

    symtabObj: PreinitObject
      execute()
      {
        // stash a reference to the symbol table in
        // my 'symtab' property, so that it will
        // remain available at run-time
        symtab = t3GetGlobalSymbols();
      }
      symtab = nil
    ;
:::

To reference the symbol table at run-time, you would get it from
[symtabObj.symtab]{.code}. Note that even though you stored a reference
to the table, [t3GetGlobalSymbols()]{.code} will still return nil at
run-time if the program wasn\'t compiled for debugging; the reference
you saved is to the table that was created during pre-initialization,
which at run-time is just an ordinary LookupTable object loaded from the
image file.

If you don\'t store a reference to the symbol table during
pre-initialization, the garbage collector will detect that the table is
unreachable, and will automatically discard the object. This saves space
in the image file (and at run-time) for programs that don\'t need access
to the information during normal execution.

Here\'s an example of using the symbol table to call a method by name.
This example asks the user to type in the name of a method, then looks
up the name in the symbol table and calls the property, if it\'s found.

::: code
    callMethod(obj)
    {
      local methodName;
      local prop;

      // ask for the name of a method to call
      "Enter a method name: ";
      methodName = inputLine();

      // look up the symbol
      prop = symtabObj.symtab[methodName];

      // make sure we found a property
      if (prop == nil)
        "Undefined symbol";
      else if (dataType(prop) != TypeProp)
        "Not a property";
      else
      {
        // be sure to catch any errors in the call
        try
        {
          // call the property with no arguments
          obj.(prop)();
        }

        catch (Exception exc)
        {
          // show the error
          "Error calling method: ";
          exc.displayException();
        }
      }
    }
:::

## Preprocessor macros

The [t3GetGlobalSymbols()]{.code} function can also retrieve information
on the preprocessor macros defined in the program\'s source code. This
information is in the correct format for use with the
[DynamicFunc](dynfunc.htm) class\'s dynamic compiler, so you can pass it
directly to the DynamicFunc constructor as the \"macroTable\" argument.

To retrieve the macro information, specify the constant value
[T3PreprocMacros]{.code} as the selector argument to
[t3GetGlobalSymbols()]{.code}:

::: code
    local macros = t3GetGlobalSymbols(T3PreprocMacros);
:::

This retrieves a LookupTable containing all of the \"global\" macros
defined in the compiled program\'s source code (more on this
[shortly](#globalMacros)). Each key in the table is a macro symbol name,
and the corresponding value contains information on the definition of
the macro.

The definition of a macro consists of a list with three elements:

-   Element \[1\] is the text of the macro\'s expansion (that is, the
    part of the original source text of the #define that follows the
    macro\'s name and parameter list).
-   Element \[2\] is a list giving the names of the parameters to the
    macro. This is an empty list if the macro doesn\'t take any
    arguments.
-   Element \[3\] is an integer with a combination of bit flags
    (combined with the bitwise OR operator \"[\|]{.code}\") with more
    details on the macro:
    -   T3MacroHasArgs (0x0001) is set if the macro has a parameter list
        at all. A macro defined without a parameter list behaves a
        little differently from a macro defined with an empty parameter
        list, so this flag is needed to distinguish the two cases when
        there are zero arguments.
    -   T3MacroHasVarargs (0x0002) is set if the macro takes a varying
        number of arguments, which is specified with a \"\...\" suffix
        on the macro\'s last parameter name. (Note that the \"\...\" is
        **not** included in the name list in element \[2\] of the macro,
        which is why you need this flag to tell whether it was included
        in the macro\'s definition.)

Here are a few examples of macros and their corresponding table
information.

::: code
    #define HUNDRED  100
       ->   ['100', [], 0]

    #define square(x) ((x)*(x))
       ->   ['((x)*(x))', ['x'], 0x0001]

    #define debugPrint(msg...)  tadsSay('Debug message: ', ##msg)
       ->   ['tadsSay(\'Debug message: \', ##msg)', ['msg'], 0x0003]
:::

### []{#globalMacros}What makes a macro global?

The macro table returned by [t3GetGlobalSymbols()]{.code} only contains
\"global\" macros.

A global macro is one that has a fixed value throughout the program.
Global macros are the most common type, because the usual convention is
to define macros in common header files, which ensures that each module
throughout the program has the same definition for any given macro.
However, it\'s perfectly legal to use [#define]{.code} directly in a
source code module, rather than in a header, and it\'s legal for
different modules to have different definitions for the same macro.
It\'s also possible to change a macro\'s definition one or more times
within a single source module, by using [#undef]{.code} to remove the
old definition. In either case, the table excludes macros that have two
or more distinct definitions anywhere in the program.

The reason for excluding non-global macros is that the table itself is
global: there\'s only one table for the whole program, so the table
can\'t be tied to any particular source code file or portion of a file.
If a macro is redefined with different expansions in different parts of
the source code, there\'s no \"one true definition\" that applies
throughout the program. So, the system considers such macros to be
roughly analogous to local variables, and omits them from the global
macro table.

### Availability of macro information

The macro table is available under the same conditions as the global
symbol table: during preinit, and during normal execution as long as the
program was compiled for debugging. You can use the same trick we saw
for the global symbol table if you want to be able to access the macros
during normal program execution in release mode: retrieve the table
during preinit, and save a reference in an object property.

## Custom reflection services

You can replace the reflection services defined in reflect.t by defining
your own versions. For the most part, the services defined there are for
your program\'s consumption, so you can define the interfaces however
you like. However, the VM makes its own calls to certain reflect.t
services when they\'re available, so for full functionality you\'ll need
to define your replacements using the same interfaces in those cases.
The specific requirements are:

-   [reflectionServices.valToSymbol(val)]{.code} - returns a string
    giving the symbolic version of *val*, if possible. You can use
    whatever names you want for the object and property, as long as you
    export your names as follows:

    ::: code
        export reflectionServices 'reflection.reflectionServices';
        export valToSymbol 'reflection.valToSymbol';
    :::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Reflection\
[[*Prev:* Capturing Calls to Undefined Methods](undef.htm){.nav}    
[*Next:* Extending Intrinsic Classes](icext.htm){.nav}     ]{.navnp}
:::
