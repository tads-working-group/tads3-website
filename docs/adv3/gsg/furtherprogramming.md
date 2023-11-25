::: topbar
[![](topbar.jpg){border="0"}](index.html)
:::

::: main
[\[Main\]](index.html)\
*[\[Previous\]](programmingprolegomena.htm)   [\[Next\]](chapter2.htm)*

Further Programming Concepts and Constructs

We have only scratched the surface of the TADS 3 language here, but
further details are available in the *System Manual*, and in the
meantime we have covered most of the basic features of the language that
you need to follow this *Guide*. A few more will be introduced as we go
along. There are, however, a few more fairly basic TADS 3 programming
concepts we haven\'t covered yet, and as you\'ll probably need them
sooner rather than later they\'re introduced here. It is not necessary
to master these in order to use the rest of this *Guide*, however, so
you may prefer to skip this section for now and get on with the more
interesting business of discovering how to construct your first TADS 3
game, returning to this section later on if you need to.

### a. Comments, Identifiers and Scope

#### (i) Comments

Outside of a quoted string, two consecutive slashes, //, indicate that
the rest of the line is a comment. Everything up to the next newline is
ignored. Alternatively, C-style comments can be used; these start with
/\* and end with \*/; this type of comment can span multiple lines.\
\
Examples:

    // This line is a comment. /*This is a commentwhich goes acrossseveral lines.*/

\

#### ii) Identifiers

Identifiers must start with a letter (upper or lower case), and may
contain letters, numbers, dollar signs, and underscores. Identifiers can
be up to 39 characters long. Upper and lower case letters are distinct
(so that, for example, cloakroom, Cloakroom and CloakRoom are three
different identifiers).

\

#### iii) Scope of Identifiers and Local Variables

All objects and functions are named by global identifiers. No identifier
may be used to identify different things; that is, no two objects can
have the same name, an identifier naming a function can\'t also be used
for an object, and so forth.

Property names are also global identifiers. A name used for a property
can\'t be used for a function or object, or vice versa. However, unlike
functions and objects, the same property name can be used in many
different objects. Since a property name is never used alone, but always
in conjunction with an object, the TADS compiler is able to determine
which object\'s property is being referenced even if the same name is
used in many objects.

Function arguments and local variables are visible only in the function
in which they appear. It is permissible to re-use a global identifier as
a function argument or local variable, in which case the variable
supersedes the global meaning within the function. However, this is
discouraged, as it can be a bit confusing.

Local variables in functions and methods must be declared with the
keyword local before they are used. Local variable declarations can
appear anywhere within a code block. A local variable definition that
appears in the middle of a code block creates a variable that is in
scope from that point in the code block to the closing brace of the code
block. (TADS 2 only allowed local variable declarations at the start of
a code block.)

You can define local variables for the current code block. This is done
with a statement such as this:

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  local *identifier-list* ; \
\
The *identifier-list* has the form:\
\
*  identifier \[ initializer \] \[*, *identifier-list \]* \
\
An *initializer*, which is optional, has the form:\
  \
= *expression* \
\
where the *expression* is any valid expression, which can contain
arguments to the function or method, as well as any local variables
defined prior to the local variable being initialized with the
expression. The expression is evaluated, and the resulting value is
assigned to the local variable prior to evaluating the next initializer,
if any, and prior to executing the first statement after the local
declaration. Local variables with initializers and local variables
without initializers can be freely intermixed in a single statement; any
local variables without initializers are automatically set to nil by the
run-time system.\
\
The identifiers defined in this fashion are visible only inside the
function or method in which the local statement appears (actually, the
situation can be slightly more complex than this when anonymous
functions are involved - see the section on [Anonymous
Functions](../sysman/anonfn.htm) in the System Manual for the full
story). Furthermore, the local statement supersedes any global meaning
of the identifiers within the function or method.\
\
An example of declaring local variables, using multiple local
statements, and using initializers is below.

    f(a, b){  local i, j;                   /* no initializers */  local k = 1, m, n = 2;        /* some with initializers, some without */  local q = 5 * k, r = m + q;   /* OK to use q after it's initialized */  for (i = 1 ; i < q ; i++)  {    local x, y;                 /* locals can be declared in any block */    say(i);  }}

