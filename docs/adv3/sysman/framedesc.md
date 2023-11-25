::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> StackFrameDesc\
[[*Prev:* RexPattern](rexpat.htm){.nav}     [*Next:*
String](string.htm){.nav}     ]{.navnp}
:::

::: main
# StackFrameDesc

The StackFrameDesc (\"desc\" for \"descriptor\") class provides access
to the local variables and method context variables ([self]{.code},
[definingobj]{.code}, [targetprop]{.code}, [targetobj]{.code}) in an
active stack frame. This lets you retrieve and change the values of
local variables in a calling function, and to retrieve the method
context information. This type of manipulation isn\'t commonly used in
ordinary programming tasks, but it\'s occasionally useful for special
cases, especially for utility libraries that implement things like
extension languages or debugging facilities. It also lets you create
[dynamically compiled functions](dynfunc.htm) that can access the local
variables in calling frames.

A \"stack frame\" is a storage area within the TADS 3 virtual machine
that represents a function or method call in progress. The frame
contains the local variables for the routine along with its method
context variables, plus information on where control passes when the
routine returns to its caller. It\'s called a \"frame\" because it\'s a
self-contained chunk of memory that\'s reserved for the use of that one
active routine. These frames are arranged into a \"stack,\" which is a
data structure perfectly suited for the way control flows from a caller
to a callee and then to another callee: each time a new function is
called, the frame for the new one is piled on top of the last one; when
a callee returns, its frame is taken off the pile, which restores its
caller as the active frame.

## How to get a StackFrameDesc object

You can\'t create StackFrameDesc objects using the [new]{.code}
operator. Instead, you obtain them from the
[[t3GetStackTrace()]{.code}](t3vm.htm#t3GetStackTrace) function. This
function returns a trace of the active call stack, which contains
information on each caller of the current routine. One of the bits of
information that you can get for each caller is a StackFrameDesc object
for its stack frame. To get the StackFrameDesc, you must include the
[T3GetStackDesc]{.code} flag in the call to [t3GetStackTrace()]{.code}.
This tells the function to include the frame descriptor object, and
store it in the [frameDesc\_]{.code} property of each stack trace item.

Here\'s an example that retrieves the StackFrameDesc object for the
immediate caller. The current, active routine (the routine that\'s
running right now) is always at level 1, so the immediate caller is at
level 2. We thus ask the stack trace function to give us information for
stack level 2, and we specify the [T3GetStackDesc]{.code} flag to
request the frame descriptor object.

::: code
    local frame = t3GetStackTrace(2, T3GetStackDesc).frameDesc_;
:::

Once you have the frame descriptor object, you can call its methods to
retrieve information on the stack frame and manipulate its local
variables.

## Stack frame lifetime

A stack frame is inherently ephemeral, because it represents a running
function or method. The frame doesn\'t represent the function or method
itself - it merely represents the current *invocation* of the function
or method. When that call to the routine exits, either because the
routine uses [return]{.code} to return control to its caller or because
[throw]{.code} transfers control back to a [catch]{.code} block in a
caller, the stack frame representing the call ceases to exist.

A stack frame is still valid during times when the function or method is
suspended waiting for another routine it called to return. The frame
only expires when its function or method returns or throws an error that
returns control to a caller.

Unlike the underlying stack frame, a StackFrameDesc object *doesn\'t*
disappear when the routine associated with the stack frame exits. A
StackFrameDesc object is only a *description* of a stack frame, so it
can continue to exist after the frame it points to has been deleted.

When a stack frame is destroyed, but a StackFrameDesc object that points
to the frame still exists, the system automatically makes a \"snapshot\"
of the local variables in the frame. That is, it makes a private copy of
the variables, and stores it with the StackFrameDesc object. After that
point, whenever you use the StackFrameDesc object to access the local
variables, the StackFrameDesc will simply use its private snapshot copy
instead of going to the true stack frame. This is all done
automatically; you don\'t have to do anything different in your code.

You can specifically test a StackFrameDesc to see if the frame is still
alive, using the [isActive()]{.code} method. This returns [true]{.code}
if the stack frame is still active, or [nil]{.code} if the routine has
already exited (via [return]{.code} or [throw]{.code}).

Note that stack frame lifetime is only an issue if you pass a stack
frame from one routine to another (via [return]{.code}, for example, or
by storing it in an object property). If you only use a frame descriptor
within the routine that obtained it, the frame won\'t become invalid
during the time you\'re using it, since the only way for it to become
invalid is for the method or function call it represents to return - and
*that* can\'t happen until the current routine returns first.

## Accessing local variables

To access local variables in the stack frame, you use the indexing
operator, [\[\]]{.code}, with the name of a local variable as the index
value. Use a single-quoted string for the name.

For example, to access local variable [i]{.code}, you\'d simply write
[frame\[\'i\'\]]{.code}.

Here\'s a more complete example:

::: code
    main(args)
    {
      for (local i = 1 ; i <= 10 ; ++i)
        f(i);
    }

    f(x)
    {
      // Get the stack frame information for our caller.  The first level of
      // the stack trace is always the current routine; we're interested in
      // the routine that called us, which is at level 2.  Use the T3GetStackDesc
      // flag to retrieve the StackFrameDesc object for the frame.
      local t = t3GetStackTrace(2, T3GetStackDesc);

      // get the frame object from the stack level description
      local f = t.frameDesc_;

      // show the value of local variable 'i' in the caller
      "The caller's value of i is <<f['i']>>.\n";
    }
:::

If you attempt to access a local variable that doesn\'t exist in the
frame, the system will throw a run-time error (\"index out of range\").

You can assign a new value to a variable in the frame using the normal
assignment syntax:

::: code
    f['i'] = 100;
:::

As long as the underlying stack frame is still active, all access to the
local variables will directly read and write the **live** values. That
means that any changes you make will change the actual local variables
in the function or method associated with the stack frame. Likewise, any
changes that the routine itself makes will be visible.

When the routine associated with the stack frame exits, the actual stack
frame will be deleted, along with its local variables. However, the
StackFrameDesc object will automatically make a snapshot copy of the
locals at that very moment - so it will have the latest values as they
were just before the routine exited. From that point on, access to the
local variables through the StackFrameDesc object will use the snapshot.
You can still make changes, but the changes will only update the
snapshot, since the true local variables will no longer exist.

## StackFrameDesc methods

[getDefiningObj()]{.code}

::: fdef
Retrieves the value of [definingobj]{.code} from the frame, returning
the value. This is the object which actually contains the definition of
the method being executed; since methods can be inherited from
superclasses, this might not be the same as the [self]{.code} object in
the frame. If the level refers to an ordinary function rather than a
method, returns nil.
:::

[getInvokee()]{.code}

::: fdef
Retrieve the value of [invokee]{.code} in the frame, returning the
value.
:::

[getSelf()]{.code}

::: fdef
Retrieves the value of [self]{.code} from the frame, returning the
value. If the level refers to an ordinary function rather than a method,
returns nil.
:::

[getTargetObj()]{.code}

::: fdef
Retrieves the value of [targetobj]{.code} from the frame, returning the
value. [targetobj]{.code} is the object on the left side of the \".\"
expression that invoked the method. This is usually the same as
[self]{.code}, but can differ when [delegated]{.code} is used to invoke
another object\'s method as though it belonged to the calling object. If
the level refers to an ordinary function rather than a method, returns
nil.
:::

[getTargetProp()]{.code}

::: fdef
Retrieves the value of [targetprop]{.code} from the frame, returning the
value. This is the property value on the right side of the \".\"
expression that invoked the method. If the level refers to an ordinary
function rather than a method, returns nil.
:::

[getVars()]{.code}

::: fdef
Returns a LookupTable containing all of the local variables in the
frame. The table is keyed by variable name (each name is given as a
single-quoted string), and each associated value is the value of the
variable.

The values in the lookup table are snapshot copies of the variable
values, as they were at the time you called [getVars()]{.code}. The
values in the table are **not** updated when the actual local variable
values change.

A new LookupTable is constructed each time this routine is called, based
on the variable values at the time of the call.

There are two main uses for [getVars()]{.code}. First, it lets you
enumerate all of the locals in the frame (using the [forEach()]{.code}
method on the table), or get a list of their names (using
[keysToList()]{.code}). Second, it lets you get a fixed snapshot copy of
the locals, in case you want the values at a particular point in time.
:::

[isActive()]{.code}

::: fdef
Determines if the frame is still active. Returns [true]{.code} if so,
[nil]{.code} if not. A frame is active as long as the function or method
call it represents has not returned to its caller; once the routine
returns to its caller, the system automatically deletes the associated
stack frame. A frame does remain valid during the time it\'s suspended
waiting for a routine it called to return.

Note that you don\'t have to worry about whether the frame is active or
not if all you want to do is access its local variables. When the actual
stack frame is destroyed, if a StackFrameDesc object exists, the system
automatically makes a snapshot copy of the frame\'s local variables in
the StackFrameDesc, which then uses the snapshot copy whenever you
access the locals. This means that you can access the locals even after
the true stack frame has been deleted.
:::
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> StackFrameDesc\
[[*Prev:* RexPattern](rexpat.htm){.nav}     [*Next:*
String](string.htm){.nav}     ]{.navnp}
:::
