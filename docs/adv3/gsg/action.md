::: topbar
[![](topbar.jpg){border="0"}](index.html)
:::

::: main
[\[Main\]](index.html)\
*[\[Previous\]](check.htm)   [\[Next\]](precond.htm)*

### Action

The action() routine is in a sense the most straightforward to
understand, it\'s the routine that does the actual work of carrying out
an action (once it\'s passed the verify, precondition and check stages).
However, depending on the nature of the action, it may contain the most
complex code, since it\'s here that the game state may actually be
changed. We have already seen several examples of `action()` routines,
most recently that for drinking the poison on p. 72 above. The only
complication to bear in mind is that if you define `action() `routines
on both the direct and indirect objects of an action, both action
routines will be carried out (the indirect object\'s first), so you need
to make sure that their combination does what you want; normally, it\'s
better to define an action routine on one or the other of the objects
involved in a two-object command, but not both.

\

------------------------------------------------------------------------

*Getting Started in TADS 3*\
[\[Main\]](index.html)\
*[\[Previous\]](check.htm)   [\[Next\]](precond.htm)*
:::