\

### b. Loops

A common programming requirement - and one that can turn up quite
frequently in TADS programming - is the need to repeat a statement or
set of statements a number of times. This may either be a fixed number
of times or, more commonly, a number of times determined by some
condition, such as the number of objects in a set we wish to examine.
For example at the start of the game we might want to go through every
object in the game and ensure that it is has been added to the
[contents ]{.code}property of its immediately container (the library in
fact does this for us). It would be tedious indeed to have to write code
to do this on every single object that might be affected; it\'s far
better to write a set of statements once and have that same set of
statements executed for every relevant object in our game. A programming
construct that accomplishes this sort of task is traditionally called a
*loop*, and the TADS 3 language provides four types of loop: while,
do-while, for and foreach. It also contains a number of statements to
help control how loops function.

\

#### i) While

The while statement defines a loop: set of statements that is executed
repeatedly as long as a certain condition is true.

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- ------------------------------------
                                      while ( *expression* ) statement \

  ----------------------------------- ------------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

As with the if statement, the *statement* may be a single statement or a
set of statements enclosed in braces. The *expression* should evaluate
to a number (in which case 0 is false and anything else is true), or a
truth value (true or nil).\
\
The *expression* is evaluated *before* the first time through the loop;
if the *expression* is false at that time, the statement or statements
in the loop are skipped. Otherwise, the statement or statements are
executed once, and the *expression* is evaluated again; if the
*expression* is still true, the loop executes one more time and the
cycle is repeated. Once the *expression* is false, execution resumes at
the next statement after the loop.\
\
For example, suppose we had a custom class called Book and we wanted to
loop through every Book in our game setting its hasBeenRead property to
nil unless its author property refers to the Player Character. We could
write:

    local obj = firstObj(Book);while(obj != nil){  if(obj.author==gPlayerChar)      obj.hasBeenRead = true;  else      obj.hasBeenRead = nil;  obj = nextObj(obj, Book);}

#### ii) Do-While

The do-while statement defines a slightly different type of loop from
the while statement. This type of loop also executes until a controlling
expression becomes false (0 or nil), but evaluates the controlling
expression *after* each iteration of the loop. This ensures that the
loop is executed at least once, since the expression isn\'t tested for
the first time until after the first iteration of the loop.

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The general form of this statement is:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- ------------------------------------------
                                      do *statement* while ( *expression* ); \

  ----------------------------------- ------------------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The statement may again be a single statement or a set of statements
enclosed in braces. The expression should again evaluate either to a
number (in which case 0 is false and anything else is true), or a truth
value (true or nil).\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

For example, to calculate factorial n:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      factorial(n) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          local x = 1, res = 1; \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          do \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
                                      { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          res = res \* x; \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          x++; \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      } \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
                                          while (x \<= n); \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          return res; \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
  *iii)*                              *For* * \
                                      *

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The for statement defines a very powerful and general type of loop. You
can always use while to construct any loop you can construct with for,
but the for statement is often a much more compact and readable notation
for the same effect.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The general form of this statement is:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- ---------------------------------------------------------------
                                      for ( *init-expr*; *cond-expr*; *reinit-expr* ) *statement* \

  ----------------------------------- ---------------------------------------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

