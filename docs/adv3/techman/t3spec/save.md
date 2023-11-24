![](../topbar.jpg)

[Table of Contents](../toc.htm) \| [T3 VM Technical
Documentation](../t3spec.htm) \> Saving and Restoring State  
[*Prev:* Metaclass Identifier List](metalist.htm)     [*Next:* TADS
Special Characters](tadsspch.htm)    

![](t3logo.gif)

  
  

## Appendix: Saving and Restoring State

Because the T3 VM is designed primarily for running games, an essential
feature of any implementation is the ability to save the state of the
game so that the state can be restored at a later time to continue the
session where it left off. The details of saving and restoring the
machine's state are inherently dependent on the implementation, so the
T3 VM specification does not prescribe a particular format for saved
state files. This section describes the format used by the MJR-T3
reference implementation so that other implementations can follow the
same format if desired; however, the format is subject to change in
future versions.

For the most part, saving and restoring state is a simple matter of
saving the state all reachable non-transient objects. However, a few
other bits of information must be stored as well.

### Version Compatibility

The purpose of a saved state file is to allow a player (i.e., the user
of a program running under the VM) to save a session at a particular
point and then resume the session again later as though the original
session had never been interrupted. Players typically use this feature
for two main purposes: first, to break up a long game into several
sessions, such as over several days or weeks; and second, to go back to
a prior saved position several times in order to experiment with
different paths from that position.

Based on the typical uses of a saved state file, we make the assumption
that a saved state file has a short useful lifetime, and is used by a
single user, but possibly on multiple computers (many people routinely
use more than one computer on a regular basis, so some users might wish
to be able to move a session among their various machines). We therefore
assign the following priorities to the saved state mechanism:

- Because of the short useful lifetime, we give low priority to the
  permanent validity of a saved state file, hence we will allow
  different VM implementations, and different versions of the same
  implementation, to use mutually incompatible saved state file formats,
  and to reject other formats on restore. This assumption is central to
  the absence of a required saved state format in the VM specification.
  Furthermore, this implies that saved state files should contain format
  information (such as a file signature) that allows a particular
  version of a particular VM implementation to ensure that a given state
  file is in the correct format for that VM version.
- Saved state files should be portable among different computers running
  the same VM implementation and version. This is easily accomplished
  using the same canonical data formats that the VM uses for image
  files.

### Save File Format for the MJR-T3 Reference Implementation

The MJR-T3 save file format contains the following data, in the order
shown:

> Signature  
> Size/checksum  
> Timestamp  
> Image Filename  
> Metaclasses  
> Table of Objects  
> Objects  
> Synthetic Exports  

These are described in more detail below.

#### Signature

The signature is used to identify the file as a saved state file and to
indicate the format version. For the reference implementation, this
consists of the following 17 bytes:

        T3-state-v####\015\012\032

The "#" symbols are replaced by a format version number, which is simply
a serial number changed whenever an incompatible change is made to the
format. The backslash sequences are in C octal code format, so "\015"
represents a single byte containing the decimal value 13. (The last
three characters are the ASCII codes that on most systems represent
carriage return, line feed, and end-of-file characters. On many systems,
this sequence will allow human-readable display of the signature string
when the file is displayed on interactive terminals; but this is only a
nicety, so the fact that it doesn't have this effect on all systems is
not important.)

The current file format version is 0008 (as of MJR-T3 v3.0.4).

#### Size/Checksum

The size and checksum fields are used to validate the file on loading,
to ensure that the file is not corrupted. This section contains a pair
of little-endian, 32-bit integers: the first is the size in bytes of the
saved state datastream, and the second is a checksum of the datastream.
For the purposes of both of these values, the datastream includes
everything **after** the size/checksum block - so, the bytes of the
signature and the size/checksum fields are **not** included in the size
or checksum values.

