::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The System
Library](lib.htm){.nav} \> Miscellaneous Library Definitions\
[[*Prev:* Basic Tokenizer](tok.htm){.nav}     [*Next:* Replacing the
System Library](nodef.htm){.nav}     ]{.navnp}
:::

::: main
# Miscellaneous Library Definitions

This section describes a few miscellaneous functions and classes that
the system library defines.

## Functions

[forEachInstance(*cls*, *func*)]{.code}

::: fdef
This function is a simple object \"iterator\" function; it iterates (in
arbitrary order) over all instances of the class given by the *cls*
argument, and for each instance invokes the function given by *func*,
passing the current instance as the function\'s single argument.

This function is a convenience. You can use it as an alternative to
writing a loop involving the firstObj/nextObj functions. For example, to
set the [isAnimate]{.code} property for all instances of Actor:

::: code
    forEachInstance(Actor, {obj: obj.isAnimate = true});
:::
:::

[\_default_display_fn(*val*)]{.code}

::: fdef
This function simply calls the function [tadsSay(val)]{.code} from the
[tads-io](tadsio.htm) intrinsic function set. It\'s defined as a
function here simply so that the library can register it with the VM as
the default display function.
:::

## Classes

[class Exception: object]{.code}

::: fdef
This class is defined to serve as the base class for all exceptions,
including run-time errors and program-defined exceptions. The class
defines a method, [displayException()]{.code}, that should be overridden
in all subclasses to display an appropriate message describing the
exception.
:::

[class RuntimeError: Exception]{.code}

::: fdef
This class is the base class for all run-time exceptions that the VM
itself throws.
:::

[class ModuleExecObject: object]{.code}

::: fdef
This is the base class for PreinitObject and InitObject. (See the
section on [initialization](init.htm) for full details on these
objects.)
:::

[mainGlobal: object]{.code}

::: fdef
This object simply serves as a repository for global variables for the
system library. In particular, this object\'s property
[preinited\_]{.code} stores the pre-initialization status; this property
is set to [true]{.code} after pre-initialization has been completed, so
that the library knows that the process won\'t have to be repeated when
the program is started.
:::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The System
Library](lib.htm){.nav} \> Miscellaneous Library Definitions\
[[*Prev:* Basic Tokenizer](tok.htm){.nav}     [*Next:* Replacing the
System Library](nodef.htm){.nav}     ]{.navnp}
:::
