::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> RexPattern\
[[*Prev:* Object](objic.htm){.nav}     [*Next:*
StackFrameDesc](framedesc.htm){.nav}     ]{.navnp}
:::

::: main
# RexPattern

A RexPattern object stores the internal representation, known as the
\"compiled\" version, of a regular expression pattern. The internal
details of the compiled representation aren\'t important, and the
program can\'t access the compiled data directly.

Every time the program performs a search involving a regular expression
(using the [[rexMatch()]{.code}, [rexSearch()]{.code}, or
[rexReplace()]{.code} functions](tadsgen.htm#rexmatch)), the system must
work with the compiled form of the search pattern. The simplest way to
call these functions is to pass them a string giving the search pattern,
but when the program does this, the system must compile the string,
which converts the string to the internal representation. This
compilation process is relatively time-consuming; typically, compiling
the pattern takes about half the time involved in performing a regular
expression search.

The purpose of the RexPattern class is to let the program perform this
compilation work just once for a given pattern string, and then re-use
the same compiled representation every time the program searches for the
pattern. If a given pattern is used repeatedly, this can improve the
program\'s efficiency by avoiding repeated compilation of the same
pattern string.

## [Regular expression literals]{#rexlit}

You can define a static RexPattern object using the regular expression
literal syntax:

::: code
    local r = R'%w+';
:::

That defines a static RexPattern object that matches any series of one
or more \"word\" characters.

The regular expression literal syntax consists of a capital \"R\"
followed immediately (with no intervening spaces) by an open quote.
Single and double quotes are interchangeable for \"R\" strings - they
have exactly the same meaning, but of course the ending quote must match
the open quote. You can also use the triple-quote syntax with \"R\"
strings:

::: code
    local r2 = R"""%w"%w""";
:::

That creates a pattern that matches a word character followed by a
double quote followed by a word character. (In this case the triple
quotes aren\'t really necessary, in that it might have been easier to
just use single quotes to delimit the string: [R\'%w\"%w\']{.code}.)

The embedding expression syntax, [\<\< \>\>]{.code}, isn\'t allowed in
regular expression literals.

## RexPattern creation

You can create a RexPattern object dynamically using the [new]{.code}
operator, giving the pattern string as the argument:

::: code
    local pat = new RexPattern('a.*b');
:::

This creates the pattern object and compiles the pattern string. You can
now use the object in the regular expression search and match functions
([rexMatch()]{.code}, etc.) in place of the pattern string. The
functions will behave exactly as though you had used the original
pattern string, except that they will run a little faster, because they
won\'t need to compile the string.

## RexPattern methods

The class provides the standard Object intrinsic class methods, plus the
following:

[getPatternString()]{.code}

::: fdef
Returns the original string used to create the object (i.e., the string
passed as the argument in the \"new\" expression that created the
object).
:::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> RexPattern\
[[*Prev:* Object](objic.htm){.nav}     [*Next:*
StackFrameDesc](framedesc.htm){.nav}     ]{.navnp}
:::
