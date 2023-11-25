::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> The Preprocessor\
[[*Prev:* Source File Character Sets](charmap.htm){.nav}     [*Next:*
Fundamental Datatypes](types.htm){.nav}     ]{.navnp}
:::

::: main
# The Preprocessor

TADS 3 provides a macro preprocessor that\'s essentially equivalent to
the standard ANSI C preprocessor.

The preprocessor is effectively a separate phase of processing that runs
before the compiler: the preprocessor\'s output is the compiler\'s
input. The preprocessor works entirely at the textual level; it\'s not
part of the compiler per se, and it doesn\'t make any attempt to
understand the underlying TADS language or program structure.

## Lexical structure

The preprocessor uses all the same lexical rules as the TADS language:
strings are enclosed in single or double quotes; symbols consist of an
alphabetic or underscore character followed by zero or more alphanumeric
or underscore characters; numbers consist of strings of digits, with
periods to indicate decimal points and \'e\' or \'E\' to indicate
exponents in floating-point values; and various punctuation marks and
combinations of punctuation marks are used as operator tokens.

Block comments are specified with /\* \... \*/ sequences, and // begins
a comment that runs to the end of the line. Each comment is replaced
with single space character **before** any other work is done.

In addition to the basic TADS lexical structure, the preprocessor has a
couple of special features of its own:

-   If the last character of a source line is \"\\\" (a backslash), the
    preprocessor replaces the backslash and the newline that follows
    with a single space character. This effectively joins two physical
    lines of the source file into one \"logical\" line. This is done
    before directives are interpreted, which allows you to write a
    single directive that spans multiple physical lines. Note that this
    only takes effect when a \"\\\" is the very last character on the
    line; if anything else follows, even whitespace, the backslash is
    treated as just part of the source text, and doesn\'t join the line
    with the next one.
-   \"#\" at the beginning of a line introduces a preprocessor
    directive. Whitespace can optionally precede the \"#\" and can come
    between the \"#\" and the directive name. Each directive is exactly
    one *logical* line long, and runs to the end of the logical line.

## Directives

All preprocessor directives have compilation unit scope. A few, such as
#pragma newline_spacing, are further limited to the current include
file; exceptions to compilation unit scope are noted with the individual
directive descriptions.

### #charset

#charset specifies the file\'s character set. If this directive is used,
it **must** be the very first thing in the file. It can\'t be preceded
by anything, not even a comment or whitespace.

The syntax is:

::: syntax
    #charset "name"
:::