The checksum is computed using the standard CRC-32 (32-bit Cyclic
Redundancy Check) algorithm, as expressed in the [sample
code](#crc-sample) later in this appendix.

When loading a saved state file, the loader can check that the file is
at least as large a required, and that the bytes in the file match the
checksum computed when the file was saved. If these checks fail, the
loader should reject the attempt to restore the file, because the file
must have been corrupted and thus cannot be reliably loaded.

#### Timestamp

This is simply the timestamp information from the image file's
[signature](format.htm#Signature) block, in the same 24-byte format used
in the image file. The purpose of this information is to ensure that a
particular saved state file is restored only with the exact image file
that created it; saved state files are dependent upon the exact
internals of a particular image file (such as object and property ID
numbering), so a saved state file cannot meaningfully be restored except
with the exact version of the image file that created it.

#### Image Filename

This field contains a UINT2 length prefix followed by the bytes of the
image filename, in the local character set representation that was used
to load the image file in the first place. This information is stored to
allow a user to start the VM using only the saved state file as the
startup parameter: the VM reads the name of the image file from the
state file, loads the image, then restores the state. This procedure is
useful on operating systems with graphical desktop interfaces, for
example, in that it allows the user to launch the VM by double-clicking
(or using whatever UI gesture is appropriate) on a saved state file on
the desktop.

Note that this information is **not** used to validate that the correct
image file is loaded; only the timestamp information is used for
validation. The image filename is not a reliable indicator, since the
name can change when the program's image file is copied across a network
or even simply moved to another directory. The VM should thus not
attempt to validate the image file based on this field; instead, this
field is meant only to allow launching the image file when the user
specifies only the saved state file.

#### Metaclasses

This section consists of a UINT2 giving the number of metaclass entries,
followed by the metaclass entries. The metaclass entries are stored in
order of metaclass dependency index. Let *N* be the number of
metaclasses in the image file's MCLD block: then the first *N* entries
in the saved state file will be the same as the entries stored in the
image file, and must be in the same order. However, the saved state file
may contain more than *N* metaclass entries, because one metaclass can
be dependent upon another and thus create a run-time metaclass
dependency table entry not present in the image file.

Each metaclass entry is stored as follows:

- A UINT2 giving the size of the metaclass global name, followed by the
  bytes of the global name.
- A UINT4 giving the object ID of the metaclass's associated
  IntrinsicClass object.
- A UINT2 giving the number of entries in the metaclass's property
  translation table.
- A UINT2 giving the minimum property ID in the translation table.
- A UINT2 giving the maximum property ID in the translation table.
- The translation table for the metaclass, with each entry stored as
  follows:
  - A UINT2 giving the property ID of the property at the current index.
    This gives the property defined in the image file that is used to
    invoke the metaclass intrinsic function at the current index in the
    metaclass's intrinsic function vector.

#### Table of Objects

This section contains a "table of contents" for the saved objects. This
facilitates the fix-up process during restoration, by allowing the VM to
create a mapping table (from the file's object numbering scheme to the
new ID's assigned on restore) *prior* to deserializing the first object.
The VM thus has a full translation table at all times during the
deserialization process.

The table of objects includes *all* objects reachable at the time of
saving, including both transient and non-transient objects. Note that
transient objects will not actually be saved in the file, but at restore
time we will nonetheless need to know that an ID referred to a transient
object, hence we need to include transients in the table of objects.

This section consists of a UINT4 giving the number of objects in the
table of contents, followed by one entry per object. Each object entry
consists of:

- A UINT 4 giving the ID of the object, in the ID numbering scheme
  effective at the time of saving (on restore, this will be called the
  "file numbering scheme," because the object references within the
  saved state file are in terms of these object ID numbers)
- A UINT4 giving the object's flags. This is a bitwise-OR'd combination
  of the following:
  - 0x00000001 - this bit is set if the object is transient.

#### Objects

This section consists of a UINT4 giving the number of objects stored,
followed by the objects. Each object's entry is stored as follows:

- A UINT4 giving the object ID of this object.
- A BYTE with value 1 if the object is part of the "root set" (i.e., the
  object was originally loaded from the image file), 0 if not.
- A BYTE giving the metaclass dependency table index (in the metaclass
  table in the saved state file, as described above) of the object's
  metaclass.
- A variable number of bytes giving the data needed to reconstruct the
  object. These bytes are meaningful only to the particular metaclass
  that defines the object.

#### Synthetic Exports

This section gives the "synthetic exports" of the image file: these are
the symbols that the VM attempted to import from the image file when the
image file was loaded, but which the image file did not export. In some
cases, the VM simply treats unexported symbols as undefined, and in
other cases the VM must synthesize its own values for these symbols. In
the latter case, these dynamically generated values are called
"synthetic exports," because the VM acts as though they were exported by
the image file even though the image file left them undefined.

The VM can create synthetic exports that are not true exports, but are
*always* synthetic. In other words, when the VM must create a property
or object for its own internal use, it can use the synthetic export
mechanism to keep track of it, by assigning an external universally
unique name to the entity but never importing the entity from the image
file.

This section consists of a UINT4 giving the number of synthetic exports,
followed by the synthetic exports. Each export is stored as follows:

- A UINT2 giving the number of bytes in the name of this export.
- The bytes of the name of the export. This is one of the [predefined
  symbol](model.htm#predefined) names.
- A DATAHOLDER giving the synthesized value of the name.

The VM saves the synthetic exports to ensure that, upon restoring a
previously saved state, the same synthetic exports are used again.

When a VM loads a saved state, any synthetic exports loaded from the
saved state must be saved if the state is later saved again, **even if
the VM doesn't use the exports**. This is important because a user might
create a saved state with one VM version, restore the saved state on a
computer with a different VM version, save the state again, and then
move the new saved state file back to the original machine and thus the
original VM version. If the intermediate VM were not to include
unrecognized exports in the new saved state file, the original VM would
attempt to re-create the exports it had created the first time, which
could lead to an inconsistent state. By saving all exports, whether
recognized by the loading VM or not, consistency is assured when moving
the saved state file to another VM version.

### MIME Types and File Extesions

For the MJR-T3 save file format, we use the ad hoc MIME type
"application/x-t3vm-state".

On Windows systems, we use the default extension ".t3v".

Note that any alternative implementations with incompatible saved-state
formats should use a **different** MIME type and default extension, to
make the difference in file format explicit in the type metadata.

  
  

------------------------------------------------------------------------

### Sample CRC-32 Implementation

This is a sample of the CRC-32 computation used to compute the checksum
value for the saved state data stream.


    /*
     *  Compute the CRC-32 value of the given byte buffer
     */
    unsigned long crc32(const unsigned char *s, unsigned int len)
    {
        unsigned long val;
        static unsigned long tab[] = {
            0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
            0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
            0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
            0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, 0x84be41deL,
            0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, 0x136c9856L,
            0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, 0x63066cd9L,
            0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
            0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL,
            0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L,
            0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, 0x51de003aL,
            0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, 0xcfba9599L,
            0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, 0xb10be924L,
            0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
            0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL,
            0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL,
            0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, 0xe6635c01L,
            0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, 0x6c0695edL,
            0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, 0x12b7e950L,
            0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
            0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L,
            0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL,
            0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, 0x33031de5L,
            0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, 0xbe0b1010L,
            0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, 0xce61e49fL,
            0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
            0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L,
            0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L,
            0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L,
            0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, 0xf00f9344L,
            0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, 0x806567cbL,
            0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
            0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L,
            0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L,
            0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL,
            0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, 0x316e8eefL,
            0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, 0x5268e236L,
            0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
            0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L,
            0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL,
            0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, 0x05005713L,
            0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, 0x92d28e9bL,
            0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, 0xf1d4e242L,
            0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
            0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL,
            0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L,
            0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, 0xd06016f7L,
            0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, 0x40df0b66L,
            0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, 0x30b5ffe9L,
            0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
            0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L,
            0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL,
            0x2d02ef8dL
        };
      
        /* compute the CRC value */
        for (val = 0 ; len != 0 ; ++s, --len)
            val = tab[(val ^ *s) & 0xff] ^ (val >> 8);

        /* return the computed value */
        return val;
    }

Copyright © 2001, 2006 by Michael J. Roberts.  
Revision: September, 2006

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](../toc.htm) \| [T3 VM Technical
Documentation](../t3spec.htm) \> Saving and Restoring State  
[*Prev:* Metaclass Identifier List](metalist.htm)     [*Next:* TADS
Special Characters](tadsspch.htm)    
