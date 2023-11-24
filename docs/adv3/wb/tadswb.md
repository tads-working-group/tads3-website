Help Topics \> [Table of Contents](wbcont.htm)  
  

  
  
  
![](../htmltads.jpg)  

# TADS Workbench

  
  

## Overview

TADS Workbench is an integrated environment for writing TADS games. TADS
Workbench lets you run the compiler, resource bundler, executable
builder, and debugger, all with simple menu commands, eliminating the
need to enter complex command lines to run the compiler and other tools.
TADS Workbench also lets you view and edit your source files with a
full-featured built-in text editor.

## Starting a New Game

TADS Workbench includes a "Wizard" that creates a starter game for you
automatically. All you have to do is answer a few questions to tell TADS
where to put your game files. See [Creating a New Game](newgame.htm) for
step-by-step instructions.

## Loading an Existing Game

If you've already created your game's source files, you can load the
game into TADS Workbench from either the source file or the compiled
game file:

- Open TADS Workbench.
- At the "Welcome" dialog, select "Open an Existing Game." (If you've
  disabled the Welcome dialog, open the "File" menu, then select "Load
  Game.")
- Select either your game's source file (which usually ends in ".t") or
  your game's compiled game file (which usually ends in ".t3"). You can
  also select your game's "project" file, whose name is the same as the
  game file's, but ends in ".t3c" (for "TADS 3 Configuration"). You
  don't directly created .t3c files; Workbench creates one of these for
  you automatically the first time you load a particular game.
  - If you select a .t3 or .t3c file, TADS Workbench will load the game
    and you'll be ready to start working.
  - If you select a source file, TADS Workbench will ask you to identify
    the compiled game file. The project file for your game always goes
    with your compiled game file, not your source file, so TADS
    Workbench can't identify your game's project file based on the
    source file alone.
- If your game doesn't already have a project file, TADS Workbench will
  create one.

## Editing Source Code

Workbench has a built-in text editor that you can use to edit your
source code. The integrated editor is a popular programmer's text editor
called Scintilla, which has all the features you'd expect from a
programmer's editor: multi-level undo, syntax coloring, automatic
indenting, and much more.

Remember that when you make changes to your source code, you must always
**save** and **compile** before the changes will take effect. If you run
without recompiling, you'll still be running the old version of your
game.

If you prefer to use a separate text editor application to edit your
source code, you can use the "External Editor" page of the Options
dialog to tell Workbench how to open your editor program. Refer to
[Using an External Editor](helped.htm) for details.

## Searching the Documentation

The Search toolbar lets you search for keywords in the TADS
documentation. This works a lot like a Web search - you just type the
keywords you want to find and press Return. Workbench will open a window
showing the documentation pages that match your search, showing the
"best" (most relevant) matches first.

Note that the Search toolbar has a little button next to the search box
that lets you change the type of search it performs. Use the drop-down
menu to change the search type. Make sure that "Search User's Manuals"
is selected when you want to perform a documentation search.

The doc search system has some special syntax that you can use to
customize the search. By default, the search system looks for pages that
contain **every** word you enter, allowing for common variations in the
words - for example, if you type `operator`, the search will also match
variations like operators, operating, operated, and so on.

If you want to look for pages that contain **any** of several words, you
can separate the words with the keyword OR. (The keyword must be entered
in **all upper case letters**.) For example, if you type
`operator OR expression`, the search will find pages that contain
*either* of those words (again, including common variations on the
words).

You can also **exclude** words from the search, by preceding each word
you want to exclude with the keyword NOT (which must be in **all upper
case letters**). For example, if you type `operator NOT expression`, the
search will find pages that contain "operator" (and common variations),
and will exclude any pages that also contain "expression" (or
variations).

If you want to search for an **exact word**, without allowing the search
system to look for common variations of the word, enclose the word in
double quotes. For example, `"operator"` will find only that word, not
variations like operators, operated, etc.

You can also use quotes to look for an **exact phrase**, in cases where
you want to find two or more words in a particular order. For example,
`"addition operator"` would find only pages containing that exact
phrase.

## Searching in Files

Workbench provides several ways to search for text in the files in your
project.

The Search bar lets you perform a quick search of the current text
editor window or of the entire project's text files. Use the drop-down
menu next to the search box to select which type of search you'd like to
perform, then type the text you'd like to find and press Return. If you
perform a Current File search, Workbench will simply highlight the next
instance of the text in the file. If you perform a Project search,
Workbench will open a window showing a list of the matching lines
throughout the project - click on a match to jump to that file location.

Unlike the Documentation search system, File and Project searches do
**not** use the "keyword" search system. So, these searches don't look
for variations on the words you type, and they don't allow the OR or NOT
keywords or the quoting syntax. Instead, File and Project searches
simply look for the **literal text** you enter. The search is
case-insensitive (meaning that it ignores upper-case and lower-case
differences in the text), but otherwise looks for exactly the text you
enter.

If you want more File search options, use the Find command on the Edit
menu. This lets you perform regular-expression searches (these are like
"wildcard" searches, but more powerful - you can use the full TADS 3
regular expression syntax, which you can read about in the TADS 3
manuals if you search for "regular expressions"), case-sensitive
matching, and whole-word matching.

If you want more Project-wide search options, use the Find in Project
Files command on the Project menu. This lets you specify regular
expression, exact-case, and whole-word searches throughout the project.

**Collapsing spaces:** When you perform a project-wide search (the Find
in Project Files command), the search dialog has a checkbox labeled
"Collapse spaces and newlines." If you select this checkbox, the
searcher will "collapse" each run of whitespace it finds in each file
before searching the file. That is, the searcher looks for any series of
whitespace characters (spaces, tabs, and newlines), and converts each
consecutive series of these characters into a single space. It then
searches the result for your search string or regular expression
pattern.

A big benefit of this feature is that it allows the searcher to match
your string or pattern even when the matching text in the file is split
across two or more lines. This is especially useful when you're
searching for a term that occurs in paragraphs of text, such as in long
description strings - long strings in source code are often broken up
over several lines for readability.

Note one bit of caution you have to use with this feature: you have to
be careful to avoid putting multiple consecutive spaces in your *search*
string. If you do, the term will never match anything when the "collapse
spaces" option is in effect, because all runs of multiple spaces will be
stripped out of the source text before it's searched.

## Compiling

TADS Workbench offers a graphical interface to the TADS compiler,
resource bundler, and executable builder. To compile your game, first
configure your compilation options by opening the "Build" menu and
selecting "Settings," then compile by opening the "Build" menu and
selecting the appropriate "Compile" command. See [Compiling with TADS
Workbench](helpcomp.htm) for details.

## Debugging

The core of TADS Workbench is the TADS Debugger. After you've compiled
your game, you can run it within TADS Workbench by using the "Go"
command (on the toolbar or in the "Debug" menu). The [Debugger
Overview](helptdb.htm) describes the debugger in greater detail.

## Project Files (.t3c)

TADS Workbench stores information on your game in a special file called
a "project file." A project file contains information of interest only
to TADS Workbench; you don't need to edit this file directly.

Each game has its own separate project file, because the information in
the file is specific to the game. The project file for a game always has
the same name as the compiled game file, with the ".t3" suffix replaced
by the ".t3c" suffix, and is always in the same directory as the
compiled game file.

The project file contains information on the window layout, debugger
breakpoints, option settings, and build parameters.

TADS Workbench will always create a new project file for you when you
open a game that doesn't already have a project file. You don't need to
do anything special to create or manage project files; TADS Workbench
handles them automatically without requiring any action on your part.

Note that, when loading a game, you can load the .t3c file or the .t3
file; the two are interchangeable for the purposes of loading a game
into TADS Workbench.  
  
  
  
  

------------------------------------------------------------------------

  
Help Topics \> [Table of Contents](wbcont.htm)  
  
Copyright ©1999, 2007 by Michael J. Roberts.