where *name* is the character set name. You can use one of the built-in
character sets (\"us-ascii\", \"latin1\") or any of the available
mappings. On most platforms, the TADS 3 distribution includes a large
set of common mappings, including the ISO-8859-n character sets, many of
the 8-bit Windows code pages, and the Macintosh sets.

### #define

This directive defines a macro. It has two forms: one that defines a
simple constant symbol, and one that defines a function-like macro with
parameters.

::: syntax
    #define simpleMacro text
    #define funcMacro( [ param1 [ , param2 ... ]  ]  ) textWithParameters
:::

The first form defines a \"simple\" macro, which simply associates a
symbol name with some replacement text. Each time the macro symbol name
appears in subsequent source text, it\'s simply replaced with the
expansion text.

The second form defines a \"function-like\" macro. This means that the
macro is syntactically like a function, in that a list of arguments,
enclosed in parentheses, must appear after the macro name each time
it\'s used. The parameter list can include zero, one, or more
parameters, separated by commas; each parameter name must be a symbol
token, and a name cannot be repeated within the list. Whenever the macro
name appears in the source text, it must be followed by a parenthesized
list of values; these values will be substituted into the replacement
text where the names of the parameters appear in the replacement text.

Note that if you define a parameter list, there must be no whitespace
between the macro symbol name and the open parenthesis. The parenthesis
must appear *immediately* after the macro name.

Macro processing is described in more detail [below.](#macros)

### #error

This macro lets you generate a compiler error with your own custom
message. The message is displayed on the console in the same format as
an actual compiler message. This is most useful with conditional
compilation, such as to flag build configurations or module combinations
that you don\'t wish to allow.

The syntax is:

::: syntax
    #error token [ token2 ... ] 
:::

The token list can contain any number of tokens of any kind. However,
note that macro expansion is performed on the line, so in most cases,
you\'ll want to enclose your message text in quotes so that it\'s
displayed literally, rather than being expanded into any macros that
happen to match the words in the message text.

Here\'s an example that checks to make sure an included library header
has a suitable version number:

::: code
    #include "MyLib.h"
    #if MYLIB_VSN < 5
    #error "This module requires MyLib version 5 or higher."
    #endif
:::

### #if, #ifdef, #elif, #else, #endif

These directives allow you to include or exclude code conditionally.

The syntax of these macros is as follows:

::: syntax
    #if expression
    #ifdef macroName
    #elif expression
    #else
    #endif
:::

The *macro* of an #ifdef is simply a macro symbol.

The *expression* of an #if or #elif can evaluate to a string constant,
an integer constant, or the tokens `true` or `nil`. You can use the
standard arithmetic operators (+, -, \*, /, %, \<\<, \>\>, !, &, \|, &&,
\|\|, ?:) within integer and boolean expressions. In addition, the
special operator `defined(`*`macro`*`)` evalutes to 1 if the given macro
symbol is currently defined, 0 if not. An #if or #elif expression is
considered true if it evaluates to a non-zero integer, or to any string
value, or to the special value `true`.

Each #if or #ifdef must be matched by exactly one #endif.

Within a #if\...#endif or #ifdef\...#endif block, you can include any
number of #elif directives, and you can optionally include a single
#else directive that follows any #elif directives. #elif stands for
\"else if\"; it takes effect only if its expression evaluates to true
*and* the controlling #if or #ifdef evaluated to false *and* all
preceding #elif\'s in the same block evaluated to false.

The preprocessor handles an #if\...#endif block as follows. It first
expands any macros in the expression, then evaluates the result as a
constant expression (taking into account arithmetic operators). Then:

-   If the expression evaluates to true (as defined above), the source
    text between the #if and the matching #elif, #else, or #endif -
    whichever comes first - is retained; all text after the matching
    #elif or #else is discarded and replaced with whitespace, up to the
    matching #endif.
-   If, on the other hand, the expression evaluates to false, the source
    text between the #if and the matching #elif, #else, or #endif is
    discarded and replaced with whitespace. If the next thing is an
    #elif, its condition is evaluated, and the process is repeated as
    though it were the original #if. If the next thing is instead an
    #else, the text between the #else and the #endif is retained.

#ifdef is handled much the same way, except that its condition is simply
the existence or absence of a definition for the given macro symbol. The
#ifdef condition is true if the given macro symbol has been defined,
false if not.

Note that there\'s no such thing as \"#elifdef\" - that is,
else-if-defined - but you can get the same effect by using \"#elif
defined(*macro*)\".

#if and #ifdef blocks can be nested to any depth.

Here\'s an example Note that the defined() preprocessor operator can be
used within an expression in these directives to test to determine if a
preprocessor symbol is defined. This allows for tests of combinations of
defined symbols: #if defined(MSDOS) \|\| defined(AMIGA) \|\|
defined(UNIX)

### #include

This directive inserts the contents of another source file into the
compilation unit at the current point. The contents of the included file
effectively replace the #include directive in the preprocessor output.

#include has two forms.

::: syntax
    #include "filename"
:::

This form searches for a file with the given name, starting the search
in the directory containing the *including* file, then in the directory
containing the file that included the including file, and so on up the
list of includers until reaching the original source file. We search in
this order and stop at the first matching file we find. If we still
can\'t find the file after looking in the directory containing the
top-level source file, then we proceed as for an angle-bracketed file.

::: syntax
    #include <filename>
:::

This form searches for the given file in each directory in the \"include
path,\" as specified in the compiler command options. For the
command-line t3make program, this is the list of directories specified
with -I options. The directories are searched in the order of the -I (or
equivalent) options, and we stop and use the first matching file we
find. If we exhast the include path without finding the file, we search
in the compiler\'s install directory - this is where the standard system
headers are usually located.

In both cases above, if the file still can\'t be found after searching
all of the directories described, and the filename appears to be an
\"absolute\" path (according to local path naming conventions, which
vary by system), the compiler tries again, this time treating the name
as an absolute path. An absolute path is one that fully specifies the
location of the file; on Unix, for example, this is a path starting with
a \"/\", and on Windows it\'s a path starting with a drive specifier
(such as \"C:\").

The file can be specified with a macro symbol or a combination of macro
symbols. If you use a macro expression, the expansion must match one of
the formats shown above.

#### Specifying relative directory paths in include file names

Filenames in #include directives can refer to relative paths (such as to
subdirectories) using relative URL-style notation. (A URL is a \"uniform
resource locator,\" which is a World Wide Web standard mechanism for
specifying names of things like files.) In particular, you can use a
forward slash, \"/\", as the path separator character, regardless of
your local system\'s filename conventions. Even if you\'re running on
Windows (which uses \"\\\" as the path separator) or Macintosh (which
uses \":\" as the separator and has rather different rules than
Unix-style systems), you can use \"/\" to specify relative paths, and
your source will compile correctly on all systems.

For example, suppose you\'re using a Macintosh, and you have your source
files in a folder called \"My HD:My TADS Games:Caverns of Gloom\". Now,
suppose you decide that you\'d like to keep your include files in a
subfolder of this folder called \"Include Files\". You could write your
#include lines like so:

::: code
    #include ":Include Files:defs.h"
:::

But if you did this, and then you gave a copy of your source code to a
friend running Windows, your friend wouldn\'t be able to compile the
code without changing that #include directive to match Windows path name
conventions.

The solution to this problem is to use URL-style path names. A URL-style
path name works the same on every system, so your friend on Windows will
be able to compile your code without changes if you use this notation.
To use URL notation, use \"/\" as the path separator, and - regardless
of local conventions - place slashes only between path elements, never
at the beginning of the filename. So, we\'d rewrite the example above
like this:

::: code
    #include "Include Files/defs.h"
:::

Even though this doesn\'t look a thing like a Mac path name, the Mac
version of the TADS 3 compiler will happily find your file in the
correct directory, because the Mac version knows how to convert
URL-style path names to the correct Mac conventions, just like the
Windows and Unix versions know how to convert URL-style names to their
own local conventions.

In all include file searches, when the filename looks like a URL-style
path, the compiler takes the following steps to look for the file. It
takes these steps at each point in the include path search before moving
on to the next directory in the list:

-   First, the compiler tries treating the filename as a URL-style path.
    This means that the compiler converts all \"/\" characters to the
    local path separator characters, and performs any other
    transformations required to make the name appear relative. For
    example, on the Mac, the compiler would convert \"Include
    Files/defs.h\" to \":Include Files:defs.h\", then would try looking
    for that file relative to the current directory being searched.
-   If the first step fails to find a file, and the file does not use an
    absolute path (according to the local file system rules), the
    compiler tries again, this time treating the name as a native name,
    rather than URL path. That is, the compiler simply uses the name
    exactly as given, without any syntax conversions, and looks for a
    file with that name in the directory currently being searched.

Even though the compiler accepts local filenames, we strongly encourage
using URL-style filenames for all #include files that specify paths,
since this will ensure that your source code will compile without
changes on other platforms.

### #line

As the preprocessor reads through the source and include files, it
automatically keeps track of where it is in the file - the filename and
the current line number in the file. This lets the compiler tell you
where it was looking whenever it encounters a syntax error or other
problem in your code, to make it easier to pinpoint the source of a
problem so you can fix it.

This directive lets you override the compiler\'s internal notion of its
current position in the source text. The syntax is:

::: syntax
    #line number 'filename'
:::

This tells the compiler that it should pretend that it\'s reading from
the file named *file* at line number *number*.

Note that this directive doesn\'t change where the compiler is
*actually* reading from. In particular, it doesn\'t force the compiler
to jump ahead to a different line in the file, or change to a different
file. The directive merely overrides the location that the compiler will
*report* on subsequent error messages.

The #line directive is mainly of interest to people writing their own
pre-compiler tools. A pre-compiler is a tool that runs before the
compiler, reading from a user-prepared source file and writing out a
temporary file, and then passing the temporary file to t3make as the
TADS 3 source file. For tools like this, the #line directive lets the
tool apprise the TADS compiler of the original source code location
associated with the generated code in the temporary file. This in turn
causes the TADS compiler to report error messages at locations that will
be meaningful to the user. Since the user is working with the original
pre-compiler input file, it will be a lot more helpful to report errors
in terms of the original input file than in terms of the temporary file.

### #pragma message

This directive lets you display a message on the console while the
compiler is running. The syntax is:

::: syntax
    #pragma message ( token ... )
:::

Each *token* can be a single-quoted string, a double-quoted string, a
symbol token, or an integer. Any macro symbols you use are expanded as
in normal program text.

### #pragma newline_spacing

Unlike C and Java, a string in TADS 3 doesn\'t have to fit all on one
line. You can instead write a string that spans several lines:

::: code
    "This is a string
    that spans several
    lines of source code. ";
:::

By default, the compiler treats this as though you had written it all on
one line. It converts each line break into a single space character. If
a line break is immediately followed by one or more whitespace
characters (spaces, tabs, and so on), the compiler collapses the line
break and all of the subsequent spaces into a single space character; so
each line break turns into a single space, no matter how many spaces are
at the start of the next line. This is important because most people
like to use indentation to make their source code easier to read;
ignoring the leading whitespace on each extra line within a string means
that you don\'t have to worry about indentation affecting the appearance
of a string.

This default handling is called \"collapse\" mode, because each newline
and subsequent run of whitespace is collapsed into a single space. You
can explicitly set this mode by writing this directive in your source
file:

::: code
    #pragma newline_spacing(collapse)
:::

(Prior to TADS 3.1.3, this mode\'s name was \"on\" instead of
\"collapse\". The compiler still accepts [#pragma
newline_spacing(on)]{.code} as equivalent, so existing code will work
without any changes.)

