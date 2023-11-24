![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Language](langsec.htm) \>
Enumerators  
[*Prev:* String Literals](strlit.htm)     [*Next:* The Main Program
Entrypoint](startup.htm)    

# Enumerators

An enumerator is a named, constant data value. Enumerators are similar
to the C and C++ "enum" type, but have some important differences:

- C enum values are grouped into sets; each set of enum values is
  effectively a separate datatype. TADS enumerators are global constants
  that are not grouped into sets, and defining an enumerator does not
  create a new datatype.
- In C, an enum value is really just a named integer constant, and can
  be converted to and from its underlying integer value (an enum value
  can be cast to "int", for example, and used in arithmetic). In TADS,
  enumerator values cannot be converted to or from integers or any other
  type.

To define an enumerator, use the "enum" statement. This is a top-level
statement that appears outside of functions and object definitions.
After the "enum" keyword, simply list the enumerator names you wish to
define, separating multiple names with commas and ending the list with a
semicolon. For example:

    enum apple, orange, pear;

If you're familiar with C or C++, note that there is no name for the
group of symbols. In fact, defining these symbols together in a single
enum statement is merely a convenience and does not establish any
grouping or relation among these three symbols; there is no difference
between defining these symbols as a group and defining them with three
separate statements.

Enumerator names are global symbols, so they must co-exist with object,
function, and property names. An enumerator cannot have the same name as
any other global symbol.

You can use an enumerator anywhere a value is required, although an
enumerator cannot be used where a value of another datatype (such as an
integer) is required. So, you can assign an enumerator value to a
property or a local variable, store it in a list, or compare it to
another value. You cannot use an enumerator value in arithmetic
expressions.

    local x = apple;
    switch(lst[i])
    {
    case apple:
      "It's red.";
      break;
    case orange:
      "It's orange.";
      break;
    case pear:
      "It's green.";
      break;
    }

Enumerators have advantages and disadvantages relative to the primary
alternative, which is preprocessor symbols created with the \#define
directive. With preprocessor symbols, you can specify an integer or
other type of value that is used to represent the constant; this allows
you to use the constant in calculations and other places where it might
be convenient to treat the constant as having an underlying value of
some kind. Because you define an explicit value for a preprocessor
constant, you can be certain that these values will be stable from one
compilation to the next (assuming you don't change the definitions), so
you can write them to external files that are independent of any version
of your program. Enumerators, on the other hand, save you the trouble of
specifying a unique value for each constant; in addition, the debugger
shows you the symbolic name of an enumerator value, whereas it can only
show you the underlying value of a preprocessor constant.

A special type of enumerator defines "token" enumerators. A token
enumerator differs from a regular enumerator only in that a token
enumerator can be used in a grammar statement's match list. A token
enumerator is declared by adding the word "token" after the "enum"
keyword in the definition:

    enum token dictWord, unknownWord, punctuation;

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Language](langsec.htm) \>
Enumerators  
[*Prev:* String Literals](strlit.htm)     [*Next:* The Main Program
Entrypoint](startup.htm)    