As with other looping constructs, the *statement* can be either a single
statement, or a block of statements enclosed in braces.\
\
The first expression, *init-expr*, is the \"initialization expression.\"
This expression is evaluated once, before the first iteration of the
loop. It is used to initialize the variables involved in the loop.\
\
The second expression, *cond-expr*, is the condition of the loop. It
serves the same purpose as the controlling expression of a while
statement. Before each iteration of the loop, the *cond-expr* is
evaluated. If the value is true the body of the loop is executed;
otherwise, the loop is terminated, and execution resumes at the
statement following the loop body. Note that, like the while
statement\'s controlling expression, the *cond-expr* of a for statement
is evaluated prior to the first time through the loop (but after the
*init-expr* has been evaluated), so a for loop will execute zero times
if the *cond-expr* is false prior to the first iteration.\
\
The third expression, *reinit-expr*, is the \"re-initialization
expression.\" This expression is evaluated *after* each iteration of the
loop. Its value is ignored; the only purpose of this expression is to
change the loop variables as necessary for the next iteration of the
loop. Usually, the re-initialization expression will increment a counter
or perform some similar function.\
\
Any or all of the three expressions may be omitted. Omitting the
expression condition is equivalent to using true as the expression
condition; hence, a loop that starts \"for ( ;; )\" will iterate forever
(or until a break statement is executed within the loop). A for
statement that omits the initialization and re-initialization
expressions is the same as a while loop.\
\
Here\'s an example of using a for statement. This function implements a
simple loop that computes the sum of the elements of a list.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        sumlist(lst) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        { \

  ----------------------------------- -----------------------------------

  ----------------------------------- ----------------------------------------
                                          local len = length(lst), sum, i; \

  ----------------------------------- ----------------------------------------

  ----------------------------------- ----------------------------------------------
                                          for (sum = 0, i = 1 ; i \<= len ; i++) \

  ----------------------------------- ----------------------------------------------

  ----------------------------------- -----------------------------------
                                            sum += lst\[i\]; \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        } \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\
Note that an equivalent loop could be written with an empty loop body,
by performing the summation in the re-initialization expression. We
could also move the initialization of len within the initialization
expression of the loop.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        sumlist(lst) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          local len, sum, i; \

  ----------------------------------- -----------------------------------

  ----------------------------------- ------------------------------------------------------------
                                          for (len = length(lst), sum = 0, i = 1 ; i \<= len ; \

  ----------------------------------- ------------------------------------------------------------

  ----------------------------------- -----------------------------------
                                            sum += lst\[i\], i++); \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        } \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\
You can define new local variables in the initializer part of a for
statement by using the local keyword in the initializer. For example:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

    for (i = 1, local j = 3, local k = 4, l = 5 ; i \< 5 ; ++i) // \...\
\
This declares two new local variables, j and k, and uses the existing
variables i and l. Note that l is *not* a new local, even though it
comes after the local k definition, because each local keyword in a for
initializer defines only one variable. Note also that an initial value
assignment is required for each new local declared.\
\
The new locals declared in a for initializer are local in scope to the
for statement and its body (this is the same rule that Java uses,
although note that it differs from the (undesirable) way C++ works). The
effect is exactly as though an extra open brace (\"{\") followed by a
local statement for each new local appeared immediately before the for
statement, and an extra close brace (\"}\") appeared immediately after
the end of the body of the loop.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
  *iv)*                               *Foreach**** \
                                      ***

  ----------------------------------- -----------------------------------

  ------ --
  ****   
  ------ --

The foreach statement provides a convenient syntax for writing a loop
over the contents of a collection, such as a List or a Vector.\
\
The syntax of the foreach statement is:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

   foreach ( *foreach_lvalue *in *expression* ) *body\
*\
The *foreach_lvalue* specifies a local variable or other \"lvalue\"
expression which serves as the looping variable. This can be any
   lvalue (any expression that can be used on the left-hand side of an
assignment operator), or it can be the keyword local followed by the
name of a new local variable; if local is used, a new local variable is
created with scope local to the foreach statement and its body. (Note
that as of TADS 3.1.0 we can use for in place of foreach in such loops,
and that there are also other varieties of for..in loop that we needn\'t
worry about here.)\
\
The *expression* is any expression that evaluates to a Collection object
(for which see the [*System Manual*](../sysman/collect.htm)), such as a
List or Vector value.\
\
The statement loops over the elements of the collection. For each
element, the statement assigns the current element to the lvalue, then
executes the body.\
\
Here\'s an example that displays the elements of a list.\
\
   local lst = \[1, 2, 3, 4, 5\];\
   foreach (local x in lst)\
      \"\<\<x\>\>\\n\";\
\

  ----------------------------------- -----------------------------------
  *v)*                                *Break and Continue \
                                      *

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

