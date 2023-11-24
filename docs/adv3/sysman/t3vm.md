![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \> t3vm
Function Set  
[*Prev:* The Intrinsics](builtins.htm)     [*Next:* tads-gen Function
Set](tadsgen.htm)    

# t3vm Function Set

The t3vm function set provides access to internal operations in the VM.
This function set is provided by all T3 VM implementations and all host
applications.

t3AllocProp()

Allocates a new property ID value, which is a property not previously
used by any object in the program. Note that property IDs are a somewhat
limited resource: only about 65,000 can be allocated, including those
defined statically in the program.

t3DebugTrace(*mode*, ...)

Debugger interface. The *mode* parameter indicates the function to be
performed. Any arguments after mode are specific to the mode. The valid
*mode* values are:

- T3DebugCheck - check to determine if a debugger is present. Returns
  true if a debugger is present, nil if not.
- T3DebugBreak - break into the debugger, if present. Returns true if a
  debugger is present, nil if not. If the function returns nil, it will
  have had no effect, since it's meaningless to break into the debugger
  if no debugger is present. If a debugger is present, though, the
  function will activate single-stepping mode, which will cause the
  debugger to take control immediately after the function returns.
- T3DebugLog - write a message to the debug log. The second argument is
  a string with the message text to write to the log. When the program
  is running in an interactive debugger (such as TADS Workbench on
  Windows), debug log messages are usually displayed in a window (or
  something similar) in the debugger UI. For the regular interpreter,
  these messages are written to a text file called tadslog.txt, which is
  stored in a directory location that varies by system. On Windows,
  tadslog.txt is stored in the TADS install directory.

If this function is called with any other values for the *mode*
argument, it simply ignores any additional arguments and returns nil;
this allows for compatible extensions to the function in the future by
the addition of new mode values.

t3GetGlobalSymbols(*which*?)

Returns information on the program's compile-time symbols.

*which* determines which type of symbol information to retrieve. This is
one of the following constant values:

- T3GlobalSymbols: retrieve the global symbol table, which contains
  symbol names for functions, static objects, properties, intrinsic
  functions, intrinsic classes, and enum values.
- T3PreprocMacros: retrieve the preprocessor macro table, which contains
  the definitions of "global" macros. A global macro is one that has the
  same definition throughout the program. If the same macro is defined
  multiple times with different values (in different modules, or
  redefined within a single module using \#undef), it's considered local
  to a portion of the program, and isn't included in the global macro
  table.

The *which* argument is optional. If you omit it, the default is
T3GlobalSymbols, to retrieve the global symbol table.

The symbolic information this function retrieves is available during
pre-initialization (i.e., when t3GetVMPreinitMode() returns true), and
during normal execution **if** the program was compiled for debugging.
At other times, symbol information isn't available, so this function
returns nil. Because the return value is an ordinary LookupTable object,
though, it's easy to keep it available at all times by adding a little
code of your own. Simply call this function during preinit, and store
the result in an object property. For example:

    symTabSaver: PreinitObject
       execute() { symtab = t3GetGlobalSymbols(); }{
       symtab = nil;
    ;

With the code above, you can access the symbol table at any time after
preinit, even in a regular build, using symTabSaver.symtab.

For more information, see the [reflection](reflect.htm) section.

t3GetNamedArg(*name*, *defval*?)

Retrieves the value of the [named argument](namedargs.htm) with the
given name.

*name* is a string giving the argument name. If the specified named
argument exists, the function returns the value of the argument.

*defval* is the default value. If the named argument doesn't exist, and
*defval* is provided, the function returns *defval*. If the argument
doesn't exist and *defval* is omitted, the function instead throws an
error.

t3GetNamedArgList()

Retrieves a list of the names of all of the named arguments currently in
effect. If no named arguments are in effect, returns an empty list. You
can get the current value of a named argument by calling t3GetNamedArg()
on the name.

t3GetStackTrace(*level*?, *flags*?)

Returns information on the current call stack, or on a given stack
level.

If *level* is omitted, the function returns a list of T3StackInfo
objects, one for each level of the entire stack. Each object in the list
represents one level, or "frame," of the stack trace. A frame is the
data structure that the virtual machine establishes each time the
program invokes a method or function; the frame contains information on
the function or object method invoked, and the actual parameters (i.e.,
the argument values).

The first T3StackInfo object in the list represents the current function
or method - that is, the code that invoked t3GetStackTrace(). The second
element of the list represents the current code's caller, the third
element represents the second element's caller, and so on.

If *level* is specified, it's an integer giving the single stack level
to retrieve: 1 is the current active level, 2 is the immediate caller,
and so on. The function then returns a single T3StackInfo object giving
the description of that level. (The return value isn't a list in this
case-it's simply the T3StackInfo object.)

*flags* is a combination (with the bitwise OR operator, '\|') of the
following bit values:

- T3GetStackLocals - include the local variable table (in the locals\_
  property) and the named argument table (in the namedArgs\_ property)
  for each retrieved stack level. If this flag isn't included, the local
  variables and named arguments aren't included in the stack trace.
  Retrieving local variables takes extra time, so the function gives you
  the option to skip the extra work if you don't need the information.
- T3GetStackDesc - include a StackFrameDesc object for each retrieved
  stack level, in the frameDesc\_ property. If this flag isn't included,
  the frame references are omitted. This is optional because the frame
  references take extra time to create.

If *flags* is omitted, the default value is 0.

T3StackInfo is an ordinary class defined in the basic system library.
This class defines the following properties:

- func\_ - the function at this level, as a function pointer, or nil if
  this is an object method. If the caller is an intrinsic function, this
  will be a built-in function pointer value (of type TypeBifPtr).
- obj\_ - the object whose method is being invoked, or nil if this is a
  function. Note that this is not necessarily the same as the self in
  the frame: this is the object where the method is actually defined,
  which can be a base class of the self object if the method was
  inherited.
- prop - the property pointer value for the method invoked, or nil if
  this is a function.
- self\_ - the self object in the frame, or nil if this is a function.
- argList\_ - a list of the actual parameters (argument values) to the
  function or method. The elements of the list are in the same order as
  the arguments.
- locals\_ - a [LookupTable](lookup.htm) of the local variables at the
  stack level. Each local variable name is a key in the table, and the
  corresponding table value is the variable's value. This is present
  only if the T3GetStackLocals flag is included in the *flags* argument;
  if not, this property is nil. It's also nil for system (native code)
  routines, even when the flag is set. Note that this table is merely a
  copy of the locals in the frame, so changing a value in the table
  won't affect the value of the local in the stack frame.
- namedArgs\_ - a [LookupTable](lookup.htm) of the named argument values
  to the function or method. Each argument name is a key in the table,
  and the corresponding value in the table is the value of the argument.
  This is present only if the T3GetStackLocals flag is included in the
  *flags* argument; if not, this property is nil. It's also nil if there
  are no named arguments at this stack level. Note that this table is a
  copy of the actual arguments in the stack, so changing values in the
  table won't affect the argument variables.
- frameDesc\_ - a [StackFrameDesc](framedesc.htm) object for the stack
  level. This is only present if the T3GetStackFrames flag is included
  in the *flags* argument; if not, this property is nil. It's also nil
  for system (native code) routines, even when the flag is set. The
  StackFrameDesc lets you retrieve more information from the frame, and
  also lets you change the values of the local variables in the frame.
- srcInfo\_ - the source code location for the next execution point in
  the frame, or nil if source information is not available. Source
  information is available only if the program was compiled for
  debugging, but is never available for system routines. The source
  information is given as a list of two elements: the first element is a
  string giving the name of a source file, and the second is an integer
  giving the line number in the source file. Note that srcInfo\_
  indicates the location of the next instruction that will be executed
  when control returns to the frame, so this will frequently indicate
  the next source code statement after the one that actually invoked the
  next more nested frame.

In addition, the class defines the following method:

- isSystem() - returns true if the frame represents a call to an
  intrinsic function or a intrinsic class method. (Before version 3.1,
  system functions had no information in the trace: no function pointer,
  object or property values, or argument lists. Starting in 3.1, full
  information is available for system functions, except for the source
  code location and local variables.)

t3GetVMBanner()

Returns the T3 VM banner string, which is a string identifying the VM,
its version number, and its copyright information. This string is
suitable for displaying as a start-up banner.

t3GetVMID()

Returns the T3 VM identification string. This is a short string
identifying the particular VM implementation; each different
implementation has a unique identifier. The reference T3 VM
implementation has the identifying string 'mjr-T3'.

Note that the VM identification string identifies the VM itself, not the
host application environment.

t3GetVMPreinitMode()

Returns true if the VM is operating in pre-initialization mode, nil if
the VM is operating in normal execution mode. Pre-initialization mode is
the mode that's active during the preinit phase of compilation.

t3GetVMVsn()

Get the T3 VM version number. This returns an integer value; the
high-order 16 bits of the value give the major version number of the VM;
the next 8 bits give the minor version number; and the low-order 8 bits
give the patch release number. So, if *V* is the return value of this
function,

- ((V \>\> 16) & 0xffff) yields the major version number
- ((V \>\> 8) & 0xff) yields the minor version number
- (V & 0xff) yields the patch release number

t3RunGC()

Explicitly runs the [garbage collector](gc.htm). This traces through
memory to determine which objects can be referenced through local
variables, properties of reachable objects, and any other ways that the
program can refer to objects. Objects that aren't reachable are removed
from memory.

The garbage collector runs automatically from time to time, according to
memory usage and other factors, so you never have to call this function
explicitly. However, it's sometimes useful to make the collector run at
particular times.

- Before visiting all objects in memory via
  [firstObj](tadsgen.htm#firstObj) and [nextObj](tadsgen.htm#nextObj),
  you can run the collector explicitly to make sure that any currently
  unreachable objects are removed from memory and thus won't be
  retrieved in your object loop.
- There might be a particular place in your program where, by design, a
  large number of objects become unreachable en masse, and a large
  number of objects are likely to be allocated soon. It could be
  advantageous to run the collector specially at such a time, to reclaim
  the memory used by the newly unreachable objects before embarking on
  the new allocations.
- Any time you have a deliberate delay in the user interaction, you can
  take advantage of the fact that the program will be pausing anyway to
  run garbage collection. The user wouldn't notice the work being done
  by the collector because the program would appear to be pausing for
  other reasons. Each collection run resets the internal conditions that
  count down to the next automatic run, so you maximize the time before
  the next automatic run each time you run the collector explicitly. (In
  practice, the collector runs so quickly in most cases that the user
  would never perceive a pause from an automatic run, so it's not
  terribly important to look for these optimization opportunities.)

This function has no return value.

t3SetSay(*val*)

Set the default output function or method to the given value:

- If *val* is a property pointer, this sets the default output method to
  the given property. The VM invokes this property on whatever self
  object is currently active each time a double-quoted string is
  evaluated and each time an embedded expression in a double-quoted
  string is to be displayed. The VM invokes this function only when all
  of the following conditions are true at the time a string is to be
  displayed:
  - There is a valid self object (i.e., a method is being executed, not
    a stand-alone function).
  - A default display method has been defined with t3SetSay().
  - The current self object defines or inherits the default display
    method.

  If these conditions aren't all true, the VM uses the default display
  function instead.
- If *val* is a function pointer (to a user-defined function, not an
  intrinsic function), this sets the default output function to the
  function *val* points to. The function must take a single argument,
  which is the value to be displayed, and returns no value. The VM
  invokes this function when a double-quoted string is evaluated, and
  when an embedded expression in a double-quoted string is to be
  displayed, except that the default display method is called instead
  when applicable.
- If *val* is the special value T3SetSayNoMethod, this removes any
  default output method.
- If *val* is the special value T3SetSayNoFunc, this removes any default
  output function.

This return value gives the previous default output function or method.
If *val* is a property pointer or the special value T3SetSayNoMethod,
the return value is the old default output method; otherwise, the return
value is the old default output function. The special values
T3SetSayNoFunc and T3SetSayNoMethod can also be returned, indicating
that there was no previous function or method, respectively. The return
value allows the caller to save and later restore the setting being
changed, which is useful when the caller just wants to change the
setting temporarily while running a particular block of code.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \> t3vm
Function Set  
[*Prev:* The Intrinsics](builtins.htm)     [*Next:* tads-gen Function
Set](tadsgen.htm)    