In some written languages, such as Chinese, there isn\'t typically any
whitespace between words. In such languages, the normal \"collapse\"
mode described above isn\'t convenient, since it introduces unwanted
spacing between words wherever you happen to put a line break in the
source code. To accommodate languages without inter-word spacing, the
compiler has another newline spacing mode, called \"delete\" mode:

::: code
    #pragma newline_spacing(delete)
:::

(The pre-3.1.3 name for this mode was \"off\", which is also still
accepted and is equivalent to \"delete\" mode.)

In \"delete\" mode, when the compiler encounters a line break within a
string, it simply deletes the newline and all immediately subsequent
whitespace. This mashes the text on the two lines together without any
spacing.

There\'s one additional mode, \"preserve\" mode, for times when you want
precise control over the contents of strings.

::: code
    #pragma newline_spacing(preserve)
:::

In \"preserve\" mode, the compiler keeps the string exactly as you wrote
it, with each line break turning into a [\\n]{.code} (newline)
character, and all subsequent spacing left intact. This can be useful if
you\'re constructing multi-line strings for special purposes, such as
storing in external files.

The newline_spacing pragma only affects strings following the pragma in
the source file, so you can change the mode at any time within the same
source file. Whenever you change the mode, the new mode is in effect
until you change it with another pragma, or until the end of the current
source file. This means that if you change the mode within a header
file, the mode will revert to its previous setting at the end of the
header file. This lets you #include a file without worrying about mode
changes, because even if the included file changes the mode, the mode
will revert back once the compiler finishes with the included file.

### #pragma sourceTextGroup

This directive lets you control the generation of
[sourceTextGroup](objdef.htm#sourceTextGroup) property values. You can
also control this with the compiler\'s \"-Gstg\" command-line option,
but the #pragma gives you finer-grained control, since it lets you turn
generation on and off within particular modules, or even within sections
of a module.

To turn on sourceTextGroup generation, include this directive in your
source code:

::: code
    #pragma sourceTextGroup(on)
:::

This tells the compiler to generate sourceTextGroup values for objects
defined after this point in the current module\'s source code.

You can turn sourceTextGroup generation off with this directive:

::: code
    #pragma sourceTextGroup(off)
:::

This disables sourceTextGroup generation for subsequent object
definitions.

Note that the effect of `#pragma sourceTextGroup` lasts only within the
source module where it appears. The directive doesn\'t carry over to
other modules that are part of the same build - at the start of each new
module, the compiler resets to the status specified in the command line
makefile (off by default, or on if the \"-Gstg\" option is specifed).

### #pragma once

This directive adds the current file (i.e., the file in which the
#pragma directly appears) to the \"once-only\" list. After a file is in
the once-only list, subsequent #include directives that attempt to
include the file will be ignored.

This is sometimes useful to ensure that a header file isn\'t included
redundantly. For example, suppose you are creating a library that has
several header files for different subsystems in the library, and all of
these main subsystem headers in turn depend on a common header for the
overall library. Each of the subsystem headers would need to #include
the common header. However, you can\'t predict in advance which of the
subsystem headers a user might need to #include in her own program: the
user might want to include only one of your subsystem headers, but also
might be using several of your subsystems and thus would need to include
several of the headers. That\'s where the problem comes up: if the user
includes three of your subsystem headers, and each of the subsystem
headers includes the common header, the common header will end up being
included three times. This could cause compiler errors due to the
repeated inclusions of the definitions in the common header. You can
avoid this by putting a \"#pragma once\" directive in the common header;
if you do this, it will ensure that only the first inclusion of the file
will have any effect, and the subsequent redundant inclusions will be
harmlessly ignored.

Note that C/C++ programmers usually solve this same problem by enclosing
the entire contents of each header file in a protective series of
#ifdef-type directives. Each header file follows this pattern:

::: code
    #ifndef MY_HEADER_NAME_H
    #define MY_HEADER_NAME_H

    // the rest of the contents of the header go here

    #endif
:::

The idea is that, the first time this file is included, the preprocessor
symbol MY_HEADER_NAME_H (which is usually based on the name of the
header file: for myheader.h, we\'d use MYHEADER_H) will be undefined, so
the #ifndef (\"if not defined\") would succeed. Thus, everything between
the #ifndef and the matching #endif would be compiled, including the
#define for the same symbol. If the same file is included again,
MY_HEADER_NAME_H would be defined this time, because of the #define that
got compiled the first time around; so the #ifndef would fail, so the
compiler would skip everything up to the matching #endif.

### #pragma all_once

This directive turns \"all-once\" mode on or off. \"#pragma all_once +\"
turns all-once mode on, and \"#pragma all_once -\" turns it off.

By default, all-once mode is off. When all-once mode is on, the
preprocessor automatically adds each included file to the once-only list
at the moment when the #include for the file is encountered.

Once activated, all-once mode remains in effect until explicitly turned
off.

### #undef

This directive deletes - \"undefines\" - a macro that was previously
defined. This is useful because it lets you redefine a macro with a new
value. The syntax is:

::: syntax
    #undef macroName
:::

It\'s perfectly legal to undefine a macro that was never defined. This
is silently ignored; it doesn\'t even generate a warning.

## [Macros]{#macros}

### Substitution parameters

When you define a macro with a parameter list, any occurrences of the
parameter names in the macro\'s expansion text are replaced with the
actual values in each usage of the macro.

For example, suppose we define this macro:

::: code
    #define ERROR(msg)  tadsSay('An error occurred: ' + msg + '\n')
:::

Now suppose we write this in our code somewhere:

::: code
    ERROR('invalid value');
:::

During compilation, the preprocessor will expand this macro invocation,
substituting the actual parameter value when msg appears in the
replacement text. The resulting expansion is:

::: code
    tadsSay('An error occurred: ' + 'invalid value' + '\n');
:::

(It is worth pointing out that the compiler will subsequently compute
the constant value of this string concatenation, so this will not result
in any string concatenation at run-time.)

### Macros referencing macros

It\'s perfectly legal for a macro\'s expansion text to refer to other
macros.

Macro references within a macro\'s definition are expanded when a macro
is *expanded*, rather than when it\'s defined. This is important,
because it means that a macro\'s full, final expansion isn\'t set in
stone at the moment the macro is defined. It\'s not until the macro is
actually used that the full implications of its expansion can be known.
What\'s more, different occurrences of the same macro could have
radically different expansions due to changes in the other macros that
the first macro references.

Here\'s how this works: each time the preprocessor expands a macro -
that is, substitutes the macro\'s definition for an occurrence of the
macro name in the source text - the preprocessor \"re-scans\" the
expansion text to see if it contains any macros that need to be
expanded.

For example, consider the following:

::: code
    #define SUM(a, b)  (VAL(a) + VAL(b))
    #define VAL(a)     (a)

    local x = SUM(1, 2);

    #undef VAL
    #define VAL(a)     (-(a))

    local y = SUM(1, 2);
:::

There are two important things to note about this example. The first is
that our macro SUM references a macro named VAL that isn\'t even defined
yet at the point where SUM is defined. This is perfectly okay, because
of the delayed expansion behavior: since we won\'t try to expand macros
in SUM\'s definition until SUM is actually used, it doesn\'t matter
whether or not VAL is defined at the point where SUM is defined. The
second thing to notice is that we redefine VAL before using SUM for the
second time. Since SUM\'s expansion is re-scanned for other macros each
and every time it\'s used, this means that we\'ve effectively changed
the definition of SUM when we change the definition of VAL.

The code above will expand as follows:

::: code
    local x = ((1) + (2));
    local y = ((-(1)) + (-(2)));
:::

### Recursive macros

Despite the re-scanning rule for macro expansion, the preprocessor
doesn\'t expand macros recursively - that is, if a macro\'s expansion
contains a mention of the macro\'s own name, the recursive
self-reference is *not* expanded. Similarly, the preprocessor won\'t
expand circular references, where macro A\'s expansion contains macro B,
and macro B\'s expansion contains macro A.

There\'s no rule against writing a recursive-*looking* macro. Rather,
the prohibition on recursion is embodied in the ANSI C rules of macro
expansion. Basically, when a macro is being expanded, the preprocessor
temporarily \"forgets\" the macro, then remembers it again as soon as
the expansion is finished. So, for example, suppose you write this:

::: code
    #define hello(x) hello((x)+1)
:::

This macro *looks* like it would expand forever. If we wrote hello(1),
we\'d naively expect this to expand to hello((1)+1), which would in turn
expand to hello(((1)+1)+1), then to hello((((1)+1)+1)+1), and so on *ad
infinitum*. However, the rule against recursive macros prevents this.
Instead, the preprocessor simply forgets about the definition of hello()
while expanding it, so we simply get hello((1)+1) - and then we\'re
done.

The TADS 3 preprocessor uses the detailed ANSI C rules with regard to
recursive and circular macro definitions. These rules are quite complex
and only rarely come into play in real-world situations, so we won\'t
try to explain them in full here. Instead, we invite authors who feel
the need to know the full gory details to refer to an ANSI C programming
book.

### Macros with variable-length argument lists

A macro can be defined to take a varying number of arguments, which is
especially useful when the macro calls a function or method with a
varying number of parameters. Although the 1999 ANSI C specification
includes a varying macro argument feature, the ANSI C version is quite
limited. TADS 3 diverges here from the ANSI definition to provide a more
powerful facility.

To define a macro with varying arguments, place an ellipsis (\"\...\")
immediately after the last parameter in the macro\'s formal parameter
list:

::: code
    #define ERROR(msg, args...) displayError('Error:', msg, args)
:::

The \"\...\" after the last argument tells the preprocessor that the
macro allows zero or more arguments in place of the last parameter, so
the ERROR() macro defined above will accept one or more arguments. We
call this the \"varying argument\" - this single parameter name stands
in for zero, one, or more actual arguments each time the macro is used.

#### Simple expansion with the variable list parameter

During expansion, the parameter name of the varying argument will be
replaced by the entire varying part of the argument list, including the
commas between adjacent arguments, but not including the comma before
the first varying argument. For example:

::: code
    #define VAR(a, b...) { b }
:::

This macro will expand as follows:

::: code
    VAR(1) expands to { }
    VAR(1,2) expands to { 2 }
    VAR(1,2,3,4) expands to { 2,3,4 }
:::

#### Expansion with no variable arguments, and deleting the extra comma

If the varying part of the list contains zero arguments, note that it is
replaced by nothing at all. In some cases, this can be problematic; for
example, in the ERROR macro defined above, consider this expansion:

::: code
    ERROR('syntax error') -> displayError('Error:', 'syntax error', )
:::

Note the extra comma after the last argument to displayError - the comma
is from the original expansion text in the macro definition, not from
the parameter \"args\", which is empty in this case because no varying
arguments were supplied. The extra comma will cause a syntax error when
the function call is compiled, so the macro as written is not compatible
with an empty varying argument list, even though the preprocessor will
allow it.

To correct this problem, we can use a special feature of the
token-pasting operator (described in more detail below), \"##\". This
operator has a special meaning when it appears after a comma and before
a varying-argument macro parameter: when (and only when) the varying
list is empty, the \"##\" operator deletes the preceding comma. This
only works with commas - if anything else precedes the \"##\" operator,
the operator works as it would in normal (non-varying arguments) cases.
We can use this feature to rewrite the ERROR macro:

::: code
    #define ERROR(msg, args...) displayError('Error:', msg, ## args)
:::

Now when we expand this macro with no additional arguments, the extra
comma is deleted:

ERROR(\'syntax error\') expands to displayError(\'Error:\', \'syntax
error\')\
ERROR(\'token error\', 1) expand to displayError(\'Error:\', \'token
error\', 1)

(In case you\'re wondering where this bizarre kludge came from, the idea
is borrowed from the Gnu C compiler, which has the same feature. It\'s
not some random thing we invented, even though it might look that way.
It\'s a reasonably simple solution for the most common case, and it
doesn\'t seem to create any significant complications for other cases,
so we included support for it. Read on for our more general alternative
approach, though.)

#### Iterative expansion with #foreach

The comma-deleting feature of the \"##\" operator is useful as far as it
goes, but sometimes it\'s necessary to construct more elaborate
expansions from varying arguments. For example, suppose we wanted to
concatenate the arguments to the ERROR macro together - in other words,
we\'d like the expansion to look like this:

ERROR(\'token error\', 1, 2) expands to displayError(\'Error:\' +
\'token error\' + 1 + 2)

This is clearly beyond the scope of what we\'ve seen so far.
Fortunately, the TADS 3 preprocessor has another feature that makes this
sort of construction possible: the #foreach operator. This operator must
immediately follow - with no intervening spaces - the varying argument
name, and must be immediately followed with a \"delimiter\" character.
Following the delimiter is the main iteration expansion, which ends at
the next instance of the delimiter character. Following the second
delimiter is the \"interim\" expansion, which itself ends at the next
instance of the delimiter.

You can choose any non-symbol character for the delimiter, as long as it
doesn\'t appear in any of the expansion text - a non-symbol character is
anything that can\'t appear in a symbol, specifically alphabetic
characters, numerals, and underscores. The point of letting you choose
your own delimiter is to allow you to use anything in the expansion text
by choosing a delimiter that doesn\'t collide with the expansion.

Note that you should be careful if you choose a forward slash (\"/\") as
the delimiter - the preprocessor removes comments before processing
macros, so if you have an empty section, the compiler will completely
remove two consecutive slashes because it will think it indicates a
comment. You\'re probably better off avoiding using \"/\" as the
delimiter.

This sounds a bit complicated, so let\'s see an example:

::: code
    #define ERROR(msg, arg...) displayError('Error: ' + msg arg#foreach: +arg ::)
:::

The first part of the macro is simple:

::: code
    displayError('Error: ' + msg
:::

This part expands in the familiar way. Now we come to this sequence:

::: code
    arg#foreach: +arg ::
:::

Remember that the #foreach operator must appear immediately after the
varying argument name, as we see here. After the #foreach operator, we
have the delimiter; in this case, we\'ve chosen \":\", since we don\'t
need any colons in our expansion text. We could just as well have chosen
any other character; all that matters is that we don\'t need the
character anywhere in our expansion, since the next appearance of this
character terminates the expansion.

So, we have two sub-parts, delimited by colons. The first subpart is \"
+arg \", and the second subpart is empty.

The first subpart is the main iteration expansion. The preprocessor
expands this part once for each actual varying argument, expanding the
varying argument name in this part to merely the current argument in the
varying list. In the rest of the macro, remember that the varying
argument name expands to the full varying list; in a #foreach, though,
the varying argument name expands merely to the single, current
argument.

The second subpart is the interim iteration expansion. The preprocessor
expands this part once for each actual varying argument except for the
last one. This is why we call it the \"interim\" expansion - it\'s
expanded between iterations.

Let\'s look at how the macro expands. Consider this invocation:

::: code
    ERROR('syntax error')
:::

In this case, we have no varying arguments at all, so the entire
#foreach sequence - from the \"arg#foreach\" part to the final colon -
is iterated zero times, and hence expands to nothing at all. The
expansion is thus:

::: code
    displayError('Error:' + 'syntax error' )
:::

Note that we don\'t have any problem handling the zero varying
arguments, since the entire iteration simply occurs zero times in this
case.

Now consider what happens when we include some arguments:

::: code
    ERROR('token error', 1, 2)
:::

This time, the #foreach sequence is iterated twice. The first time,
\"arg\" expands to \"1\", since that\'s the first varying argument, and
the second time, \"arg\" expands to \"2\". The two iterations are
expanded like this:

::: code
    +1
    +2
:::

These are concatenated together, so the result looks like this:

::: code
    displayError('Error: ' + 'token error' +1 +2)
:::

The \"interim\" portion is useful for solving the same kinds of problems
as the \"##\" comma deletion feature, but is more general. Since the
interim portion appears only between each adjacent pair of varying
arguments, it is useful for building lists of zero or more arguments.
For example, suppose we want to write a macro that adds zero or more
values:

::: code
    #define ADD(val...) val#foreach:val:+:
:::

If we call this with no arguments, the expansion will be empty, because
we\'ll iterate the #foreach zero times. If we call this with one
argument, the result will simply be the argument: we\'ll iterate the
#foreach one time, but we won\'t include the interim expansion at all,
because we skip the interim expansion after the last argument. With two
arguments, we\'ll expand the interim once, between the two. Here are
some sample expansions:

::: code
    ADD() expands to nothing
    ADD(1) expands to 1
    ADD(1,2) expands to 1+2
    ADD(1,2,3) expands to 1+2+3
:::

#### Conditional expansion with #ifempty and #ifnempty

In some cases, it\'s necessary to include a block of text immediately
before or after the variable arguments, but only when the argument list
is non-empty. In other cases, it\'s necessary to provide some text
instead of the variable arguments when the variable argument list is
empty. A pair of operators, #ifempty and #ifnempty, provide these types
of conditional expansion.

The #ifempty and #ifnempty operators are similar in syntax to #foreach:
these operators must appear in macro expansion text directly after the
name of the variable argument formal parameter, with no intervening
spaces, and the operator is immediately followed by a delimiter
character. After the delimiter comes the conditional expansion text,
which is terminated by another copy of the delimiter character.

#ifempty includes its expansion text in the macro\'s expansion only when
the variable argument list is empty, and #ifnempty includes the text
only when the variable argument list is non-empty.

For example, suppose you want to define a macro that expands its
variable arguments into a concatenated list, and then passes the
concatenated list as the second argument to another function. We might
try defining this using #foreach:

::: code
    #define CALL_CONCAT(firstArg, args...) \
       myFunc(firstArg, args#foreach#args#+#)
:::

However, this has a problem: if the varying argument part of the list is
empty, we have an unnecessary comma in the expansion:

::: code
    CALL_CONCAT(test) -> myFunc(test, )
:::

This is similar to the problem that we mentioned earlier in describing
the \"##\" operator, but we can\'t use the \"##\" operator to delete the
comma in this case, because the \"##\" comma deletion works only when
the variable list argument appears directly after the \", ##\" sequence.

This is where the #ifempty and #ifnempty operators come in. In this
case, we want to include the comma after firstArg in the expansion only
when the argument list isn\'t empty, so we can change the macro like
this:

::: code
    #define CALL_CONCAT(firstArg, args...) \
       myFunc(firstArg args#ifnempty#,# args#foreach#args#+#)
:::

This does what we want: when the variable argument list is empty, the
#ifnempty expansion text is omitted, so we have no extra comma; when we
have one or more varying arguments, the #ifnempty expansion is included,
so the comma is included in the expansion.

#### Getting the variable argument count with #argcount

There\'s one more feature for varying argument lists: you can obtain the
number of varying arguments with the #argcount operator. Like #foreach,
the #argcount operator must appear immediately after the name of the
varying parameter, without any spaces. This operator expands to a token
giving the number of arguments in the varying list. For example:

::: code
    #define MAKELIST(ret, val...) ret = [val#argcount val#foreach#,val##]
:::

This expands as follows:

MAKELIST(lst) expands to lst = \[0\]\
MAKELIST(lst, \'a\') expands to lst = \[1,\'a\'\]\
MAKELIST(lst, \'a\', \'b\') expands to lst = \[2,\'a\',\'b\'\]

Note that #argcount expands to the number of arguments in the varying
part of the list only, and doesn\'t count any fixed arguments.

### Stringizing

It\'s sometimes useful to write a macro that uses the actual text of a
substitution parameter as a string constant. This can be accomplished
using the \"stringizing\" operators. The \# operator, when it precedes
the name of a macro formal parameter in macro expansion text, is
replaced by the text of the actual argument value enclosed in double
quotes. The #@ operator has a similar effect, but encloses the text in
single quotes. For example, suppose we wanted to write a debugging macro
that displays the value of an arbitrary expression:

::: code
    #define printval(val) tadsSay(#@val + ' = ' + toString(val))
:::

We could use this macro in our code like this:

::: code
    printval(MyObject.codeNum);
:::

This would expand as follows:

::: code
    tadsSay('MyObject.codeNum' + ' = ' + toString(MyObject.codeNum));
:::

### Token Pasting

In some cases, it\'s useful to be able to construct a new symbol out of
different parts. This can be accomplished with \"token pasting,\" which
constructs a single token from what were originally several tokens. The
token pasting operator, ##, when it appears in a macro\'s expansion
text, takes the text of the token to the left of the operator and the
text of the token to the right of the operator and pastes them together
to form a single token. If the token on either side is a formal
parameter to the macro, the operator first expands the formal parameter,
then performs pasting on the result.

For example, suppose we wanted to construct a method call based on a
partial method name:

::: code
    #define callDo(verb, actor)  do##verb(actor)
:::

We could use the macro like this:

::: code
    dobj.callDo(Take, Me);
:::

This would expand into this text:

::: code
    dobj.doTake(Me);
:::

The preprocessor scans a pasted token for further expansion, so if the
pasted token is itself another macro, the preprocessor expands that as
well:

::: code
    #define PASTE(a, b) a##b
    #define FOOBAR 123
    PASTE(FOO, BAR)
:::

The macro above expands as follows. First, the preprocessor expands the
PASTE macro, pasting the two arguments together to yield the token
FOOBAR. The preprocessor then scans that and finds that it\'s another
macro, so it expands it. The final text is simply 123.

Token pasting only works within macro expansion text; the token pasting
operator is ignored if it appears anywhere outside of a #define.

#### String Concatenation

When you use the \## operator to paste two tokens together, the
preprocessor checks to see if both of the tokens being pasted together
are strings of the same kind (i.e., they both have the same type of
quotes). If they are, the preprocessor combines the strings by removing
the closing quote of the first string and the opening quote of the
second string.

If either operand of the \## operator is itself modified by the \#
operator, the preprocessor first applies the \# operator or operators,
and then applies the \## operator. So, if you paste together two
stringized parameters, the result is a single string.

Here are some examples:

::: code
    #define PAREN_STR(a) "(" ## a ")"
    #define CONCAT(a, b) a ## b
    #define CONCAT_STR(a, b) #a ## #b
    #define DEBUG_PRINT(a) "value of " ## #a ## " = <<a>>"

    1: PAREN_STR("parens")
    2: CONCAT("abc", "def")
    3: CONCAT_STR(uvw, xyz)
    4: DEBUG_PRINT(obj.prop[3])
:::

After preprocessing, the file above would appear as follows:

::: code
    1: "(parens)"
    2: "abcdef"
    3: "uvwxyz"
    4: "value of obj.prop[3] = <<obj.prop[3]>>"
:::

Note that string concatenation is a TADS extension, and is not found in
ANSI C preprocessors. The C preprocessor doesn\'t provide a way of
combining string tokens because the C language (not the preprocessor,
but the language itself) has a different way of accomplishing the same
thing: in C, two adjacent string tokens are always treated as a single
string formed by concatenating the two strings together. The TADS
language doesn\'t allow this kind of implicit string pasting, because
(unlike in C) there are times when it is valid to use two or more
adjacent string tokens, such as in dictionary property lists. The TADS
preprocessor therefore provides its own mechanism for concatenating
string tokens.

#### Pre-defined Macros

The compiler provides several pre-defined macros that you can use to get
information about the compilation environment. Note that these macros
are defined by the **compiler** - they don\'t necessarily tell you
anything about the run-time environment, since they\'re fixed at compile
time, and don\'t change while the program is running.

**\_\_DEBUG** is defined as 1 for debug-mode builds, and is undefined
for release-mode builds. This means that you can use `#ifdef __DEBUG` to
conditionally include code for debug builds only, excluding the code for
versions that you release to users. The Adv3 library uses this feature
to include some debugging verbs in games only in debug builds, so that
the verbs are available while you\'re testing the game but won\'t be
included in releases.

**\_\_TADS_SYSTEM_NAME** is defined as a symbol giving the name of the
operating system where the compiler is running. (Note that this only
tells you where you **compiled** your program - it doesn\'t tell you
which system the program is actually executing on at run-time.) This
varies by operating system; on Windows, it\'s WIN32.

**\_\_TADS_SYS_xxx** is defined as 1, where **xxx** is the current
operating system symbol defined for \_\_TADS_SYSTEM_NAME. For example,
when compiling on Windows, \_\_TADS_SYS_WIN32 is defined as 1.

**\_\_TADS_VERSION_MAJOR** is the major version number of the compiler -
this will always be 3 for TADS 3.

**\_\_TADS_VERSION_MINOR** is the minor version number. This is the
second element of the dotted version string for the compiler: for
example, for TADS 3.0.15, this is 0; for 3.11.22, this would be 11.

**\_\_TADS3** is defined as 1. This provides an easy way to detect that
the compiler is a TADS 3 compiler (as opposed to a TADS 2 compiler,
say). (This is essentially redundant with \_\_TADS_SYSTEM_MAJOR, except
that if for some reason you wanted to write single-sourced code that
compiled under TADS 2 and TADS 3, using conditional compilation to
handle the syntax differences in the languages, you wouldn\'t have been
able to use \_\_TADS_SYSTEM_MAJOR, because TADS 2 doesn\'t have an
equivalent of the #if feature for macro expression evaluation.)

**\_\_DATE\_\_** is defined as a single-quoted string giving the date at
which the compilation started, in the format \'MMM dd yyyy\', where MMM
is the three-letter month abbreviation, dd is the day of the month in a
two-digit format, and yyyy is the four-digit year. For example, August
15, 2008 would be represented as \'Aug 15 2008\'.

**\_\_TIME\_\_** is defined as a single-quoted string giving the time at
which compilation started, in the format \'hh:mm:ss\', where hh is the
two-digit hour on the 24-hour clock (midnight is 00, noon is 12, eleven
PM is 23, etc.), mm is the two-digit minute of the hour, and ss is the
two-digit second within the minute. For example, half past noon is
represented as \'12:30:00\'.

**\_\_LINE\_\_** is a always defined as the current line number within
the current source file that the compiler is scanning. The line
numbering starts at 1 in each file, and increases by 1 at each newline
(usually a carriage-return, line-feed, or combination of the two,
depending on local conventions).

**\_\_FILE\_\_** is always defined as a single-quoted string giving the
name of the source file that the compiler is scanning.

\_\_FILE\_\_ and \_\_LINE\_\_ sometimes come in handy for debugging
purposes, since they let you flag the source file location of a
particular bit of code for examination at run-time. This is especially
useful within macros, because \_\_FILE\_\_ and \_\_LINE\_\_ are always
expanded at the last possible moment - if you use them within a macro,
they won\'t be expanded until the containing macro is itself expanded,
which means they\'ll yield the source location of the code that
ultimately invoked the macro rather than the location of the definition
of the macro.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> The Preprocessor\
[[*Prev:* Source File Character Sets](charmap.htm){.nav}     [*Next:*
Fundamental Datatypes](types.htm){.nav}     ]{.navnp}
:::