A program can get out of a loop early using the break statement:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------- ----------------------- -----------------------
                            break;  \             

  ----------------------- ----------------------- -----------------------

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

This is useful for terminating a loop at a midpoint. Execution resumes
at the statement immediately following the innermost loop in which the
break appears.\
\
The break statement also is used to exit a switch statement. In a switch
statement, a break causes execution to resume at the statement following
the closing brace of the switch statement.\
\
The continue statement does roughly the opposite of the break statement;
it resumes execution back at the start of the innermost loop in which it
appears. The continue statement may be used in for, while, foreach, and
do-while loops.\
\
In a for loop, continue causes execution to resume at the
re-initialization step. That is, the third expression (if present) in
the for statement is evaluated, then the second expression (if present)
is evaluated; if the second expression\'s value is non-nil or the second
expression isn\'t present, execution resumes at the first statement
within the statement block following the for, otherwise at the next
statement following the block.\
\
For example, suppose we want to loop through a player\'s possessions
until we find one that is of class LightSource; we might do something
like this:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      local obj; \

  ----------------------------------- -----------------------------------

  ----------------------------------- ----------------------------------------
                                      foreach(obj in gPlayerChar.contents) \

  ----------------------------------- ----------------------------------------

  ----------------------------------- -----------------------------------
                                      { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                         if(obj.ofKind(LightSource)) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                            break; \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The break and continue statements can optionally specify a target label.
When a label is used with one of these statements, it must refer to a
statement that encloses the break or continue. In the case of continue,
the label must refer directly to a loop statement: a for, while, or
do-while statement. The target of a break may be any enclosing
statement.\
\
When a label is used with break, the statement transfers control to the
statement immediately following the labeled statement. If the target
statement is a loop, control transfers to the statement following the
loop body. If the target is a compound statement (a group of statements
enclosed in braces), control transfers to the next statement after the
block\'s closing brace. Targeted break statements are especially useful
when you want to break out of a loop from within a switch statement:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

scanLoop:\
    for (i = 1 ; i \< 10 ; ++i)\
    {\
        switch(val\[i\])\
        {\
        case \'+\':\
            ++sum;\
            break;\
 \
        case \'-\':\
            \--sum;\
            break;\
 \
        case \'eof\':\
            break scanLoop;\
        }\
    }\
\
Targeted break statements are also useful for breaking out of nested
loops:\
\
matchLoop:\
\
    for (i = 1 ; i \<= val.length() ; ++i)\
    {\
        for (j = 1 ; j \< i ; ++j)\
        {\
            if (val\[i\] == val\[j\])\
                break matchLoop;\
        }\
    }\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
  *vi)*                               *Alternatives to Loops \
                                      *

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

It seems to be one of the best kept secrets of TADS 3 that for many
purposes there\'s often a more compact alternative to using a loop,
particular when working with a *Collection* such as List or Vector. For
example the foreach loop used above to identify a LightSource held by
the player could have been replaced with a single statement:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- --------------------------------------------------------------------------
                                      local obj = gPlayerChar.contents.valWhich({x: x.ofKind(LightSource)}); \

  ----------------------------------- --------------------------------------------------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

The above statement will hardly be transparent to the novice, and this
probably isn\'t the best place to explain it, since it involves concepts
that go some way beyond the introductory. At this point it must suffice
to call your attention to the possibility of this kind of construct,
which can be extremely powerful once mastered. To find out more (when
you feel ready), read the sections on [Anonymous
Functions](../sysman/anonfn.htm), [List](../sysman/list.htm) and
[Vector](../sysman/vector.htm) in the *System Manual*.\
\
\

### c. Inheritance

TADS 3 is an object-oriented language which makes heavy use of
inheritance (that is to say, the language supports inheritance and the
library makes heavy use of it). At its simplest inheritance allows us to
have the best of both worlds: to modify the behaviour of an existing
object or class but still make use of the behaviour defined on that
class. For example, suppose we defined a Switch class with a method that
defines what happens when it\'s switched on and off:

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Switch: Thing\

  ----------------------------------- -----------------------------------
                                      makeOn(stat) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                         isOn = stat; \

  ----------------------------------- -----------------------------------

  ----------------------------------- ------------------------------------------------------------------
                                         \"You flip the switch \<\< stat ? \'on\' : \'off\' \>\>. \" \

  ----------------------------------- ------------------------------------------------------------------

  ----------------------------------- -----------------------------------
                                      } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      isOn = nil \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

;\
\
Now suppose you wanted a LightSwitch class that did exactly the same as
the Switch class, but also turn on an associated light source when
turned on. You could derive this from Switch as a subclass, and you\'d
still want its makeOn method to do everything Switch\'s makeOn method
does, but you\'d also want it to light the light source. It would be
tedious to have to retype the whole makeOn(stat) method, particularly in
cases where it was something rather more substantial than here; instead
we can inherit it and then add our own modifications:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

LightSwitch: Switch\

  ----------------------------------- -----------------------------------
                                      makeOn(stat) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                         inherited(stat); \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                         if(myLight != nil) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                           myLight.makeLit(stat); \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      myLight = nil \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Note that we don\'t have to repeat the definition of the isOn property,
since this is already inherited from the Switch class. We\'ll now
examine this mechanism in a bit more detail.\
\

  ----------------------------------- -----------------------------------
  *i)*                                *Inherited \
                                      *

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

