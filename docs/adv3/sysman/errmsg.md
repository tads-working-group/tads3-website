::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> VM Run-Time Error Codes\
[[*Prev:* Exporting Symbols](export.htm){.nav}     [*Next:* The
Intrinsics](builtins.htm){.nav}     ]{.navnp}
:::

::: main
# VM Run-Time Error Codes

When the VM encounters an error in the user program, it throws an
exception of class RuntimeError. This exception object always contains
an integer value its [errno\_]{.code} property giving the VM error code
for the error condition. Programs that need to apply special handling
for certain types of errors can determine the specific VM error
condition via the error code [errno\_]{.code}.

[101: error reading file]{.errid}

::: errvb
Error reading file. The file might be corrupted or a media error might
have occurred.
:::

[102: error writing file]{.errid}

::: errvb
Error writing file. The media might be full, or another media error
might have occurred.
:::

[103: file not found]{.errid}

::: errvb
Error opening file. The specified file might not exist, you might not
have sufficient privileges to open the file, or a sharing violation
might have occurred.
:::

[104: error creating file]{.errid}

::: errvb
Error creating file. You might not have sufficient privileges to open
the file, or a sharing violation might have occurred.
:::

[105: error closing file]{.errid}

::: errvb
Error closing file. Some or all changes made to the file might not have
been properly written to the physical disk/media.
:::

[106: error deleting file]{.errid}

::: errvb
Error deleting file. This could because you don\'t have sufficient
privileges, the file is marked as read-only, another program is using
the file, or a physical media error occurred.
:::

[107: data packer format string parsing error at character index
*nnn*]{.errid}

::: errvb
The format string for the data packing or unpacking has a syntax error
at character index *nnn*.
:::

[108: data packer argument type mismatch at format string index
*nnn*]{.errid}

::: errvb
Data packer argument type mismatch. The type of the argument doesn\'t
match the format code at character index *nnn* in the format string.
:::

[109: wrong number of data packer arguments at format string index
*nnn*]{.errid}

::: errvb
Wrong number of arguments to the data packer. The number of argument
values doesn\'t match the number of elements in the format string.
:::

[110: this file operation isn\'t supported for storage server
files]{.errid}

::: errvb
This file operation isn\'t supported for storage server files. This
operation can only be used with local disk files.
:::

[111: error renaming file]{.errid}

::: errvb
An error occurred renaming the file. The new name might already be used
by an existing file, you might not have the necessary permissions in the
new or old directory locations, or the new name might be in an
incompatible location, such as on a different device or volume.
:::

[201: object ID in use - the image/save file might be corrupted]{.errid}

::: errvb
An object ID requested by the image/save file is already in use and
cannot be allocated to the file. This might indicate that the file is
corrupted.
:::

[202: out of memory]{.errid}

::: errvb
Out of memory. Try making more memory available by closing other
applications if possible.
:::

[203: out of memory allocating pool page]{.errid}

::: errvb
Out of memory allocating pool page. Try making more memory available by
closing other applications.
:::

[204: invalid page size - file is not valid]{.errid}

::: errvb
Invalid page size. The file being loaded is not valid.
:::

