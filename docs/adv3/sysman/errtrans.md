::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [Translating and Localizing
TADS](local.htm){.nav} \> Translating Error Messages\
[[*Prev:* Translating and Localizing TADS](local.htm){.nav}     [*Next:*
Creating a Character-Mapping File](cmap.htm){.nav}     ]{.navnp}
:::

::: main
# Translating Error Messages

The TADS 3 Compiler and Interpreter can display system error messages in
any language. By default, the programs use English messages, but this
can be changed.

The compiler and interpreter use external message files to provide
non-English messages. (The English messages are built in to the
programs, so no external message file is required for the English
messages. This ensures that a set of messages is always available, even
when an external message file isn\'t installed.)

To configure the programs to use non-English messages, you must put
messages files into the directory containing the compiler and
interpreter executables. These files always have the same names:

Interpreter: T3_VM.msg\
Compiler: t3make.msg

When the interpreter starts running, it looks for a file called
\"T3_VM.msg\"; the interpreter looks in the directory containing the
interpreter\'s executable file (its \"application\" file). Similarly,
the compiler looks for a file called \"t3make.msg\" in the directory
containing its executable.

If the programs do not find their respective message files, they simply
use the built-in English messages. The programs do not display any error
message when there is no external message file, since they assume that
the user simply wishes to use the built-in English messages.

## Creating a Message File

TADS\'s author is not sufficiently multilingual to create error message
files in all of the languages in which uses might be interested. So,
instead of attempting to provide translations for the system messages,
we have provided a tool that translators can use to create localized
messages.

To create a translated message file, you start with a message source
file, which uses a simple text format, and use a message compiler to
create a \".msg\" file that the TADS programs can load.

The format of the message source file is simple. For each message, you
list the message ID, which is a code number that the system uses
internally to identify the message; a short message; and a long message.
The short message is a brief, usually one-sentence version of the
message, and the long message is a longer explanation. The two versions
are provided to allow the user to select the level of message detail;
for example, the compiler by default displays short messages, but the
\"-v\" (\"verbose\") option lets the user select the long messages
instead.

The message ID and the short message normally go on a single line, but
you can put them on separate lines. The long message always starts on
the next line after the short message, and goes on until the next blank
line.

Messages are separated by one or more blank lines. Comments are lines
starting with two slashes ([//]{.code}), but comments cannot appear in
the middle of a message, so a comment must always be preceded by a blank
line (or appear at the start of the file).

Two special directives let you control compilation.

The [#charset]{.code} directive lets you specify the character set that
the message file uses. You must provide a [#charset]{.code} directive
before the first message, because the message compiler must know what
character set you\'re using. The message file is stored in Unicode
format, like everything else in TADS 3, so the compiler must know the
source file character set in order to translate it properly. The line
looks like this:

::: code
    #charset "cp437"
:::

The character set name is in the same format that the compiler and
interpreter use. For Windows, this is always \"cp\" followed by the code
page number. For other platforms, check your release notes for details
on local conventions.

The [#include]{.code} directive lets you include a header file. Unlike
the TADS compiler itself, you can only include files from the main file
(included files cannot themselves include other files). Furthermore,
#include files have only one purpose: they define symbolic message
ID\'s. You should normally include the following file, depending on
which type of message file you\'re creating:

Interpreter: [#include \"vmerrnum.h\"]{.code}\
Compiler: [#include \"tcerrnum.h\"]{.code}

## Compiling

To compile a message file, you use the t3msgc tool. If you\'re using a
command-line operating system, you run the t3msgc program with two
arguments: the first is your source file, and the second is the \".msg\"
file you wish to create. For example, suppose you created a source file
called \"vm_deu.txt\" with German messages for the interpreter, and you
wish to compile it to create vm_deu.msg. You\'d use a command like this:

::: cmdline
    t3msgc vm_deu.txt vm_deu.msg
:::

The compiler has one option: -strict, which displays a warning for every
defined symbolic message ID that has no message. You can use this option
to ensure that you have defined a message for every symbolic ID (if you
didn\'t do this, the interpreter or compiler would display a \"message
not found\" error if it should ever have to display one of the messages
you didn\'t defined).

::: cmdline
    t3msgc -strict vm_deu.txt vm_deu.msg
:::

To install the message file so that the interpreter or compiler actually
starts using it, simply copy it to the appropriate filename for the type
of message file (\"t3_vm.msg\" or \"t3make.msg\") and place it in the
same directory as the interpreter or compiler executable.

## Sample Message File

Here\'s an example of a message file. This file only defines two
messages, so a real message file would obviously be a lot longer, but
this file has all of the essential elements and will compile properly.

::: code
    #charset "cp1252"
    #include "vmerrnum.h"

    VMERR_IMAGE_NO_CODE image contains no code
    This image file contains no executable code.  This file
     might be corrupted.

    VMERR_IMAGE_INCOMPAT_HDR_FMT 
    incompatible image file format; method header too old
    This image file has an incompatible method header format.
     This is an older image file version which this interpreter
     does not support.
:::

The first line specifies the character set, which in this case is
Windows code page 1252 (the Windows US/Western Europe code page).

The second line includes \"vmerrnum.h\"; this is an interpreter message
file, so this is the appropriate header for this file.

Next, after the blank line, we have our first message. The message ID is
\"VMERR_IMAGE_NO_CODE\", a symbolic message identifier that you will
find in vmerrnum.h. Immediately following the identifier on the same
line is the short message text. The next line begins the long message,
which goes on for two lines.

Note that the second line of the long message starts with a space. When
the compiler reads your messages, it keeps all of the whitespace at the
beginnings and ends of the long message lines, except that it removes
any embedded newlines (line breaks). In other words, the compiler
strings together all of the lines of the long message into a single line
of text; we must therefore explicitly put in any spacing we want between
words across lines. We could just as well have put the space at the end
of the previous line, but it\'s much easier to see whitespace when it\'s
at the beginning of a line, which is why we\'ve done so here.

The second message follows the blank line after the first long message.
Messages are always separated by blank lines.

Note that we have chosen to put the identifier for the second message on
one line, and the short message on the next line. This is equivalent to
putting both on one line, but in this case the short message is a bit
lengthy, so it\'s easier to read when it\'s on a separate line from the
message ID.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [Translating and Localizing
TADS](local.htm){.nav} \> Translating Error Messages\
[[*Prev:* Translating and Localizing TADS](local.htm){.nav}     [*Next:*
Creating a Character-Mapping File](cmap.htm){.nav}     ]{.navnp}
:::