A special pseudo-object called inherited allows you to call a method in
the current self object\'s superclass. Moreover, you can use
inherited in an expression, so any value returned by the superclass
method can be determined and used by the current method. Third, you can
pass arguments to the property invoked with the
inherited pseudo-object.\
\
You can use inherited in an expression anywhere that you can use self.\
\
Here is an example of using inherited.\
\

  ----------------------------------- -----------------------------------
                                        MyClass: object \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          sdesc = \"myclass\" \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          prop1(a, b) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          { \

  ----------------------------------- -----------------------------------

  ----------------------------------- ---------------------------------------------------------------
                                             \"This is myclass\'s prop1.  self = \<\< sdesc \>\>, \

  ----------------------------------- ---------------------------------------------------------------

  ----------------------------------- -------------------------------------------------------
                                              a = \<\< a \>\>, and b = \<\< b \>\>.\\n\"; \

  ----------------------------------- -------------------------------------------------------

  ----------------------------------- -----------------------------------
                                              return(123); \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        ; \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        myobj: MyClass \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          sdesc = \"myobj\" \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          prop1(d, e, f) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                              local x; \

  ----------------------------------- -----------------------------------

  ----------------------------------- --------------------------------------------------------------
                                              \"This is myobj\'s prop1.  self = \<\< sdesc \>\>, \

  ----------------------------------- --------------------------------------------------------------

  ----------------------------------- ------------------------------------------------------------------------
                                              d = \<\< d \>\>, e = \<\< e \>\>, and f = \<\< f \>\>.\\n\"; \

  ----------------------------------- ------------------------------------------------------------------------

  ----------------------------------- -------------------------------------------
                                              x = inherited.prop1(d, f) \* 2; \

  ----------------------------------- -------------------------------------------

  ----------------------------------- ------------------------------------------------------------
                                              \"Back in myobj\'s prop1.  x = \<\< x \>\>\\n\"; \

  ----------------------------------- ------------------------------------------------------------

  ----------------------------------- -----------------------------------
                                          } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        ; \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

   When you call myobj.prop1(1, 2, 3), the following will be displayed:\
\

  ----------------------- ------------------------------------------------------------------- -----------------------
                           This is myobj\'s prop1. self = myobj, d = 1, e = 2, and f = 3. \   

  ----------------------- ------------------------------------------------------------------- -----------------------

  ----------------------- -------------------------------------------------------------- -----------------------
                           This is myclass\'s prop1. self = myobj, a = 1, and b = 3. \   

  ----------------------- -------------------------------------------------------------- -----------------------

  ----------------------- ------------------------------------- -----------------------
                           Back in myobj\'s prop1. x = 246. \   

  ----------------------- ------------------------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

