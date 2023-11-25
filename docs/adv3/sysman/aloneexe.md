::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Tools](tools.htm){.nav} \>
Stand-Alone Executables\
[[*Prev:* Universal Paths](univpath.htm){.nav}     [*Next:* Running
Programs: The Interpreter](terp.htm){.nav}     ]{.navnp}
:::

::: main
# Stand-Alone Executables

For ease of distribution, you can create a \"stand-alone executable\"
version of your game for some operating systems. A stand-alone
executable combines a TADS 3 interpreter executable and your program\'s
image (.t3) file into a single file, which is a native application
executable file for the target operating system. This file contains
everything a player needs - in particular, the player won\'t have to
find or install the TADS interpreter.

Bundling your game as a stand-alone executable has some advantages and
some disadvantages. The main advantages are:

-   The total number of files you have to distribute is reduced, since
    the interpreter and your game\'s image file are combined into a
    single file.
-   Users don\'t have to worry about finding or downloading a TADS 3
    interpreter program, so you don\'t have to worry about including one
    with your game or telling users where to find one.
-   Users have fewer files to manage, so it\'s easier for a user to move
    your game to a new directory or delete your game from their hard
    disk.
-   Most people feel that a stand-alone program has a more professional
    and polished appearance than one that requires a separate
    interpreter program.

There are some disadvantages, however, that you should be aware of:

-   If you\'re distributing your program via the internet, a stand-alone
    executable version will be much larger than the .t3 version, because
    the entire TADS 3 interpreter is included with your download.
-   If a player already has a TADS interpreter installed on his or her
    machine, downloading the extra copy incorporated into a stand-alone
    game would unnecessarily take additional download time and consume
    additional space on the hard disk.
-   A stand-alone version of your game is not portable to different
    operating systems or computer hardware. Users can only run a
    stand-alone executable on the type of system supported by the
    bundled interpreter. You must therefore either limit your game to a
    particular set of platforms, or create a separate stand-alone
    executable for each platform.

Because of the trade-offs involved in distributing a stand-alone
version, many game authors prefer to create stand-alone versions for a
couple of platforms, and also distribute a .t3 version. This way, you
can provide a stand-alone executable for those who want it, while still
making it possible for users on other platforms to run the program, and
still allowing people who already have a TADS 3 interpreter installed to
bypass the redundant download and installation.

## Creating a Stand-Alone Executable

The exact method you use to create a stand-alone executable varies by
interpreter, and not all interpreters have this capability. If you
don\'t see your platform listed below, refer to your platform-specific
release notes.

### Workbench for Windows

If you\'re using TADS 3 Workbench, creating a stand-alone executable is
easy. First, go to your project\'s Build Settings (via the Settings item
on the Build menu), and select the Output tab. Go to the \"Executable
(.EXE) file\" field: this lets you specify the name of the generated
.exe file. When you create a project, Workbench picks a default for this
setting based on the name of the project, so if you\'re happy with the
default you can leave it as it is.

Once you have the output .exe filename set up the way you want, you can
build the executable simply by selecting Compile Application (.EXE) from
the Build menu. This will do a full build (that is, it will compile your
source files to produce a .t3 file), then will automatically build the
executable from the .t3 file. The final product will be a .exe file
containing the HTML TADS interpreter plus your compiled game, all in one
file.

### Windows 95/NT 4 (and later) - command-line

Windows users can create a stand-alone executable from the command line
(the \"DOS box\") using the maketrx32 program. This program reads a .t3
file and creates a .exe file that contains your image file plus a TADS 3
interpreter. So, before you build your executable, you first must
compile your game with t3make the same way you always do.

Once you\'ve compiled your .t3 file, you can use the maketrx32 program
to create the executable version. You can create a text-only version, or
graphical HTML version. A text-only version is built using the console
(DOS box) version of the interpreter; an HTML version is built using the
HTML TADS interpreter.

You run maketrx32 like this:

::: cmdline
    maketrx32 -t3 mygame.t3
:::

This creates a new file called mygame.exe which combines your image file
(mygame.t3) and the TADS 3 text-only interpreter (the \"console mode\"
version, which runs in a DOS window). If you want to create a graphical
Windows application with HTML display support instead, add the -html
option:

::: cmdline
    maketrx32 -t3 -html mygame.t3
:::

## Character mapping files and stand-alone games

An important feature of TADS 3 is its ability to translate the Unicode
characters it uses internally to any local character set. The
interpreters accomplish this using [character mapping files](cmap.htm).
The TADS interpreter comes with several mapping files; because you
normally install these files along with an interpreter, character
mapping is usually completely transparent, and you don\'t have to know
anything about it. However, if you\'re distributing your game as a
stand-alone executable, your players won\'t be using a standard
interpreter installation, so you\'ll have to provide mapping files with
your distribution.

One way you can provide mapping files is to include a set of \".tcm\"
(TADS character map) files with your game. You can simply copy all of
.tcm files included with your copy of TADS 3 along with your stand-alone
game.

Unfortunately, to some extent, including a set of .tcm files defeats the
purpose of a stand-alone executable distribution. To address this, some
TADS 3 interpreters allow you to bundle a library of character maps into
a stand-alone executable.

### Windows 95/NT 4 (and later)

The maketrx32 program automatically includes the file cmaplib.t3r in the
stand-alone executable, if that file is installed. This file is part of
the TADS 3 Author\'s Kit for Windows, so you don\'t have to do any extra
work to include the standard set of character maps on Windows.

The file cmaplib.t3r consists of all of the character map (.tcm) files
that are part of the TADS 3 Author\'s Kit for Windows. However, you
might wish to add one or more .tcm files of your own to the stand-alone
executables you create. If you do, you must perform these steps:

-   First, [create the character map (.tcm) files](cmap.htm) you want to
    add.
-   Next, create your own character map library file.
-   Finally, whenever you create a stand-alone executable, explicitly
    include your own character map file library file in the bundle.

To create your own character map library file, you use the TADS 3
resource compiler, t3res. Use a command like this:

::: cmdline
    t3res -create mylib.t3r charmap\cp1252.tcm charmap\cp437.tcm
:::

Note that the filenames must either be in the \"charmap\" subdirectory
or in the current directory, or the interpreter will not find the
character maps at run-time.

List each character map file that you want to include. You can, of
course, overwrite the original cmaplib.t3r file with your own file, but
you might want to keep a back-up copy of the original, just in case you
want to revert to it at some point.

If you overwrite cmaplib.t3r with your own file, you won\'t need to do
anything extra to bundle the new library into your stand-alone
executables, since maketrx32 will automatically use your new file.
However, if you give your new character map library file a different
name, you must explicitly add it to the bundle using the -clib option:

::: cmdline
    maketrx32 -t3 -clib mylib.t3r mygame.t3
:::

The -clib option tells maketrx32 to add your character map library
instead of the standard one.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Tools](tools.htm){.nav} \>
Stand-Alone Executables\
[[*Prev:* Universal Paths](univpath.htm){.nav}     [*Next:* Running
Programs: The Interpreter](terp.htm){.nav}     ]{.navnp}
:::
