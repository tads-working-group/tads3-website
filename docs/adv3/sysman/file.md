::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> File\
[[*Prev:* DynamicFunc](dynfunc.htm){.nav}     [*Next:*
FileName](filename.htm){.nav}     ]{.navnp}
:::

::: main
keep additional \"metadata\" about each file, such as the date it was
File class can be used to read TADS
\"[resources](build.htm#resources).\" Resources are most often used for
multimedia objects, such as JPEG images or Ogg audio tracks, but you can
also use them as ordinary external data files. A TADS resource is
similar to a file in most respects, but has three important differences.
First, resource names use a URL-style syntax instead of the local
operating system path naming syntax. This makes it easier to write
portable code, since you don\'t have to worry about varying path naming
rules when accessing resource files. Second, you can embed a resource
file into the program\'s image (.t3) file, or into an external resource
bundle file. The benefit of embedding resources is that it simplifies
packaging by reducing the number of separate files you have to
distribute. Third, resources are read-only. You can\'t change the data
in a resource file at run-time.

To use File objects, you must [#include \<file.h\>]{.code} in your
source files.
TADS 3 provides access to files using three basic \"formats.\" A file\'s
format is simply the way the file\'s data are arranged; each format is
-   Text. A file in text format stores a sequence of ordinary characters
    (letters, numbers, punctuation), organized into \"lines.\" A line of
    text is simply a sequence of characters ending with a special
    \"newline\" character or character sequence. Text format files are
    useful when you want to read or write data intended for direct
    viewing or editing by a person, and because of their simple format
    can be interchanged among many different application programs. When
    you use a text format file, TADS automatically converts between the
    Unicode characters that TADS uses internally and the local character
    set used by the file, and TADS also automatically translates newline
    sequences in the file according to local conventions, which vary
    among platforms.
-   Data. A file in \"data\" format can store integers, enums, strings,
    ByteArray values, BigNumber values, and \"true\" values. Data format
    files use a private data format that only TADS can read and write,
    so this format is not useful for files that must be interchanged
    with other application programs. When you wish to create a file for
    use only by your program or other TADS programs, though, this format
    is convenient because it allows you to read and write all of the
    datatypes listed above directly - TADS automatically converts the
    values to and from an appropriate representation in the file. This
    format is also convenient because the format is portable to all TADS
    platforms - a \"data\" format file is binary-compatible across all
    platforms where TADS runs, with no conversions of any kind necessary
    when you copy a file from one type of system to another.
-   Raw. A file in raw format simply stores bytes, and gives your
    program direct access to the bytes with no automatic translations.
    This gives you total flexibility to read and write file formats
    defined by other applications or Internet standards, such as JPEG
    images or word processing documents. The easiest way to work with a
    raw file is via the [byte packing](pack.htm) methods,
    [packBytes](#packBytes) and [unpackBytes](#unpackBytes). You can
    also use the [readBytes](readBytes) and [writeBytes](writeBytes)
    methods to work directly at the byte level, via
    [ByteArray](bytearr.htm) objects.
to the file: the format you\'re using to read and write the file, the
file where you\'re reading or writing.
File objects aren\'t created with [new]{.code}. Instead, you use one of
the \"open\" methods of the File class itself. The \"open\" methods come
in two main varities: files and resources. They also differentiate which
type of format you\'re using to access the file.
[File.openTextFile(*filename*, *access*, *charset*?)]{.code}\
[File.openDataFile(*filename*, *access*)]{.code}\
[File.openRawFile(*filename*, *access*)]{.code}
::: fdef
-   A [FileName](filename.htm) object naming the file to open.
-   A string giving the name of the file to open. This must be a valid
    filename in the local file system, conforming to local file [naming
    rules](#namingRules).
-   A [special file ID](#specialFile).
-   A [TemporaryFile](tempfile.htm) object, specifying a local temporary
    file to open. Pass the TemporaryFile object itself, **not** the
    string name of the file.
-   An object with a [File Spec](#filespec) interface.
-   [FileAccessRead]{.code} - the file is to be opened for reading. The
    file must exist, or the method will throw a
    [FileNotFoundException]{.code}.
-   [FileAccessWrite]{.code} - the file is to be opened for writing. If
    no file of the given name exists, a new file is created. If a file
    with the same name already exists, the existing file is replaced
    with the new file, and any contents of the existing file are
    discarded. If the file cannot be created, a
    [FileCreationException]{.code} is thrown.
-   [FileAccessReadWriteKeep]{.code} - the file is to be opened for both
    reading and writing. If the file already exists, the existing file
    is opened, otherwise a new file is created. If the file cannot be
    opened, a [FileOpenException]{.code} is thrown.
-   [FileAccessReadWriteTrunc]{.code} - the file is to be opened for
    both reading and writing. If the file already exists, its existing
    contents are discarded (the file is truncated to zero length); if
    the file doesn\'t exist, a new file is created. If the file cannot
    be opened, a FileOpenException is thrown.

[File.openTextFile(*filename*, *access*, *charset*?)]{.code} opens a
file in text format. Any access mode may be used with this method. If
the *charset* argument is present and not [nil]{.code}, it must be an
object of the CharacterSet intrinsic class giving the character set to
be used to translate between the file\'s character set and the internal
TADS Unicode character set, *or* a string giving the name of a character
set. If this argument is missing or [nil]{.code}, the system\'s default
character set for file contents is used; this is the character set that
[[getLocalCharSet]{.code}](tadsio.htm#getLocalCharSet)[(CharsetFileCont)]{.code}
returns.

[File.openDataFile(*filename*, *access*)]{.code} opens a file in
\"data\" format. Any access mode may be used with this method.

[File.openRawFile(*filename*, *access*)]{.code} opens a file in \"raw\"
format. Any access mode may be used with this method.

All of the \"open\" methods check the [file
safety](terp.htm#file-safety) level settings to ensure that the file
access is allowed. If the file safety level is too restrictive for a
requested operation, the method throws a [FileSafetyException]{.code}.
The file safety level is a setting that the user specifies in a manner
that varies by interpreter; it allows the user to restrict the
operations that a program running under the interpreter can perform, to
protect the user\'s computer against malicious programs.
methods will throw a [FileException]{.code} subclass indicating which
type of error occurred:

-   [FileNotFoundException]{.code} - indicates that the requested file
    doesn\'t exist. This is thrown when the access mode requires an
    existing file but the named file does not exist.
-   [FileCreationException]{.code} - indicates that the requested file
    could not be created. This is thrown when the access mode requires
    creating a new file but the named file cannot be created.
-   [FileOpenException]{.code} - indicates that the requested file could
    not be opened. This is thrown when the access mode allows either an
    existing file to be opened or a new file to be created, but neither
    could be accomplished.
-   [FileSafetyException]{.code} - the requested access mode is not
    allowed for the given file due to the current file safety level set
    by the user. Users can set the file safety level (through
    command-line switches or other preference mechanisms which vary by
    interpreter) to restrict the types of file operations that
    applications are allowed to perform, in order to protect their
    systems from malicious programs. This exception indicates that the
    user has set a safety level that is too restrictive for the
    requested operation.
:::

[openTextResource(*resName*, *charset*?)]{.code}\
[openRawResource(*resName*)]{.code}

::: fdef
is given as a URL-style relative path name: the \"/\" character is used
as the path separator, but the path cannot start with a \"/\", as it
must be relative to the working directory. (This is normally the
directory containing the image file, but some tools override this; for
example, when running inside Workbench for Windows, this is the project
the URL notation is universal: you must always use the same \"/\" path
conventions. This means that when you\'re opening a resource file, you
don\'t have to be concerned with the local file system naming rules;
[openTextFile()]{.code}.
The open-resource methods don\'t have an argument specifying the access
opened for reading. Since it\'s not possible to open a resource in any
mode other than [FileAccessRead]{.code}, there\'s no need for a separate
access mode argument.
files. Resource are read-only, so you can\'t use resource access to do
you attempt to open a resource file, and the resource isn\'t found among
file\'s directory. If the file safety level is 4 or higher (no local
read access), TADS won\'t substitute local files for missing resources.
This means that it\'s okay to use local file substitution during
development and testing, but you must always explicitly bundle resources
into the .t3 file when you release your game.
types of exceptions as the [openFileXxx()]{.code} methods.
:::
## []{#namingRules}Local system file naming rules
you\'re not making assumptions about file names and paths that will only
For files that you create and manage for your program\'s own internal
use, you probably won\'t want to ask the user to name them. For these
sorts of files you\'ll need to hard-code their names. The best way to
-   Avoid most punctuation marks in file names. To be completely safe,
    use only letters and digits; but you\'ll be safe on Windows, Mac OS,
    and Linux if you avoid these: [\* + ? = \[ \] / \\ & \| \" : \<
    \>]{.code}

-   Stick to ASCII characters - avoid accented letters, for example.
    Most modern systems allow Latin-1 or Unicode characters in file
    names, but character set handling in file names is tricky at best,
    so it\'s easiest to avoid the issue by using only the ASCII subset.

-   Shorter names are safer. Most systems these days allow very long
    file names, so in practice you probably won\'t actually bump up
    against any limits; but when there\'s no dire need for a long name,
    you might want to keep names relatively short just to be safe, in
    the range of 20 characters or so.

-   Don\'t hard-code directory paths based on your own operating
    system\'s path syntax, because path syntax varies across platforms.
    It probably goes without saying, but you should never hard-code
    \"absolute\" paths that start in the root directory, such as
    \"/tads/games\" or \"C:\\TADS\\GAMES\" - you obviously can\'t count
    on every machine having the same top-level folder tree that you use.
    More subtly, you shouldn\'t even write relative sub-folder paths
    using your local OS syntax, because that syntax won\'t work when
    users run your program on other systems. For example, if you write
    your program on Windows, you might think it\'s okay to write a
    relative path like \"data\\stats.txt\". It\'s not okay! That
    backslash won\'t work on Unix or Mac systems.

    Fortunately, there\'s a way around this problem: use
    [FileName.fromUniversal()](filename.htm#fromUniversal) to create
    local paths based on a portable \"universal\" syntax.

## []{#specialFiles}Special Files
addition, there are certain \"special\" files that you can access. You
don\'t refer to these files by name, but rather by purpose; you tell the
where the file is and what it\'s called. The purpose of this layer of
[openFileXxx()]{.code} methods. Here are the special files currently
defined:

-   [LibraryDefaultsFile]{.code} - this file stores global default
    values for library preference settings. A game library (e.g., Adv3)
    can use this file as a repository of default option settings. The
    settings file is shared across games, so that a user\'s preference
    settings automatically transfer to each new game played. The
    interpreter determines the directory location where this file is
    stored.
-   [WebUIPrefsFile]{.code} - this file stores the display style
    settings for the Web UI. This file is shared across games, so that a
    user\'s display customizations are preserved when starting a new
    game. This file is stored in the same location as the library
    defaults file.

Special files aren\'t subject to [file safety](terp.htm#file-safety)
locations designated by the interpreter, so it\'s not possible for a T3
## []{#tempfiles}Temporary files
It\'s sometimes convenient to store certain working data in external
to ensure that it\'s deleted when the program exits or no longer needs
access to the file. Once you\'ve created a TemporaryFile object
File \"open\" methods to open the file for read or write access:
::: code
:::
ensures that they\'re deleted by the time the program exits, so you
don\'t have to worry about explicitly cleaning up the disk space you use
for these files. Second, temporary files bypass the [file
because they\'re already protected from misuse by their design: the
system controls the name and location of a temporary file, so it\'s not
Traditionally, the way to specify a file\'s identity in TADS was simply
operating system\'s conventions for naming files. A file in TADS very
straightforwardly represented a file on the local machine\'s hard disk,
With the addition of the Web UI infrastruture in TADS 3.1, we\'ve had to
make the interfaces a little more abstract. It\'s no longer always the
-   [Temporary files](#tempfiles). These are physically stored on the
    local disk, like traditional files. But they have some additional
    special features, such as automatic deletion when you\'re done with
    them.
-   Remote \"cloud\" files. When running in a client/server
    configuration, TADS can store files on a remote machine, known as a
    [storage server](webdeploy.htm#storageServer), rather than on a
    local disk. Some people call this \"cloud\" storage, since from the
    user\'s perspective they\'re stored out in some nebulous location on
    the network, and the user doesn\'t need to know the details of
    exactly where. At the File level, TADS makes this transparent; you
    just operate on File objects as normal, and TADS takes care of
    moving data to and from the remote server. However, there are
    differences at the UI level.
-   Client files. It\'s also possible to use the client/server
    configuration *without* a storage server. In this setup, files are
    stored on the user\'s client machine, rather than on the machine
    running the game. File transfers to and from the client are
    accomplished via HTTP uploads and downloads.
File \"open\" methods accept more than just filename strings: they also
new external storage types, beyond what\'s built into the system. TADS
\"cloud\" files. File Spec interfaces let you build your own additional
In concrete terms, a File Spec is really pretty simple. It\'s just a
-   [getFilename()]{.code} returns a system file identifier: either a
    string containing a filename, or a TemporaryFile object. When the
    system wants to open the underlying disk file, it calls this method
    to find out where on disk to read or write the data. This method is
    required.
-   [closeFile()]{.code} is optional. When the system closes the
    underlying disk file, it calls this method to let you know. This
    gives you a chance to perform any desired post-processing on the
    file.
location, synthesizing the data from scratch just before it\'s accessed,
Here\'s an example of how this feature can be used. The Adv3 Web UI uses
we\'re done with it. When the user types SAVE, the library would
normally display a file selector dialog asking for a file for saving the
game. With client-side files, the library instead just creates a custom
object with the File Spec methods, and creates a TemporaryFile object to
go with it. The library uses this special object to call
[saveGame()]{.code}. When [saveGame()]{.code} opens the file, it calls
[getFilename()]{.code} on the File Spec object, which returns the
TemporaryFile; this means that [saveGame()]{.code} ends up saving the
current game state to the temporary file on the server machine. When the
save is finished, [saveGame()]{.code} closes the file, which calls the
[closeFile()]{.code} method on the File Spec object. The File Spec
object\'s implementation of [closeFile()]{.code} finishes the operation
by sending information about the newly available file to the Web UI
client, which responds by offering the user a chance to download and
save the file. The result from the user\'s perspective is the SAVE
command offers a \"save file\" dialog that saves the game to the local
hard disk, just as in the traditional stand-alone interpreter.
[closeFile()]{.code}
::: fdef
close files explicitly as soon as you know you\'re done with them.
throw a [FileClosedException]{.code}. (This doesn\'t mean that you
can\'t do more work on the underlying operating system file - it simply
means that you have to open it again with a new File object.)

Note that [closeFile()]{.code} can throw an error. The only situation
where an error can usually occur on close is when the file was opened
for writing, and you\'ve made updates. In this case, the system might
have buffered (delayed) some of the physical updates to the underlying
media, and will attempt to complete them on closing the file. This is
where there\'s a potential for trouble, since something could go wrong
writing the final updates to disk. For example, the disk might be too
full, or the write might encounter a hardware media error. If an error
does occur, the File object is still marked as closed, so no further
file could be in an inconsistent state. It\'s difficult in general to
correct these sorts of errors programmatically, but it\'s often worth
notifying the user so they\'re aware of the possible data loss right
:::
[deleteFile(*filename*)]{.code}
::: fdef
::: code
:::
addition, the function will fail if the file can\'t be deleted at the
:::
[digestMD5(*length*?)]{.code}
::: fdef
*length* is omitted or [nil]{.code}, the entire rest of the file (from
the current seek position to the end of the file) is included in the
digest.
:::
[getCharacterSet()]{.code}
::: fdef
:::
[getFileMode()]{.code}
::: fdef
Returns the file\'s current data mode. The return value is one of the
-   [FileModeText]{.code} - text mode ([openTextFile()]{.code})
-   [FileModeData]{.code} - data mode ([openDataFile()]{.code})
-   [FileModeRaw]{.code} - raw (binary) mode ([openRawFile()]{.code})
:::
[getFileSize()]{.code}
::: fdef
of the file\'s data stream as the program sees it; for example, if the
:::
[getPos()]{.code}
::: fdef
:::
[]{#getRootName}
[getRootName(*filename*)]{.code}

::: fdef
Returns a string giving the \"root\" name of *filename*, using the local
system\'s directory path conventions. *filename* is a string giving the
::: code
:::
[File.getRootName(\'a\\\\b\\\\c.txt\')]{.code} returns
[\'c.txt\']{.code}. The same program running on a Linux machine will
return [\'a\\\\b\\\\c.txt\']{.code} for the same function, because the
backslash isn\'t a path separator character on Linux.
This method only does superficial parsing; it doesn\'t actually check
string containing a path, from sources such as [inputFile()]{.code} or
the program startup arguments.
:::

[]{#packBytes}
[packBytes(*format*, \...)]{.code}
::: fdef
The return value is the number of bytes written. (More precisely, it\'s
:::

[]{#readBytes}
[readBytes(*byteArr*, *start*?, *cnt*?)]{.code}
::: fdef
:::
[readFile()]{.code}
::: fdef
according to the file\'s format:

-   Text format: the next line of text is read from the file and
    returned as a string. The line ends at the next \"newline\"
    character or sequence.

    TADS recognizes newlines according to local platform conventions.
    For example, on Windows platforms, TADS considers each CR-LF pair to
    represent a single newline sequence. TADS translates the local
    newline sequence to \'\\n\', so each string returned from readFile()
    will always end in a single \'\\n\', regardless of the local
    platform conventions. This ensures that your code doesn\'t have to
    worry about different conventions on different machines; it\'ll run
    the same way everywhere. Note that if the file ends in mid-line,
    without a terminating newline sequence within the file itself,
    readFile() likewise will return the last string without a \'\\n\'
    character at the end. This is done so that the readFile() results
    accurately reflect what\'s in the file, in case it\'s important to
    you whether or not the file ends in a final newline sequence.

    The characters read from the file are translated through the
    currently active character set, so the returned string is always a
    valid Unicode string, regardless of the character set of the
    external file. This means that you don\'t have to worry about
    character set differences on different platforms, apart from making
    sure that the proper character set is specified when opening the
    file.

-   Data format: the next data item is read from the file and returned.
    The return value will be of the same type as the value that was
    originally written to the file.

-   Raw format: this function is not allowed for raw files (a
    FileModeException is thrown if this is attempted on a raw file).
[nil]{.code}. If any error occurs reading the file, the method throws a
[FileIOException]{.code}.
Note that if the file is open for write-only access, a
[FileModeException]{.code} will be thrown.
:::
[setCharacterSet(*charset*)]{.code}
::: fdef
-   A [CharacterSet](charset.htm) object.
-   A string giving a character mapping name. A CharacterSet object is
    automatically created for the mapping name.
-   [nil]{.code}. This selects the local system\'s default character set
    for text files.
:::
[setFileMode(*mode*, *charset*?)]{.code}
::: fdef
new file mode ([FileModeText]{.code}, [FileModeData]{.code},
[FileModeRaw]{.code}).

If the *mode* value is [FileModeText]{.code}, *charset* specifies the
character set for the file\'s contents. Any text you write to the file
will be mapped to this character set, and any text you read from the
file will be converted from this character set. The character set can be
specified as a [[CharacterSet]{.code}](charset.htm) object, or as a
string giving the name of a character set. If *charset* is [nil]{.code}
or the argument is omitted entirely, the local system\'s default
character set for file contents is used.
interpret the file\'s contents according to the new mode.
:::
[setPos(*pos*)]{.code}
::: fdef
position that was previously returned from a call to [getPos()]{.code}.
Text and data format files have data structures that span multiple bytes
in the file, so setting the file to an arbitrary byte position could
cause the next read or write to occur in the middle of one of these
multi-byte structures, which could corrupt the file or cause data read
to be misinterpreted.
without confusing the File object. However, if you\'re defining your own
:::
[setPosEnd()]{.code}
::: fdef
the file and then using [getPos()]{.code} to determine the new position
in the file).
Note that the warnings mentioned in [setPos()]{.code} regarding valid
positions generally don\'t apply to [setPosEnd()]{.code}. It is usually
safe to go to the end of a file, because whatever multi-byte data
structures occur in the file should be complete units, hence moving to
the end of the file should set the position to the end of the last
structure.
:::
[sha256(*length*?)]{.code}
::: fdef
If *length* is omitted or [nil]{.code}, the entire rest of the file
(from the current seek position to the end of the file) is hashed.
:::
[]{#unpackBytes}
[unpackBytes(*format*)]{.code}

::: fdef
format string. An error is thrown if the file doesn\'t have enough data
:::

[]{#writeBytes}
[writeBytes(*source*, *start*?, *cnt*?)]{.code}
::: fdef
-   [ByteArray]{.code}: the specified range of bytes from the byte array
    is written to the file. *start* is the index within the byte array
    of the first byte of the range to copy to the file; if omitted, the
    default index is 1 (i.e., the first byte of the array). *cnt* is the
    number of bytes to write; if omitted, all bytes from the starting
    index to the end of the array are copied.
-   [File]{.code}: bytes are read from the *source* file and written to
    the target file. The source file must be open with read access, and
    it must be in \"raw\" mode, since this function reads individual
    bytes from the file without any character set or data type
    translation. *start* is a seek location within the source file; if
    it\'s omitted, the default is the current seek position in the file
    (the location that [getPos()]{.code} returns). *cnt* is the number
    of bytes to copy; if omitted, the file\'s entire contents from the
    starting seek position to the end of the file are copied.
bytes, a [FileIOException]{.code} is thrown. If the source object is a
[File]{.code}, a [FileIOException]{.code} can also result if any errors
occur reading the source object.
Note that if the file is open for read-only access, a
[FileModeException]{.code} will be thrown.
:::
[writeFile(*val*)]{.code}
::: fdef
the file\'s format:

-   Text format: val is converted into a string using the default
    conversion for its type if it\'s not already a string; if the value
    is not convertible to a string, the function throws a runtime
    exception. The string is written to the file by translating its
    characters to the local character set through the currently active
    character set object for the file.
-   Data format: the value can be an integer, string, enum, BigNumber,
    ByteArray, or [true]{.code} value. The value is written in the
    private TADS data-file format so that it can be read back later with
    the readFile() method.
-   Raw format: this function is not allowed for raw files (a
    FileModeException is thrown if this is attempted on a raw file).
the [writeFile()]{.code} function stores in the file. When you use
[readFile()]{.code} to read an enumerator value, the system uses the
current internal enumerator value assignments made by the compiler.
Because these values are arbitrary, they can vary from one compilation
to the next, so it is not guaranteed that a file containing enumerators
can be correctly read after you have recompiled your program. For this
reason, you should never write enumerators to a file unless you\'re
certain that the file will only be used by the identical version of your
program (so it\'s safe, for example, to use enumerators in a temporary
file that you\'ll read back during the same run of the program). If you
must store enumerators in a file that might be read by a future version
of your program, you should use some mechanism (such as reflection) to
translate enumerator values into integers, strings, or other values that
you define and can therefore keep stable as you modify your program.
the method throws a [FileIOException]{.code}. If the file is open for
read-only access, a [FileModeException]{.code} is thrown.
:::
creation methods ([openTextFile()]{.code}, etc.) are transient and thus
not affected by save, restore, restart, or undo.
be \"unsynchronized\" when the program is loaded. This means that the
File object no longer refers to an open operating system file - once the
this, the File object throws a [FileSyncException]{.code} if any of
these operations are attempted on an unsynchronized file.
:::
::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> File\
[[*Prev:* DynamicFunc](dynfunc.htm){.nav}     [*Next:*
FileName](filename.htm){.nav}     ]{.navnp}
:::