Note that the self object that is in effect while the superclass method
is being executed is the *same* as the self object in the calling
(subclass) method. This makes inherited very different from calling the
superclass method directly (i.e., by using the superclass object\'s name
in place of inherited).\
\
You can also specify the name of the superclass after the \'inherited\'
keyword; this is otherwise similar to the normal \'inherited\' syntax:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

     inherited Fixture.actionDobjTake();\

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

\
This specifies that you want the method to inherit the actionDobjTake()
implementation from the Fixture superclass, regardless of whether TADS
might normally have chosen another superclass as the overridden method.
This is useful for situations involving multiple inheritance where you
want more control over which of the base classes of an object should
provide a particular behavior for the subclass.\
\
If the last example had been called from within the actionDobjTake()
method of the object in question, we could simply have written:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      inherited Fixture(); \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

It is legal to omit the property name or expression in an inherited or
delegated (see below) expression. When the property name or expression
is omitted, the property inherited or delegated to is implicitly the
same as the current target property. For example, consider this code:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      myObj: myClass \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        myMethod(a, b) \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        { \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                          inherited(a\*2, b\*2); \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                        } \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      ; \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\
This invokes the inherited myMethod(), as though we had instead written
inherited.myMethod(a\*2, b\*2). Because the current method is myMethod
when the inherited expression is evaluated, myMethod is the implied
property of the inherited expression.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
  *ii)*                               *Multiple Inheritance \
                                      *

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

An object can inherit properties from more than one other object. This
is called Multiple Inheritance. It complicates things considerably,
primarily because it can be confusing to figure out exactly where an
object is inheriting its properties from. In essence, the order in which
you specify an object\'s superclasses determines the priority of
inheritance if the object could inherit the same property from several
of its superclasses.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- ------------------------------------
                                      multiObj: class1, class2, class3 \

  ----------------------------------- ------------------------------------

  ----------------------------------- -----------------------------------
                                      ; \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\
