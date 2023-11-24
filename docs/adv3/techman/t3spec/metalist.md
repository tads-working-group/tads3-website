![](../topbar.jpg)

[Table of Contents](../toc.htm) \| [T3 VM Technical
Documentation](../t3spec.htm) \> Metaclass Identifier List  
[*Prev:* t3vm Function Set](fnset_t3.htm)     [*Next:* Saving and
Restoring State](save.htm)    

![](t3logo.gif)

  
  

## Appendix: Metaclass Identifier List

The T3 VM uses metaclass identifiers to associate metaclass types with
their implementations. A T3 application stores the identifiers of the
metaclasses it uses in its image file; the VM uses these identifiers to
allow the application to call code in the metaclasses. Refer to the
[machine model](model.htm#metaclass_id) documentation for details of
this mechanism.

Metaclass identifiers are universally unique. A given metaclass ID
string always refers to the same metaclass type, for all VM
implementations and for all applications. This universal identification
mechanism ensures that an application and VM implementation can agree on
the exact meaning of a metaclass type. To ensure universal uniqueness,
we main a central registry of defined metaclasses and their identifiers.

The defined metaclass identifiers are shown below. Metaclass identifier
strings use only 7-bit ASCII characters, and may be from 1 to 255
characters in length. By convention, we avoid spaces (using a hyphen
instead for each word break), and use lower-case letters; however,
future identifiers will not necessarily be restricted to this subset, so
implementations should be prepared to accept any 7-bit ASCII characters
from code points 32 to 126 inclusive.

ID

Metaclass

tads-object

TADS Object

list

List

string

String

lookuptable

Lookup Table

vector

Vector

**Implementation Developers:** Anyone who needs to add new metaclasses
in the course of adapting a T3 VM implementation to a new application
domain should contact the T3 VM specification's maintainer to register
the new metaclasses and obtain identifiers. This will ensure that the
new metaclasses will coexist with others, which will allow the new
system to interoperate with existing compilers and other tools.

Copyright © 2001, 2006 by Michael J. Roberts.  
Revision: September, 2006

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](../toc.htm) \| [T3 VM Technical
Documentation](../t3spec.htm) \> Metaclass Identifier List  
[*Prev:* t3vm Function Set](fnset_t3.htm)     [*Next:* Saving and
Restoring State](save.htm)    
