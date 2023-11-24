![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
FileName  
[*Prev:* File](file.htm)     [*Next:* GrammarProd](gramprod.htm)    

# FileName

A FileName object represents the name of a file on the host operating
system. This class provides methods to build and parse path names using
the local operating system's syntax rules. It also offers methods to
manipulate the file system object corresponding to a given filename,
such as deleting or renaming a file, creating or deleting a directory,
listing the contents of a directory, and retrieving a file's metadata
(such as its creation date and size).

It might seem strange to use a special class to represent filenames,
since most people - and most programming languages, for that matter -
think of filenames as ordinary character strings. Even TADS itself
traditionally did just this. The problem with treating filenames as
plain text strings is that filenames have an internal structure to them,
and that structure varies by operating system. This makes it hard to
write portable code that builds and parses filenames. For example, if
you want to write the name of a file in a subfolder, how do you do this
with character strings? If you're a Windows user, the simplest approach
is to write something like 'images\\pic.jpg'. But if you're a Unix user,
you'd instead write 'images/pic.jpg'. Okay, you say, we can solve this
little snag with the old Windows hack where we take advantage of the
bug/feature where Windows happens to accept "/" slashes in place of "\\
slashes - so we just write 'images/pic.jpg' and everyone's happy, right?
Well, not really. For one thing, that really is a hack, not an
officially supported feature, and it's not clear that Microsoft is
committed to supporting it forever. (Changing it would break a lot of
existing programs, but that hasn't always stopped Microsoft in the
past.) More importantly, this hack doesn't help at all on other
operating systems that use yet other path separators and different path
syntax. VMS paths are utterly different, for instance - the VMS
equivalent of our example here would be \[.IMAGES\]PIC.JPG. When you
take into account all of the OSes in use, there's simply no way to write
a native filename path as a string that will work everywhere.

This is why we need a class like FileName. This class takes care of the
file syntax variations among operating systems, making it much easier to
write portable code that operates on filenames. FileName knows that the
string it contains is a file name, not just an ordinary text string, and
it knows the local rules for constructing and parsing those names on
each operating system where TADS runs.

You can use a FileName object as the file name argument in any of the
"open" routines in the [File](file.htm) class. You can also use a
FileName in most other system functions and methods where file names are
required, such as [saveGame()](tadsgen.htm#saveGame)

FileName objects are like ordinary strings in one important respect:
they merely represent *names*, not actual objects in the host file
system. This means that it's perfectly fine to create FileName objects
with non-existent file names or non-existent directory names. Merely
creating a FileName object makes no attempt to verify that the named
object actually exists anywhere, or that any of its path components are
valid. When you use a FileName to open a file, create a directory, etc.,
though, the name will obviously be validated at that point.

When using the FileName class, you should \#include either file.h or
filename.h in your source files. You should also add file.t (from the
system library) to your build.

## Construction

new FileName()

This creates a FileName object representing the working directory - the
equivalent of "." on Unix or Windows.

new FileName(*str*)

*str* is a string containing a filename, using the host operating
system's syntax. This creates a FileName representing that local
filename. Note that this isn't a license to hard-code strings with path
separators and other local syntax, because *str* has to use the syntax
for the local operating system at **run-time**, which might not be the
same as the OS you use to write your program. Rather, this constructor
is useful when you receive a filename string from a local source at
run-time, such as user input. This lets you wrap the string in a
FileName object so that you can further manipulate it using local
conventions.

new FileName(*path*, *name*)

*path* and *name* can be either filename strings, using the host
operating system's syntax, or FileName objects. This combines the two
elements into a single filename path: *path* is treated as a directory
path location, and *name* is a file in that location. For example, if
you want to construct a path to a file called pic.jpg in a subfolder
called images, you could write new FileName('images', 'pic.jpg'). This
solves the exact problem we mentioned earlier about how you write a
directory-path name like 'images/pic.jpg' portably.

You can also use the [fromUniversal()](#fromUniversal) method to create
a FileName from a hard-coded string in universal syntax.

## Operators

*FileName* + *string* yields a new FileName object combining the
directory path given by the FileName object with the file name given by
the string. This uses the correct local syntax to combine the path
elements, so this provides an easy way to build path names from
subdirectory components.

For example, new FileName('images') + 'pic.jpg' yields a FileName object
representing images/pic.jpg when running on Unix, images\\pic.jpg on
Windows, etc.

*FileName* + *FileName* yields a combined directory path for the two
elements, just like adding a string to a FileName object.

Comparing two FileName objects with == or !=, or comparing a FileName to
a string, compares the names using the local file system naming rules.
This is almost the same as comparing the name strings directly, but it
ignores meaningless syntax differences between the two names (for
example, it treats "a/b" as equal to "a//b" on Unix, since Unix treats
multiple slashes in a row the same as a single slash), and it takes into
account whether or not the local file system is sensitive to case (so
"a" == "A" on Windows, but not on Unix).

## Save and restore

When a FileName object is saved to a file via
[saveGame()](tadsgen.htm#saveGame), it's converted to the "universal"
syntax (see [fromUniversal()](#fromUniversal)) for storage. When that
file is later restored, the universal syntax is automatically converted
back to the correct local syntax. This means that if a player saves a
game on one machine and restores it on another, the FileName objects
restored will automatically adapt to the local syntax on the new
machine.

## Network storage server

When a game runs in [Web UI](webui.htm) mode, with files stored on the
[network storage server](webdeploy.htm#storageServer), the FileName
class uses storage server rules for building and parsing filenames.
Storage server filenames are syntactically similar to Unix filenames,
but there's no concept of a root directory; all files are within the
user's folder for the current game, and nothing outside of this folder
is visible or accessible.

The FileName methods for accessing the local file system, such as
createDirectory() and getFileInfo(), are generally not supported on the
storage server. The storage server is designed only for deploying
traditional text games, so it provides only the core functions needed
for storing and retrieving saved games, log files, and any other files
the game creates for its own use.

## Methods

addToPath(*element*)

Adds the path element *element* to the end of this filename, returning a
new FileName object with the combined path. *element* can be either
another FileName object or a string using the local file system syntax.
This method uses the correct local file system syntax to combine the
path elements. Note that this has the same effect as self + *element*.

createDirectory(*createParents*?)

Creates a directory, using the name given by this object.

If *createParents* is specified, it must be true or nil; this indicates
whether or not the method should create any missing intermediate
directories in the path, if the path has multiple elements. For example,
suppose we're running on Unix, and the FileName object represents path
'/a/b/c', and the directory '/a' currently exists but doesn't have a
subdirectory 'b'; in this case, the function creates '/a/b' first if
*createParents* is true. If *createParents* is omitted or nil in this
case, the function will typically fail, since most systems don't allow
creating '/a/b/c' if '/a/b' doesn't exist. (This rule is enforced by the
operating system, though, not by the createDirectory() method. If the
underlying OS creates the intermediate directories automatically, then
this method will also do so even when *createParents* is nil.)

This function throws an error if the directory creation fails. The file
safety settings must allow write access to the directory containing the
new subdirectory.

deleteFile()

Deletes the file named by this object. There's no return value; if the
operation fails, the method throws a run-time error ("error deleting
file").

The file safety settings must allow write access to the file; if not, a
file safety exception is thrown.

forEachFile(*func*, *recursive*?)

Enumerates the files in the directory named by this object, invoking the
callback function *func* for each file. *func* is invoked as
*func*(*filename*), where *filename* is a FileName object giving the
name a file in the directory.

If *recursive* is true, the function recursively scans the contents of
each subdirectory of the original directory, along with any
subdirectories of the subdirectories, and so on. If *recursive* is nil
or is omitted, only the direct contents of the named directory are
scanned.

This method is similar to [lisDir()](#listDir), but is more convenient
for recursive directory tree scans. In addition, since it doesn't build
a list of results, it uses less memory when you only need to perform an
operation per file rather than compiling a list of files.

fromUniversal(*path*)

Creates a new FileName object based on a path expressed in the TADS
"universal" path syntax. *path* is a string giving a filename path in
the universal syntax. The method translates the universal syntax to the
local operating system's path syntax, and creates a new FileName object
representing that local path.

The universal syntax is similar to Unix-style path notation, with
forward slashes ("/") separating path elements. For example,
'files/data/stats.txt' refers to a file named stats.txt within a folder
data within a parent folder files within the working directory.

This is a static method that you call on the FileName object itself:

    local name = FileName.fromUniversal('files/data/stat.txt');

This method doesn't open the file or check its validity, so you can use
it with files and paths that don't exist on the local machine.

The purpose of this method is to make it convenient to write hard-coded
path names in a program without tying the program to a particular
operating system. If you wrote hard-coded paths using your own OS's
syntax, your program wouldn't work properly if someone ran it on a
different OS. This method solves the problem by letting you write the
path in a universal format, and then translating it at run-time to the
local OS syntax.

getAbsolutePath()

Returns a new FileName object giving the absolute path to this file. If
the 'self' object's path is a relative path (see isAbsolute), this
combines the relative path with the current working directory to form a
fully-qualfied absolute path. The method uses the correct local syntax
to form the combined path. If the 'self' object's path is already in
absolute format, the new FileName will usually contain the same path as
the original, but it might be changed slightly, depending on the local
operating system's rules, to rewrite it in a "canonical" format. For
example, minor syntax variations might be rewritten to use a standard
format.

On some systems, it might not be possible to convert every path to
absolute format. If the path can't be converted, this returns nil.

getFileInfo(*asLink*?)

This method checks to see if the file named by this object exists, and
if so retrieves its file system metadata, including its size, type, and
timestamps. If the file exists, the function returns a FileInfo object
with the metadata; if the file doesn't exist or can't be accessed due to
operating system-level permissions or another OS error, the return value
is nil.

The optional *asLink* flag specifies the behavior if the named file is a
symbolic link, which is a special type of file supported on some
operating systems that functions as a pointer or proxy for another file.
For most file operations, such as opening, reading, or writing the file,
the operating system automatically follows the link and carries out the
operation on the target file. However, the link file also has its own
separate identity as a link and its own separate creation time and so
forth, so in some cases it's useful to be able to retrieve information
on the link itself instead of the target file. For example, when listing
a directory containing links, the unresolved links are included in the
listing, not the target files. That's where *asLink* comes in. If it's
true, the return value from getFileInfo() describes the link file
itself; if *asLink* is omitted or nil, the return value describes the
target of the link. Any additional links are resolved as well in this
case: if this file is a link that points to another link which points to
third link, etc., the function keeps following those links until it
reaches a regular file, and returns the information on that file.
*asLink* has no effect for files that aren't symbolic links. Some
operating systems also support "hard" links, which allow multiple file
names to point to the same underlying data; hard links are by design
indistinguishable from ordinary files on most systems that support them,
so *asLink* usually has no effect if the named file is a hard link.

The FileInfo object is defined in the system library file file.t, which
you should include in your build if you use this function. FileInfo has
the following properties:

- fileType - an integer giving the type of the file, as a combination of
  FileTypeXxx bit flags. This is the same value returned by
  [getFileType()](#getFileType).
- fileAttrs - an integer giving the attributes of the file, as a
  combination of FileAttrXxx bit flags. Test for the presence of an
  attribute using the & operator (e.g., if ((info.fileAttrs &
  FileAttrHidden) != 0)). The attribute flags are:
  - FileAttrHidden - the file is marked as hidden. Some systems use a
    naming convention to indicate that a file is hidden (e.g., the "."
    prefix on Unix); others (such as Windows) use special attribute
    flags in the file system. Not all systems have a concept of hidden
    files; this flag will never appear in a file's attributes on systems
    that don't have an equivalent.

    The exact behavior of hidden files varies by system, but on most
    systems, hidden files are excluded from the default view of a
    directory listing presented to the user, and from command wildcards
    (e.g., "rm \*" on Unix doesn't delete any files whose names start
    with "."). However, the "hidden" attribute isn't a security or
    permissions mechanism, and hidden files aren't truly invisible.
    Users can still usually view these files in directory listings by
    specifying special overrides (e.g., "ls -a" on Unix) and can usually
    manipulate them by naming them explicitly in commands. The purpose
    of the "hidden" flag is to reduce clutter in the user interface, by
    hiding internal bookkeeping files that are maintained by the
    operating system or applications (such as preference files, caches,
    and indices). Users don't generally need to manage these sorts of
    files manually, so it's easier for the user to find her own files if
    the system omits the non-user files from most directory views.

    Hidden files are **not** filtered out of the directory listings
    returned by [listDir()](#listDir), since that method is for
    programmatic access and thus returns all files, whether hidden or
    not. It's up to you to filter out hidden files, if appropriate, when
    displaying the results to the user.

  - FileAttrSystem - the file is marked as a "system" file. This is
    primarily a DOS/Windows concept; this flag will never appear in a
    file's attributes on most other systems. The purpose of the "system"
    flag is to mark a file as belonging to the operating system; Windows
    uses this for its bootstrap loader files, swap file, and similar
    core OS files. For practical purposes, "system" files should be
    treated exactly like "hidden" files: they should be omitted from
    default directory views, and excluded from wildcard ("\*.\*")
    matches. The only reason that we distinguish "system" as a separate
    flag from "hidden" is to allow programs to display the two
    attributes separately on systems that use both of them, since users
    might be accustomed to seeing the two distinct attributes.

  - FileAttrRead - the program has read access to the file, as
    determined by operating system permissions. This attribute only
    reflects the permission settings for the file; it doesn't guarantee
    that a given attempt to read the file will succeed, since conditions
    at the time of the read attempt could interfere, such as physical
    media errors or locking by another process.

  - FileAttrWrite - the program has write access to the file, as
    determined by operating system permissions. On systems where files
    can be marked as read-only (e.g., DOS or Windows) separately from
    permissions settings, this attribute also indicates that the
    read-only flag is not set. Note that this attribute doesn't
    guarantee that a given attempt to write the file will succeed, since
    conditions at the time of the write attempt could interfere, such as
    insufficient disk space, physical media errors, or locking by
    another process.
- isDir - true if this is a directory/folder, nil if not. This is the
  same information as the FileTypeDir bit in the fileType property, but
  FileInfo breaks it out as a separate property for convenience, since
  this is an especially common attribute to test for.
- specialLink - this duplicates the FileTypeSelfLink and
  FileTypeParentLink flags from the fileType property. This is for
  convenience: you can test if a file represents "." or ".." (or the
  local system's equivalent) simply by comparing specialLink to zero. If
  specialLink is non-zero, the file is one of these special links.
- fileSize - an integer value giving the size in bytes of the file. If
  the value is too big for the 32-bit integer type, fileSize will be a
  BigNumber value. The size is usually meaningful only for ordinary
  files (those with type FileTypeFile).
- fileCreateTime - the file's creation time, as a [Date](date.htm)
  object. If the operating system doesn't record a file's creation time,
  this is nil.
- fileModifyTime - the time of the file's last modification, as a
  [Date](date.htm) object. If the OS doesn't record the modification
  time, this is nil.
- fileAccessTime - the time of the last access to the file, as a
  [Date](date.htm) object. (The access time records when the file was
  last accessed, whether or not it was modified at that time, whereas
  the modification time is only updated when the contents of the file
  are changed.) If the OS doesn't record the access time, this is nil.

Some operating systems don't record all three timestamps. If a given
timestamp isn't available on the local system, it'll be set to nil.
Nearly all systems minimally keep track of the modification time.
Unix-like and Windows systems keep all three, when the standard file
systems are used (although the FAT32 file system on windows only records
the access time to the nearest day, so files on FAT32 disks will always
show midnight as the time of day for the access time).

The file safety level must allow ordinary read access to the file,
otherwise a file safety exception is thrown. There's one special case:
if the file safety settings allow read access to the working directory,
and the file in question is a parent directory of the working directory,
getFileInfo() access is allowed. The parent folder of the working
directory, and its parent, and so on, are all part of the path to the
working directory, so their metadata are considered part of the working
folder's metadata. The parent folders therefore get the same file safety
treatment as the working folder for the purposes of getFileInfo(). For
other operations, the parent folders are considered outside the sandbox.

getFileType(*asLink*?)

Tests to see if the file named by the object exists, and if so
determines its type. If the file exists, the return value is an integer
giving the file type, as a combination of the FileTypeXxx flags below.
If the file doesn't exist, or it can't be accessed due to file system
permissions or some other OS error, the return value is nil.

- FileTypeFile - an ordinary file (such as a disk file)
- FileTypeDir - a directory (folder)
- FileTypeChar - a character-mode device, known as a character special
  file on Unix-like systms. This represents an input/output device that
  works in terms of a character stream, such as a console or printer.
- FileTypeBlock - a block-mode device, known as a block special file on
  Unix-like systems. This provides low-level access to a hard disk,
  CD-ROM, etc. at the sector level, bypassing any file system structure
  on the device. (Disk devices that also have file systems aren't
  normally accessible in this mode except under special conditions or
  with special privileges, since bypassing the file system can corrupt
  the file layout.)
- FileTypePipe - a pipe or similar interprocess communications channel
  (e.g., a Unix FIFO)
- FileTypeSocket - a network socket
- FileTypeLink - a symbolic link (a file that acts as a proxy or pointer
  to another file or directory; when the link file is opened, read,
  written, etc., the file system normally accesses the target of the
  link, transparently to the caller)
- FileTypeSelfLink - a special system-defined directory link to self
  (e.g., "." on Unix or Windows)
- FileTypeParentLink - a special system-defined link to the parent
  directory (e.g., ".." on Unix or Windows)

The type codes are bit flags, so more than one can apply to a given
file; use the & operator to check if a particular flag is set. For
example, to check if a given filename refers to a directory, use
(f.getFileType() & FileTypeDir) != 0.

*asLink* has the same meaning as in [getFileInfo](#getFileInfo).

Note that a return value of zero has a different meaning than nil. nil
means that the file doesn't exist; 0 means that the file exists, but
that it's a type of object that doesn't fit any of the FileTypeXxx
flags. (This shouldn't happen on current versions of Windows, Mac OS, or
Unix-like systems, since these flags cover all of the file types on
those systems. Future versions of those OSes might add new file types
outside of our categories, though, and more exotic platforms might
already have some.)

getName()

Returns a string giving the filename this object represents, using the
local syntax of the host operating system. The format of the string
generally matches the format that was used to create the FileName
object; the result is usually a relative path if the FileName was
created from a relative path, or an absolute path if the FileName was
created from an absolute path.

The result is the same string returned from toString(self), and is the
same same text used if the FileName is implicitly converted to a string,
such as if you display the FileName via "\<\< \>\>" string embedding.

getPath()

Returns a string giving the directory location portion of the name
represented by this FileName object. This separates the FileName into a
directory location portion and a file name portion, and returns just the
directory location. In a Unix-style name, this is the path with its last
element removed - for example, for 'data/images/pic.jpg', this method
returns 'data/images'.

This method works purely in terms of the path string stored in the
FileName object. It doesn't look anything up in the host file system.
For example, if the FileName represents 'pic.jpg', this method simply
returns an empty string, since the stored name doesn't have a directory
path portion.

getRootDirs()

Get a list of the root directories on the local system. Returns a list
of FileName objects representing the root directories. The list only
includes roots to which the file safety settings allow access for
getFileInfo(). Note that this doesn't necessarily mean that you'll be
allowed to perform other operations on the returned roots, such as
listing the directory contents.

This is a static method, so you call it on the FileName class itself:

    local roots = FileName.getRootDirs();

Most Unix-like systems only have one root directory, usually called "/".
Many other systems have a separate root directory for each volume or
device; for example, Windows has a root folder for each drive letter, so
the root list might contain paths like C:\\ D:\\ etc. Some systems have
no concept of a root directory at all, in which case the result will be
an empty list; this is the case for the network storage server.

getBaseName()

Returns a string giving the base filename part of the path represented
by this FileName object. This separates the FileName into a directory
location portion and a file name portion, and returns just the file
name. In a Unix-style path, this is the last element of a path, giving
the name of the file stripped of its directory location. For example,
for 'data/images/pic.jpg', the base name is 'pic.jpg'. Other systems use
different syntax; this method parses the name according to the local
syntax on the host machine at run-time.

isAbsolute()

Determines if the filename that the object represents is an absolute
path on the local system; returns true if so, nil if not. An absolute
path is one that contains a root folder specification, such as a Unix
path starting with "/", or a Windows path starting with "C:\\. Such a
path can't be added to another "base" path, since it already fully
specifies a location. The format for an absolute path varies by
operating system, but the general principle is that an absolute path
name is a self-contained, fully specified location name that doesn't
depend on a working directory, current volume setting, or any other
context. If a path isn't absolute, it's relative; a relative path is one
that can be added to a base path to form a full path. When used without
first being combined with a base path, a relative path is implicitly
relative to a current working directory or similar context, which varies
by operating system.

listDir()

Returns a list of the names of the files contained in the directory
named by this object. The file listing is returned as a list of FileName
objects, each of which represents a file in this folder. Only the direct
contents of the directory are included; the contents of any
subdirectories within the directory aren't included.

If the file named by this object isn't a directory, or if the directory
can't be accessed, a FileOpenException is thrown. The file safety
settings must allow read access to the directory; if not, a file safety
exception is thrown. For the purposes of directory listings, the sandbox
folder itself is considered within the sandbox.

The list of files is returned in an order that's determined by the
operating system. You can use the [sort()](list.htm#sort) method on the
returned list if you want to sort the entries in a particular order.

Some operating systems, including Windows and Unix-like systems, include
special files in the results that represent relative links to the listed
directory and its parent. On Windows and Unix, these are called "." and
"..", respectively - but other systems use different names, so don't
just compare the name. Instead, use [getFileType()](#getFileInfo), and
check the FileTypeSelfLink and FileTypeParentLink flags (or use
[getFileInfo()](#getFileInfo), and check the specialLink property of the
returned FileInfo object).

Here's an example that lists the contents of a directory, recursively
listing the contents of any subdirectories. This illustrates how to test
a result to see if it's a regular file or a directory, and how to filter
out the special "." and ".." links to avoid infinite recursion. This
function expects *dir* to be a FileName object naming the directory to
list.

    listDir(dir, level = 0)
    {
       for (local file in dir.listDir())
       {
          local info = file.getFileInfo();
          "<<makeString('\t', level)>><<file.getBaseName().htmlify()>>\n";
          if (info.isDir && !info.specialLink)
             listDir(file, level + 1);
       }
    }

This function is similar to [forEachFile()](#forEachFile), but is more
convenient if you need a list of results, such as for sorting.
forEachFile() is better when you only need to perform an operation per
file rather than compiling a list, and it's also more convenient for
recursive scans since it can do those automatically.

Note that listDir() does **not** filter out files marked with the
"hidden" or "system" attributes (see the [getFileInfo()](#getFileInfo)
method and the fileAttrs property of the FileInfo object). Those
attributes are only meant to affect the way a directory listing is
presented to a user, whereas listDir() is designed to be used for more
general file management purposes where you might need the full file list
including hidden and system files. When you use listDir() to get a list
of files to display to the user, you should filter the list yourself to
remove hidden and system files, if desired, by checking each file's
attributes via getFileInfo().

removeDirectory(*deleteContents*?)

Deletes the directory named by this object.

If *removeContents* is specified, it must be true or nil. This indicates
whether or not the routine should delete the contents of the directory
before removing the directory itself. If this is true, the function
attempts to delete any files and subdirectories in the directory
(recursively deleting subdirectory contents) before deleting the
directory itself. If any file within the directory can't be deleted, the
method throws an error; if this happens, the directory's contents might
be partially deleted, since some files might already have been
successfully deleted before the error was encountered.

If *removeContents* is omitted or is nil, and the directory isn't
already empty, the routine returns nil (indicating failure) without
deleting anything. (Special system files that are always present in a
directory, such as "." and ".." on Unix, don't count when determining if
the directory is empty.) This is the default, since it helps avoid
accidentally deleting files that the application didn't explicitly
choose to remove.

For obvious reasons, use caution when using the *removeContents* flag.

This method requires that the file safety settings allow write access to
the directory to be deleted.

renameFile(*newname*)

Renames the file named by this object to *newname*, which may be given
as a string or a FileName object. The new name is treated as a full
path; the function can move the file to a new directory location in
addition to renaming it, if this is supported on the host operating
system. Some systems might support some file moves but not others; for
example, some systems allow moving files within a device or volume, but
not across volumes. Directories can be renamed if the host system
supports it.

There's no return value. If the operation fails, the method throws an
error.

*newname* must not refer to an existing file; if it does, the operation
isn't allowed. The file safety settings must allow write access to both
the old and new files (so you can't, for example, move a file to a
directory where you wouldn't have access to the relocated file).

toUniversal()

Returns a string with the FileName's path converted to the TADS
universal file path notation. This notation is similar to Unix path
syntax, with "/" as the path separator character. You can convert the
string back to a local path on the current system, or on a different
operating system, using [fromUniversal()](#fromUniversal).

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
FileName  
[*Prev:* File](file.htm)     [*Next:* GrammarProd](gramprod.htm)    
