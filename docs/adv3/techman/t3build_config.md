![](topbar.jpg)

[Table of Contents](toc.htm) \| [Fundamentals](fund.htm) \> Using Build
Configurations  
[*Prev:* Some Common Input/Output Issues](t3inout.htm)     [*Next:*
Understanding Separate Compilation](t3inc.htm)    

# Using Build Configurations

One of the facts of life of computer programming is that it takes at
least as much time to test and debug a program as it does to write it in
the first place. Interactive debugging tools like TADS Workbench can
help enormously in testing a program, but sometimes the easiest way to
track down a problem is to "instrument" the code: adding extra
statements to the program that test for unusual conditions, print out
extra debugging information, and so on. In an adventure game, it's also
often handy to add special commands to the game for testing purposes,
such as commands that magically move characters and objects around the
game.

The problem with adding instrumentation, extra testing commands, and
other "debug-mode" code is that you don't want to include it in the
final game. You *could* just go through the game before you release it
and delete all of the extra debug-mode code, but that's tedious and
error-prone; it's easy to miss something, and it's easy to just forget
to do it in the first place. It's also a terrible approach if you're
going to release another version of the game later, because you might
want to bring back all of that debugging code.

This problem isn't unique to adventure games - it comes up in almost any
kind of programming. Fortunately, it comes up so often in "real"
programming that it's been pretty well solved. This article explains how
to use the TADS 3 tools to create separate debug and release versions of
your program *without* having to manually edit your code before
releasing it.

## Configurations and TADS Workbench

TADS Workbench specifically supports creating separate debug and release
builds of your game. In the Build menu, there are two ways to compile
your game to a ".t3" file: you can Compile for Debugging, or Compile for
Release.

**Compile for Debugging** creates the debug build of your game, which is
what you must use if you want to step through your game with the
Workbench debugger. The debug build includes extra symbol information in
the .t3 file that lets the debugger figure out the names of your objects
and properties as the program runs.

**Compile for Release** creates the release build of your game. This is
what you'd normally want to distribute to players. The release version
of the .t3 file does *not* include any debugger symbol information,
which makes the file a lot smaller. In addition, the compiler is able to
generate slightly smaller code for a release build, because it can
eliminate instructions that don't end up doing any work; the debug
version often has to include do-nothing instructions so that the
debugger can show the proper original source location when stepping
through the code.

In the Build Settings dialog, on the Output page, note that the debug
and release versions of the .t3 file have separate filename boxes. When
you Compile for Debugging, Workbench writes out the .t3 file you specify
for the debug build; when you Compile for Release, Workbench creates the
separate .t3 file you specify for the release build.

## Configurations and the command-line compiler

The command-line compiler generates the release build by default. If you
want to create a debug build, you must specify the "-d" option. If
you're using a project (.t3m) file, which you usually should, you just
add the "-d" option before naming the project file:

       t3make -d -f mygame

The "-d" option tells the compiler to include the symbolic debugging
information, just like the Workbench "Compile for Debugging" command.
(In fact, the Compile for Debugging command in Workbench simply invokes
the compiler with the "-d" option.)

## Using `#ifdef __DEBUG`

Now that we've covered the mechanics of how you actually create the two
different types of build, we can talk about how you put different code
in the different versions. The key is the \#ifdef preprocessor
directive, with the \_\_DEBUG symbol.

If you're not familiar with C or C++, \#ifdef is probably a new idea for
you. In brief, \#ifdef tells the compiler to keep or discard a block of
source code, according to whether or not a preprocessor symbol is
defined ("ifdef" is an abbreviation for "if defined"). The important
thing to understand is that \#ifdef is superficially similar to an "if"
statement in your program, but it's really a different kind of animal.
The "if" statement causes some code to be executed, or not, according to
a condition that's evaluated each time the statement is reached in the
running program. In contrast, \#ifdef is a directive to the compiler
itself, telling the compiler to keep the code, or not, according
**only** to the conditions that hold **when the program is compiled**.
Once the program is compiled, the code inside the \#ifdef is either
included in the program or not; the question is never revisited when the
program is executed. This is why \#ifdef is such a great feature for
managing different build configurations: it lets you write essentially
two (or more) programs in a single source file, with the compiler
selecting which program to generate each time you compile.