Here we have defined multiObj to inherit properties first from class1,
then from class2, then from class3. If all three classes define a
property prop1, multiObj inherits prop1 from class1, since it is
specified first.\
\
Multiple inheritance can be a very useful feature. For example, suppose
you wanted to define a huge vase; it should be fixed in the room, since
it is too heavy to carry, but it should also be a container. With
multiple inheritance, you can define the object to be both a Heavy and a
Container (which are classes defined in the standard library).\
\
If a property is inherited from more than one of its superclasses (and
is not overridden in the object\'s own property list), the property is
inherited from the superclass that appears earliest in the list. For
example, suppose you define an object like this:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  ----------------------------------- -----------------------------------
                                      vase: Container, Heavy; \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\
If both Container and Heavy define a method named m1, and vase itself
doesn\'t define an m1 method, then m1 is inherited from Container,
because it appears earlier in the superclass list than Heavy.\
\
There is a more complicated case that can occur. You do not need to
master this in order to follow this guide, so skip this section if you
find it confusing. Suppose that in the example above, both Container and
Heavy have the superclass Thing, and that Thing and Heavy define method
m2, and that neither Container nor vase define m2. Now, since
Container inherits m2 from Thing, it might seem that vase should inherit
m2 from Container and thus from Thing. However, this is not the case;
since the m2 defined in Heavy overrides the one defined in Thing, vase
inherits the m2 from Heavy rather than the one from Thing. Hence, the
rule, fully stated, is: the inherited property in the case of multiple
inheritance is that property of the earliest (leftmost) superclass in
the object\'s superclass list that is not overridden by a subsequent
superclass. An alternative way of expressing this is \"The first
(left-most) superclass has precedence for inheritance, so any properties
or methods that it defines effectively override the same properties and
methods defined in subsequent superclasses, except that an ancestor
class does not override a method or property on any of its descendent
classes.\"\
\
Don\'t worry if this is less than crystal-clear at the moment; simply
think of it as something you may need come back to. In the meantime bear
in mind two simple consequences: (1) it may not always be immediately
obvious (in a situation of multiple inheritance) what the keyword
inherited will inherit from; and (2) the order of classes in an object
definition can be important (e.g myDoor: Lockable, Door works properly
while myDoor: Door, Lockable doesn\'t).\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

(When you\'re ready for fuller explanations of the mysteries of multiple
inheritance, these are available both in the *[System
Manual](../sysman/inherit.htm){target="_top"}* and in the *[Technical
Manual](../techman/t3mi.htm){target="_top"}).\
*

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------------------- -----------------------------------
  *iii)*                              *Replace and Modify* * \
                                      *

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

Most game authors sooner or later find that, when writing a substantial
game, they need to modify the standard library behaviour at a number of
points. While it would in principle be possible to modify the library
files, this would create a problem when a new version of TADS is
released, because you must either continue to use the old version of
adv3, which means that any bug fixes or enhancements in the new version
are not available, or take the time to reconcile your changes to your
custom adv3 files with those made in the standard version. The replace
and modify mechanism can help you deal with this problem.\
\
These keywords allow you to make changes to objects and classes that
have been previously defined. In other words, you can use the standard
adv3 library, and then make changes to the objects that the compiler has
*already* finished compiling. Using these keywords, you can make four
types of changes to previously-defined objects: you can replace a
function entirely, you can replace an object entirely, or you can add to
or change the methods already defined in an object, or you can modify a
function.\
\
To replace a function that\'s already been defined, you simply preface
your replacement definition with the keyword replace. Following the
keyword replace is an otherwise normal function definition. The
following example replaces the addToScore() function defined in
score.t (part of the standard adv3 library):\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

replace addToScore(points, desc) \
{ \
   if(gPlayerChar.isWorthy)\
      libScore.addToScore\_(points, desc); \
} \

  ----------------------- ----------------------- -----------------------
                              \                   

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

You can do exactly the same thing with objects or classes. For example,
you can entirely replace the coarseMesh object defined in sense.t:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

replace coarseMesh: Material \
   seeThru = transparent \
   hearThru = transparent \
   smellThru = distant\
   touchThru = transparent \
; \

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

Replacing an object or class entirely deletes the previous definition,
including all inheritance information and vocabulary. The only
properties of a replaced object are those defined in the replacement;
the original definition is entirely discarded.\
\
You can also modify an object or class, retaining its original
definition (including inheritance information, vocabulary, and
properties). This allows you to add new properties and vocabulary. You
can also override properties, simply by redefining them in the new
definition.\
\
For example, you might want to change one of the standard library
responses and add one of your own:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

modify playerActionMessages\
   cannotTurnMsg = \'{The dobj/he} just will not turn. \'\
   shouldNotSpitMsg = \'It\'s rude to spit in public. \'\
;\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\
Note that no superclass information can be specified in a modify
statement; this is because the superclass list for the modified object
is the same as for the original object.\
\
In a method that you redefine with modify, you can use inherited to
refer to the *replaced* method in the original definition of the object.
In essence, using modify renames the original object, and then creates a
new object under the original name; the new object is created as a
subclass of the original (now unnamed) object. (There is no way to refer
to the original object directly; you can only refer to it indirectly
through the new replacement object.) Here\'s an example of using
inherited with modify.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

     class testClass: object\
       sdesc = \"testClass\"\
     ;\
\
     testObj: testClass\
        sdesc \
       {\
          \"testObj\...\";\
      inherited;\
       }\
     ;\
\
     modify testObj\
        sdesc \
       {\
         \"modified testObj\...\";\
      inherited;\
       }\
     ;\

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

Evaluating testObj.sdesc results in this display:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  ----------------------- ---------------------------------------------- -----------------------
                            modified testObj\...testObj\...testClass \   

  ----------------------- ---------------------------------------------- -----------------------

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

You can also replace a property entirely, erasing all traces of the
original definition of a property. The original definition is entirely
forgotten - using inherited will refer to the method inherited by the
original object. To do this, use the replace keyword with the property
itself. In the example above, we could do this instead:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

      modify testObj\
        replace sdesc\
       {\
           \"modified testObj\...\";\
        inherited;\
       }\
      ;\
\
   This would result in a different display for testObj.sdesc:\

  ----------------------- ----------------------------------- -----------------------
                            modified testObj\...testClass \   

  ----------------------- ----------------------------------- -----------------------

  ----------------------- ----------------------- -----------------------
                           \                      

  ----------------------- ----------------------- -----------------------

  -- -- -- --
           
  -- -- -- --

The replace keyword before the property definition tells the compiler to
completely delete the previous definitions of the property. This allows
you to completely replace the property, and not merely override it,
meaning that inherited will refer to the property actually inherited
from the superclass, and not the original definition of the property.\
\
The modify keyword can also be used in a function definition. Modifying
a function is just like replacing it (using the replace keyword), except
that the new definition of the function can invoke the old definition of
the function (i.e., the definition that\'s being replaced). This allows
the program to apply incremental changes to a function, such as adding
new special cases, without the need to copy the full text of the
original function.\
\
To invoke the previous definition of the function, use the replaced
keyword. This keyword is syntactically like the name of a function, so
you can put a parenthesized argument list after it to invoke the past
function, and you can simply use the replaced keyword by itself to
obtain a pointer to the old function. Here\'s an example.\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

\
    getName(val)\
    {\
      switch(dataType(val))\
      {\
      case TypeObject:\
        return val.name;\
 \
      default:\
        return \'unknown\';\
    }\
 \
    // later, or in a separate source module\
    modify getName(val)\
    {\
      if (dataType(val) == TypeSString)\
        return \'\\\'\' + val + \'\\\'\';\
      else\
        return replaced(val);\
    }\
\
\
Note how the modified function refers back to the original version: we
add handling for string values, which the original definition didn\'t
provide, but simply invoke the original version of the function for any
other type. The call to replaced(val) invokes the previous definition of
the function, which we\'re replacing.\
\
Once a function is redefined using modify, it\'s no longer possible to
invoke the old definition of the function directly by name. The only way
to reach the old definition is via the replaced keyword, and that can
only be used within the new definition of the function.\
 \

  ----------------------------------- -----------------------------------
  *iv)*                               *Delegated \
                                      *

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

It is sometimes desirable to be able to circumvent the normal
inheritance relationships between objects, and call a method in an
unrelated object as though it were inherited from a base class of the
current object. For example, you might want to create an object that
sometimes acts as though it were derived from one base class, and
sometimes acts as though it were derived from another class, based on
some dynamic state in the object. Or, you might wish to create a
specialized set of inheritance relationships that don\'t fit into the
usual class tree model.\
\
The delegated keyword can be useful for these situations. This keyword
is similar to the inherited keyword, in that it allows you to invoke a
method in another object while retaining the same \"self\" object as the
caller. delegated differs from inherited, though, in that you can
delegate a call to *any* object (or class), whether or not the object is
related to \"self.\" In addition, you can use an object expression with
delegated, whereas inherited requires a compile-time constant object.\
\
The syntax of delegated is similar to that of inherited:\

  ----------------------------------- -----------------------------------
                                       \

  ----------------------------------- -----------------------------------

  -- --
     
  -- --

  return_value = delegated object_expression.property \
optional_argument_list*\
*\
\
For example:\
\
book: Thing\
  handler = Readable\
  doTake(actor) { return delegated handler.doTake(actor); }\
;\
\
In this example, the doTake method delegates its processing to the
doTake method of the object given by the \"handler\" property of the
\"self\" object, which in this case is the Readable object. When
Readable.doTake executes, its \"self\" object will be the same as it was
in book.doTake, because delegated preserves the \"self\" object in the
delegatee.\
\
In the delegatee, the targetobj pseudo-variable contains the object that
was the target of the delegated expression.\

### d. Afterword

There is more to the TADS 3 language than has been described here, but
hopefully we have now covered the basics, and once you have mastered
those you will be able to glean the rest from the

[System Manual](../sysman/langsec.htm){target="_top"}. There\'s no need
to do that until you\'ve worked your way through this guide, although of
course if you\'re burning with curiosity to find out what else is there,
there\'s nothing to stop you!

\

------------------------------------------------------------------------

*Getting Started in TADS 3*\
[\[Main\]](index.html)\
*[\[Previous\]](programmingprolegomena.htm)   [\[Next\]](chapter2.htm)*
:::