[205: no more property ID\'s are available]{.errid}

::: errvb
Out of property ID\'s. No more properties can be allocated.
:::

[206: circular initialization dependency in intrinsic class (internal
error)]{.errid}

::: errvb
Circular initialization dependency detected in intrinsic class. This
indicates an internal error in the interpreter. Please report this error
to the interpreter\'s maintainer.
:::

[301: this interpreter version cannot run this program (program requires
intrinsic class *xxx*, which is not available in this
interpreter)]{.errid}

::: errvb
This image file requires an intrinsic class with the identifier
\"*xxx*\", but the class is not available in this interpreter. This
program cannot be executed with this interpreter.
:::

[302: this interpreter version cannot run this program (program requires
intrinsic function set *xxx*, which is not available in this
interpreter)]{.errid}

::: errvb
This image file requires a function set with the identifier \"*xxx*\",
but the function set is not available in this intepreter. This program
cannot be executed with this interpreter.
:::

[303: reading past end of image file - program might be
corrupted]{.errid}

::: errvb
Reading past end of image file. The image file might be corrupted.
:::

[304: this is not an image file (no valid signature found)]{.errid}

::: errvb
This file is not a valid image file - the file has an invalid signature.
The image file might be corrupted.
:::

[305: this interpreter version cannot run this program (unknown block
type in image file)]{.errid}

::: errvb
Unknown block type. This image file is either incompatible with this
version of the interpreter, or has been corrupted.
:::

[306: data block too small]{.errid}

::: errvb
A data block in the image file is too small. The image file might be
corrupted.
:::

[307: invalid image file: pool page before pool definition]{.errid}

::: errvb
This image file is invalid because it specifies a pool page before the
pool\'s definition. The image file might be corrupted.
:::

[308: invalid image file: pool page out of range of definition]{.errid}

::: errvb
This image file is invalid because it specifies a pool page outside of
the range of the pool\'s definition. The image file might be corrupted.
:::

[309: invalid image file: invalid pool ID]{.errid}

::: errvb
This image file is invalid because it specifies an invalid pool ID. The
image file might be corrupted.
:::

[310: invalid image file: bad page index]{.errid}

::: errvb
This image file is invalid because it specifies an invalid page index.
The image file might be corrupted.
:::

[311: loading undefined pool page]{.errid}

::: errvb
The program is attempting to load a pool page that is not present in the
image file. The image file might be corrupted.
:::

[312: invalid image file: pool is defined more than once]{.errid}

::: errvb
This image file is invalid because it defines a pool more than once. The
image file might be corrupted.
:::

[313: invalid image file: multiple intrinsic class dependency tables
found]{.errid}

::: errvb
This image file is invalid because it contains multiple intrinsic class
tables. The image file might be corrupted.
:::

[314: invalid image file: no intrinsic class dependency table
found]{.errid}

::: errvb
This image file is invalid because it contains no intrinsic class
tables. The image file might be corrupted.
:::

[315: invalid image file: multiple function set dependency tables
found]{.errid}

::: errvb
This image file is invalid because it contains multiple function set
tables. The image file might be corrupted.
:::

[316: invalid image file: no function set dependency table
found]{.errid}

::: errvb
This image file is invalid because it contains no function set tables.
The image file might be corrupted.
:::

[317: invalid image file: multiple entrypoints found]{.errid}

::: errvb
This image file is invalid because it contains multiple entrypoint
definitions. The image file might be corrupted.
:::

[318: invalid image file: no entrypoint found]{.errid}

::: errvb
This image file is invalid because it contains no entrypoint
specification. The image file might be corrupted.
:::

[319: incompatible image file format version]{.errid}

::: errvb
This image file has an incompatible format version. You must obtain a
newer version of the interpreter to execute this program.
:::

[320: image contains no code]{.errid}

::: errvb
This image file contains no executable code. The file might be
corrupted.
:::

[321: incomptabile image file format: method header too old]{.errid}

::: errvb
This image file has an incompatible method header format. This is an
older image file version which this interpreter does not support.
:::

[322: unavailable intrinsic function called (index *nnn* in function set
\"*xxx*\")]{.errid}

::: errvb
Unavailable intrinsic function called (the function is at index *nnn* in
function set \"*xxx*\"). This function is not available in this version
of the interpreter and cannot be called when running the program with
this version. This normally indicates either (a) that the \"preinit\"
function (or code invoked by preinit) called an intrinsic that isn\'t
available during this phase, such as an advanced display function; or
(b) that the program used \'&\' to refer to a function address, andthe
function isn\'t available in this interpreter version.
:::

[323: unknown internal intrinsic class ID *nnn*]{.errid}

::: errvb
Unknown internal intrinsic class ID *nnn*. This indicates an internal
error in the interpreter. Please report this error to the interpreter\'s
maintainer.
:::

[324: page mask is not allowed for in-memory image file]{.errid}

::: errvb
This image file cannot be loaded from memory because it contains masked
data. Masked data is not valid with in-memory files. This probably
indicates that the program file was not installed properly; you must
convert this program file for in-memory use before you can load the
program with this version of the interpreter.
:::

[325: no embedded image file found in executable]{.errid}

::: errvb
This executable does not contain an embedded image file. The application
might not be configured properly or might need to be rebuilt. Re-install
the application or obtain an updated version from the application\'s
author.
:::

[326: object size exceeds hardware limits of this computer]{.errid}

::: errvb
An object defined in this program file exceeds the hardware limits of
this computer. This program cannot be executed on this type of computer
or operating system. Contact the program\'s author for assistance.
:::

[327: this interpreter is too old to run this program (program requires
intrinsic class version *xxx*, interpreter provides version
*xxx*)]{.errid}

::: errvb
This program needs the intrinsic class \"*xxx*\". This VM implementation
does not provide a sufficiently recent version of this intrinsic class;
the latest version available in this VM is \"*xxx*\". This program
cannot run with this version of the VM; you must use a more recent
version of the VM to execute this program.
:::

[328: invalid intrinsic class data - image file may be
corrupted]{.errid}

::: errvb
Invalid data were detected in an intrinsic class. This might indicate
that the image file has been corrupted. You might need to re-install the
program.
:::

[329: invalid object - class does not allow loading]{.errid}

::: errvb
An object in the image file cannot be loaded because its class does not
allow creation of objects of the class. This usually means that the
class is abstract and cannot be instantiated as a concrete object.
:::

[330: this interpreter is too old to run this program (program requires
function set version *xxx*, interpreter provides version *xxx*)]{.errid}

::: errvb
This program needs the function set \"*xxx*\". This VM implementation
does not provide a sufficiently recent version of this function set; the
latest version available in this VM is \"*xxx*\". This program cannot
run with this version of the VM; you must use a more recent version of
the VM to execute this program.
:::

[331: exported symbol \"*xxx*\" is of incorrect datatype]{.errid}

::: errvb
The exported symbol \"*xxx*\" is of the incorrect datatype. Check the
program and the library version.
:::

[332: invalid data in macro definitions in image file (error code
*nnn*)]{.errid}

::: errvb
The image file contains invalid data in the macro symbols in the
debugging records: macro loader error code *nnn*. This might indicate
that the image file is corrupted.
:::

[333: this program is not capable of restoring a saved state on
startup]{.errid}

::: errvb
This program is not capable of restoring a saved state on startup. To
restore the saved state, you must run the program normally, then use the
appropriate command or operation within the running program to restore
the saved position file.
:::

[334: image file is incompatible with debugger - recompile the
program]{.errid}

::: errvb
This image file was created with a version of the compiler that is
incompatible with this debugger. Recompile the program with the compiler
that\'s bundled with this debugger. If no compiler is bundled, check the
debugger release notes for information on which compiler to use.
:::

[400: this operation is not allowed by the network safety level
settings]{.errid}

::: errvb
This operation is not allowed by the current network safety level
settings. The program is attempting to access network features that you
have disabled with the network safety level options. If you wish to
allow this operation, you must restart the program with new network
safety settings.
:::

[1001: property cannot be set for object]{.errid}

::: errvb
Invalid property change - this property cannot be set for this object.
This normally indicates that the object is of a type that does not allow
setting of properties at all, or at least of certain properties. For
example, a string object does not allow setting properties at all.
:::

[1201: file is not a valid saved state file]{.errid}

::: errvb
This file is not a valid saved state file. Either the file was not
created as a saved state file, or its contents have been corrupted.
:::

[1202: saved state is for a different program or a different version of
this program]{.errid}

::: errvb
This file does not contain saved state information for this program. The
file was saved by another program, or by a different version of this
program; in either case, it cannot be restored with this version of this
program.
:::

[1203: intrinsic class name in saved state file is too long]{.errid}

::: errvb
An intrinsic class name in the saved state file is too long. The file
might be corrupted, or might have been saved by an incompatible version
of the interpreter.
:::

[1206: invalid object ID in saved state file]{.errid}

::: errvb
The saved state file contains an invalid object ID. The saved state file
might be corrupted.
:::

[1207: saved state file is corrupted (incorrect checksum)]{.errid}

::: errvb
The saved state file\'s checksum is invalid. This usually indicates that
the file has been corrupted (which could be due to a media error,
modification by another application, or a file transfer that lost or
changed data).
:::

[1209: storage server error]{.errid}

::: errvb
An error occurred accessing the storage server. This could be due to a
network problem, invalid user credentials, or a configuration problem on
the game server.
:::

[1210: saved file metadata table exceeds 64k bytes]{.errid}

::: errvb
The metadata table for the saved state file is too large. This table is
limited to 64k bytes in length.
:::

[1208: invalid intrinsic class data in saved state file]{.errid}

::: errvb
The saved state file contains intrinsic class data that is not valid.
This usually means that the file was saved with an incompatible version
of the interpreter program.
:::

[2001: cannot convert value to string]{.errid}

::: errvb
This value cannot be converted to a string.
:::

[2002: string conversion buffer overflow]{.errid}

::: errvb
An internal buffer overflow occurred converting this value to a string.
:::

[2003: invalid datatypes for addition operator]{.errid}

::: errvb
Invalid datatypes for addition operator. The values being added cannot
be combined in this manner.
:::

[2004: numeric value required]{.errid}

::: errvb
Invalid value type - a numeric value is required.
:::

[2005: integer value required]{.errid}

::: errvb
Invalid value type - an integer value is required.
:::

[2006: cannot convert value to logical (true/nil)]{.errid}

::: errvb
This value cannot be converted to a logical (true/nil) value.
:::

[2007: invalid datatypes for subtraction operator]{.errid}

::: errvb
Invalid datatypes for subtraction operator. The values used cannot be
combined in this manner.
:::

[2008: division by zero]{.errid}

::: errvb
Arithmetic error - Division by zero.
:::

[2009: invalid comparison]{.errid}

::: errvb
Invalid comparison - these values cannot be compared to one another.
:::

[2010: object value required]{.errid}

::: errvb
An object value is required.
:::

[2011: property pointer required]{.errid}

::: errvb
A property pointer value is required.
:::

[2012: logical value required]{.errid}

::: errvb
A logical (true/nil) value is required.
:::

[2013: function pointer required]{.errid}

::: errvb
A function pointer value is required.
:::

[2014: invalid index operation - this type of value cannot be
indexed]{.errid}

::: errvb
This type of value cannot be indexed.
:::

[2015: index out of range]{.errid}

::: errvb
The index value is out of range for the value being indexed (it is too
low or too high).
:::

[2016: invalid intrinsic class index]{.errid}

::: errvb
The intrinsic class index is out of range. This probably indicates that
the image file is corrupted.
:::

[2017: invalid dynamic object creation (intrinsic class does not support
NEW)]{.errid}

::: errvb
This type of object cannot be dynamically created, because the intrinsic
class does not support dynamic creation.
:::

[2018: object value required for base class]{.errid}

::: errvb
An object value must be specified for the base class of a dynamic object
creation operation. The superclass value is of a non-object type.
:::

[2019: string value required]{.errid}

::: errvb
A string value is required.
:::

[2020: list value required]{.errid}

::: errvb
A list value is required.
:::

[2021: list or string reference found in dictionary (entry \"*xxx*\") -
this dictionary cannot be saved in the image file]{.errid}

::: errvb
A dictionary entry (for the string \"*xxx*\") referred to a string or
list value for its associated value data. This dictionary cannot be
stored in the image file, so the image file cannot be created. Check
dictionary word additions and ensure that only objects are added to the
dictionary.
:::

[2022: invalid object type - cannot convert to required object
type]{.errid}

::: errvb
An object is not of the correct type. The object specified cannot be
converted to the required object type.
:::

[2023: numeric overflow]{.errid}

::: errvb
A numeric calculation overflowed the limits of the datatype.
:::

[2024: invalid datatypes for multiplication operator]{.errid}

::: errvb
Invalid datatypes for multiplication operator. The values being added
cannot be combined in this manner.
:::

[2025: invalid datatypes for division operator]{.errid}

::: errvb
Invalid datatypes for division operator. The values being added cannot
be combined in this manner.
:::

[2026: invalid datatype for arithmetic negation operator]{.errid}

::: errvb
Invalid datatype for arithmetic negation operator. The value cannot be
negated.
:::

[2027: value is out of range]{.errid}

::: errvb
A value that was outside of the legal range of inputs was specified for
a calculation.
:::

[2028: string is too long]{.errid}

::: errvb
A string value is limited to 65535 bytes in length. This string exceeds
the length limit.
:::

[2029: list too long]{.errid}

::: errvb
A list value is limited to about 13100 elements. This list exceeds the
limit.
:::

[2030: maximum equality test/hash recursion depth exceeded]{.errid}

::: errvb
This equality comparison or hash calculation is too complex and cannot
be performed. This usually indicates that a value contains circular
references, such as a Vector that contains a reference to itself, or to
another Vector that contains a reference to the first one. This type of
value cannot be compared for equality or used in a LookupTable.
:::

[2031: cannot convert value to integer]{.errid}

::: errvb
This value cannot be converted to an integer.
:::

[2032: invalid datatype for modulo operator]{.errid}

::: errvb
Invalid datatype for the modulo operator. These values can\'t be
combined with this operator.
:::

[2033: invalid datatype for bitwise AND operator]{.errid}

::: errvb
Invalid datatype for the bitwise AND operator. These values can\'t be
combined with this operator.
:::

[2034: invalid datatype for bitwise OR operator]{.errid}

::: errvb
Invalid datatype for the bitwise OR operator. These values can\'t be
combined with this operator.
:::

[2035: invalid datatype for XOR operator]{.errid}

::: errvb
Invalid datatype for the XOR operator. These values can\'t be combined
with this operator.
:::

[2036: invalid datatype for left-shift operator \'\<\<\']{.errid}

::: errvb
Invalid datatype for the left-shift operator \'\<\<\'. These values
can\'t be combined with this operator.
:::

[2037: invalid datatype for arithmetic right-shift operator
\'\>\>\']{.errid}

::: errvb
Invalid datatype for the arithmetic right-shift operator \'\>\>\'. These
values can\'t be combined with this operator.
:::

[2038: invalid datatype for bitwise NOT operator]{.errid}

::: errvb
Invalid datatype for the bitwise NOT operator. These values can\'t be
combined with this operator.
:::

[2039: code pointer value required]{.errid}

::: errvb
Invalid type - code pointer value required. (This probably indicates an
internal problem in the interpreter.)
:::

[2040: exception object required, but \'new\' did not yield an
object]{.errid}

::: errvb
The VM tried to construct a new program-defined exception object to
represent a run-time error that occurred, but \'new\' did not yield an
object. Note that another underlying run-time error occurred that
triggered the throw in the first place, but information on that error is
not available now because of the problem creating the exception object
to represent that error.
:::

[2041: cannot convert value to native floating point]{.errid}

::: errvb
The value cannot be converted to a floating-point type.
:::

[2042: cannot convert value to a numeric type]{.errid}

::: errvb
The value cannot be converted to a numeric type. Only values that can be
converted to integer or BigNumber can be used in this context.
:::

[2043: invalid datatype for logical right-shift operator
\'\>\>\>\']{.errid}

::: errvb
Invalid datatype for the logical right-shift operator \'\>\>\>\'. These
values can\'t be combined with this operator.
:::

[2201: wrong number of arguments]{.errid}

::: errvb
The wrong number of arguments was passed to a function or method in the
invocation of the function or method.
:::

[2202: argument mismatch calling *xxx* - function definition is
incorrect]{.errid}

::: errvb
The number of arguments doesn\'t match the number expected calling
*xxx*. Check the function or method and correct the number of parameters
that it is declared to receive.
:::

[2203: nil object reference]{.errid}

::: errvb
The value \'nil\' was used to reference an object property. Only valid
object references can be used in property evaluations.
:::

[2204: missing named argument \'*xxx*\']{.errid}

::: errvb
The named argument \'*xxx*\' was expected in a function or method call,
but it wasn\'t provided by the caller.
:::

[2205: invalid type for call]{.errid}

::: errvb
The value cannot be invoked as a method or function.
:::

[2206: nil \'self\' value is not allowed]{.errid}

::: errvb
\'self\' cannot be nil. The function or method context has a nil value
for \'self\', which is not allowed.
:::

[2270: cannot create instance of object - object is not a class]{.errid}

::: errvb
An instance of this object cannot be created, because this object is not
a class.
:::

[2271: cannot create instance - class does not allow dynamic
construction]{.errid}

::: errvb
An instance of this class cannot be created, because this class does not
allow dynamic construction.
:::

[2301: invalid opcode - possible image file corruption]{.errid}

::: errvb
Invalid instruction opcode - the image file might be corrupted.
:::

[2302: unhandled exception]{.errid}

::: errvb
An exception was thrown but was not caught by the program. The
interpreter is terminating execution of the program.
:::

[2303: stack overflow]{.errid}

::: errvb
Stack overflow. This indicates that function or method calls were nested
too deeply; this might have occurred because of unterminated recursion,
which can happen when a function or method calls itself (either directly
or indirectly).
:::

[2304: invalid type for intrinsic function argument]{.errid}

::: errvb
An invalid datatype was provided for an intrinsic function argument.
:::

[2305: default output function is not defined]{.errid}

::: errvb
The default output function is not defined. Implicit string display is
not allowed until a default output function is specified.
:::

[2306: invalid value for intrinsic function argument]{.errid}

::: errvb
An invalid value was specified for an intrinsic function argument. The
value is out of range or is not an allowed value.
:::

[2307: breakpoint encountered]{.errid}

::: errvb
A breakpoint instruction was encountered, and no debugger is active. The
compiler might have inserted this breakpoint to indicate an invalid or
unreachable location in the code, so executing this instruction probably
indicates an error in the program.
:::

[2308: external function calls are not implemented in this
version]{.errid}

::: errvb
This version of the interpreter does not implement external function
calls. This program requires an interpreter that provides external
function call capabilities, so this program is not compatible with this
interpreter.
:::

[2309: invalid opcode modifier - possible image file corruption]{.errid}

::: errvb
Invalid instruction opcode modifier - the image file might be corrupted.
:::

[2310: No mapping file available for local character set
\"*xxx*\"]{.errid}

::: errvb
\[Warning: no mapping file is available for the local character set
\"*xxx*\". The system will use a default ASCII character set mapping
instead, so accented characters will be displayed without their
accents.\]
:::

[2311: Unhandled exception: *xxx*]{.errid}

::: errvb
Unhandled exception: *xxx*
:::

[2312: VM Error: *xxx*]{.errid}

::: errvb
VM Error: *xxx*

(This is used as a generic template for VM run-time exception messages.
The interpreter uses this to display unhandled exceptions that terminate
the program.)
:::

[2313: VM Error: code *nnn*]{.errid}

::: errvb
VM Error: code *nnn*

(This is used as a generic template for VM run-time exceptions. The
interpreter uses this to report unhandled exceptions that terminate the
program. When it can\'t find any message for the VM error code, the
interpreter simply displays the error number using this template.)
:::

[2314: Exception in static initializer for *xxx*.*xxx*: *xxx*]{.errid}

::: errvb
An exception occurred in the static initializer for *xxx*.*xxx*: *xxx*
:::

[2315: intrinsic class exception: *xxx*]{.errid}

::: errvb
Exception in intrinsic class method: *xxx*
:::

[2316: stack access is out of bounds]{.errid}

::: errvb
The program attempted to access a stack location that isn\'t part of the
current expression storage area. This probably indicates a problem with
the compiler that was used to create this program, or a corrupted
program file.
:::

[2391: \'abort\' signal]{.errid}

::: errvb
\'abort\' signal

(This exception is used internally by the debugger to signal program
termination via the debugger UI.)
:::

[2392: \'restart\' signal]{.errid}

::: errvb
\'restart\' signal

(This exception is used internally by the debugger to signal program
restart via the debugger UI.)
:::

[2394: debugger VM halt]{.errid}

::: errvb
debugger VM halt

(This exception is used internally by the debugger to signal program
termination via the debugger UI.)
:::

[2395: interrupted by user]{.errid}

::: errvb
The program was interrupted by a user interrupt key or other action.
:::

[2396: no debugger available]{.errid}

::: errvb
An instruction was encountered that requires the debugger, but this
interpreter version doesn\'t include debugging capaabilities.
:::

[2500: invalid frame in debugger local/parameter evaluation]{.errid}

::: errvb
An invalid stack frame was specified in a debugger local/parameter
evaluation. This probably indicates an internal problem in the debugger.
:::

[2501: invalid speculative expression]{.errid}

::: errvb
This expression cannot be executed speculatively. (This does not
indicate a problem; it\'s merely an internal condition in the debugger.)
:::

[2502: invalid debugger expression]{.errid}

::: errvb
This expression cannot be evaluated in the debugger.
:::

[2503: image file has no debugging information - recompile for
debugging]{.errid}

::: errvb
The image file has no debugging information. You must recompile the
source code for this program with debugging information in order to run
the program under the debugger.
:::

[2600: out of temporary floating point registers (calculation too
complex)]{.errid}

::: errvb
The interpreter is out of temporary floating point registers. This
probably indicates that an excessively complex calculation has been
attempted.
:::

[2601: cannot convert value to BigNumber]{.errid}

::: errvb
This value cannot be converted to a BigNumber.
:::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The Language](langsec.htm){.nav}
\> VM Run-Time Error Codes\
[[*Prev:* Exporting Symbols](export.htm){.nav}     [*Next:* The
Intrinsics](builtins.htm){.nav}     ]{.navnp}
:::