When you're compiling for debugging, the compiler automatically defines
the preprocessor symbol \_\_DEBUG (that's two underscores at the
beginning of the name). When you compile for release, the compiler does
*not* define this symbol. This means that if you want to include some
code only in a debug version of your program, you simply do this:

      #ifdef __DEBUG

      // my debug-mode-only code

      #endif

Similarly, if you want to include some code only in the release version
of your game, you can do it like so:

      #ifndef __DEBUG

      // my release-mode-only code

      #endif

The \#ifndef directive is essentially the opposite of \#ifdef - it tells
the compiler to include the given code only if the named symbol is *not*
defined.

If you have one bit of code you want to include in the debug version of
your game, and a corresponding bit you want to include only in the
release version, you can use both of the constructs above, obviously.
Or, slightly more concisely, you can use \#else:

      #ifdef __DEBUG

      // my debug-mode-only code

      #else

      // my release-mode-only code

      #endif

## Including library modules conditionally

In some cases, your debug-mode or release-mode version might have a
dependency on a library module that doesn't exist in the other mode. For
example, you might want to include some extra code in your debug build
that uses the "reflection" mechanism, defined in the library module
reflect.t. Since you only require reflect.t in your debug build, you
probably want to omit it from your release build, to minimize the size
of the final .t3 file.

The way to accomplish this in TADS 3 is a little roundabout, but it's
relatively easy. Basically, you use \#ifdef to include or not include an
entire library module.

The first step is to create your own file that corresponds to the
library file you want to include. For example, suppose you want to
include reflect.t, but only in your debug build; so, create your own
file corresponding to reflect.t, but call it dbg_reflect.t. (The "dbg\_"
prefix emphasizes that the file is involved in the debug build.)

Second, inside the new file (dbg_reflect.t, in our example), put code
like this:

      #charset "us-ascii"
      #ifdef __DEBUG
      #include <reflect.t>
      #endif

That's the entire file; you don't put any other source code in this
file. (For that matter, even the \#charset directive isn't strictly
required, since US-ASCII is a subset of essentially any 8-bit character
set that the compiler recognizes. But it doesn't hurt to include it, if
only for documentary purposes.)

Finally, add the new file to your project (i.e., add it to your
project's .t3m file with a "-source" directive, or add it to the source
file list in Workbench). Note that you must **not** include the original
library file in your project - you include *only* your special cover
version of the file.

Here's how this works. Regardless of what kind of build your create,
your new file - dbg_reflect.t - is always included in the build. If
you're compiling for debugging, the \_\_DEBUG symbol is defined, so the
compiler "sees" the \#include directive that includes the underlying
library file. So, the compiler brings in the library file's entire
contents at that point, which means its code is properly included in the
build. When you compile for release, however, the \_\_DEBUG symbol
*isn't* defined, so the compiler *doesn't* see the \#include directive.
So, your dbg_reflect.t file looks completely empty to the compiler. The
compiler is perfectly happy to accept an empty file; the empty file
simply doesn't contribute anything to the build, and it doesn't increase
the size of the final .t3 file.

Note that we would normally discourage using \#include with a ".t" file,
because you should normally use separate compilation instead. However,
it's okay in this case, because we're not diluting the value of separate
compilation at all; since dbg_reflect.t doesn't contain any other code,
it's simply standing in for the underlying reflect.t. In other words,
reflect.t's code is still being compiled separately from that of your
other source modules; it's just that it's being pulled in indirectly,
through your new file.

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](toc.htm) \| [Fundamentals](fund.htm) \> Using Build
Configurations  
[*Prev:* Some Common Input/Output Issues](t3inout.htm)     [*Next:*
Understanding Separate Compilation](t3inc.htm)    
