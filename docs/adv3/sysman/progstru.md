::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Source Code Structure\
[[*Prev:* The Language](langsec.htm){.nav}     [*Next:* Source File
Character Sets](charmap.htm){.nav}     ]{.navnp}
:::

::: main
# Source Code Structure

## Tokens, whitespace, and newlines

For the most part, the TADS 3 compiler doesn\'t count whitespace
characters (spaces, tabs, and newlines) as significant.

Whitespace is only important when it comes between two characters that
would otherwise combine to form a single \"token\" (which we\'ll explain
in a moment), or when it appears in a string constant.

TADS 3 **does not** use newlines to determine where statements end. Some
languages (BASIC, for example) use newlines as statement separators.
TADS 3 does not; you can break up a single statement over as many lines
as you want, or you can pile a bunch of statements together on one line.
**Note:** there is an exception, which is that the
[preprocessor](preproc.htm) **does** use newlines to determine where
\"#\" directives end

Likewise, TADS 3 **does not** use indentation to determine statement
nesting structure. Some languages (Python, for example) use indentation
to indicate that a statement is nested within another statement, such in
an if-then-else construct. TADS 3 doesn\'t pay any attention to
indentation for this purpose; the TADS language uses punctuation marks
(mostly braces, [ { }]{.code}) to indicate statement grouping. To the
TADS compiler, spacing at the beginning of a line is no different from
any other whitespace.

A token is the basic lexical unit of the compiler and the preprocessor.
The first thing the compiler does when it looks at a program\'s source
code is to break up the text into tokens.

A token is:

-   An alphanumeric symbol: an alphabetic character or underscore (a to
    z, A to Z, or \"\_\"), followed by zero or more alphanumeric
    characters (alphabetics plus the digits 0 to 9) or underscores.
-   A decimal number: a non-zero decimal digit (1 to 9) followed by zero
    or more decimal digits (0 to 9), or just the digit 0 by itself.
-   An octal number: \"0\" followed by one more more octal digits (0 to
    7).
-   A hexadecimal number: \"0x\" followed by a string of hex digits (0
    to 9, a to f, and A to F).
-   A floating-point number: a non-zero decimal digit, followed by a
    string of decimal digits, optionally followed by a period and more
    digits, optionally followed by an \"e\" or \"E\", an optional \"+\"
    or \"-\", and a string of decimal digits. Examples: [1.25]{.code},
    [1e10]{.code}, [1.000e+207]{.code}, [1.23456E-5]{.code}
