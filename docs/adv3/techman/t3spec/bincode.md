::: topbar
![](../topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](../toc.htm){.nav} \| [T3 VM Technical
Documentation](../t3spec.htm){.nav} \> Portable Binary Encoding\
[[*Prev:* Image File Format](format.htm){.nav}     [*Next:* Character
Mapping](charmap.htm){.nav}     ]{.navnp}
:::

::: main
![](t3logo.gif)

\
\

## T3 Portable Binary Encoding

All T3 binary files are encoded in a portable format that allows a
binary file created on one type of computer to be used without any
changes with T3 implementations on other types of computers. To achieve
this binary portability, T3 binary files use a portable encoding that
represents datatypes in a standard format. Each T3 implementation
translates between the standard format and the local representation of
the datatype when reading and writing files.

### Datatypes

The following are the portable datatypes and their encoding:

#### UTF-8 Text

Unicode text is encoded in UTF-8. This encoding represents each 16-bit
Unicode character with one, two, or three bytes:

From

To

Binary Encoding

0x0000

0x007f

0bbbbbbb

0x0080

0x07ff

110bbbbb 10bbbbbb

0x0800

0xffff

1110bbbb 10bbbbbb 10bbbbbb

The bits of the 16-bit value are encoded into the **b**\'s in the table
above with the most significant group of bits in the first byte. So:
0x571 has the 16-bit Unicode binary pattern 0000011001110001, and is
encoded in UTF-8 as 11011001 10110001.

Note that UTF-8 encodes the most significant bits in the first bytes;
this is different from the byte ordering used for other types (such as
integers), which are all stored in little-endian format
(least-significant byte first). The reason for this disparity is that
this ordering makes it possible to compare two UTF-8 strings in a
byte-wise fashion. (This type of magnitude comparison is not always
especially useful, since it does not produce correct results for a
localized sorting order, but it at least produces a uniform sorting
order based on the Unicode code points stored in the string and hence
may be useful in certain cases for building internal indices and
tables.)

#### Integer values

Integer values are stored in little-endian format (i.e.,
least-significant byte first) in fixed-size byte arrays. These values
are not aligned on any particular boundary in the file. These values can
be interpreted as signed or unsigned. Signed values are encoded in
2\'s-complement notation.

**16-bit integers** are stored as 2-byte arrays. The first byte has the
low-order 8 bits, the second byte has the high-order 8 bits.

**32-bit integers** are stored as 4-byte arrays. The first byte has the
low-order 8 bits, the second byte has the next more significant 8 bits,
the third byte has the next more significant 8 bits, and the fourth byte
has the most significant 8 bits.

### Data Holders

The T3 VM uses run-time typing, which allows certain types of variables
to hold any type of value; this type of value is tagged with its type,
so that the VM can interpret the value correctly whenever it is used.

In order to store these \"variant\" types, the VM defines a composite
type called a data holder. This composite contains the type information
along with the value.

To store a data holder portably, we store a 5-byte array. The first byte
contains the type ID value. The remaining 4 bytes encode the value using
the standard primitive type encodings; the table below shows the
correspondence between the primitive types and their encodings.

When an encoding does not take up the full 4 bytes, the value is packed
into the earlier bytes, and the later bytes have arbitrary values. For
example, a property ID is encoded in a data holder as follows:

Byte Index

Value

0

6 (the type code for VM_PROP)

1

low-order 8 bits of property ID value

2

high-order 8 bits of property ID value

3

arbitrary

4

arbitrary

### Type ID\'s

The table below shows the assigned ID values for the primitive types.
(The types shown in italics are reserved for internal use by
implementations and will never appear in portable files; we list them
for the sake of completeness, but they\'ll never be stored persistently
and thus are not relevant to the portable file format.)

Type Name

Type ID

Description

Value Encoding

VM_NIL

1

nil (boolean \"false\" or null pointer)

none

VM_TRUE

2

boolean \"true\"

none

*VM_STACK*

3

*Reserved for implementation use for storing native machine pointers to
stack frames (see note below)*

none

*VM_CODEPTR*

4

*Reserved for implementation use for storing native machine pointers to
code (see note below)*

none

VM_OBJ

5

object reference as a 32-bit unsigned object ID number

UINT4

VM_PROP

6

property ID as a 16-bit unsigned number

UINT2

VM_INT

7

integer as a 32-bit signed number

INT4

VM_SSTRING

8

single-quoted string; 32-bit unsigned constant pool offset

UINT4

VM_DSTRING

9

double-quoted string; 32-bit unsigned constant pool offset

UINT4

VM_LIST

10

list constant; 32-bit unsigned constant pool offset

UINT4

VM_CODEOFS

11

code offset; 32-bit unsigned code pool offset

UINT4

VM_FUNCPTR

12

function pointer; 32-bit unsigned code pool offset

UINT4

VM_EMPTY

13

no value (this is useful in some cases to represent an explicitly unused
data slot, such as a slot that has never been initialized)

none

*VM_NATIVE_CODE*

14

*Reserved for implementation use for storing native machine pointers to
native code (see note below)*

none

VM_ENUM

15

enumerated constant; 32-bit integer

UINT4

VM_BIFPTR

16

built-in function pointer; 32-bit integer, encoding the function set
dependency table index in the high-order 16 bits, and the function\'s
index within its set in the low-order 16 bits.

UINT4

*VM_OBJX*

17

*Reserved for implementation use for an executable object, as a 32-bit
object ID number (see note below)*

UINT4

Note that types 3 (VM_STACK), 4 (VM_CODEPTR), 14 (VM_NATIVE_CODE), and
17 (VM_OBJX) are reserved for implementation use. These will **never**
appear in a portable binary file; we list them here only for
completeness. These types are intended to allow implementations to store
native datatypes (such as native machine pointers) for which there is no
meaningful portable representation. Implementations are free to use
these types for any purposes of their own; the names and descriptions in
the table are for mnemonic value only and shouldn\'t be taken to imply a
required use for these types.

### Type Names

The file format specifications use the following names to refer to the
portable datatypes:

Name

Description

SBYTE

Signed 8-bit byte

UBYTE

Unsigned 8-bit byte

UTF8

Unicode text encoded as UTF-8

INT2

Signed 16-bit (2-byte) integer

UINT2

Unsigned 16-bit (2-byte) integer

INT4

Signed 32-bit (4-byte) integer

UINT4

Unsigned 32-bit (4-byte) integer

DATA_HOLDER

Data holder for any primitive type

::: t3spec_version
Copyright © 2001, 2006 by Michael J. Roberts.\
Revision: September, 2006
:::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 Technical Manual*\
[Table of Contents](../toc.htm){.nav} \| [T3 VM Technical
Documentation](../t3spec.htm){.nav} \> Portable Binary Encoding\
[[*Prev:* Image File Format](format.htm){.nav}     [*Next:* Character
Mapping](charmap.htm){.nav}     ]{.navnp}
:::
