HTML TADS System Compatibility Notes

\
\
\

![](htmltads.jpg) [\
System Compatibility Notes]{.title}

\
\
\

If you\'re experiencing a problem with HTML TADS or TADS Workbench,
please consult the notes below. We\'ve found a few situations where
different Windows system configurations can cause problems. The notes
below explain how to fix the configuration problems we know about.

If you can\'t find a solution to your problem here, you might try
checking the Usenet newsgroup
[rec.arts.int-fiction](news:rec.arts.int-fiction) to see if anyone else
has run into the same problem, or you can go to
[tads.org](http://www.tads.org) for information on how to contact us.\
\
\

::: bar1
::: heading
Workbench on Windows 95/98: \"SHELL32.DLL:SHGetFolderPathA\" Error
:::

::: content
If you\'re running TADS Workbench on Windows 95 or 98, launching
Workbench might show the following error messages:

::: indented
    Error Starting Program
    The HTMLDB3.EXE file is linked to missing export SHELL32.DLL:SHGetFolderPathA.
:::

If you get this error, you should be able to fix it by installing
Microsoft Internet Explorer version 5 or later. The issue is that
Workbench depends upon a newer version of a certain Windows system DLL
than what comes with 95 and 98 by default. IE 5 and later automatically
upgrade this DLL as part of their installation process, so updating the
DLL is simply a matter of updating IE.
:::
:::

::: bar2
::: heading
Crash running HTML TADS
:::

::: content
If HTML TADS crashes, particularly when you select the \"Options\" item
of the \"Edit\" menu or \"Customize\" on the \"Themes\" menu, you
probably have an out-of-date version of a Windows system file called
COMCTL32.DLL. If you encounter this problem, you can fix it by
downloading this file from the Microsoft web site:

::: indented
<ftp://ftp.microsoft.com/softlib/mslfiles/com32upd.exe>
:::

After downloading the file, double-click it to run the installation
program, which will install the upgraded DLL for you. Note that HTML
TADS automatically checks to make sure you have the correct version
installed and warns you at startup if you don\'t. Although you can
choose to continue running if TADS displays this warning, we strongly
encourage you to upgrade your COMCTL32.DLL before running HTML TADS.
:::
:::

::: bar1
::: heading
Crash using Wine (Windows emulator for Linux)
:::

::: content
If you\'re running HTML TADS in the Wine environment (a Windows
emulation environment for Linux/Unix systems), you might need to use the
\"-noalphablend\" command-line option when running htmltads.exe. Some
versions of Wine have a bug that causes the program to crash immediately
after startup. This has been reported in particular on the version known
as WineX. If you\'re running on Wine, and the interpreter crashes
immediately when you run it, try running it from the command line like
this:

::: indented
    htmltads -noalphablend
:::
:::
:::

::: bar2
::: heading
Western European characters on localized (Non-English) Windows systems
:::

::: content
If you\'re running a Windows system that uses a character set other than
US/Western Europe (such as Windows Eastern European or Cyrillic), please
read this note.

If you have any problems with HTML TADS displaying characters that are
**supposed** to be from the US/Western Europe character set, but are
instead displayed as characters from your system\'s default character
set, you might need to adjust your system configuration to remove \"font
substitutions.\" Many non-US/Western Europe systems use font
substitutions as a way to work around older applications that don\'t
have proper localized character set support, but the substitutions can
interfere with applications like HTML TADS that do properly support
localized character sets.

To check for font substitutions, look at your WIN.INI file (usually in
your C:\\WINDOWS directory). Look for a line that starts with
\"\[fontsubstitutes\]\", then look for lines like this:

::: indented
    Arial,0=Arial,238
:::

(The second number might be something other than 238.) If you find any
lines like this, you might want to try deleting them or commenting them
out (by putting a semicolon, \";\", at the start of each line). You
might need to reboot your system before your changes take effect.

**Windows NT users:** On NT, the font substitutions are specified in the
registry rather than in WIN.INI. Run REGEDIT and look for a registry key
with this path:

::: indented
    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontSubstitutes
:::
:::
:::
