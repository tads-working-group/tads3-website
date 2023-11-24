![](../topbar.jpg)

[Table of Contents](../toc.htm) \| [T3 VM Technical
Documentation](../t3spec.htm) \> Byte-Code Instruction Set  
[*Prev:* The Metaclasses](metacl.htm)     [*Next:* Image File
Format](format.htm)    

![](t3logo.gif)

  
  

## T3 VM Byte-code Instruction Set

This document describes the instruction set of the T3 Virtual Machine.
The executable code in a T3 program is constructed from sequences of
instructions, with each instruction directing the machine to execute a
particular action. This document provides the details of how each
instruction is encoded and how the VM implementation carries out the
action specific by each instruction.

**Indices:**

- [Alphabetically by Mnemonic](#index_by_name)
- [By Category](#index_by_cat)
- [By Numeric Opcode](#index_by_opcode)

------------------------------------------------------------------------

### Instruction Set Design Philosophy

#### Stack-based machine

The T3 VM is a stack-based machine, which means that most operations are
performed through the machine stack. This is an extremely natural model
for translation of high-level language programs, which makes it easier
to design efficient compilers that target the T3 VM.

Most instructions that perform computations, perform comparisons, or
otherwise operate on data values use the stack. In nearly all cases,
these instructions simply operate on the top one or two (or occasionally
more) elements of the stack; these instructions are hence very simple
and are often completely unparameterized, in that they always operate on
the top of the stack.

Instructions that operate on non-stack data generally have the effect of
moving data to or from the stack. Thus, performing a computation on a
non-stack item such as an object property is a matter of pushing the
property value onto the stack, performing the computation (implicitly on
the item on the top of the stack), then popping the value at the top of
the stack and setting the property to that value.

#### Field Encoding

Many real computers (i.e., those implemented directly in hardware, as
opposed to entirely software constructs such as the T3 VM) use an
instruction encoding that divides each instruction into a set of fields,
each field specifying a particular aspect of the operation to be
performed. These fields are generally orthogonal, so that, for example,
an instruction's addressing mode can be determined entirely by
inspecting the addressing mode field, without knowing anything else
about the instruction.

Field-based instructions work well for real computers precisely because
they're implemented in hardware. In particular, hardware computers can
use circuitry dedicated to decoding each field of an instruction
separately, so the various decoding tasks can proceed in parallel to an
extent.

The T3 VM uses a much simpler instruction encoding. T3 instructions do
not encode orthogonal fields of information; instead, each instruction
encodes a separate operation, and implies all of the operation's
characteristics.

This may seem less efficient than a field-based instruction set. For
example, many different instructions may use the same addressing mode
(accessing a local variable, for example), so one could imagine some
advantage deriving from an addressing mode field so that common code
could be executed for all instructions involving that address mode.

This is a somewhat illusory advantage, for a number of reasons, but
mostly because nearly all T3 VM instructions simply operate on the
stack. Because of this regularity, encoding such additional information
as addressing modes would actually decrease execution efficiency,
because the VM would have to decode the addressing mode for every
instruction, even though nearly all instructions would use the same mode
and hence could skip this step.

#### High-level instructions

The T3 VM instruction set is high-level: it operates on datatypes that
are constructed out of more primitive pieces. The instruction set does
not even include instructions to operate on a lower level of abstraction
than that provided through the system datatypes; this vastly simplifies
the machine model and makes programming the machine much safer (in that
it is difficult or impossible to write a program that actually corrupts
the internal state of the VM itself; even the most ill-formed or
malicious programs should at worst cause run-time exceptions which the
VM can detect and handle gracefully), but it means that it is not
practical to implement an efficient T3 VM using the T3 VM.

#### Internal Redundancy

The instruction set includes a certain amount of redundancy, in that the
effect of certain instructions can be constructed entirely from other,
simpler instructions. For example, the OBJGETPROP instruction is not
strictly necessary, because the same effect could be obtained from a
combination of the PUSHOBJ and CALLPROP instructions. Similarly, the
ADDILCL4 instruction could be replaced with a combination of the
PUSHINT, GETLCL2, ADD, and SETLCL2 instructions.

These redundant instructions are included as an optimization. Certain
sequences of operations occur very frequently in typical programs; by
combining some of the most frequently repeated sequences into single
instructions, we allow compilers to generate smaller code that we can
execute more efficiently. Compilers are, of course, free to ignore these
composite instructions and generate only the more orthogonal
instructions, but compilers that are capable of taking advantage of the
optimizations will generally produce smaller, faster code.

------------------------------------------------------------------------

### Instruction Set Overview

The T3 program format is defined independently of any particular
computer hardware. The byte-code format is portable to all types of
computers, with no changes to the binary coding.

T3 executable code is composed of streams of byte-code instructions.
Each instruction consists of a one-byte "opcode," followed immediately
(with no padding bytes) by operand data. Immediately following the
operand data is the next instruction.

The size and interpretation of the operand data varies by instruction.
Most instructions have a fixed operand size, so the number of bytes of
operand data can be deduced directly from the instruction's opcode; a
few instructions, however, use varying-length operand data, in which
case the size is encoded in the operand data. Some instructions have no
operands; the opcode byte is the entirety of such instructions.

Operands are encoded in a portable binary format. Refer to the [TADS
portable binary encoding documentation](bincode.htm) for details of the
portable representations used; this format specifies for each of a set
of datatypes a coding that uses the same size and byte layout on all
types of computers.

The opcode descriptions below give a name for each opcode. This name is
provided only for documentary purposes, and never occurs in actual
byte-code instructions, which are stored as 8-bit numeric codes. Each
opcode description lists the numeric code for the instruction as a
hexadecimal number in parentheses after the opcode name.

In the opcode descriptions below, the operands are listed after the
opcode name. Instructions that take no operands are marked as such. Each
operand is described with its portable binary encoding type name, and is
also given an operand name; the operand name is for documentary purposes
only, to allow the desriptive text to refer to the operands more easily.
Note that we sometimes refer to these operands as "immediate data,"
since they're encoded directly into the instruction stream.

#### Local Variables and Parameters

Each local variable and each parameter occupies one stack location.

To call a function or method, the caller pushes the actual parameters
onto the stack in reverse order. For example, if the caller wants to
call a function with three numeric arguments, the first set to 1, the
second to 2, and the third to 3, the caller pushes the value 3, then 2,
then 1. The caller then calls the function or method. The VM sets up the
callee's stack frame, which involves allocating space for local
variables and storing certain values (return address, target property,
"self" instance reference, method header pointer) in the stack, then
transfers control to the start of the callee's code.

Locals and parameters are accessed through explicit instructions that
refer to these special stack locations.

Locals are numbered from 0 through the number of locals minus one. So,
if a function's header indicates that the function has three local
variables, the variables are numbered 0, 1, and 2.

Parameters are numbered from 0 through the number of parameters minus 1.
So, if a function has four parameters, they're numbered 0, 1, 2, and 3.
Parameter 0 is the first argument, which is the last value pushed by the
caller.

#### "Integer" vs. "Number"

This specification intentionally makes a distinction between "integers"
and "numbers" (or "numeric values") as T3 primitive datatypes. The term
"integer" is meant specifically as the T3 machine's 32-bit signed
integer type. The terms "number" and "numeric value" are meant to
include *any* T3 numeric primitive type.

At present, the only primitive numeric datatype that the T3 machine
defines is integer, so "integer" and "number" are effectively equivalent
at the moment. We've nonetheless drawn the distinction in order to keep
open the possibility that other numeric datatypes, such as a
floating-point type, can be added in the future with minimal reworking
of this document. Introducing a new numeric datatype will certainly
require some additions in any case, in that issues such as promotion and
rounding will arise, but we have tried to be precise about where
integers specifically are required as opposed to where numeric types
that may be added in the future could be used. For example, the bitwise
operations (BAND, BOR, SHL, etc.) are only meaningful with integer
values, so non-integer numeric types would not be usable with these
operations and they therefore refer to integer operands; the arithmetic
operations (MUL, DIV, SUB), on the other hand, would be meaningful with
any numeric types, hence they refer to numeric operands.

#### Branching Instructions

Certain instructions (JMP; JT, JF, and so on; SWITCH) cause execution to
branch to another location within the same function or method. These
instructions encode the branch location as a *relative offset*. In all
cases, the branch offset is given as a 16-bit signed integer in portable
INT2 format, and is to be interpreted as a number of bytes to add to a
pointer to the first byte of the INT2 branch offset value itself. Hence,
if *p* is a character pointer containing the address of the first byte
of the INT2 operand of a JMP instruction, and the INT2 contains the
signed 16-bit value *branch_offset*, the address of the next instruction
to execute is given by *p* + *branch_offset*.

Branch instructions must always refer to addresses within the same
method or function. Since any single method or function must be entirely
contained within a single code pool segment, a branch will always refer
to code in the same code pool segment, hence there is never a
possibility that a branch will involve a separate segment. Branching
therefore can always be processed without any pool swapping effects,
regardless of the swapping configuration.

#### Stack Illustrations

The T3 VM is a stack-based machine, so most instructions modify the
stack in some way. For quick reference, the description of each
instruction below features a concise schematic illustrating the
instruction's effect on the stack.

Each stack illustration depicts the state of the stack before and after
the instruction. Each schematic starts with the initial state of the
stack, showing the condition of the stack just before the instruction;
this is followed by a right arrow ("→"); the schematic ends with the
final state of the stack, showing the condition just after the
instruction.

The values depicted in the stack are either variables or constants;
variables are shown in *italics*. In many cases, the diagrams use
explicit "type casts" to indicate the type of the value; these are used
in particular with "immediate" values (encoded directly in
instructions), because the type of an immediate value is usually
implicit in the instruction containing it. For example, the GETPROP
instruction has a UINT2 immediate value giving a property ID, so the
stack diagram for the instruction uses this notation to indicate
explicitly that a property ID value should be constructed from the UINT2
immediate value:

    propid(*prop_id*)

In this notation, propid() is a "type cast" that states explicitly that
the value contained within the parentheses is to be converted to a
property ID value. We use these casts:

object()

Convert a UINT4 to an object reference, treating the UINT4 as the ID of
an object

propid()

Convert a UINT2 to a property pointer, treating the UINT2 as the ID of a
property

string()

Convert a UINT4 to a constant string (SSTRING) value, treating the UINT4
as a constant pool offset

list()

Convert a UINT4 to a constant list value, treating the UINT4 as a
constant pool offset

int()

Convert a value (SBYTE, INT2, INT4, etc) to an integer

function_pointer()

Convert a UINT4 value to a function pointer, treating the UINT4 as a
constant pool offset

Only the top few elements of the stack are depicted in each schematic;
everything below these elements is shown as "..." in the illustration.
The stack grows to the right in each schematic, and the top element of
the stack is the rightmost element. So, if the top element of the stack
is the integer 1, the next element is the integer 2, and the next
element is the integer 3, the schematic would look like this:

... int(3) int(2) int(1)

The elements depicted after the "..." symbol are the elements affected
by the instruction. The instruction never affects anything below the
first explicitly listed element.

Note that, in some cases, an ellipsis occurs *within* the explicitly
listed items on the stack, as well as at the left. An ellipsis within
the listed items indicates a varying number of items; for example, if
several arguments to a function were on the stack, we'd use this
notation:

... argumentN ... argument1

Some instructions only add elements to the stack; in these cases, the
initial state is shown simply as "...", since nothing previously on the
stack is affected by the instruction. Similarly, some instructions only
remove items from the stack; we show this with only "..." in the final
state.

Here's an example of an instruction that simply pushes a new value, nil,
onto the stack:

... → ... nil

Here's an example that simply removes an item from the stack:

... *val* → ...

The next illustration shows an instruction that removes two elements
from the stack, computes the sum of the two elements, and pushes the
result:

... *val1* *val2* → ... (*val1* + *val2*)

The stack illustrations are meant to make it easy to tell at a glance
how an instruction affects the stack, but they rarely tell the whole
story. Note, in particular, that effects on local variables are not
depicted in the diagrams, even though local variables are stored in the
stack, because local variable operations don't affect the stack pointer
(i.e., they don't change the number of items on the stack).

#### Operator Overloading

Starting with the December 2010 revision (3.1 of the MJR-T3 reference
implementation), some operators in the language can be overloaded for
objects. Not all operators are overloadable; only specific ones. The
overloadable operators, and the affected byte-code instructions, are
shown in the table below.

Description

Type

Affected Instructions

Import Symbol

addition

binary

[ADD](#opc_ADD), [INC](#opc_INC), [INCLCL](#opc_INCLCL),
[ADDILCL1](#opc_ADDILCL1), [ADDILCL4](#opc_ADDILCL4),
[ADDTOLCL](#opc_ADDTOLCL)

'operator +'

subtraction

binary

[SUB](#opc_SUB), [DEC](#opc_DEC), [DECLCL](#opc_DECLCL),
[SUBFROMLCL](#opc_SUBFROMLCL)

'operator -'

multiplication

binary

[MUL](#opc_MUL)

'operator \*'

division

binary

[DIV](#opc_DIV)

'operator /'

modulo

binary

[MOD](#opc_MOD)

'operator %'

XOR

binary

[XOR](#opc_XOR)

'operator ^'

left-shift

binary

[SHL](#opc_SHL)

'operator \<\<'

arithmetic right-shift

binary

[ASHR](#opc_ASHR)

'operator \>\>'

logical right-shift

binary

[LSHR](#opc_LSHR)

'operator \>\>\>'

bitwise NOT

unary

[BNOT](#opc_BNOT)

'operator ~'

bitwise OR

binary

[BOR](#opc_BOR)

'operator \|'

bitwise AND

binary

[BAND](#opc_BAND)

'operator &'

arithmetic negation

unary

[NEG](#opc_NEG)

'operator negate'

indexing

binary

[INDEX](#opc_INDEX), [IDXLCL1INT8](#opc_IDXLCL1INT8),
[IDXINT8](#opc_IDXINT8) [](#opc_%3Ctd%3E'operator%20%5B%5D')

'operator \[\]'

index-and-assign

ternary

[SETIND](#opc_SETIND), [SETINDLCL1I8](#opc_SETINDLCL1I8)

'operator \[\]='

Operator overloading is defined on the single operand of a unary
operator, or the left operand of a binary or ternary operator, as
written in algebraic notation. (The only overloadable ternary operator
is the index-and-assign operator. The algebraic notation for this
operator is *container*\[*index*\]=*value*, so the left operand for
overloading purposes is the *container* value.)

The handling of operator overloading is specifically designed to have
zero performance impact in cases where native types are involved. In
particular, native operator handling is always applied first;
overloading is invoked only if no valid native handling is available for
an operation, in which case a type mismatch error would result if no
overloading were defined. For programs that don't use overloading, then,
the presence of the feature makes no difference at all. (Assuming a
correct program, anyway. A program with type mismatch errors would in
fact see slightly slower error handling, because the VM has to check for
an override before finally throwing the error. It seems unlikely that
any program would intentionally use type mismatch errors as a control
flow mechanism, especially in a performance-sensitive section of the
code, so this conceivable element of performance impact seems
negligible.)

For the affected byte-code instructions, the instruction spec will say
"try operator overloading" as the execution step *after* all native-type
combinations are exhausted, and *before* throwing a type mismatch error.
"Try operator overloading" means specifically:

- Identify the controlling operand. For a unary operator, this is the
  single operand. For a binary operator, it's the left operand as
  written in algebraic notation. For the index-and-assign operator, it's
  the container operator.
- If the controlling operand is not of type object, operator overloading
  fails.
- Look up the "operator *x*" import symbol associated with the operator.
  This is a property pointer value if defined. If this import isn't
  defined by the loaded image file, operator overloading fails.
- Check to see if the *operator x* property of the controlling operand
  object is defined. If not, operator overloading fails.
- Call the *operator x* property of the controlling operand, passing as
  arguments the additional operands, in left-to-right order per the
  algebraic form. (For index-and-assign, the argument list is (*index*,
  *value to assign*).) For example, for "a\*b", we'd call
  *a*.operator\*(*b*).
- The return value of the method call is the result of the operator.
  Handle it according to the normal semantics for the instruction (e.g.,
  push it on the stack, assign it to a local variable, etc).
- Operator overloading is successful, so the opcode is now done.

Implementation notes: the easiest way for a VM implementation to achieve
the "call the operator property" step is with a recursive call into the
VM. The reference MJR-T3 implementation handles this a little
differently, for performance reasons. MJR-T3 handles overloading like a
GETPROP instruction, via a non-recursive transfer to the property's byte
code. However, because the regular method call interface returns its
value in R0, and operator instructions all require some other handling
for the return value (such as pushing on the stack or assigning to a
local), it's necessary to set up some kind of intermediate subroutine on
return to apply the instruction's return value handling. The MJR-T3 code
does this by saving the true return address on the stack (along with any
additional required information, such as the local variable index to be
assigned on return); it then patches in a "fake" return address for the
method call. On return, the VM's return handler recognizes the fake
address and carries out the appropriate "subroutine" operations, and
finally returns to the saved address. This approach is slightly faster
than making a recursive VM call, and the extra handling on return
doesn't affect overall performance because the VM already had other
special handling at the same place, to handle returns from recursive
invocations. The addition of new fake return addresses doesn't cost
anything because we already had to check for a fake return anyway.

#### List-like Objects

Operator overloading makes it possible to define custom byte-code
objects (of metaclass tads-object) that behave like lists. For the most
part this is in the province of the metaclasses to respect, but there's
one instruction that cares about it: MAKELSTPAR. This instruction must
treat a list-like object the same way it treats a list.

A list-like object is defined as an object with the following
characteristics:

- It defines (or inherits) the property given by the import symbol
  'operator \[\]'
- It defines (or inherits) the property given by the import symbol
  'length'
- Its 'length' property requires zero arguments, and when evaluated
  returns a non-negative integer value

If an object meets these tests, it must be treated as list-like by
MAKELSTPAR.

------------------------------------------------------------------------

## Instruction Set Listing

All of the T3 byte code instructions are listed below. The instructions
are ordered by the numeric opcode value. For other orderings, refer to
the indices:

- [Alphabetically by Mnemonic](#index_by_name)
- [By Category](#index_by_cat)

------------------------------------------------------------------------

**PUSH_0 (0x01)**  
*No operands.*

Stack: ... → ... int(0)

Push the constant integer value 0 (zero) onto the stack.

This instruction is redundant with PUSHINT, but is defined as a code
size optimization for this frequently-used operation; this instruction
requires only one byte, whereas the PUSHINT equivalent would require
five bytes.

------------------------------------------------------------------------

**PUSH_1 (0x02)**  
*No operands.*

Stack: ... → ... int(1)

Push the constant integer value 1 (one) onto the stack.

This instruction is redundant with PUSHINT, but is defined as a code
size optimization for this frequently-used operation; this instruction
requires only one byte, whereas the PUSHINT equivalent would require
five bytes.

------------------------------------------------------------------------

**PUSHINT8 (0x03)**  
SBYTE *val*

Stack: ... → ... int(*val*)

Push the integer value *val* onto the stack. *val* is interpreted as a
signed 8-bit integer in the range -128 and 127 inclusive.

This instruction is redundant with PUSHINT, but is defined as a code
size optimization; this instruction requires only two bytes, whereas the
PUSHINT equivalent would require five bytes.

------------------------------------------------------------------------

**PUSHINT (0x04)**  
INT4 *val*

Stack: ... → ... int(*val*)

Push the integer value *val* onto the stack.

------------------------------------------------------------------------

**PUSHSTR (0x05)**  
UINT4 *offset*

Stack: ... → ... string(*offset*)

Push the constant string at *offset* in the constant pool onto the
stack.

------------------------------------------------------------------------

**PUSHLST (0x06)**  
UINT4 *offset*

Stack: ... → ... list(*val*)

Push the constant list at *offset* in the constant pool onto the stack.

**Implementation note:** interactive debuggers should generally not
attempt to push constant lists, but instead construct lists dynamically.
There is no equivalent of the [PUSHSTRI](#opc_pushstri) instruction for
constant lists, specifically because lists can easily be constructed
dynamically with the [NEW1](#opc_new1) and related instructions.

------------------------------------------------------------------------

**PUSHOBJ (0x07)**  
UINT4 *objid*

Stack: ... → ... object(*objid*)

Push a reference the object with ID *objid* onto the stack.

------------------------------------------------------------------------

**PUSHNIL (0x08)**  
*No operands.*

Stack: ... → ... nil

Push the value `nil` onto the stack.

------------------------------------------------------------------------

**PUSHTRUE (0x09)**  
*No operands.*

Stack: ... → ... true

Push the value `true` onto the stack.

------------------------------------------------------------------------

**PUSHPROPID (0x0A)**  
UINT2 *propid*

Stack: ... → ... propid(*propid*)

Push the property ID value *propid* onto the stack.

------------------------------------------------------------------------

**PUSHFNPTR (0x0B)**  
UINT4 *code_offset*

Stack: ... → ... function_pointer(*code_offset*)

Push the function pointer value *code_offset* onto the stack.

------------------------------------------------------------------------

**PUSHSTRI (0x0C)**  
UINT2 *string_length*  
*string_bytes*

Stack: ... → ... object(*string_object_id*)

Push an "in-line" string. Create a new string object using the bytes
following the instruction (string_length gives the number of bytes in
string_bytes; the string bytes specify characters encoded in UTF-8
format). Push the object ID of the new string object onto the stack.

**Implementation note:** this instruction is provided for use by
debugging utilities for evaluating expressions, such as those entered
interactively by the user. By encoding the string bytes in-line with the
byte code, rather than referring to the constant pool, the debugger can
keep the code fragment from a compiled expression entirely
self-contained within the byte code. In addition, because this
instruction creates a new string object when executed, the code fragment
can be deleted as soon as execution is completed, since the VM will not
need to retain a reference to any constant data. In contrast, the
[PUSHSTR](#opc_pushstr) instruction pushes a reference to constant pool
data, so the constant pool data cannot be deleted as long as the
reference remains accessible (which in practice means that the constant
pool data can never be deleted, since the garbage collector doesn't keep
track of references to the constant pool, specifically because constant
pool data are defined as permanent).

------------------------------------------------------------------------

**PUSHPARLST (0x0D)**  
UBYTE *fixed_arg_count*  

Stack: ... → ... list(*variable_parameters*)

Construct a new list consisting of the arguments after the given fixed
argument count, in the same order as they appear in the actual
parameters, and push the resulting new list.

For example, if the function has two named (fixed) formal parameters,
and the function was called with five actual parameters, the list
consists of the third, fourth, and fifth actual parameter values, in
that order. The purpose of this instruction is to set up for entry to a
varargs function that wishes to receive its variable arguments in the
form of a list.

Because the compiler will be unable to determine how much stack space
this opcode consumes, this opcode must explicitly check to make sure
enough stack space is available.

------------------------------------------------------------------------

**MAKELSTPAR (0x0E)**  
*No operands.*

Stack: ... *argc* *val* → ... *argumentN* ... *argument2* *argument1*
*argc*

Pop the top element of the stack and call it *val*. Pop the next element
of the stack and call it *argc*; if this value is not an integer, throw
an error (INT_VAL_REQD). Check the type of *val*:

- If *val* is a list *or* it's a [list-like object](#listlike), convert
  it to an argument list as follows. Starting with the last element of
  the list in *val*, push each element of the list onto the stack, and
  increment the value in *argc* once for each element pushed. Finally,
  push *argc*.
- If *val* is **not** a list or list-like value, push *val*, then
  increment *argc* and push *argc*.

The purpose of this instruction is to prepare to call a varargs function
using the contents of a list as the parameters to the function.

Because the compiler will be unable to determine how much stack space
this opcode consumes, this opcode must explicitly check to make sure
enough stack space is available to push the entire list. Since other
values might be pushed later, the interpreter should be conservative and
check that the stack space immediately required for the list parameters,
plus the full size of the stack required for the function less the
current usage, is available.

------------------------------------------------------------------------

**PUSHENUM (0x0F)**  
INT4 *val*

Stack: ... → ... enum(*val*)

Push the enumerator value *val* onto the stack.

------------------------------------------------------------------------

**PUSHBIFPTR (0x10)**  
UINT2 *function_index*  
UINT2 *set_index*

Stack: ... → ... *bifptr(set_index, function_index)*

Push a pointer to the specified built-in function onto the stack. The
function is identified by its function set index and index within the
function set. The set index is an index in the function set dependency
table in the image file.

------------------------------------------------------------------------

**NEG (0x20)**  
*No operands.*

Stack: ... *x* → ... (-*x*)

Remove the top element from the stack.

If the value is numeric, compute the arithmetic negative (i.e., the 2's
complement value) of the numeric value, and push the result onto the
stack.

If the value is an object, call the object's "negate" virtual
(metaclass) method and push the result value onto the stack. If there's
no "negate" method defined for the metaclass, try [operator
overloading](#opov) with the imported property symbol "operator negate".

For any other type, throw an error (NUM_VAL_REQD).

------------------------------------------------------------------------

**BNOT (0x21)**  
*No operands.*

Stack: ... *x* → ... (Bitwise-NOT *x*)

Remove the top element from the stack. If it's an integer, compute the
bitwise NOT (i.e., the 1's complement value), and push the result onto
the stack.

If the value is an object, try [operator overloading](#opov) with the
imported property symbol "operator ~".

Throws run-time error (BAD_TYPE_BNOT) for any other type.

------------------------------------------------------------------------

**ADD (0x22)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* + *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.
Compute the value *val1* + *val2* and push the result onto the stack.

The type of the result and the meaning of the "+" operator depend upon
the type of *val1*:

- Integer: *val2* must also be a number, or NUM_VAL_REQD is thrown. The
  result is the arithmetic sum of the two integer values.
- String: *val2* is implicitly converted to a string (see [data
  conversions](model.htm#conversions)). The result is the string
  concatenation of *val1* and *val2*. The result is always a new object;
  the string contained in *val1* is not altered, but instead a new
  string object is created.
- List: if *val2* is also a list, the elements of *val2* are appended to
  the elements of *val1* to form a new list whose number of elements is
  the sum of the number of elements of *val1* and the number of elements
  of *val2*. Otherwise, *val2* is appended as a new element to *val1*,
  giving a list whose number of elements is one greater than the number
  of elements of *val1*. The result is always a new object; the list
  contained in *val1* is not altered, but instead a new list object is
  created.
- Object: invoke *val1*'s virtual (metaclass) "add" method, passing
  *val2* as the parameter. Push the resulting value onto the stack. If
  the "add" method is not defined for the metaclass, try [operator
  overloading](#opov) with the imported property symbol "operator +".
- All other types: the run-time exception BAD_TYPE_ADD is thrown.

------------------------------------------------------------------------

**SUB (0x23)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* - *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.
Compute the value *val1* - *val2* and push the result onto the stack.

The type of the result and the meaning of the "-" operator depend upon
the type of *val1*:

- Integer: *val2* must also be a number, or NUM_VAL_REQD is thrown. The
  result is the arithmetic difference obtained by subtracting *val2*
  from *val1*.
- List: *val2* is also a list, we remove each element of *val1* that is
  also in *val2*, and the result is a list containing only the remaining
  elements of *val1*. If *val2* is not a list, we search for *val2* in
  *val1* and remove each matching element; the result is a list with
  each matching element removed, or the original *val1* list if no such
  element is found. In all cases, the result is a new object; the
  original contents of *val1* are not modified.
- Object: invoke *val1*'s virtual (metaclass) "subtract" method, passing
  *val2* as the parameter. Push the resulting value onto the stack. If
  the subtract method isn't defined in the metaclass, try [operator
  overloading](#opov) with the imported property symbol "operator -".
- All other types: the run-time exception BAD_TYPE_SUB is thrown.

------------------------------------------------------------------------

**MUL (0x24)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* \* *val2*)

Remove the top two elements from the stack; call the first value removed
*val2* and the second value removed *val1*.

If the type of *val1* is object reference, call *val1*'s virtual
"multiply" method, passing *val2* as the parameter, and push the result
value.

If *val1* is numeric, then *val2* must be numeric as well; if it isn't,
throw an error (BAD_TYPE_MUL). Compute the arithmetic product of the two
numbers and push the result onto the stack. If an integer overflow
occurs, the resulting value is implementation-defined, but no error
occurs. For most implementations, the result of a multiplication
overflow will simply be the low-order 32 bits of the algebraic product,
because this is what most computer hardware platforms yield for an
integer multiplication overflow.

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator \*".

If *val1* is of any other type, throw an error (BAD_TYPE_MUL).

------------------------------------------------------------------------

**BAND (0x25)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* Bitwise-AND *val2*)

Remove the top two elements from the stack.

If both are integers, compute the bitwise AND of the two values and push
the result onto the stack.

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator &".

Otherwise, throw an error (BAD_TYPE_BAND).

------------------------------------------------------------------------

**BOR (0x26)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* Bitwise-OR *val2*)

Remove the top two elements from the stack.

If both values are integers, compute the bitwise OR of the two values
and push the result onto the stack.

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator \|".

For any other types, throw an error (BAD_TYPE_BOR).

------------------------------------------------------------------------

**SHL (0x27)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* \<\< *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.

If both values are integers, shift *val1* left by *val2* bits,
effectively multiplying *val1* by 2 raised to the power *val2*; in C
language terms, the value is *val1* \<\< *val2*. Push the result onto
the stack.

With integer operands, this instruction specifically performs the
**logical** left shift: vacated low bits of *val1* are set to zero, and
the high *val2* bits of *val1* are simply be discarded. For C/C++
implementations, there's no difference between arithmetic and logical
shift left. Other languages, however, might make the distinction that an
arithmetic left shift can trigger an arithmetic overflow exception,
whereas a logical shift can't.

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator \<\<".

For any other type, throw an error (BAD_TYPE_SHL).

------------------------------------------------------------------------

**ASHR (0x28)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* \>\> *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.

If both values are integers, perform an arithmetic shift right on *val1*
by *val2* bits. Push the result onto the stack.

With integer operands, this instruction specifically performs an
**arithmetic shift**, which is defined as preserving the sign of the
source value. The high bits vacated by the shift are filled with the
same value as the original high bit of *val1*. It's particularly
important to pay attention to this detail in C/C++ implementations,
because the behavior of the native C \>\> operator with respect to
vacated high bits varies by platform.

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator \>\>".

For any other types, throw an error (BAD_TYPE_ASHR).

------------------------------------------------------------------------

**XOR (0x29)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* XOR *val2*)

Remove the top two elements from the stack. If both values are logical
(true or nil), compute the logical XOR of the two values and push the
result. If both values are integers, compute the bitwise XOR of the two
integers and push the resulting integer. If one value is numeric and the
other value is logical, convert the numeric value to a logical value by
treating 0 as nil and all other values as true, then compute the logical
XOR of the two logical values and push the result.

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator ^".

Throw the run-time exception BAD_TYPE_XOR if any other combination of
types is present.

------------------------------------------------------------------------

**LSHR (0x30)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* \>\> *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.

If both values are integers, perform a logical right shift of *val1* by
*val2* bits. Push the result onto the stack.

With integer operands, this instruction specifically performs a
**logical shift**, which is defined as zeroing the vacated high bits,
regardless of the original high bit's value. It's particularly important
to pay attention to this detail in C/C++ implementations, because the
behavior of the native C \>\> operator with respect to vacated high bits
varies by platform.

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator \>\>\>".

For any other types, throw an error (BAD_TYPE_LSHR).

------------------------------------------------------------------------

**DIV (0x2A)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* / *val2*)

Remove the top two elements from the stack; call the first value removed
*val2* and the second value removed *val1*.

If the type of *val1* is object reference, call *val1*'s virtual
"divide" method, passing *val2* as the parameter, and push the result
value.

If *val1* is numeric, then *val2* must be numeric as well; if it isn't,
throw an error (BAD_TYPE_DIV). If *val2* is zero, throw an error
(DIVIDE_BY_ZERO). Compute the integer quotient *val1*/*val2* and push
the result. If the result of the algebraic division of the two numbers
is not exactly representable as an integer, the fractional part is
discarded. (Note that this is the same behavior specified by ANSI C.)

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator /".

If *val1* is of any other type, throw an error (BAD_TYPE_DIV).

------------------------------------------------------------------------

**MOD (0x2B)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* MOD *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.
Compute the remainder of the integer division of *val1* by *val2*, and
push the result onto the stack. If *val2* is zero, throw the run-time
exception DIVIDE_BY_ZERO. If either value is not a number, throw
NUM_VAL_REQD.

The result of this operation produces a value such that, for any
integers a and b, (a/b)\*b + a%b equals a. (Note that this is the same
behavior specified by ANSI C.)

If *val1* is an object, try [operator overloading](#opov) with the
imported property symbol "operator %".

For any other types, throw an error (BAD_TYPE_MOD).

------------------------------------------------------------------------

**NOT (0x2C)**  
*No operands.*

Stack: ... *val* → ... (NOT *val*)

Remove the top element from the stack, compute the logical negation of
the value, and push the result onto the stack.

If the value is a number, the result is true if the number is zero, and
nil if the number is nonzero. If the value is true, the result is nil;
if the value is nil, the result is true. If the value is a (non-nil)
object reference, a property ID, a function pointer, a (single-quoted)
string, a list, or an enum value, the result is nil. If the result is of
any other type, throw error NO_LOG_CONV (cannot convert to logical).

------------------------------------------------------------------------

**BOOLIZE (0x2D)**  
*No operands.*

Stack: ... *val* → ... (boolean of *val*)

Remove the top element from the stack, compute its boolean value, and
push the result onto the stack.

If the value is a number, the result is nil if the number is zero, and
true if the number is nonzero. If the value is true, the result is true;
if the value is nil, the result is nil. If the result is of any other
type, throw error NO_LOG_CONV (cannot convert to logical).

This operation is effectively the same as applying the NOT instruction
to a value twice in a row. This can be used to ensure that the results
of certain types of expressions (such as logical AND and OR expressions)
is always a true/nil value.

------------------------------------------------------------------------

**INC (0x2E)**  
*No operands.*

Stack: ... *val* → ... (*val* + 1)

Increment the value at the top of the stack by adding the numeric
value 1. The behavior is equivalent to that of the ADD operator with the
second value set to the integer value 1. All of the same type conversion
behavior of ADD should apply.

------------------------------------------------------------------------

**DEC (0x2F)**  
*No operands.*

Stack: ... *val* → ... (*val* - 1)

Decrement the value at the top of the stack by subtracting the numeric
value 1. The behavior is equivalent to that of the SUB operator with the
second value set to the integer value 1. All of the same type conversion
behavior of SUB should apply.

------------------------------------------------------------------------

**EQ (0x40)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* == *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*. Test
the two values for equality; push true if the two values are equal, nil
if not.

The equality comparison is based on the type of the first value:

- Nil, true: the values are equal if the second value has the same type.
- Numeric: the values are equal if the second value is also a numeric
  value and both have the same numeric value.
- Property pointer: the values are equal if the second value is also a
  property pointer, and both have the same property value.
- Enumerator: the values are equal if the second value is also an
  enumerator and has the same internal enumerator ID value.
- String (single-quoted): the values are equal if the second value is
  also a string and has the same value.
- List: the values are equal if the second value is also a list, the two
  lists are of the same length, and all of the elements in the list are
  equal (under these same rules).
- Code Offset: the values are equal if the second value is also a code
  offset value and refers to the same code pool address.
- Empty, self-printing (double-quoted) string: these types never match
  any other values, even of the same type.
- Object: call the object's "equals" virtual method, passing the other
  value as the argument. If the method returns true, the values are
  equal, otherwise they are not equal.

------------------------------------------------------------------------

**NE (0x41)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* != *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*. Test
the two values for equality; push nil if the two values are equal, true
if not. The same equality comparison rules that the [EQ
instruction](#opc_eq) uses apply to this instruction.

------------------------------------------------------------------------

**LT (0x42)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* \< *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.
Compare the magnitudes of the values, and push true if *val1* is less
than *val2*, nil if not.

The result of the comparison depends on the type of the first value:

- Numeric. If the second value is numeric, the value with the greater
  arithmetic value is the greater value. If the second value is not
  numeric, throw an error (INVALID_COMPARISON).
- String (single-quoted): if the second value is a string, perform a
  lexical comparison of the two strings, character by character,
  comparing the Unicode code point values of the characters. If the
  strings are of different lengths and are identical up to the shorter
  of the two lengths, the longer string is greater than the shorter
  string. If the strings are identical in the first *N* characters,
  where *N* is less than the length of the shorter string, but differ in
  the character at position *N+1*, the string whose first character at
  position *N+1* has a higher Unicode code point value (when expressed
  as an unsigned 16-bit integer) is the greater string. If the second
  value is not a string, throw an error (INVALID_COMPARISON).
- Object: call the object's "compare" virtual method, passing the second
  value as the argument, and use the result to determine which value is
  greater.
- For any other type, throw an error (INVALID_COMPARISON).

------------------------------------------------------------------------

**LE (0x43)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* \<= *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.
Compare the magnitudes of the values, and push true if *val1* is less
than or equal to *val2*, nil if not.

Perform the comparison using the same rules as the [LT
instruction](#opc_lt).

------------------------------------------------------------------------

**GT (0x44)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* \> *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.
Compare the magnitudes of the values, and push true if *val1* is greater
than *val2*, nil if not.

Perform the comparison using the same rules as the [LT
instruction](#opc_lt).

------------------------------------------------------------------------

**GE (0x45)**  
*No operands.*

Stack: ... *val1* *val2* → ... (*val1* ≥ *val2*)

Remove the top element from the stack, calling this value *val2*, then
remove the next element from the stack, calling this value *val1*.
Compare the magnitudes of the values, and push true if *val1* is greater
than or equal to *val2*, nil if not.

Perform the comparison using the same rules as the [LT
instruction](#opc_lt).

------------------------------------------------------------------------

**RETVAL (0x50)**  
*No operands.*

Stack: ... *argumentN* ... *argument1* *self* *enclosing_code_offset*
*enclosing_EP* *argc* *enclosing_FP* ... *retval* → ...

Return from the current function.

The value at top of stack is the value to be returned; pop this value
from the stack, and store it in data register 0 (R0).

Next, restore the enclosing frame (including the instruction pointer
register, the entry pointer register, and the frame pointer register),
and discard the caller's arguments from the stack.

To restore the enclosing frame, set the stack pointer to the frame
pointer, pop the frame pointer, pop the argument count, pop the entry
pointer, pop the code offset. Then, discard the arguments by discarding
(argument count + 4) stack elements (this is four greater than the
argument count because of the implicit "self", defining object, target
object, and target property parameters). Finally, compute the new
program counter by adding the code offset to the entry pointer and
translating the result to a physical address.

------------------------------------------------------------------------

**RETNIL (0x51)**  
*No operands.*

Stack: *same as for* [RET](#opc_ret) *with retval =* nil

Return nil from the current function. Restore the enclosing frame in the
same manner as the RET instruction, but store nil in data register 0
(R0).

------------------------------------------------------------------------

**RETTRUE (0x52)**  
*No operands.*

Stack: *same as for* [RET](#opc_ret) *with retval =* true

Return true from the current function. Restore the enclosing frame in
the same manner as the RET instruction, but store true in data register
0 (R0).

------------------------------------------------------------------------

**RET (0x54)**  
*No operands.*

Stack: ... *argumentN* ... *argument1*

target_prop *orig_target_obj* *defining_obj* *self*
*enclosing_code_offset* *enclosing_EP* *argc* *enclosing_FP*
*arbitrary_temporary_values* → ...

Return from the current function with no return value. This operates the
same as the RETVAL instruction, but does not change the contents of
register R0.

Note that this instruction does not change the contents of R0, so
compilers can use this instruction for functions that return no value,
and also to return a value obtained from calling another function or
method. The called function will leave its return value in R0, so a RET
instruction will pass this value back to its own caller unchanged.
Hence, a peephole optimizer can convert the pair of instructions GETR0,
RETVAL to a single RET instruction.

------------------------------------------------------------------------

**NAMEDARGPTR (0x56)**  
UBYTE *named_arg_count*  
UINT2 *table_offset*  

Stack: ... *named_arg_N ... named_arg_1 ... named_arg_0* → ...

To execute this instruction: discard *arg_count* elements from the
stack.

*named_arg_count* is the number of named arguments in the associated
table; this should always match the number in the associated NAMEDARGTAB
instruction. It's redundant to store the value in both places, but this
is for faster execution, to avoid the need to find the table in order to
get the argument count.

*table_offset* is the offset from the *table_offset* element to the
associated NAMEDARGTAB instruction. The offset is given to the first
byte of the instruction, containing the NAMEDARGTAB opcode.

This instruction can be placed after a call instruction (CALL, PTRCALL,
GETPROP, etc) that passes named arguments to its callee, in lieu of a
[NAMEDARGTAB](opc_namedargtab) instruction and table. Instead of storing
the table in-line directly after the call instruction, the code
generator can store a NAMEDARGPTR that points to the table, and then
store the table in an unreachable section of the function's byte stream,
after the final "return" instruction. The reason to separate the table
from the call via NAMEDARGPTR is that NAMEDARGPTR is slightly faster to
execute than NAMEDARGTAB, since NAMEDARGPTR has a fixed length.

------------------------------------------------------------------------

**NAMEDARGTAB (0x57)**  
UINT2 *table_bytes*  
UINT2 *arg_count*  
UINT2 *arg 0 offset*  
UINT2 *arg 1 offset*  
...  
UINT2 *arg N offset*  
*arg 0 name bytes*  
*arg 1 name bytes*  
...  
*arg N-1 bytes*  

Stack: ... *named_arg_N ... named_arg_1 named_arg_0* → ...

To execute this instruction: discard *arg_count* elements from the
stack, then skip the table by adding *table_bytes*+2 to the instruction
pointer.

This instruction prefixes a named argument caller table, which contains
the names of the named arguments for a given function call that passes
named actuals. This table can be stored directly after a call
instruction (CALL, PTRCALL, GETPROP, etc), but more typically it's
stored at the end of a function (after the final "return"), and a
[NAMEDARGPTR](#opc_namedargptr) opcode is placed directly after the call
instruction with a pointer to the table. Executing NAMEDARGPTR is
slightly faster than executing NAMEDARGTABLE because the former has a
fixed length.

Note that if this instruction is separated from its call opcode (i.e., a
NAMEDARGPTR is used after the call instead), this opcode must be located
in an unreachable part of the function body, because its effect on the
stack is only correct when the instruction is executed immediately after
its call returns. The typical code generation technique when separating
the table is to place all of these tables after the final "return" for
the function.

*table_bytes* is the size in bytes of the table, not including the
*table_bytes* element itself. *arg_count* is the number of arguments.
The *arg n offset* form an index to the strings: each entry gives the
offset from the start of the index (i.e., from the *arg 0 offset*
element) to the start of the byte string for the entry's name.

Note that the string index contains *arg_count*+1 elements. The last
element is the offset of the next byte after the last string. This lets
you calculate the length of any string in the table by subtracting *arg
i offset* from *arg i+1 offset*.

The strings are stored in UTF-8 format as usual. Note that there are no
separators or delimiters (no null bytes, for example) between the name
strings, since the length of each string can be determined from the
index.

------------------------------------------------------------------------

**CALL (0x58)**  
UBYTE *arg_count*  
UINT4 *func_offset*

Stack: ... *argumentN* ... *argument1* → ... *argumentN* ... *argument1*
nil nil nil nil *enclosing_code_offset* *enclosing_EP* *argc*
*enclosing_FP* *local1*=nil ... *localN*=nil

Call the function at offset *func_offset* in the code pool, passing as
parameters the *arg_count* items at the top of the stack.

To set up the new frame, push nil four times (since a stand-alone
function has no target property, no target object, no defining object,
and no "self" object); compute the byte offset from the current method
header of the next instruction to execute, and push the result; push the
current entry pointer register; push the argument count; push the frame
pointer; and load the frame pointer with the location in the stack where
we just pushed the frame pointer. Then, load the entry pointer register
with *func_offset*; check *arg_count* to ensure that it matches the
conditions required in the new method header; get the count of local
variables from the new method header, and push nil for each local.
Finally, load the program counter with the first byte of the new
function's executable code, which starts immediately after the
function's header.

If the actual parameter count does not match the expected number of
parameters, throw an error (WRONG_NUM_OF_ARGS). Note that the formal
parameter count is stored in the method header as follows:

- If (*formal_count* AND 0x80) == 0x80, then (*formal_count* AND 0x7f)
  gives the *minimum* number of parameters, so *arg_count* is greater
  than or equal to this value. If *arg_count* is less than this value,
  throw an error.
- Otherwise, *formal_count* gives the *exact* number of parameters.
  Throw an error if *arg_count* is not equal to this value.

------------------------------------------------------------------------

**PTRCALL (0x59)**  
UBYTE *arg_count*  

Stack: ... *argumentN* ... *argument1* function_pointer(*func*) → ...
*argumentN* ... *argument1* nil nil nil nil *enclosing_code_offset*
*enclosing_EP* *argc* *enclosing_FP* *local1*=nil ... *localN*=nil

Pop the top value from the stack, calling the value *val*; if the value
is of any type other than function pointer, property ID, or object
reference, throw an error (FUNCPTR_VAL_REQD).

If *val* is of type function pointer, proceed as with [CALL](#opc_call),
but use *val* as the *func_offset* value rather than obtaining the value
from immediate data.

If the *val* is of type property ID, proceed as with the
[PTRCALLPROPSELF](#opc_ptrcallpropself) instruction. However, if there
is no valid "self" object (i.e., the code executing is inside a function
rather than a method), throw an error (FUNCPTR_VAL_REQD).

If the *val* is of type object, check the "ObjectCallProp" [predefined
property ID](model.htm#predefined). If the predefined symbol
"ObjectCallProp" is defined in the image, and the object referenced by
*val* defines or inherits this property, retrieve the value of this
property, which must be of type function pointer; if it's not throw an
error (FUNCPTR_VAL_REQD). Invoke the code at the offset given in this
function pointer, using the same stack preparation that the
[CALL](#opc_call) instruction uses, and using the original *val* object
as the "self" object.

------------------------------------------------------------------------

**GETPROP (0x60)**  
UINT2 *prop_id*  

Stack for non-code property values: ... *target_val* → ...

Stack for code property values: ... *target_val* → ... propid(*prop_id*)
*target_val* *defining_object* *target_val* *enclosing_code_offset*
*enclosing_EP* *argc*=0 *enclosing_FP* *local1*=nil ... *localN*=nil

Get a property of the object, constant list, or constant string at top
of stack. Pop the value at top of stack, calling it *target_val*.
Evaluate the property of *target_val* identified by *prop_id*, as
follows:

**Case 1:** If the *target_val* defines or inherits the property
identified by *prop_id*, the action depends on the type of the
property's value:

- If the type of the property is nil, true, object ID, property ID,
  integer, single-quoted string constant, function pointer, or list
  constant, store the value in R0.
- If the type of the property is double-quoted string constant, invoke
  the default string output function or method to display the string, in
  the same manner as the [SAY instruction](#opc_say). Note that this
  involves a function call to a function or method defined in the image.
- If the type of the property is code offset, invoke the code, using the
  same stack frame preparation that the [CALL](#opc_call) operation
  uses. The object whose property is being evaluated is the "self"
  value, and the number of actual parameters is implicitly zero. Note
  that the object where the property was actually found (which might be
  a superclass of the target object) is pushed as *defining_object*.

**Case 2:** If the object *target_val* does **not** define or inherit
the property *prop_id*, check to see if *target_val* defines or inherits
the imported property with the [predefined property
identifier](model.htm#predefined) "propNotDefined". If this property is
defined, push *prop_id* as an additional (first) argument, and then
proceed with **case 1** above as though the "propNotDefined" property
had been invoked in the first place. If the "propNotDefined" property is
not defined or inherited, simply store nil in R0.

This operation is redundant with CALLPROP, since CALLPROP has the same
effect when its *arg_count* immediate parameter is zero. However,
evaluating a property with no arguments is an extremely common
operation, hence substantial code size savings can be achieved for many
programs by using this shorter code sequence.

The method of property evaluation depends on the type of *target_val*:

- If *target_val* is an object value, call the object's virtual "get
  property" method.
- If *target_val* is a constant string, use the string metaclass's
  constant string property evaluator.
- If *target_val* is a constant list, use the list metaclass's constant
  list property evaluator.
- For any other type, throw an error (OBJ_VAL_REQD).

------------------------------------------------------------------------

**CALLPROP (0x61)**  
UBYTE *arg_count*  
UINT2 *prop_id*  

Stack: ... *argumentN* ... *argument1* *target_val* → ... *argumentN*
... *argument1* propid(*prop_id*) *target_val* *defining_object*
*target_val* *enclosing_code_offset* *enclosing_EP* *argc*
*enclosing_FP* *local1*=nil ... *localN*=nil

Call a method of the object, string constant, or list constant at top of
stack. Pop the value at top of stack and call this *target_val*. Look up
the property identified by *prop_id*, in the same manner as
[GETPROP](#opc_getprop). If *target_val* is an object, apply inheritance
if the object does not directly define the property.

**Case 1:** If *target_val* defines or inherits *prop_id*, proceed
according to the type of the value stored in the property:

- If the type of the property is code offset, invoke the code, using the
  same stack frame preparation that the CALL operation uses. The object
  whose property is being evaluated is the "self" value, and the number
  of actual parameters is given by *arg_count*.
- If the property has any other type, and the argument count is
  non-zero, throw an error (WRONG_NUM_OF_ARGS). If the argument count is
  zero, proceed in the same manner as [GETPROP](#opc_getprop).

**Case 2:** If the object *target_val* does **not** define or inherit
the property *prop_id*, check to see if *target_val* defines or inherits
the imported property with the [predefined property
identifier](model.htm#predefined) "propNotDefined". If this property is
defined, push *prop_id* as an additional (first) argument, and then
proceed with **case 1** above as though the "propNotDefined" property
had been invoked in the first place. If the "propNotDefined" property is
not defined or inherited, discard the *arg_count* items at the top of
the stack, and store nil in R0.

------------------------------------------------------------------------

**PTRCALLPROP (0x62)**  
UBYTE *arg_count*  

Stack: ... *argumentN* ... *argument1* *target_val* *prop* → ...
*argumentN* ... *argument1* *prop* *target_val* *defining_object*
*target_val* *enclosing_code_offset* *enclosing_EP* *argc*
*enclosing_FP* *local1*=nil ... *localN*=nil

Pop the property ID value from the top of stack, and call this value
*prop*. Pop a value from the top of the stack, and call this value
*target_val*. Proceed in the same manner as [CALLPROP](#opc_callprop),
but use *prop* as the property to evaluate rather than immediate data.

------------------------------------------------------------------------

**GETPROPSELF (0x63)**  
UINT2 *prop_id*  

Stack for non-code property values: *No change.*

Stack for code property values: ... → propid(*prop_id*) self
*defining_object* self *enclosing_code_offset* *enclosing_EP* *argc*=0
*enclosing_FP* *local1*=nil ... *localN*=nil

Evaluate a property of self: proceed as with GETPROP, but rather than
popping the target value whose property is to be evaluated from the
stack, evaluate the property of the active "self" object. Leaves the
value in register R0.

------------------------------------------------------------------------

**CALLPROPSELF (0x64)**  
UBYTE *arg_count*  
UINT2 *prop_id*  

Stack: ... *argumentN* ... *argument1* → ... *argumentN* ... *argument1*
propid(*prop_id*) self *defining_object* self *enclosing_code_offset*
*enclosing_EP* *argc* *enclosing_FP* *local1*=nil ... *localN*=nil

Call a method of self: proceed as with CALLPROP, but rather than popping
the target value whose method is to be invoked from the stack, call the
method of the active "self" object.

------------------------------------------------------------------------

**PTRCALLPROPSELF (0x65)**  
UBYTE *arg_count*  

Stack: ... *argumentN* ... *argument1* *prop* → ... *argumentN* ...
*argument1* *prop* self *defining_object* self *enclosing_code_offset*
*enclosing_EP* *argc* *enclosing_FP* *local1*=nil ... *localN*=nil

Call a method of self through a property pointer: proceed as with
PTRCALLPROP, but rather than popping the target value whose method to be
invoked from the stack, call the method of the active "self" object.

------------------------------------------------------------------------

**OBJGETPROP (0x66)**  
UINT4 *obj_id*  
UINT2 *prop_id*  

Stack for non-code property values: *No change.*

Stack for code property values: ... → ... propid(*prop_id*)
object(*obj_id*) *defining_object* object(*obj_id*)
*enclosing_code_offset* *enclosing_EP* *argc*=0 *enclosing_FP*
*local1*=nil ... *localN*=nil

Evaluate a property of a specific object: proceed in the same manner as
[GETPROP](#opc_getprop), but rather than popping the target value whose
property is to be evaluated from the stack, use *obj_id*.

This operation is not strictly necessary, since the same effect could be
obtained with a combination of PUSHOBJ and GETPROP; however, since
evaluating a property of a specific object is a common operation, many
programs will derive code size and execution time reductions from the
use of this single instruction.

------------------------------------------------------------------------

**OBJCALLPROP (0x67)**  
UBYTE *arg_count*  
UINT4 *obj_id*  
UINT2 *prop_id*  

Stack: ... *argumentN* ... *argument1* → ... *argumentN* ... *argument1*
propid(*prop_id*) object(*obj_id*) *defining_object* object(*obj_id*)
*enclosing_code_offset* *enclosing_EP* *argc* *enclosing_FP*
*local1*=nil ... *localN*=nil

Call a method of a specific object: proceed in the same manner as
[CALLPROP](#opc_callprop), but rather than popping the object whose
method is to be called from the stack, use *obj_id*.

------------------------------------------------------------------------

**GETPROPDATA (0x68)**  
UINT2 *prop_id*  

Stack: *same as* [GETPROP](#opc_getprop)

This operation is the same as [GETPROP](#opc_getprop), except that
GETPROPDATA does not allow any side effects. In particular, if the
property value has type code offset or double-quoted string, throw an
error (BAD_SPEC_EVAL). So, to execute this operation, first check the
property's datatype, throwing an error if the datatype is not allowed,
then proceed as though performing a GETPROP operation.

If the target value *target_val* (see [GETPROP](#opc_getprop)) is not an
object value, throw BAD_SPEC_EVAL, because evaluating a property of a
native type requires execution of native code, which is not allowed
during speculative evaluation.

This operation is used in place of GETPROP when the compiler generates
code in "speculative evaluation" mode, which the debugger uses to
evaluate certain expressions automatically (without the user
specifically asking). For example, a GUI debugger implementation may
attempt to parse text near the mouse cursor when the user holds the
mouse cursor in one place for a few moments, then speculatively evaluate
the expression represented by the text; since the debugger is attempting
this evaluation as a convenience for the user, rather than in response
to a direct request from the user, it would be highly undesirable for
the evaluation to cause any side effects. So, the debugger uses this
opcode instead of the normal GETPROP when compiling such an expression,
ensuring that the evaluation will abort (with a BAD_SPEC_EVAL error)
rather than cause an unwanted side effect.

------------------------------------------------------------------------

**PTRGETPROPDATA (0x69)**  
*No operands.*

Stack: *same as* [PTRGETPROP](#opc_ptrgetprop)

Pop the property ID value from the stack, calling this value *prop*. Pop
the target value from the stack, calling this value *target_val*.
Proceed in the same manner as [GETPROPDATA](#opc_getpropdata), using
*prop* as the property to evaluate rather than immediate data.

------------------------------------------------------------------------

**GETPROPLCL1 (0x6A)**  
UBYTE *local_number*  
UINT2 *prop_id*  

Stack: *same as* [GETPROPSELF](#opc_getpropself)

Evaluates the given property, taking the value of the local variable
*local_number* as the target object. This instruction behaves like
[GETPROP](#opc_getprop), except that rather than popping the target
object from the top of the stack, we take the value of the given local
variable as the target object. Leaves the value in register R0.

------------------------------------------------------------------------

**CALLPROPLCL1 (0x6B)**  
UBYTE *arg_count*  
UBYTE *local_number*  
UINT2 *prop_id*  

Stack: *same as* [CALLPROPSELF](#opc_callpropself)

Calls the given property, taking the value of the local variable
*local_number* as the target object. This instruction behaves like
[CALLPROP](#opc_callprop), except that rather than popping the target
object from the top of the stack, we take the value of the given local
variable as the target object. Leaves the value in register R0.

------------------------------------------------------------------------

**GETPROPR0 (0x6C)**  
UINT2 *prop_id*  

Stack: *same as* [GETPROPSELF](#opc_getpropself)

Evaluates the given property, taking the value in register R0 as the
target object. This instruction behaves like [GETPROP](#opc_getprop),
except that rather than popping the target object from the top of the
stack, we take the value in register R0 as the target object. Leaves the
value in register R0.

------------------------------------------------------------------------

**CALLPROPR0 (0x6D)**  
UBYTE *arg_count*  
UINT2 *prop_id*  

Stack: *same as* [CALLPROPSELF](#opc_callpropself)

Calls the given property, taking the value of register R0 as the target
object. This instruction behaves like [CALLPROP](#opc_callprop), except
that rather than popping the target object from the top of the stack, we
take the value of register R0 as the target object. Leaves the value in
register R0.

------------------------------------------------------------------------

**INHERIT (0x72)**  
UBYTE *arg_count*  
UINT2 *prop_id*  

Stack: *same as* [CALLPROP](#opc_callprop)

Inherit the given property from the appropriate superclass of the object
that defines the currently executing code. Obtain the defining object
from the activation frame; find the inherited property using the
"inherit property" method of the defining object. Proceed in the same
manner as [CALLPROP](#opc_callprop), using the inherited property's
value, and retaining the current "self" object as the new "self" object
if calling code.

Inheriting a property works by using the same algorithm as we would use
to find the property for the GETPROP instruction, but acting as though
the definition from the current defining object (and all overriding
definitions) were never defined.

Note that the *target_object* element of the stack frame is *not*
affected by this operation. This operation differs from regular
GETPROP-type instructions and from DELEGATE-type instructions in that it
leaves both *self* and *target_object* unchanged.

------------------------------------------------------------------------

**PTRINHERIT (0x73)**  
UBYTE *arg_count*  

Stack: *same as* [PTRCALLPROP](#opc_ptrcallprop)

Pop the property pointer value from the top of the stack, calling this
value *prop_id*. Proceed in the same manner as [INHERIT](#opc_inherit),
using the *prop_id* value obtained from the stack rather than reading
the property ID from immediate data.

------------------------------------------------------------------------

**EXPINHERIT (0x74)**  
UBYTE *arg_count*  
UINT2 *prop_id*  
UINT4 *obj_id*  

Stack: *same as* [OBJCALLPROP](#opc_objcallprop)

Inherit the given property from the object given by *obj_id*. Process
this essentially the same as [CALLPROP](#opc_callprop), but rather than
using the target object (in this case, *obj_id*) as the "self" object in
any code executed as a result of this evaluation, retain the *current*
"self" object.

------------------------------------------------------------------------

**PTREXPINHERIT (0x75)**  
UBYTE *arg_count*  
UINT4 *obj_id*  

Stack: *same as* [EXPINHERIT](#opc_expinherit)*, but with the added
*prop_id* initial parameter*

Pop the property pointer value from the top of the stack, calling this
value *prop_id*. Proceed in the same manner as
[EXPINHERIT](#opc_expinherit), using the *prop_id* value obtained from
the stack rather than reading the property ID from immediate data.

------------------------------------------------------------------------

**VARARGC (0x76)**  
*No operands.*

Stack: *Not applicable.*

This is not an instruction, but rather an *instruction modifier*. This
opcode must immediately precede one of the following instructions:

- [BUILTIN_A](#opc_builtin_a)
- [BUILTIN_B](#opc_builtin_b)
- [BUILTIN_C](#opc_builtin_c)
- [BUILTIN_D](#opc_builtin_d)
- [BUILTIN1](#opc_builtin1)
- [BUILTIN2](#opc_builtin2)
- [CALL](#opc_call)
- [CALLPROP](#opc_callprop)
- [CALLPROPSELF](#opc_callpropself)
- [DELEGATE](#opc_delegate)
- [EXPINHERIT](#opc_expinherit)
- [INHERIT](#opc_inherit)
- [NEW1](#opc_new1)
- [NEW2](#opc_new2)
- [OBJCALLPROP](#opc_objcallprop)
- [PTRCALL](#opc_ptrcall)
- [PTRCALLPROP](#opc_ptrcallprop)
- [PTRCALLPROPSELF](#opc_ptrcallpropself)
- [PTRDELEGATE](#opc_ptrdelegate)
- [PTREXPINHERIT](#opc_ptrexpinherit)
- [PTRINHERIT](#opc_ptrinherit)
- [TRNEW1](#opc_trnew1)
- [TRNEW2](#opc_trnew2)

This opcode modifies the following opcode so that the actual parameter
count for the following instruction is taken from the stack rather than
from immediate data encoded into the instruction. To execute this
opcode, remove the top value from the stack; if it is not a number,
throw a run-time error (NUM_VAL_REQD). Check the following instruction
to ensure it is one of the instructions listed above; if it is not,
throw an error (INVALID_OPCODE_MOD). Skip the byte containing the
instruction opcode, and also skip the byte containing the immediate data
argument counter (all of the above instructions encode the argument
count as one byte immediately following the opcode byte). Finally,
execute the instruction exactly as normal, but using the integer value
from the stack as the argument counter.

**Note to debugger implementors:** Because this is a modifier, a
debugger should consider this opcode and the following opcode as a
single instruction for the purposes of single-stepping and setting
breakpoints. It is not legal to set a breakpoint at the modified
instruction, since that is effectively the middle of this instruction.
Any breakpoint must be set at the modifier byte itself.

------------------------------------------------------------------------

**DELEGATE (0x77)**  
UBYTE *arg_count*  
UINT2 *prop_id*  

Stack: *same as* [CALLPROP](#opc_callprop)

Delegate the given property call to the object at top of stack
(*target_val* in the CALLPROP stack parameter listing). Proceed in the
same manner as [CALLPROP](#opc_callprop), *except* that the current
"self" object is retained as the callee's "self" object.

Note that the *target_object* element of the activation frame in the
invoked method should be the target of the DELEGATE. This instruction
differs from GETPROP-type instructions in that it leaves *self*
unchanged; it differs from INHERIT-type instructions in that it does
change *target_object*.

*Remarks:* This method allows the program to call a method in a related
or unrelated object as though it were a method of 'self'. This can be
used for explicit delegation of a method call to another object, and can
also be used by compilers to implement a custom inheritance model.
Suppose that the source language treated all methods as static, and
required the 'self' object to be passed explicitly as the first
parameter of each method call; in such a language, a normal method call
would look like this:

       result = targetObject::method(targetObject, arg1, arg2);

In such a language, the DELEGATE instruction would allow the
implementation of a call like this:

       result = targetObject::method(self, arg1, arg2);

------------------------------------------------------------------------

**PTRDELEGATE (0x78)**  
UBYTE *arg_count*  

Stack: *same as* [PTRCALLPROP](#opc_ptrcallprop)

Pop the property pointer value from the top of the stack, calling this
value *prop_id*. Proceed in the same manner as
[DELEGATE](#opc_delegate), using the *prop_id* value obtained from the
stack rather than reading the property ID from immediate data.

------------------------------------------------------------------------

**SWAP2 (0x7A)**  
*No operands.*

Stack: ... *val4* *val3* *val2* *val1* → ... *val2* *val1* *val4* *val3*

Remove the top four elements from the stack, calling them in order of
removal *val1*, *val2*, *val3*, and *val4*. Push, in order, *val2*,
*val1*, *val4*, *val3*. This has the effect of swapping the top *pair*
of elements with the next pair of elements on the stack.

------------------------------------------------------------------------

**SWAPN (0x7A)**  
UBYTE *idx1*  
UBYTE *idx2*  

Stack: *see notes*

Swap the stack elements at indices *idx1* and *idx2*. These are offsets
from the current top of stack; index 0 is the top element, 1 is the
second element from the top, and so on. If the indices are 0 and 1, this
has the same effect as the [SWAP](#opc_swap) instruction.

------------------------------------------------------------------------

**GETARGN0 (0x7C)  
GETARGN1 (0x7D)  
GETARGN2 (0x7E)  
GETARGN3 (0x7F)  
**  
*No operands.*

Stack: ... → ... *value_of_argument*

Push the contents of the actual parameter at the parameter index
implicit in the opcode (parameter 0 for GETARGN0, etc). Index 0 is the
first parameter in the frame, 1 is the second, and so on; since
parameters are pushed in right-to-left (i.e., last-to-first) order, the
first explicit parameter is immediately after the "self" implicit
parameter in the stack.

These instructions are for optimization; they're otherwise redundant
with [GETARG1](#opc_getarg1). A zero-opcode instruction such as these
can usually be implemented to be slightly faster than a one-operand
instruction such as GETARG1. Although the speed advantage is slight per
instruction, it can add up to significant improvement in throughput:
GETARG-type opcodes are among the most frequently executed in a typical
program, and most of these refer to the first few parameters.

------------------------------------------------------------------------

**GETLCL1 (0x80)**  
UBYTE *local_number*

Stack: ... → ... *value_of_local*

Push the contents of the local variable at index *local_number*. Index 0
is the first local variable, 1 is the second, and so on. Since
*local_number* is an unsigned 8-bit quantity, this instruction can only
be used to retrieve the first 256 local variables (index values 0
through 255).

------------------------------------------------------------------------

**GETLCL2 (0x81)**  
UINT2 *local_number*

Stack: ... → ... *value_of_local*

Push the contents of the local variable at index *local_number*. Index 0
is the first local variable, 1 is the second, and so on. Since
*local_number* is an unsigned 16-bit quantity, this instruction can be
used to retrieve any local variable up to index value 65535.

------------------------------------------------------------------------

**GETARG1 (0x82)**  
UBYTE *param_number*

Stack: ... → ... *value_of_argument*

Push the contents of the actual parameter at index *param_number*. Index
0 is the first parameter, 1 is the second, and so on; since parameters
are pushed in right-to-left (i.e., last-to-first) order, the first
explicit parameter is immediately after the "self" implicit parameter in
the stack. This instruction's operand is an 8-bit unsigned value and
hence is limited to retrieving the first 256 parameters (index values 0
through 255).

------------------------------------------------------------------------

**GETARG2 (0x83)**  
UINT2 *param_number*

Stack: ... → ... *value_of_argument*

Push the contents of the actual parameter at index *param_number*. The
*param_number* operand is given as an unsigned 16-bit value, hence it
can retrieve any parameter up to index value 65535.

------------------------------------------------------------------------

**PUSHSELF (0x84)**  
*No operands.*

Stack: ... → ... self

Push the current "self" object. This is the object invoked (in
combination with the target property) to reach the current code; the
value is found in the activation frame.

------------------------------------------------------------------------

**GETDBLCL (0x85)**  
UINT2 *local_number*  
UINT2 *stack_level*  

Stack: ... → ... *value_of_local*

Get a debugger local: push the value of the given local variable at the
given stack level onto the stack. This instruction is similar to
[GETLCL2](#opc_getlcl2), but rather than retrieving a value from the
active stack frame, this instruction retrieves a value from the *given*
stack frame. A stack_level value of 0 indicates the last active
non-debug stack frame, 1 is the first enclosing frame (i.e., the frame
that called the last active non-debug stack frame), 2 is the next
enclosing frame (the frame that called level 1), and so on.

The "last active non-debug" frame is simply the first enclosing frame of
the active frame. The current active stack frame, which is executing the
GETDBLCL instruction, is a "debug" frame because it is created by the
debugger (it is not otherwise special - we draw this distinction only to
clarify how this instruction works). Debug frames cannot be nested
(hence the debugger can never be invoked recursively). So, the first
frame enclosing the active (debug) frame is always the last active
non-debug frame. So, a stack_level of 0 is the first frame enclosing the
active (debug) frame.

If the given frame doesn't exist (i.e., stack_level is too large), throw
an error (BAD_FRAME).

------------------------------------------------------------------------

**GETDBARG (0x86)**  
UINT2 *param_number*  
UINT2 *stack_level*  

Stack: ... → ... *value_of_param*

Get a debugger argument. This instruction works the same way as
[GETDBLCL](#opc_getdblcl), but retrieves a parameter variable in the
given stack frame rather than a local variable.

------------------------------------------------------------------------

**GETARGC (0x87)**  
*No operands.*

Stack: ... → ... argc

Get the current function's actual parameter count. Retrieve the argument
counter from the current stack frame, and push the value as an integer.
Note that the argument counter does not include the implicit "self"
argument to an object method.

------------------------------------------------------------------------

**DUP (0x88)**  
*No operands.*

Stack: ... *val* → ... *val* *val*

Get the value on top of the stack (without removing it), and push
another copy of the same value. This instruction simply duplicates the
top element on the stack, which is often convenient for compilers when
generating code involving an intermediate result that is needed more
than once in the course of an evaluation.

------------------------------------------------------------------------

**DISC (0x89)**  
*No operands.*

Stack: ... *val* → ...

Remove the top element of the stack and discard the value. This
operation is useful for the compiler in cases where the result of an
intermediate calculation is not needed but is left on the stack anyway
(for example, when evaluating an expression merely to trigger the side
effects of the evaluation).

------------------------------------------------------------------------

**DISC1 (0x8A)**  
UBYTE *count*  

Stack: ... *val1* *val2* ... *val\[count\]* → ...

Remove the top *count* elements of the stack and discard the values.
This operation is useful for the compiler in cases where the result of
an intermediate calculation is not needed but is left on the stack
anyway (for example, when evaluating an expression merely to trigger the
side effects of the evaluation).

------------------------------------------------------------------------

**GETR0 (0x8B)**  
*No Operands*

Stack: ... → ... *r0-value*

Push the contents of data register 0 (R0) onto the stack.

------------------------------------------------------------------------

**GETDBARGC (0x8C)**  
UINT2 *stack_level*

Stack: ... → ... argc

Get the actual parameter count from the given stack level. Retrieve the
argument counter from the selected stack frame, and push the value as an
integer. Note that the argument counter does not include the implicit
"self" argument to an object method.

The stack_level value selects the enclosing stack frame from which to
retrieve the argument count in the same manner as it does for the
[GETDBLCL](#opc_getdblcl) instruction.

------------------------------------------------------------------------

**SWAP (0x8D)**  
*No operands.*

Stack: ... *val2* *val1* → ... *val1* *val2*

Remove the top element from the stack, calling the value *val1*. Remove
the next element from the stack, calling the value *val2*. Push *val1*,
then push *val2*. This instruction simply exchanges the order of the top
two elements of the stack.

------------------------------------------------------------------------

**PUSHCTXELE (0x8E)**  
UBYTE *element*

Stack: ... → ... *value*

This instruction pushes one element of the current method context onto
the stack. The element to be pushed is indicated by the *element* code:

- 1: Target property. This is the property that was invoked to call the
  current method; this is stored in the activation frame.
- 2: Original target object. This is the object that was originally
  targeted by the instruction that called the current method. This is
  not necessarily the "self" object, because "self" is left unchanged by
  the various DELEGATE instructions, which set the original target
  object to their object operand. This is not necessarily the "defining
  object," because the original target object might have inherited the
  method from one of its superclasses. This is stored in the activation
  frame.
- 3: Defining object. This is the object that was actually found to
  contain the current method when the method was invoked. This is not
  necessarily the same as "self" or the original target object, because
  the defining object reflects the binding of the method currently being
  executed. This is stored in the activation frame.
- 4: Invokee. This is the object that was invoked to reach the current
  function. This is one of the following:
  - For a call to a static function or a variable containing a function
    pointer, this is the function pointer.
  - For a call to an object method containing a code offset value (i.e.,
    an execute-on-evaluate function pointer), this is a function pointer
    to the same code offset.
  - For a call to an anonymous function, this is the AnonFunc object.
  - For a call to a dynamic function, this is the DynamicFunc object.

------------------------------------------------------------------------

**DUP2 (0x8F)**  
*No operands.*

Stack: ... *val2* *val1* → ... *val2* *val2* *val2* *val2*

Get the two values at the top of the stack (without removing them), and
push another copy of each value, in the same order as they already
appear on the stack. This instruction simply duplicates the top two
elements of the stack. This is sometimes necessary for performing
compound assignment operations (e.g., "a += b"), since it allows the
compiler to evaluate elements of the lvalue only once. Evaluating the
lvalue twice (once to retrieve its old value and once to assign its new
value) must be avoided in some cases where side effects could occur in
the repeated evaluation (consider, for example, "a\[i++\] += b").

------------------------------------------------------------------------

**SWITCH (0x90)**  
UINT2 *case_count*  
*case_1*  
*case_2*  
...  
*case_N*  
INT2 *default_branch_offset*

Stack: ... *val* → ...

Each *case_x* operand consists of a DATA_HOLDER value *case_val_x*,
followed by an INT2 branch offset value *case_branch_x*. The operand
*case_count* gives the number of *case_x* operands in the table.

Pop the value at top of stack, calling this value *val*. Initialize a
counter to zero, and initialize a pointer *p* to the address of
*case_1*. Iterate through the following steps; after each iteration,
increase the counter by 1, and increase the pointer by the size of a
data holder. Terminate the loop when the counter equals *case_count*. On
each iteration, compare *val* to the data holder to which *p* points; if
the values are equal, branch to the offset in the INT2 value immediately
following the data holder value at *p* and resume execution.

If the entire array of *case_x* entries is exhausted without finding a
match for *val*, branch to the offset in *default_branch_offset*.

Each offset value (including the *case_branch_x* values and the
*default_branch_offset* value) is given as a signed 16-bit integer
which, when added to the physical memory address of the first byte of
the INT2 giving the offset, yields the physical address of the first
instruction to execute at the branch location. So, if *p* points to a
*case_x* value, the physical address of the instruction to which to
branch if the *case_val_x* value matches *val* is given by (*p* + 5 +
*case_branch_x*), because the *case_branch_x* value is at offset 5
within the *case_x* entry (since it immediately follows the 5-byte data
holder). Similarly, if *p* points to the *default_branch_offset*
operand, the physical address of the next instruction for the default
case is given by (*p* + *default_branch_offset*).

------------------------------------------------------------------------

**JMP (0x91)**  
INT2 *branch_offset*

Stack: *unchanged*

Unconditionally branch to the given offset from the current code
pointer. The offset is relative to the address of *branch_offset*
itself, so, if the physical address pointer *p* points to the
*branch_offset* operand, the physical address of the next instruction to
execute is given by (*p* + *branch_offset*).

------------------------------------------------------------------------

**JT (0x92)**  
INT2 *branch_offset*

Stack: ... *val* → ...

Remove the top element from the stack. If the value is true, or a number
with a non-zero value, jump to the given branch offset. If the value is
nil or a number with the value zero, do nothing. If the value has any
other type, jump to the given branch offset (in other words, any type of
value other than nil/true or an integer is considered true).

------------------------------------------------------------------------

**JF (0x93)**  
INT2 *branch_offset*

Stack: ... *val* → ...

Remove the top element from the stack. If the value is nil or a number
with the value zero, jump to the given branch offset. Otherwise, do
nothing.

Note that we consider any other value to be a legal "non-false" value
and do not branch. Do not throw an error regardless of the type of the
value.

------------------------------------------------------------------------

**JE (0x94)**  
INT2 *branch_offset*

Stack: ... *val1* *val2* → ...

Remove the top element from the stack, calling the value *val2*; remove
the next element from the stack, calling the value *val1*. If *val1* is
equal to *val2*, jump to the given branch offset.

Perform the comparison using the same rules as the [EQ
instruction](#opc_lt).

------------------------------------------------------------------------

**JNE (0x95)**  
INT2 *branch_offset*

Stack: ... *val1* *val2* → ...

Remove the top element from the stack, calling the value *val2*; remove
the next element from the stack, calling the value *val1*. If *val1* is
not equal to *val2*, jump to the given branch offset.

Perform the comparison using the same rules as the [EQ
instruction](#opc_lt).

------------------------------------------------------------------------

**JGT (0x96)**  
INT2 *branch_offset*

Stack: ... *val1* *val2* → ...

Remove the top element from the stack, calling the value *val2*; remove
the next element from the stack, calling the value *val1*. If *val1*
compares greater than *val2*, jump to the given branch offset.

Perform the comparison using the same rules as the [LT
instruction](#opc_lt).

------------------------------------------------------------------------

**JGE (0x97)**  
INT2 *branch_offset*

Stack: ... *val1* *val2* → ...

Remove the top element from the stack, calling the value *val2*; remove
the next element from the stack, calling the value *val1*. If *val1*
compares greater than or equal to *val2*, jump to the given branch
offset.

Perform the comparison using the same rules as the [LT
instruction](#opc_lt).

------------------------------------------------------------------------

**JLT (0x98)**  
INT2 *branch_offset*

Stack: ... *val1* *val2* → ...

Remove the top element from the stack, calling the value *val2*; remove
the next element from the stack, calling the value *val1*. If *val1*
compares less than *val2*, jump to the given branch offset.

Perform the comparison using the same rules as the [LT
instruction](#opc_lt).

------------------------------------------------------------------------

**JLE (0x99)**  
INT2 *branch_offset*

Stack: ... *val1* *val2* → ...

Remove the top element from the stack, calling the value *val2*; remove
the next element from the stack, calling the value *val1*. If *val1*
compares less than or equal to *val2*, jump to the given branch offset.

Perform the comparison using the same rules as the [LT
instruction](#opc_lt).

------------------------------------------------------------------------

**JST (0x9A)**  
INT2 *branch_offset*

Stack if *val* is true: ... *val* → *val*

Stack if *val* is not true: ... *val* → ...

Inspect the top value on the stack. If the value is nil, or has the
numeric value zero, simply discard the top element of the stack. If the
value is anything other than nil or zero, jump to the branch offset.

**Compiler note:** This instruction's mnemonic means "jump and save if
true." This instruction is useful for implementing a "short-circuit"
logical OR operator (in other words, a binary OR operator that evalutes
only its left operand if the left operand is true). To generate code for
a short-circuit OR operator, generate code to evaluate the left operand,
then generate a JST instruction that jumps to the end of the expression
evaluation code, and finally generate the code to evaluate the right
operand. This will bypass the code evaluating the right operand if the
first operand is true, and will leave the value true on the stack;
otherwise, it will discard the result of evaluating the first operand
and leave the result of evaluating the second operand on the stack.

------------------------------------------------------------------------

**JSF (0x9B)**  
INT2 *branch_offset*

Stack if *val* is nil or zero: ... *val* → *val*

Stack if *val* is anything else: ... *val* → ...

Inspect the top value on the stack. If the value is nil or the numeric
value zero, jump to the branch offset. If the value is true, discard the
top element of the stack. In any other case, simply discard the top
element of the stack.

Note that we consider any value other than nil or zero to be a valid
"non-false" value. Do not throw an error regardless of the type of the
value.

**Compiler note:** This instruction's mnemonic means "jump and save if
false." This instruction is useful for implementing a "short-circuit"
logical AND operator (in other words, a binary AND operator that
evalutes only its left operand if the left operand is false). To
generate code for a short-circuit AND operator, generate code to
evaluate the left operand, then generate a JSF instruction that jumps to
the end of the expression evaluation code, and finally generate the code
to evaluate the right operand. This will bypass the code evaluating the
right operand if the first operand is nil, and will leave the value nil
on the stack; otherwise, it will discard the result of evaluating the
first operand and leave the result of evaluating the second operand on
the stack.

------------------------------------------------------------------------

**LJSR (0x9C)**  
INT2 *branch_offset*  

Stack: ... → ... int(*return_address*)

Push the address of the start of the next instruction (i.e., the byte
immediately following the *branch_offset* operand) onto the stack.
Branch unconditionally to *branch_offset* by adding that value to the
current program counter.

This instruction's mnemonic stands for Local Jump to Sub-Routine. This
purpose of the instruction is to perform a lightweight subroutine call
that transfers to code within the same method, with the ability to
return to the caller at a later time, via the [LRET](#opc_lret)
instruction.

**Compiler note:** This instruction is particularly useful for
generating code for the `finally` clause of a `try` block. A `finally`
block must typically be executed in several separate code paths:
catching an otherwise unhandled exception, explicitly jumping out of the
`try` block through a `break`, `continue`, or `goto` statement, exiting
the method with `return` within the `try` block, or simply falling off
the end of the block. A compiler can use the LJSR to temporarily jump to
the `finally` block at each of these transfer points.

**Implementation note:** the *return_adress* value pushed on the stack
can be in any representation. The original MJR-T3 reference
implementation used an integer representing the byte offset from the
current entry pointer; later versions (3.1+) use a native byte pointer
instead. The value can only be used by the LRET instruction, so the
representation can be anything that LJSR and LRET agree on.

------------------------------------------------------------------------

**LRET (0x9D)**  
INT2 *local_variable_number*  

Stack: *No change.*

Retrieve the value of the local variable specified by
*local_variable_number*. This value must be in the correct format
defined by the implementation for the *return_address* value pushed by
an [LJSR](#opc_ljsr) instruction; throw an error if not. Transfer
control unconditionally to the address.

This instruction's mnemonic stands for Local Return. This instruction is
the complement of the LJSR instruction, and is used to return from a
local subroutine invoked with that instruction.

**Compiler Note:** LJSR pushes a value on the stack, but LRET retrieves
a value from a local variable. The target of an LJSR instruction should
normally store the value at the top of the stack into a local (using a
SETLCL1 or SETLCL2 instruction) for later retrieval with LRET. The LJSR
pushes a value onto the stack so that the caller can call the target
without knowledge of the target's local variable usage; the LRET
retrieves its value from a local to avoid complicating stack management
by requiring that the local subroutine maintain the return address as a
temporary stack value throughout its execution.

This instruction is particularly useful for compiling a `try` block with
a `finally` clause, since simplifies generating the code necessary to
invoke the `finally` block from each of the several code paths that
normally must invoke the `finally` block.

**Implementation note:** the datatype of the return address value is up
to the implementation to define in LJSR. This instruction must simply
complement LJSR by consuming the value produced there.

------------------------------------------------------------------------

**JNIL (0x9E)**  
INT2 *branch_offset*

Stack: ... *val* → ...

Remove the top element from the stack, calling the value *val*. If *val*
is nil, jump to the given branch offset.

Note that this instruction branches *only* on nil. Unlike JF, this
instruction does *not* branch on a zero integer value.

------------------------------------------------------------------------

**JNOTNIL (0x9F)**  
INT2 *branch_offset*

Stack: ... *val* → ...

Remove the top element from the stack, calling the value *val*. If *val*
is **not** nil, jump to the given branch offset.

Note that this instruction branches for *any* non-nil value. Unlike JT,
this instruction branches even on a zero integer value.

------------------------------------------------------------------------

**JR0T (0xA0)**  
INT2 *branch_offset*

Stack: *No change.*

If the value in register R0 is **anything other** than nil or the
integer value zero, jump to the given branch offset; otherwise, do
nothing. This instruction has the same branch condition as
[JT](#opc_jt), but branches on the value in register R0 rather than the
top-of-stack value.

------------------------------------------------------------------------

**JR0F (0xA1)**  
INT2 *branch_offset*

Stack: *No change.*

If the value in register R0 is nil or the integer value zero, jump to
the given branch offset; otherwise, do nothing. This instruction has the
same branch condition as [JF](#opc_jf), but branches on the value in
register R0 rather than the top-of-stack value.

------------------------------------------------------------------------

**GETSPN (0xA6)**  
UBYTE *index*

Stack: ... → ... *stack\[index\]*

Retrieve the stack value at index *index* and push it onto the stack.
The existing element at *index* isn't affected; its value is merely
copied into a newly pushed stack element. The top of stack is at index
0; the second from top is at index 1; and so on. If *index* is zero,
this instruction has the same effect as [DUP](#opc_dup).

------------------------------------------------------------------------

**GETLCLN0 (0x8AA)  
GETLCLN1 (0x8AB)  
GETLCLN2 (0x8AC)  
GETLCLN3 (0x8AD)  
GETLCLN4 (0x8AE)  
GETLCLN5 (0x8AF)**  
*No operands.*

Stack: ... → ... *value_of_local*

Push the contents of the local variable at the index implicit in the
opcode (e.g., local number 0 for GETLCLN0). Index 0 is the first local
variable in the current frame, 1 is the second, and so on.

These instructions are for optimization; they're otherwise redundant
with [GETLCL1](#opc_getlcl1). A zero-opcode instruction such as these
can usually be implemented to be slightly faster than a one-operand
instruction such as GETLCL1. Although the speed advantage is slight per
instruction, it can add up to significant improvement in throughput:
GETLCL-type opcodes are among the most frequently executed in a typical
program, and most of these refer to the first few local variables.

------------------------------------------------------------------------

**SAY (0xB0)**  
UINT4 *offset*

Stack: *same as* [CALL](#opc_call) *with one argument*

Push a string value with the given constant pool offset, then invoke the
default string display function in the same manner as for a
[CALL](#opc_call) instruction with one argument. If a default string
display function is not defined, throw an error (SAY_IS_NOT_DEFINED).

If there is an active "self" object (i.e., the currently executing code
is a method, not a stand-alone function), and a default string display
method is defined, and the active "self" object defines or inherits the
default string display method, call the default string display method,
in the same manner as a [CALLPROPSELF](#opc_callpropself) instruction,
rather than the default string display function.

------------------------------------------------------------------------

**BUILTIN_A (0xB1) BUILTIN_B (0xB2) BUILTIN_C (0xB3) BUILTIN_D
(0xB4)**  
UBYTE *argc*  
UBYTE *func_index*  

Stack: ... *argumentN* ... *argument1* → ...

Invoke the built-in function at index *func_index* in one of the first
four function sets in the function set dependency table: function set 0
(BUILTIN_A), 1 (BUILTIN_B), 2 (BUILTIN_C), or 3 (BUILTIN_D). The index
of the first function in the function set is 0. These instructions each
use a one-byte function index within the function set, so these
instructions may only be used for the first 256 functions in each
function set.

These instructions are redundant with [BUILTIN1](#opc_builtin1), but are
included in the instruction set to allow for smaller code for the
typically frequent operation of calling an intrinsic function. Four
separate instructions are provided so that calls to functions from up to
four instruction sets can be efficiently coded; it is anticipated that
most programs will rely on a small number of intrinsic function sets for
their most common operations, so four such instructions will probably
allow efficient instruction encoding for most programs.

Note that the built-in function will store its return value, if any, in
data register 0 (R0), just as a byte-code function would.

------------------------------------------------------------------------

**BUILTIN1 (0xB5)**  
UBYTE *argc*  
UBYTE *func_index*  
UBYTE *set_index*  

Stack: ... *argumentN* ... *argument1* → ...

Invoke the built-in function at index *func_index* in the function set
at index *set_index*. The index of the first function in the function
set is 0; the index of the first function set is 0.

Note that the built-in function will store its return value, if any, in
data register 0 (R0), just as a byte-code function would.

------------------------------------------------------------------------

**BUILTIN2 (0xB6)**  
UBYTE *argc*  
UINT2 *func_index*  
UBYTE *set_index*  

Stack: ... *argumentN* ... *argument1* → ...

Invoke the built-in function at index *func_index* in the function set
at index *set_index*. The index of the first function in the function
set is 0; the index of the first function set is 0.

Note that the built-in function will store its return value, if any, in
data register 0 (R0), just as a byte-code function would.

------------------------------------------------------------------------

**CALLEXT (0xB7)**  

**Deprecated.** This opcode was reserved for future use for a potential
VM feature that would invoke external (dynamically linked) user-defined
native code. As of TADS 3.1 that feature is explicitly not in the plan.

------------------------------------------------------------------------

**THROW (0xB8)**  
*No operands.*

Stack: ... object(*exception_obj*) → ... object(*exception_obj*)

*Note: this instruction will unwind the stack to the nearest enclosing
frame that contains a handler for the exception, so the stack after the
instruction is completed may look as though several RET instructions had
been executed.*

Pop the top element of the stack, calling this *exception_obj*. If this
value is not of type object, throw an error (OBJ_VAL_REQD). Otherwise,
handle the exception as described in the VM specification section on
[exceptions](model.htm#exceptions).

To summarize, the VM searches the exception table of the current stack
frame for a suitable handler; if a suitable handler is not found, the VM
unwinds the stack to the previous frame, as though returning from the
current function, then searches that frame, repeating this process until
a handler is found. Once a handler is found, the VM pushes the exception
object back onto the stack (it must be popped at the start of the search
and re-pushed at the end of the search because of the possibility of
unwinding the stack during the search), then control is transferred to
the code offset defined by the exception handler.

------------------------------------------------------------------------

**SAYVAL (0xB9)**  
*No operands.*

Stack: *same as* [CALL](#opc_call) *with one argument*

Invoke the default string display function in the same manner as for a
[CALL](#opc_call) instruction with one argument. If a default string
display function is not defined, throw an error (SAY_IS_NOT_DEFINED).

If there is an active "self" object (i.e., the currently executing code
is a method, not a stand-alone function), and a default string display
method is defined, and the active "self" object defines or inherits the
default string display method, call the default string display method,
in the same manner as a [CALLPROPSELF](#opc_callpropself) instruction,
rather than the default string display function.

This instruction is similar to [SAY](#opc_say), but invokes the default
string display function with the value already on top of the stack.

------------------------------------------------------------------------

**INDEX (0xBA)**  
*No operands.*

Stack: ... *val* *index_val* → ... (*val*\[*index_val*\])

Pop the value at the top of the stack, and call this value *index_val*.
Pop the next value on the stack, and call this value *val*. Check the
type of *val*:

- If *val* is of type list constant, check the type of *index_val*; if
  the value is not numeric, throw an error (NUM_VAL_REQD). Otherwise,
  convert the value to an integer. Check the value to ensure that it's
  in the range 1 to the number of elements in the constant list,
  inclusive; throw an error (INDEX_OUT_OF_RANGE) if not. Get the item at
  the given index in the list (1 refers to the first element, 2 to the
  second element, and so on), and push this value onto the stack.
- If *val* is of type object, call the object's virtual (metaclass)
  "index value" method, and push the resulting value onto the stack. If
  the metaclass doesn't define the operator, try [operator
  overloading](#opov) with the imported property symbol "operator \[\]".
- If *val* is of any other type, throw an error (CANNOT_INDEX_TYPE).

------------------------------------------------------------------------

**IDXLCL1INT8 (0xBB)**  
UBYTE *local_number*  
UBYTE *index_val*  

Stack: ... → ... *local_variable*\[*index_val*\]

Check the type of the local variable given by *local_number*:

- If the local variable's value is of type list constant, check
  *index_val* to ensure that it's in the range 1 to the number of
  elements in the constant list, inclusive; throw an error
  (INDEX_OUT_OF_RANGE) if not. Get the item at the given index in the
  list (1 refers to the first element, 2 to the second element, and so
  on), and push this value onto the stack.
- If the local's value is of type object, call the object's virtual
  (metaclass) "index value" method, and push the resulting value onto
  the stack. If the metaclass doesn't define the method, try [operator
  overloading](#opov) with the imported property symbol "operator \[\]".
- If the local is of any other type, throw an error (CANNOT_INDEX_TYPE).

*Note:* This instruction is similar to [INDEX](#opc_index), but
specifically indexes a local variable with a given constant integer
value. This instruction results in a more compact encoding than would be
possible with the more general INDEX instruction, and is likely to
result in faster execution because of the reduced number of instructions
to achieve the same effect.

------------------------------------------------------------------------

**IDXINT8 (0xBC)**  
UBYTE *index_val*  

Stack: ... *val* → ... *val*\[*index_val*\]

Perform the same work as the [INDEX](#opc_index) instruction, except
that rather than obtaining the index value from the stack, take it as
the integer value given by *index_val*.

------------------------------------------------------------------------

**NEW1 (0xC0)**  
UBYTE *arg_count*  
UBYTE *metaclass_id*  

Stack without byte-code constructor: ... *argumentN* ... *argument1* →
...

Stack with byte-code constructor: *same as* [CALLPROP](#opc_callprop)*,
possibly with a subset of the arguments passed to the byte-code
constructor, and the new object as self.*

Create a new object of the metaclass identified by the *metaclass_id*,
passing to the metaclass constructor the argument count. The metaclass
constructor will read and remove arguments from the stack and initialize
the object appropriately. Store a reference to the resulting object in
data register 0 (R0).

Some types of metaclass will invoke a byte-code constructor for the new
object. If the object invokes a byte-code constructor, this instruction
sets up a stack frame for the constructor in the same manner as for any
other function call; the exact protocol is defined by the metaclass. For
example, the TADS Object metaclass uses the first argument to identify
the new object's superclass, and invokes the new object's "construct"
method, passing the remaining arguments as parameters to the method.

New objects need not initially be explicitly marked as referenced, even
if a byte-code constructor is called. In the event that garbage
collection takes place during execution of the byte-code constructor,
the object will be reachable through the stack (since the new object
will be the "self" object for the purposes of the constructor) and hence
will not be deleted during garbage collection. In any other case, the
new object will be stored in register R0 by the metaclass constructor
and will thus be reachable.

The VM will store a reference to the new object in data register 0 (R0)
after this instruction. This means that, if no byte-code constructor is
invoked, this instruction will look to the caller as though it had a
return value equal to a reference to the new object.

The *metaclass_id* value does not directly identify the metaclass, but
is simply an index into the metaclass dependency table. The image file
contains the metaclass dependency table, which establishes the
correspondence between the *metaclass_id* index value and the actual
metaclass, which the table identifies by a universally unique metaclass
name. Refer to the [metaclass ID list](model.htm#metaclass_id) for more
information on the metaclass dependency table.

**Compiler note:** A byte-code constructor *must* return the "self"
object. Compilers must take care to generate byte-code for constructors
accordingly.

------------------------------------------------------------------------

**NEW2 (0xC1)**  
UINT2 *arg_count*  
UINT2 *metaclass_id*  

Stack: *same as* [NEW1](#opc_new1)

This instruction performs the same operation as [NEW1](#opc_new1), but
provides 16-bit values for the *metaclass_id* and *arg_count* values.
This form of the instruction can be used when one or both of these
operands exceeds the 8-bit capacity of NEW1.

------------------------------------------------------------------------

**TRNEW1 (0xC2)**  
UBYTE *arg_count*  
UBYTE *metaclass_id*  

Stack: *same as* [NEW1](#opc_new1)

This instruction performs the same operation as [NEW1](#opc_new1), but
the object created is [transient](model.htm#transient).

------------------------------------------------------------------------

**TRNEW2 (0xC3)**  
UINT2 *arg_count*  
UINT2 *metaclass_id*  

Stack: *same as* [NEW1](#opc_new1)

This instruction performs the same operation as [NEW2](#opc_new1), but
the object created is [transient](model.htm#transient).

------------------------------------------------------------------------

**INCLCL (0xD0)**  
UINT2 *local_number*

Stack: *No change.*

Adds the integer 1 to the local variable at index *local_number*, using
the same semantics as the [ADD](#opc_add) instruction. This instruction
is intended as an optimization, especially for the case where the local
contains an integer value; implementations are encouraged to check for
this case and apply the increment in-place if doing so would be faster.

------------------------------------------------------------------------

**NEW2 (0xC1)**  
UINT2 *arg_count*  
UINT2 *metaclass_id*  

Stack: *same as* [NEW1](#opc_new1)

------------------------------------------------------------------------

**DECLCL (0xD1)**  
UINT2 *local_number*

Stack: *No change.*

Subtracts the integer 1 from the local variable at index *local_number*,
using the same semantics as the [SUB](#opc_sub) instruction. This
instruction is intended as an optimization, especially for the case
where the local contains an integer value; implementations are
encouraged to check for this case and apply the decrement in-place if
doing so would be faster.

------------------------------------------------------------------------

**ADDILCL1 (0xD2)**  
UBYTE *local_number*  
SBYTE *val*

Stack: *No change.*

Compute the result of adding *val*, a signed integer, to the value in
the local variable at index *local_number*, using the same algorithm
that the [ADD](#opc_add) instruction uses. Assign the result to the
local variable at index *local_number*.

------------------------------------------------------------------------

**ADDILCL4 (0xD3)**  
UINT2 *local_number*  
INT4 *val*

Stack: *No change.*

Compute the result of adding *val*, a signed integer, to the value in
the local variable at index *local_number*, using the same algorithm
that the [ADD](#opc_add) instruction uses. Assign the result to the
local variable at index *local_number*.

------------------------------------------------------------------------

**ADDTOLCL (0xD4)**  
UINT2 *local_number*

Stack: ... *val* → ...

Pop the top element of the stack, calling the value *val*. Compute the
result of adding *val* to the value in the local variable at index
*local_number*, using the same algorithm that the [ADD](#opc_add)
instruction uses. Assign the result to the local variable at index
*local_number*.

------------------------------------------------------------------------

**SUBFROMLCL (0xD5)**  
UINT2 *local_number*

Stack: ... *val* → ...

Pop the top element of the stack, calling the value *val*. Compute the
result of subtracting *val* from the value in the local variable at
index *local_number*, using the same algorithm that the [SUB](#opc_sub)
instruction uses. Assign the result to the local variable at index
*local_number*.

------------------------------------------------------------------------

**ZEROLCL1 (0xD6)**  
UBYTE *local_number*

Stack: *No change.*

Sets the given local to zero.

------------------------------------------------------------------------

**ZEROLCL2 (0xD7)**  
UINT2 *local_number*

Stack: *No change.*

Sets the given local to zero.

------------------------------------------------------------------------

**NILLCL1 (0xD8)**  
UBYTE *local_number*

Stack: *No change.*

Sets the given local to nil.

------------------------------------------------------------------------

**NILLCL2 (0xD9)**  
UINT2 *local_number*

Stack: *No change.*

Sets the given local to nil.

------------------------------------------------------------------------

**ONELCL1 (0xDA)**  
UBYTE *local_number*

Stack: *No change.*

Sets the given local to the numeric value 1.

------------------------------------------------------------------------

**ONELCL2 (0xDB)**  
UINT2 *local_number*

Stack: *No change.*

Sets the given local to the numeric value 1.

------------------------------------------------------------------------

**SETLCL1 (0xE0)**  
UBYTE *local_number*

Stack: ... *val* → ...

Pop the top element of the stack, calling the value *val*. Store the
value in the local variable at index *local_number*.

------------------------------------------------------------------------

**SETLCL2 (0xE1)**  
UINT2 *local_number*

Stack: ... *val* → ...

Pop the top element of the stack, calling the value *val*. Store the
value in the local variable at index *local_number*.

------------------------------------------------------------------------

**SETARG1 (0xE2)**  
UBYTE *arg_number*

Stack: ... *val* → ...

Pop the top element of the stack, calling the value *val*. Store the
value in the parameter variable at index *arg_number*.

------------------------------------------------------------------------

**SETARG2 (0xE3)**  
UINT2 *arg_number*

Stack: ... *val* → ...

Pop the top element of the stack, calling the value *val*. Store the
value in the parameter variable at index *arg_number*.

------------------------------------------------------------------------

**SETIND (0xE4)**  
*No operands.*

Stack: ... *newval* *container_val* *index_val* → ...
*new_container_val*

Pop the top element from the stack, calling the value *index_val*. Pop
the next element from the stack, calling the value *container_val*. Pop
the next element from the stack, calling the value *newval*. Check the
type of *container_val*:

- If *container_val* is of type list constant, check the type of
  *index_val*; if the value is not numeric, throw an error
  (NUM_VAL_REQD), otherwise convert the value to an integer. Check the
  value to ensure that it's in the range 1 to the number of elements in
  the constant list, inclusive; throw an error (INDEX_OUT_OF_RANGE) if
  not. Create a new list object in which the element at index
  *index_val* (1 refers to the first element) from the original list is
  replaced by *newval*, and the other elements have the same values as
  their corresponding elements in the original list. Push the resulting
  object.
- If *container_val* is of type object, invoke the object's virtual
  (metaclass) "set value at index" method, passing *index_val* and
  *newval* as parameters. Push the result. If the metaclass doesn't
  define a set-index method, try [operator overloading](#opov) with the
  imported property symbol "operator \[\]=".
- If *container_val* is of any other type, throw an error
  (CANNOT_INDEX_TYPE).

**Compiler note:** This instruction does only part of the job of
compiling an assignment to an indexed value. Consider this code in the
TADS language:

        local x;
        x = [1 2 3 4];
        x[1] = 5;

The final statement sets element 1 of the list in local variable **x**
to the value 5. Because assignment to a list element does not actually
change the original list value but creates a new list, compiling this
statement requires two steps: first, the new list with the modified
element is created; second, the new list is assigned to **x**. So, to
compile this statement, the following sequence should be generated,
assuming that **x** is local variable \#1:

        pushint8   5     ; push the new value to assign to the element
        getlcl1    1     ; get the value of x (local variable #1)
        push_1           ; push the index value
        setind           ; create and push the modified list value
        setlcl1    1     ; assign the resulting value back to x

Note the order of the stack parameters. The new value to assign to the
element is popped last, hence pushed first. In some languages (including
the TADS language), the result of an assignment expression is the value
assigned. The order of the stack parameters to this instruction
facilitates this by allowing the compiler to duplicate the new value on
the stack after first pushing it, so that after the sequence of
instructions for carrying out the assignment, one copy of the assigned
value will remain on the stack for use in the enclosing expression. In
the example above, inserting a DUP instruction immediately after the
PUSHINT8 5 instruction would accomplish this.

------------------------------------------------------------------------

**SETPROP (0xE5)**  
UINT2 *prop_id*  

Stack: ... *new_val* object(*obj*) → ...

Pop the top element of the stack, calling the value *obj*. Pop the next
element of the stack, calling it *new_val*. Check that *obj* is of type
object; throw an error (OBJ_VAL_REQD) if it's not. Set the property
*prop_id* of the object *obj* to the new value *new_val*, using the
object's virtual "set property" method.

**Compiler note:** The new value parameter is the last item popped from
the stack (hence the first pushed) so that the compiler can duplicate
this value after originally pushing it if it's necessary to use the
value again (for example, as the result of an assignment expression).

------------------------------------------------------------------------

**PTRSETPROP (0xE6)**  
*No operands.*

Stack: ... *new_val* object(*obj*) propid(*prop_id*) → ...

Pop the top element off the stack, calling the value *prop_id*. Pop the
next element off the stack, calling this *obj*. Pop the next element off
the stack, calling this value *new_val*. If *prop_id* is not of type
property ID, throw an error (PROPPTR_VAL_REQD). Proceed as with SETPROP,
using the *prop_id* value from the stack rather than from immediate
data.

------------------------------------------------------------------------

**SETPROPSELF (0xE7)**  
UINT2 *prop_id*  

Stack: ... *new_val* → ...

Pop the top element of the stack, calling this value *new_val*. Proceed
as with SETPROP, but use the "self" object rather than popping an object
from the stack.

------------------------------------------------------------------------

**OBJSETPROP (0xE8)**  
UINT4 *obj*  
UINT2 *prop_id*  

Stack: ... *new_val* → ...

Pop the top element of the stack, calling this value *new_val*. Proceed
as with SETPROP, but use the object *obj* from the immediate data rather
than popping an object from the stack.

------------------------------------------------------------------------

**SETDBLCL (0xE9)**  
UINT2 *local_number*  
UINT2 *stack_level*  

Stack: ... *val* → ...

Set a debugger local: pop the top element of the stack, and store it in
the given local variable at the given stack level. This instruction is
similar to [SETLCL2](#opc_setlcl2), but rather than storing a value in a
local in the active stack frame, this instruction stores a value in the
*given* stack frame. A stack_level value of 0 indicates the last active
non-debug stack frame, 1 is the first enclosing frame (i.e., the frame
that called the last active non-debug stack frame), 2 is the next
enclosing frame (the frame that called level 1), and so on. Note that if
stack_level is 0, this has exactly the same effect as a
[SETLCL2](#opc_setlcl2) instruction.

Refer to the [GETDBLCL](#opc_getdblcl) instruction for details on what
stack_level means.

------------------------------------------------------------------------

**SETDBARG (0xEA)**  
UINT2 *param_number*  
UINT2 *stack_level*  

Stack: ... *val* → ...

Set a debugger argument. This instruction works the same way as
[SETDBLCL](#opc_setdblcl), but stores the value in a parameter variable
in the given stack frame rather than in a local variable.

------------------------------------------------------------------------

**SETSELF (0xEB)**  
*No operands.*

Stack: ... *objval* → ...

Pop the top element of the stack. If the value is not nil or an object
reference, throw an error (OBJ_VAL_REQD). Otherwise, set the "self"
local variable in the current frame to the given value.

------------------------------------------------------------------------

**LOADCTX (0xEC)**  
*No operands.*

Stack: ... *ctx_value* → ...

Pop the top element of the stack. Interpret the value as a stored method
context, as created by [STORECTX](#opc_storectx). Copy the values from
the stored context into the current activation frame. This instruction
allows code to re-establish a method context that was previously in
effect.

------------------------------------------------------------------------

**STORECTX (0xED)**  
*No operands.*

Stack: ... → ... *ctx_value*

Create a "stored method context" and push its value onto the stack. The
method context consists of the current "self" object, the current
"original target object" value, the current "defining object" value, and
the current "target property" value.

The format for representing the stored context is left to the
implementation, but the a couple of requirements must be met. First, the
values must be stored in such a way that they can be restored later with
LOADCTX (this is, in fact, the only defined way for a program to use the
stored context). Second, the values must be stored in such a way that
the referenced objects are recognized by the garbage collector as
reachable as long as the context object itself is reachable. Third, the
values must be stored so that they are properly handled for saving
state, restoring state, and undo. A suggested implementation that meets
these requirements is to create a List object and populate its elements
with the method context values.

------------------------------------------------------------------------

**SETLCL1R0 (0xEE)**  
UBYTE *local_number*

Stack: *No change.*

Takes the value in register R0, and stores the value in the local
variable at index *local_number*.

------------------------------------------------------------------------

**SETINDLCL1I8 (0xEF)**  
UBYTE *local_number* UBYTE *index_val*

Stack: ... *newval* → ...

This instruction behaves like [SETIND](#opc_setind), except that
*container_val* is taken from the local variable indicated by
*local_number*, and *index_val* is the integer given by *index_val*.
*newval* is still taken from the stack (and is the only value taken from
the stack in this instruction). Given these value substitutions, perform
the same steps as performed by *SETIND*; however, at the final step, do
**not** push the resulting new container value (*new_container_val*)
onto the stack, but instead assign *new_container_val* to the local
variable in *local_number*.

This instruction can be used for a more efficient encoding of an
operation that assigns a value to an indexed element of the value in a
local variable when the index is a small integer constant.

------------------------------------------------------------------------

**BP (0xF1)**  
*No operands.*

Stack: *No change.*

Breakpoint. This instruction is included for the convenience of
debugging tools. When the VM encounters this instruction, it will invoke
the debugger's main entrypoint, if a debugger is active. If a debugger
is *not* present, the VM throws an exception (BREAKPOINT) upon executing
this instruction.

Compilers do not usually generate this instruction. Instead, debuggers
use this instruction to replace an actual instruction in a method at the
point where the debugger wishes to take control (usually chosen by an
interactive user: the user points to a location in the source code at
which to place a breakpoint, and the debugger resolves this source
location to a byte code location). The debugger saves the original
instruction in its own records, then overwrites the original instruction
with the BP instruction. The debugger then allows the VM to execute the
program. When the VM executes the BP instruction, it calls the debugger;
the debugger find the breakpoint based on the byte code location, and
might allow the user to inspect the machine state (such as local
variables and object properties) before resuming execution. The debugger
must restore the original instruction (which was overwritten with the BP
instruction) before proceeding. (If the debugger wishes to re-establish
the breakpoint, it must do this in a series of steps: restore the
original instruction; step through a single instruction, to execute the
original instruction; overwrite the original instruction again with the
BP instruction, saving the original once again; and resume execution.)

------------------------------------------------------------------------

**NOP (0xF2)**  
*No operands.*

Stack: *No change.*

NOP = "No Operation"; this instruction has no effect. This opcode is
included in the instruction set for the convenience of compilers and
other tools that might need to insert padding into a byte code sequence.
This instruction provides a single byte of padding; it can always be
inserted immediately before any other instruction without changing the
meaning of a byte code sequence.

------------------------------------------------------------------------

  

### Index to Instructions, Alphabetically by Mnemonic

[ADD](#opc_add)

[ADDILCL1](#opc_addilcl1)

[ADDILCL4](#opc_addilcl4)

[ADDTOLCL](#opc_addtolcl)

[ASHR](#opc_ashr)

[BAND](#opc_band)

[BNOT](#opc_bnot)

[BOOLIZE](#opc_boolize)

[BOR](#opc_bor)

[BP](#opc_bp)

[BUILTIN_A](#opc_builtin_a)

[BUILTIN_B](#opc_builtin_b)

[BUILTIN_C](#opc_builtin_c)

[BUILTIN_D](#opc_builtin_d)

[BUILTIN1](#opc_builtin1)

[BUILTIN2](#opc_builtin2)

[CALL](#opc_call)

[CALLEXT](#opc_callext)

[CALLPROP](#opc_callprop)

[CALLPROPLCL1](#opc_callproplcl1)

[CALLPROPR0](#opc_callpropr0)

[CALLPROPSELF](#opc_callpropself)

[DEC](#opc_dec)

[DECLCL](#opc_declcl)

[DELEGATE](#opc_delegate)

[DISC](#opc_disc)

[DISC1](#opc_disc1)

[DIV](#opc_div)

[DUP](#opc_dup)

[DUP2](#opc_dup)

[EQ](#opc_eq)

[EXPINHERIT](#opc_expinherit)

[GE](#opc_ge)

[GETARG1](#opc_getarg1)

[GETARG2](#opc_getarg2)

[GETARGC](#opc_getargc)

[GETARGN0](#opc_getargn0)

[GETARGN1](#opc_getargn1)

[GETARGN2](#opc_getargn2)

[GETARGN3](#opc_getargn3)

[GETDBARG](#opc_getdbarg)

[GETDBARGC](#opc_getdbargc)

[GETDBLCL](#opc_getdblcl)

[GETLCL1](#opc_getlcl1)

[GETLCL2](#opc_getlcl2)

[GETLCLN0](#opc_getlcln0)

[GETLCLN1](#opc_getlcln1)

[GETLCLN2](#opc_getlcln2)

[GETLCLN3](#opc_getlcln3)

[GETLCLN4](#opc_getlcln4)

[GETLCLN5](#opc_getlcln5)

[GETPROP](#opc_getprop)

[GETPROPDATA](#opc_getpropdata)

[GETPROPLCL1](#opc_getproplcl1)

[GETPROPR0](#opc_getpropr0)

[GETPROPSELF](#opc_getpropself)

[GETR0](#opc_getr0)

[GETSPN](#opc_getspn)

[GT](#opc_gt)

[INC](#opc_inc)

[INCLCL](#opc_inclcl)

[INDEX](#opc_index)

[IDXINT8](#opc_idxint8)

[IDXLCL1INT8](#opc_idxlcl1int8)

[INHERIT](#opc_inherit)

[JE](#opc_je)

[JF](#opc_jf)

[JGE](#opc_jge)

[JGT](#opc_jgt)

[JLE](#opc_jle)

[JLT](#opc_jlt)

[JMP](#opc_jmp)

[JNE](#opc_jne)

[JNIL](#opc_jnil)

[JNOTNIL](#opc_jnotnil)

[JR0F](#opc_jr0f)

[JR0T](#opc_jr0t)

[JSF](#opc_jsf)

[JST](#opc_jst)

[JT](#opc_jt)

[LE](#opc_le)

[LSHR](#opc_lshr)

[LT](#opc_lt)

[LJSR](#opc_ljsr)

[LOADCTX](#opc_loadctx)

[LRET](#opc_lret)

[MAKELSTPAR](#opc_makelstpar)

[MOD](#opc_mod)

[MUL](#opc_mul)

[NAMEDARGPTR](#opc_namedargptr)

[NAMEDARGTAB](#opc_namedargtab)

[NE](#opc_ne)

[NEG](#opc_neg)

[NEW1](#opc_new1)

[NEW2](#opc_new2)

[NILLCL1](#opc_nillcl1)

[NILLCL2](#opc_nillcl2)

[NOP](#opc_nop)

[NOT](#opc_not)

[OBJCALLPROP](#opc_objcallprop)

[OBJGETPROP](#opc_objgetprop)

[OBJSETPROP](#opc_objsetprop)

[ONELCL1](#opc_onelcl1)

[ONELCL2](#opc_onelcl2)

[PTRCALL](#opc_ptrcall)

[PTRCALLPROP](#opc_ptrcallprop)

[PTRCALLPROPSELF](#opc_ptrcallpropself)

[PTRDELEGATE](#opc_ptrdelegate)

[PTREXPINHERIT](#opc_ptrexpinherit)

[PTRGETPROPDATA](#opc_ptrgetpropdata)

[PTRINHERIT](#opc_ptrinherit)

[PTRSETPROP](#opc_ptrsetprop)

[PUSHBIFPTR](#opc_pushbifptr)

[PUSHCTXELE](#opc_pushctxele)

[PUSHENUM](#opc_pushenum)

[PUSHFNPTR](#opc_pushfnptr)

[PUSHINT](#opc_pushint)

[PUSHINT8](#opc_pushint8)

[PUSHLST](#opc_pushlst)

[PUSHNIL](#opc_pushnil)

[PUSHOBJ](#opc_pushobj)

[PUSHPARLST](#opc_pushparlst)

[PUSHPROPID](#opc_pushpropid)

[PUSHSELF](#opc_pushself)

[PUSHSTR](#opc_pushstr)

[PUSHSTRI](#opc_pushstri)

[PUSHTRUE](#opc_pushtrue)

[PUSH_0](#opc_push_0)

[PUSH_1](#opc_push_1)

[RET](#opc_ret)

[RETNIL](#opc_retnil)

[RETTRUE](#opc_rettrue)

[RETVAL](#opc_retval)

[SAY](#opc_say)

[SAYVAL](#opc_say)

[SETARG1](#opc_setarg1)

[SETARG2](#opc_setarg2)

[SETDBARG](#opc_setdbarg)

[SETDBLCL](#opc_setdblcl)

[SETIND](#opc_setind)

[SETINDLCL1I8](#opc_setindlcl1i8)

[SETLCL1](#opc_setlcl1)

[SETLCL1R0](#opc_setlcl1r0)

[SETLCL2](#opc_setlcl2)

[SETPROP](#opc_setprop)

[SETPROPSELF](#opc_setpropself)

[SETSELF](#opc_setself)

[SHL](#opc_shl)

[SWAP](#opc_swap)

[STORECTX](#opc_storectx)

[SUB](#opc_sub)

[SUBFROMLCL](#opc_subfromlcl)

[TRNEW1](#opc_trnew1)

[SWAP2](#opc_swap2)

[SWAPN](#opc_swapn)

[SWITCH](#opc_switch)

[XOR](#opc_xor)

[TRNEW2](#opc_trnew2)

[THROW](#opc_throw)

[VARARGC](#opc_varargc)

[ZEROLCL1](#opc_zerolcl1)

[ZEROLCL2](#opc_zerolcl2)

------------------------------------------------------------------------

  

### Index to Instructions, Arranged by Category

#### Arithmetic

> [ADD](#opc_add)  
> [ADDILCL1](#opc_addilcl1)  
> [ADDILCL4](#opc_addilcl4)  
> [ADDTOLCL](#opc_addtolcl)  
> [ASHR](#opc_ashr)  
> [DEC](#opc_dec)  
> [DECLCL](#opc_declcl)  
> [DIV](#opc_div)  
> [INC](#opc_inc)  
> [INCLCL](#opc_inclcl)  
> [LSHR](#opc_lshr)  
> [MOD](#opc_mod)  
> [MUL](#opc_mul)  
> [NEG](#opc_neg)  
> [SHL](#opc_shl)  
> [SUB](#opc_sub)  
> [SUBFROMLCL](#opc_subfromlcl)  
> [XOR](#opc_xor)  

#### Bitwise Operations

> [BAND](#opc_band)  
> [BNOT](#opc_bnot)  
> [BOR](#opc_bor)  

#### Comparisons

> [EQ](#opc_eq)  
> [GE](#opc_ge)  
> [GT](#opc_gt)  
> [LE](#opc_le)  
> [LT](#opc_lt)  
> [NE](#opc_ne)  

#### Logical Operations

> [BOOLIZE](#opc_boolize)  
> [NOT](#opc_not)  

#### Debugging

> [BP](#opc_bp)  
> [GETDBARG](#opc_getdbarg)  
> [GETDBARGC](#opc_getdbargc)  
> [GETDBLCL](#opc_getdblcl)  
> [PUSHSTRI](#opc_pushstri)  
> [SETDBARG](#opc_setdbarg)  
> [SETDBLCL](#opc_setdblcl)  

#### Intrinsic Function Calls

> [BUILTIN_A](#opc_builtin_a)  
> [BUILTIN_B](#opc_builtin_b)  
> [BUILTIN_C](#opc_builtin_c)  
> [BUILTIN_D](#opc_builtin_d)  
> [BUILTIN1](#opc_builtin1)  
> [BUILTIN2](#opc_builtin2)  
> [SAY](#opc_say)  
> [SAYVAL](#opc_sayval)  

#### External Function Calls

> [CALLEXT](#opc_callext)  

#### Function Calls

> [CALL](#opc_call)  

#### Object Method Calls

> [CALLPROP](#opc_callprop)  
> [CALLPROPLCL1](#opc_callproplcl1)  
> [CALLPROPR0](#opc_callpropr0)  
> [CALLPROPSELF](#opc_callpropself)  
> [DELEGATE](#opc_delegate)  
> [EXPINHERIT](#opc_expinherit)  
> [GETPROP](#opc_getprop)  
> [GETPROPDATA](#opc_getpropdata)  
> [GETPROPLCL1](#opc_getproplcl1)  
> [GETPROPR0](#opc_getpropr0)  
> [GETPROPSELF](#opc_getpropself)  
> [INHERIT](#opc_inherit)  
> [OBJCALLPROP](#opc_objcallprop)  
> [OBJGETPROP](#opc_objgetprop)  
> [OBJSETPROP](#opc_objsetprop)  
> [PTRCALL](#opc_ptrcall)  
> [PTRCALLPROP](#opc_ptrcallprop)  
> [PTRCALLPROPSELF](#opc_ptrcallpropself)  
> [PTRDELEGATE](#opc_ptrdelegate)  
> [PTREXPINHERIT](#opc_ptrexpinherit)  
> [PTRGETPROPDATA](#opc_ptrgetpropdata)  
> [PTRINHERIT](#opc_ptrinherit)  

#### Stack Manipulation

> [DISC](#opc_disc)  
> [DISC1](#opc_disc1)  
> [DUP](#opc_dup)  
> [DUP2](#opc_dup2)  
> [GETSPN](#opc_getspn)  
> [SWAP](#opc_swap)  
> [SWAP2](#opc_swap2)  
> [SWAPN](#opc_swapn)  

#### List Manipulation

> [INDEX](#opc_index)  
> [IDXINT8](#opc_idxint8)  
> [IDXLCL1INT8](#opc_idxlcl1int8)  

#### Branching

> [JE](#opc_je)  
> [JF](#opc_jf)  
> [JGE](#opc_jge)  
> [JGT](#opc_jgt)  
> [JLE](#opc_jle)  
> [JLT](#opc_jlt)  
> [JMP](#opc_jmp)  
> [JNE](#opc_jne)  
> [JNIL](#opc_jnil)  
> [JNOTNIL](#opc_jnotnil)  
> [JR0F](#opc_jr0f)  
> [JR0T](#opc_jr0t)  
> [JSF](#opc_jsf)  
> [JST](#opc_jst)  
> [JT](#opc_jt)  
> [LJSR](#opc_ljsr)  
> [LRET](#opc_lret)  
> [SWITCH](#opc_switch)  

#### Function Return

> [RET](#opc_ret)  
> [RETNIL](#opc_retnil)  
> [RETTRUE](#opc_rettrue)  
> [RETVAL](#opc_retval)  

#### Exceptions

> [THROW](#opc_throw)  

#### Object Creation

> [NEW1](#opc_new1)  
> [NEW2](#opc_new2)  
> [TRNEW1](#opc_trnew1)  
> [TRNEW2](#opc_trnew2)  

#### Value Retrieval

> [GETARG1](#opc_getarg1)  
> [GETARG2](#opc_getarg2)  
> [GETARGC](#opc_getargc)  
> [GETLCL1](#opc_getlcl1)  
> [GETLCL2](#opc_getlcl2)  
> [GETR0](#opc_getr0)  
> [MAKELSTPAR](#opc_makelstpar)  
> [PUSHBIFPTR](#opc_pushbifptr)  
> [PUSHCTXELE](#opc_pushctxele)  
> [PUSHENUM](#opc_pushenum)  
> [PUSHFNPTR](#opc_pushfnptr)  
> [PUSHINT](#opc_pushint)  
> [PUSHINT8](#opc_pushint8)  
> [PUSHLST](#opc_pushlst)  
> [PUSHNIL](#opc_pushnil)  
> [PUSHOBJ](#opc_pushobj)  
> [PUSHPARLST](#opc_pushparlst)  
> [PUSHPROPID](#opc_pushpropid)  
> [PUSHSELF](#opc_pushself)  
> [PUSHSTR](#opc_pushstr)  
> [PUSHTRUE](#opc_pushtrue)  
> [PUSH_0](#opc_push_0)  
> [PUSH_1](#opc_push_1)  

#### Value Storage

> [NILLCL1](#opc_nillcl1)  
> [NILLCL2](#opc_nillcl2)  
> [ONELCL1](#opc_onelcl1)  
> [ONELCL2](#opc_onelcl2)  
> [PTRSETPROP](#opc_ptrsetprop)  
> [SETARG1](#opc_setarg1)  
> [SETARG2](#opc_setarg2)  
> [SETIND](#opc_setind)  
> [SETINDLCL1I8](#opc_setindlcl1i8)  
> [SETLCL1](#opc_setlcl1)  
> [SETLCL1R0](#opc_setlcl1r0)  
> [SETLCL2](#opc_setlcl2)  
> [SETPROP](#opc_setprop)  
> [SETPROPSELF](#opc_setpropself)  
> [SETSELF](#opc_setself)  
> [ZEROLCL1](#opc_zerolcl1)  
> [ZEROLCL2](#opc_zerolcl2)  

#### Miscellaneous

> [LOADCTX](#opc_loadctx)  
> [NOP](#opc_nop)  
> [STORECTX](#opc_storectx)  

#### Modifiers

> [VARARGC](#opc_varargc)  
> [NAMEDARGPTR](#opc_namedargptr)  
> [NAMEDARGTAB](#opc_namedargtab)  

Copyright © 2001, 2009 by Michael J. Roberts.  
Revision: December, 2009

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](../toc.htm) \| [T3 VM Technical
Documentation](../t3spec.htm) \> Byte-Code Instruction Set  
[*Prev:* The Metaclasses](metacl.htm)     [*Next:* Image File
Format](format.htm)    
