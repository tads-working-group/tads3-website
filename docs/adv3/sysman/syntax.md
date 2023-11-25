::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [Opening Moves](begin.htm){.nav}
\> Typographical Conventions\
[[*Prev:* Introduction](intro.htm){.nav}     [*Next:* Naming
Conventions](naming.htm){.nav}     ]{.navnp}
:::

::: main
# Typographical Conventions

Like many technical manuals, this book uses some special typographical
effects to convey certain information. We do this for the sake of
clarity and concision, but the trade-off is that readers have to know
our special conventions to understand what we\'re trying to say. This
section provides a quick guide to our notation.

The conventions we use are very similar to those of most other software
manuals. There\'s no \"official\" standard for this sort of notation,
but the software industry has largely converged on some common elements
that cover most needs. So, if you\'ve ever used other software books,
you\'ll probably find that you\'re already familiar with our notation.

## Command Lines

Example command lines are shown like this:

::: cmdline
    copy c:\*.* d:\backup
:::

When you see something like this, it\'s an example of something you\'d
type exactly as shown into your computer\'s command shell, or into some
other program\'s command line. It\'s implied that you must press the
Enter or Return key when you\'re done typing a command line like this.

## Program Code

We show example program code like this:

::: code
    #include <tads.h>
    main(args)
    {
       "Hello, world!\n";
    }
:::

This shows a snippet of code that you\'d type into a source file,
exactly as shown. Note that most examples like this are only fragments
of code - they\'re not meant to represent the entire contents of a
source file, but rather are just a portion pulled out to illustrate the
point being made.

## Syntax Diagrams

Throughout this manual, we need to explain the syntax for certain
things: program statements, command lines, control file entries, and so
on. \"Syntax\" basically means grammar: it\'s the set of rules governing
the order and contents of a particular piece of text input.

To explain syntax, we often use \"syntax diagrams.\" These are basically
templates describing the rules of syntax for a particular type of input.
In most cases, *parts* of a syntax diagram are things that you type
literally (that is, exactly as shown), while other parts are just
placeholders, indicating places in the input where you\'d substitute
something else. The \"something else\" is usually limited in a way
described in the rule - it might be that you have to enter a number
there, or the name of a file, or one of a few special keywords.

Note that we use both type style (italics, \"typewriter\" font) and
color to differentiate the roles of syntax elements. The color is a
secondary feature, though - you can always tell the role of an element
by its type style alone. We use colors to make it easier to read a
diagram at a glance, but we recognize that some people can\'t easily
differentiate certain colors, so we\'ve designed the format so that you
can rely entirely on the type style if you need to.

[literal]{.synLit}

When you see something like this, you have to enter it \"literally\" -
exactly as shown.

[param]{.synPar}

This style indicates a \"parameter.\" This is a placeholder: you don\'t
literally type \"param\" here, but rather you enter something else that
the parameter stands for. For example, [filename]{.synPar} might
indicate that you substitute the name of a file here, and
[number]{.synPar} might mean that you have to enter a number.

[\[ \]]{.synMark}

Square brackets written like this indicate an item or items that are
*optional*. You can either include the contents of the brackets, or omit
them entirely.

[\...]{.synMark}

An ellipsis written like this indicates that the preceding item can be
repeated one or more times.

[\|]{.synMark}

This indicates that you must choose one of the items on either side of
the bar. This can be repeated to indicate that you must choose one of
three or more items. For example:

::: syntax
    A | B | C | D
:::

This mean that you must enter exactly one of A, B, C, or D. The bar
applies out as far as the nearest enclosing parentheses or square
brackets.

[( )]{.synMark}

Parentheses are used to group a set of \"\|\" items.

### Whitespace

In most cases, the whitespace shown in these syntax diagrams isn\'t
significant. That is, the spacing is just there to make the syntax
diagram easier to read; you don\'t have to enter it when you type your
input, but you can if you want. This isn\'t universally true, though.
For example, there are times when a space is required, because it would
otherwise be impossible to tell where one item ended and the next one
started. Usually, if there\'s a punctuation mark of some kind separating
two items, you don\'t need any extra spaces, since the punctuation
serves as a clear separator; if there\'s no punctuation mark, you
usually do need a space to separate two items.

### Examples

Here are a couple of examples to illustrate how these diagrams look in
practice.

::: syntax
    copy [ /b | /a ]  sourceFile destinationFile
:::

This is the basic syntax for the MS-DOS \"copy\" command. It means that
you enter the word \"copy\" literally, followed by an *optional* \"/b\"
*or* \"/a\" switch, followed by a source and destination filename. Note
that we\'ve combined the \"\|\" vertical bar notation with the \"\[ \]\"
optional-item notation: everything within the brackets is optional, but
if you do include it, you must choose one of the two options listed.

::: syntax
    ls [ -l ]  [ file ... ] 
:::

This is a minimal syntax for the Unix \"ls\" (list files) command. It
says that you type the word \"ls\" literally, followed by an optional
\"-l\" option, followed by an optional list of files. Note that the
entire file list is optional, since it\'s enclosed in brackets. In
addition, if you do type a file list, you can type any number of files,
as indicated by the ellipsis.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [Opening Moves](begin.htm){.nav}
\> Typographical Conventions\
[[*Prev:* Introduction](intro.htm){.nav}     [*Next:* Naming
Conventions](naming.htm){.nav}     ]{.navnp}
:::