-   A single-quoted string: a single-quote mark ([\']{.code} - Unicode
    x0027), followed by any characters (including newlines) other than
    single-quotes, followed by a single-quote. Single-quotes can be
    embedded within the string by using the sequence [\\\']{.code}
    (backslash single-quote).
-   A double-quoted string: a double-quote mark ([\"]{.code} - Unicode
    x0022), followed by any characters (including newlines) other than
    double-quotes, followed by a double-quote. Double-quotes can be
    embedded within the string by using the sequence [\\\"]{.code}
    (backslash double-quote). Double-quoted strings can also contain
    embedded expressions using the [\<\< \>\>]{.code} marks; when used
    this way, a [\<\<]{.code} mark effectively ends a string token, and
    the corresponding [\>\>]{.code} mark effectively starts a new one.
-   Any of these punctuation marks or sequences: [( ) , . .. \... { } \[
    \] == = : ? ?? += ++ + -= \-- - -\> \*= \* /= / %= %]{.code} [\>=
    \>\>= \>\>\>= \> \>\> \>\>\> \<= \<\<= \<\< \< ; && &= & \|\| \|= \|
    \^= \^ != ! \~ @ \## #@ \#]{.code}

Within strings, both single-quoted and double-quoted, the backslash
character, [\\]{.code}, is special. A backslash introduces an \"escape
sequence,\" which lets you specify a character that would otherwise be
impossible (or at least difficult) to enter into the string directly:

-   [\\\"]{.code} - a double-quote mark
-   [\\\']{.code} - a single-quote mark
-   [\\\<]{.code} - a less-than sign (write [\<\\\<]{.code} to prevent
    the compiler from treating [\<\<]{.code} as the start of an embedded
    expression)
-   [\\\>]{.code} - a greater-than sign
-   [\\n]{.code} - a newline (\"line feed\") character, Unicode x000A
-   [\\b]{.code} - a \"blank line\" character, Unicode 0x000B; when
    displayed in an output window, this displays one newline if the
    current output line is empty, or two newlines otherwise
-   [\\r]{.code} - a carriage return character, Unicode x000D
-   [\\\^]{.code} - a \"capitalize\" character, Unicode x000F; when
    displayed in an output window, this sets an internal flag that
    causes the next character displayed in the same window to be
    capitalized, if it\'s alphabetic
-   [\\v]{.code} - a \"minusculize\" character, Unicode x000E; when
    displayed in an output window, this sets an internal flag that
    causes the next character displayed in the same window to be
    converted to lower-case, if it\'s alphabetic
-   [\\]{.code}  - a \"quoted space,\" Unicode x0015; when displayed in
    a formatted text window, this displays a space that isn\'t
    \"collapsed\" (i.e., combined with adjacent spaces) the way ordinary
    spaces normally are
-   [\\t]{.code} - a horizontal tab character, Unicode x0009
-   [\\u]{.code}*hhhh* - the Unicode character *hhhh*, where each *X* is
    a hexadecimal digit. For example, [\\u000A]{.code} encodes a newline
    character.
-   [\\x]{.code}*hh* - the Unicode character *hh*, where each *h* is a
    hexadecimal digit. (This differs from [\\u]{.code} only in that
    [\\x]{.code} limits the digit string to two hex digits, whereas
    [\\u]{.code} allows up to four hex digits. [\\x]{.code} is included
    only as a convenience to people familiar with other C-like languages
    that support this code.)
-   [\\]{.code}*ooo* - the Unicode character *ooo*, where each *o* is an
    octal digit.

## \"Compilation unit\" defined

A TADS 3 program is composed of one or more \"compilation units.\"

If it weren\'t for the preprocessor\'s #include mechanism, we could
simply define \"compilation unit\" as equivalent to a source file. The
#include facility muddles this equivalence, though, because it lets
multiple *actual* files be combined into one *effective* file - or, in
computerese, one *logical* file.

So we have to work a little harder to define \"compilation unit.\"
Specifically, a compilation unit is the body of source text that results
from running the preprocessor over a single source file, replacing each
#include directive with the contents of the included file, recursively
handling #include directives in included files.

The reason we bother to define the term \"compilation unit\" is that the
compiler never really sees a source file per se. The compiler instead
can only see the result of running the preprocessor over a source file,
so what the compiler sees is always a compilation unit, not the
underlying source files. So, to be precise, we usually have to refer to
compilation units rather than source files when talking about things
like identifier scope.

## Compilation unit scope vs. global scope

\"Global\" symbols are symbols that can be used from any source file, no
matter where they\'re defined. These include functions, objects,
classes, and properties. When you define an object, it becomes available
for use in any of your source files and any of your compilation units.

Global symbols are not only usable in any source file, but are also
automatically \"forward declared\" in the compilation unit in which
they\'re defined. In other words, if an object is defined in source file
A, you can refer to it from within A even before the definition (that
is, earlier in the file).

Some definitions have compilation unit scope. This means that they\'re
visible only within the compilation unit. This type of symbol includes
intrinsic function names, \"+ property\" definitions, and object
templates.

When a definition has compilation unit scope, it also has the property
that the definition only takes effect *after* the point in the source
file where the definition occurs. For example, you can\'t define an
object in terms of a template at any point in a source file before the
\"template\" statement that defines the template.

For the most part, you won\'t directly define the kinds of things that
have compilation unit scope. These types of symbols are mostly the sorts
of things that the standard system headers define for you. The fact that
these symbols take effect only after their definitions (\"after\" in
terms of source file text order) explains why you generally need to
#include system headers near the top of your source files.

## Compilation phases

The first phase of compilation is **preprocessing**. In this phase, the
preprocessor reads each source file, processes all of the \"#\"
directives (#include, #define, etc), and expands all macros (that is, it
replaces each occurrence of a macro name with the macro\'s definition,
with appropriate parameter substitutions). The preprocessor in effect
creates a new, temporary file that contains the result of all of this
work. We\'ll call this file the \"preprocessor output.\"

(In the current implementation, t3make doesn\'t *really* produce a
temporary file containing the preprocessor output. Instead, the
preprocessor keeps its output in memory, and sends the in-memory data to
the compiler. Furthermore, it doesn\'t actually run all the way through
the whole compilation unit before invoking the compiler; it actually
works incrementally, passing its output to the compiler a little at a
time. This design is intended to run a little faster than the abstract
view we describe above, in which the preprocessor and compiler and truly
decoupled and communicate via temporary files, because it avoids the
overhead of shuffling all the data through the external file system, and
it keeps memory usage within reason. However, the implementation always
*behaves* exactly the same way it would in the abstract view where the
two phases are truly decoupled.)

The second phase is the **symbol export** pass. In this phase, the
compiler parses each entire compilation unit, but does very little
more - the compiler really just analyzes the syntax of each compilation
unit so that it can identify the type of each symbol defined in the
unit. The compiler creates an intermediate file at this stage, called
the \"symbol export\" file (these files have the suffix (\".t3s\" - S
for Symbol), for each compilation unit. The symbol export file is
essentially a list giving the name and defined type (function, object,
class, etc.) of each \"global\" symbol in the program.

The symbol export phase runs over *all* compilation units before we
proceed to the next phase.

The third phase is the **compilation** pass. In this phase, the compiler
parses each compilation unit again, but this time it does a full
semantic analysis of each unit - that is, the compiler not only parses
the syntax of the compilation unit, but also analyzes the meaning of the
code. On this pass, the compiler generates the machine code (the T3
Virtual Machine byte-code) for all of the executable code in the unit,
and creates compact data structures representing the objects and classes
defined in the unit. It writes all of this information to an \"object\"
file - for each compilation unit, the compiler creates one object file.
(Object files typically have the suffix \".t3o\" - O for Object.)

During the compilation of *each* compilation unit, the compiler loads
*all* symbol export files for the entire program. This lets the compiler
know the intended usage of each symbol throughout the *entire* program.
This makes separate compilation easy to use, because you don\'t have to
worry about manually declaring all of the symbols you use in one source
file define in another. The compiler automatically scans the entire
program for you on the symbol export pass, allowing you to use global
symbols defined in any source file from within any other source file.

The compilation phase runs over *all* compilation units before we
proceed to the next phase.

The fourth phase is the **link** phase. In this phase, the compiler
loads all of the object files and correlates their global symbols - that
is, it makes the connection between each symbol that each compilation
unit depends upon and the definition of the symbol, which might come
from a separate compilation unit. It\'s possible for a unit to depend on
a symbol that isn\'t defined anywhere; if this happens, the compiler
displays an error and the compilation fails. It\'s also possible for the
same symbol to be defined in more than one unit, which is also an error.
If all of the symbols can be properly correlated, without any
conflicting definitions, the compiler links together all of the object
files and produces a single combined file, called the \"image\" file.
(This isn\'t an image in the sense of a graphic or a photo; it\'s called
an image file because it\'s a snapshot of the state of memory that the
program has when it first starts running.) The image file typically has
the suffix \".t3\".

The fifth phase is the **preinit** phase. In this phase, the compiler
invokes the T3 VM interpreter - actually, not the full interpreter that
players run, but a modified version with most of the user interface
functions removed. This phase runs your program, but not the normal way;
instead, it sets some special flags that tell the program that it\'s
running in preinit mode. In this mode, the program has a chance to do
any work it wants to do to set up for normal execution. Typically, the
program will take this opportunity to initialize data structures that
have derived information. The main purpose of the preinit phase is to
allow the program to do any time-consuming set-up work in advance, so
that users won\'t have to wait for the work to be done every time they
start the program.

After the program finishes running in preinit mode, the compiler
rewrites the image file, this time storing the *new* states of all of
the objects in memory, with all of the set-up work having been done.

The sixth phase is the **resource bundling** phase. At this point, the
compiler goes through the list of multimedia resource files (graphics,
sounds, etc.) that you included in the build, and copies the complete
contents of each resource file into the image file. This \"bundles\" the
resources into the image file, so that you don\'t have to distribute the
individual graphics and sounds and so on to end users - they\'re all
contained in whole in the image file, so the image file is the only
thing you have to give to users.

Note that when you tell the compiler to build your program in \"debug\"
mode, it skips the preinit and resource bundling phases. It skips the
preinit phase so that you can instead examine and step through the
preinit work using the debugger, if you so choose. It skips the resource
bundling phase to save time (since multimedia files can be quite large);
it can do this because you presumably won\'t be giving a debug-mode
program to anyone, and thus you wouldn\'t care about the resource
bundling.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> Source Code Structure\
[[*Prev:* The Language](langsec.htm){.nav}     [*Next:* Source File
Character Sets](charmap.htm){.nav}     ]{.navnp}
:::
