![](topbar.jpg)

[Table of Contents](toc.htm) \| [The System Library](lib.htm) \>
Replacing the System Library  
[*Prev:* Miscellaneous Library Definitions](libmisc.htm)     [*Next:*
The User Interface](ui.htm)    

# Replacing the Standard Library

The standard startup module that defines \_main(), PreinitObject, and so
on, is called \_main.t. By default, the compiler includes this in every
build automatically. Most programs will have no reason to modify the
default versions provided in \_main.t, which is why t3make includes the
file in all builds by default. However, if you do need to replace this
module, you can use the -nodef compiler option to tell the compiler not
to include this default module. If you do this, you'll minimally need to
define the \_main() and \_mainRestore() functions yourself.

Most programs also explicitly include system.tl in their project files.
This is the full system library, which includes definitions for required
support classes for the [File](file.htm) and [GrammarProd](gramprod.htm)
intrinsic classes, as well as the [Tokenizer](tok.htm) class. You can
eliminate this module from your build simply by removing system.tl from
the list of files in your project. If you do this, you'll have to define
your own versions of the support classes for File and GrammarProd, if
you use those classes.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The System Library](lib.htm) \>
Replacing the System Library  
[*Prev:* Miscellaneous Library Definitions](libmisc.htm)     [*Next:*
The User Interface](ui.htm)    
