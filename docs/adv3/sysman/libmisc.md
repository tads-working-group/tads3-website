![](topbar.jpg)

[Table of Contents](toc.htm) \| [The System Library](lib.htm) \>
Miscellaneous Library Definitions  
[*Prev:* Basic Tokenizer](tok.htm)     [*Next:* Replacing the System
Library](nodef.htm)    

# Miscellaneous Library Definitions

This section describes a few miscellaneous functions and classes that
the system library defines.

## Functions

forEachInstance(*cls*, *func*)

This function is a simple object "iterator" function; it iterates (in
arbitrary order) over all instances of the class given by the *cls*
argument, and for each instance invokes the function given by *func*,
passing the current instance as the function's single argument.

This function is a convenience. You can use it as an alternative to
writing a loop involving the firstObj/nextObj functions. For example, to
set the isAnimate property for all instances of Actor:

    forEachInstance(Actor, {obj: obj.isAnimate = true});

\_default_display_fn(*val*)

This function simply calls the function tadsSay(val) from the
[tads-io](tadsio.htm) intrinsic function set. It's defined as a function
here simply so that the library can register it with the VM as the
default display function.

## Classes

class Exception: object

This class is defined to serve as the base class for all exceptions,
including run-time errors and program-defined exceptions. The class
defines a method, displayException(), that should be overridden in all
subclasses to display an appropriate message describing the exception.

class RuntimeError: Exception

This class is the base class for all run-time exceptions that the VM
itself throws.

class ModuleExecObject: object

This is the base class for PreinitObject and InitObject. (See the
section on [initialization](init.htm) for full details on these
objects.)

mainGlobal: object

This object simply serves as a repository for global variables for the
system library. In particular, this object's property preinited\_ stores
the pre-initialization status; this property is set to true after
pre-initialization has been completed, so that the library knows that
the process won't have to be repeated when the program is started.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The System Library](lib.htm) \>
Miscellaneous Library Definitions  
[*Prev:* Basic Tokenizer](tok.htm)     [*Next:* Replacing the System
Library](nodef.htm)    
