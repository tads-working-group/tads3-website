[![](topbar.jpg)](index.html)

[\[Main\]](index.html)  
*[\[Previous\]](fillinginsomegaps.htm)
  [\[Next\]](lookingthroughthewindow.htm)*

## Counting the Cash

That the handling of cash could actually be simplified if one stops to
think about implementing a more general solution shows that there's
often more than one way to make a mousetrap in code, and that the first
workable solution one comes up with isn't necessarily the best, the
easiest or the most elegant. Even if we wanted to stick to having four
coins in our game rather than a more abstract concept of money, we could
have handled it better, and produced a better-looking output as a
result. So for the sake of completeness we'll look at another way this
could have been handed, although it is not exactly for the faint-hearted
and introduces some techniques that are really rather advanced for a
*Getting Started* guide; it may thus be this is something you'll want to
skip on first reading.

  
The way we went about it before, using a fuse to sum up the result of
handing over multiple coins in one turn, is perfectly workable, but the
library does offer another way of doing it which, if not a great deal
simpler, at least offers better control over what is displayed to the
player. This is illustrated by the routine for handing coins to Bob in
the sample game. We can adapt that code to our situation by redefining
the shopkeeper's GiveTopic object for coins thus:  

[TABLE]

|     |     |
|-----|-----|
|     |     |

++ GiveShowTopic  
   matchTopic(fromActor, obj)  
   {  
      return obj.ofKind(Coin) ? matchScore : 0;       
   }  
   handleTopic(fromActor, obj)  
   {  
     shopkeeper.cashReceived ++;  
     currency = obj;  
     if(shopkeeper.cashReceived \<= shopkeeper.price)  
          obj.moveInto(shopkeeper);  
     /\* add our special report \*/  
     gTranscript.addReport(new GiveCoinReport(obj));  
  
        /\* register for collective handling at the end of the command \*/  
     gAction.callAfterActionMain(self);  
            
   }  
    afterActionMain()  
    {  
        /\*  
         \*   adjust the transcript by summarizing consecutive coin  
         \*   acceptance reports   
         \*/  
        gTranscript.summarizeAction(  
            {x: x.ofKind(GiveCoinReport)},  
            {vec: 'You hand over '  
              + spellInt(vec.length())+' ' + currency.name+'s.\n' });  
       if(shopkeeper.saleObject == nil)  
       {  
         "\<q\>What's this for?\</q\> asks {the shopkeeper/she}, handing the   
          money back, \<q\>Shouldn't you tell me what you want to buy   
           first?\</q\>";  
        shopkeeper.cashReceived = 0;   
       }  
    else if(shopkeeper.cashReceived \< shopkeeper.price)  
      "\<q\>Er, that's not enough.\</q\> she points out, looking at you   
        expectantly while she waits for the balance. ";  
    else  
    {  
      "{The shopkeeper/she} takes the money and turns to take  
       \<\<shopkeeper.saleObject.aName\>\>  
      off the shelf. She hands you \<\<shopkeeper.saleObject.theName\>\> saying,  
       \<q\>Here you are  then";  
      if(shopkeeper.cashReceived \> shopkeeper.price)  
              ", and here's your change";  
      ".\</q\>\</p\>";  
      shopkeeper.saleObject.moveInto(gPlayerChar);  
      shopkeeper.price = 0;  
      shopkeeper.cashReceived = 0;  
      shopkeeper.saleObject = nil;  
    }  
   }  
 currency = nil  
;  

[TABLE]

|     |     |
|-----|-----|
|     |     |

The first thing you should notice about this is that we have effectively
moved the code from the shopkeeper's cashFuse method into the new
afterActionMain() method of the GiveShowTopic. This does mean that we
now have to refer to all the properties involved as shopkeeper.whatever
instead of just whatever, which makes it look a bit more complicated
(this might be an argument for redefining these all as properties of the
GiveShowTopic, but that would involve corresponding changes on the
BuyTopic definition, so we shall not do it here). It also means that we
can remove the cashFuse code from the shopkeeper object and that we no
longer need to set up the fuse at all.  
  
Clearly this is not the whole story; we have also replaced the entire
fuse mechanism. In effect the call to gAction.callAfterActionMain(self)
in handleTopic does a job analogous to the call to
shopkeeper.cashFuseID = new Fuse(shopkeeper, &cashFuse, 0) that it
replaces, in that it registers that once we have iterated over all the
coins being given in this command, we want to handle the aggregate
result of the transaction in the afterActionMain() method of self, i.e.
the current object. Note that unlike the code to create a new fuse,
there is no need to check that this has not been called on a previous
iteration, since the registration will only be effective first time
round. So far, there is not a great gain of simplicity compared with
using the fuse to do the same job, but we are at least using a library
mechanism designed to do the job we want, rather than trying to invent
our own ad hoc mechanism, and this does allow all the code for handling
the giving of coins to be put on the appropriate GiveShowTopic.  
  
But we have not exhausted what this alternative way of designing this a
particular mousetrap can do for us, even though the part that remains is
frankly not the easiest thing to grasp first time round. The trouble
with the way we did it before was that for each coin Heidi handed over
to Sally the shopkeeper (if there were several), the game reported
"pound coin: " on a new line. We mitigated this a little by trying to
make it look as if the coins were being counted out:  

[TABLE]

[TABLE]

[TABLE]

[TABLE]

[TABLE]

|     |     |
|-----|-----|
|     |     |

But it really would have been better to do away with that repeating
'pound coin:' altogether (especially in a situation where you might want
to hand over dozens of the things at a time), and simply to have one
summary report that says something like "You hand over three pound
coins." Well, this is what this new way of doing things allows us to
do.  
  
Firstly, we define what our own output for each line should be through
the call to gTranscript.addReport(new GiveCoinReport(obj)). This
actually does two things for us; first it allows us to define what will
reported if only a single coin is handed over, and secondly it gives us
a class name we have defined ourselves (GiveCoinReport) which we'll be
able to use to manipulate the final report displayed if there's more
than one coin handed over.  
  
For this to work, we need to define the GiveCoinReport class:  

[TABLE]

|     |     |
|-----|-----|
|     |     |

class GiveCoinReport: MainCommandReport  
    construct(obj)  
    {  
        /\* remember the coin we accepted \*/  
        coinObj = obj;  
  
        /\* inherit the default handling \*/  
        gMessageParams(obj);  
        inherited('You hand over {a obj/him}. ');  
    }  
  
    /\* my coin object \*/  
    coinObj = nil  
;  

[TABLE]

|     |     |
|-----|-----|
|     |     |

The construct method - the object constructor - is called when we create
a new object of the GiveCoinReport class through a call to new
GiveCoinReport(obj); the new object's coinObj property is set to the obj
passed as a parameter, and, more interestingly for our purposes, we can
customize the message that would be displayed each time a coin is handed
over, but which will in fact only be displayed if a single coin is
handed over in the turn. Here we customize it so it will read "You hand
over a pound coin." (By using the parameter string {a obj/him} rather
than the string literal 'pound coin' here we ensure that we'll still get
a decent message if someone changes the coin name to 'dollar bill' or
whatever).  
  
Then comes the really clever (and complicated part); in order to replace
the multiple reports of "You hand over a pound coin" that we'd otherwise
see, we include the following code in the afterActionMain() method:  

[TABLE]

[TABLE]

[TABLE]

[TABLE]

[TABLE]

[TABLE]

|     |     |
|-----|-----|
|     |     |

This may well look Greek to you (unless you happen to know some Greek),
but in brief we can at least say what it *does*: what it does is to
remove every instance of the "You hand over a pound coin" report that
would otherwise be displayed and instead prints the aggregate report
"You hand over three pound coins." (or however many coins it was). We
defined a custom currency property on the GiveShowTopic which is updated
with the current object being handled every time handleTopic is invoked;
that means that the currency property will refer to a coin object and we
can use it to get at the name of the currency (rather than just assuming
it's still called 'pound coin' after you've patriotically renamed it to
dollar, euro or whatever). We form the plural by simply appending an
's', which will work as well for dollar bills as for pound coins; if,
however, you've decided that your currency really has to be draxmai/
(yes, that's what Greek *really* looks like) for your game set in
ancient Athens then you'd need to handle it a bit differently; perhaps
by defining a pluralName property for your Coin class and using that
instead of the name property here). The spellInt(vec.length()) part of
this string becomes a bit more manageable if one breaks it down step by
step: the spellInt function takes an integer as an argument and returns
the equivant spelt-out string (e.g. spellInt(5) returns 'five'). vec is
going to be a vector (a kind of dynamically resizeable array) containing
all the instances of the "You hand over a pound coin" message, so the
length of the vector, i.e. the number of elements it contains, is
equivalent to the number of coins handed over.  
  
Even so, unless you're familiar with the code structure here, the line
we're examining may *still* look rather like an arcane magical
incantation; well, it's not *quite* that, but it's close to being the
next best thing - a method call involving anonymous callback functions
(if you don't feel any the wiser for being told that, don't worry; this
is *not* the most self-evident topic). Rather than confuse you any
further by trying to explain exactly what anonymous callback function
are, I'll try to offer some explanation for what they do here.
gTranscript is an object of the CommandTranscript class. We are invoking
its summarizeAction(cond, report) method. But cond and report are not
any old common-or-garden parameters of the sort we were all brought up
or feel at least moderately comfortable with; it turns out that they are
functions, functions that the summarizeAction method will use in the
form cond(cur) and report(vec). The first of these defines the condition
that must apply to the report lines that we want to replace with our
single summary report, and the second defines what that summary report
will look like.  
  
Our call to gTranscript.SummarizeAction is thus passing two arguments
that are in effect short form function definitions. The first parameter,
{x: x.ofKind(GiveCoinReport)}, in effect tells the SummarizeAction
method to treat cond() as if it were defined as:  

[TABLE]

|     |     |
|-----|-----|
|     |     |

cond(x)  
{  
    return x.ofKind(GiveCoinReport);  
}  
  
You may remember that GiveCoinReport was the custom report class we
defined a little way back, so what we're effectively telling the
SummarizeAction with this is "look out for those reports of the
GiveCoinReport class, they're the ones we want you to count up and
replace for us."  
  
Similarly, the second parameter is passed as
{vec: 'You hand over ' + spellInt(vec.length())+' ' + currency.name+'s.\n' }. This
effectively tells SummarizeAction to treat report(vec) as if it had been
defined as:  

[TABLE]

|     |     |
|-----|-----|
|     |     |

report(vec)  
{  
    return 'You hand over ' + spellInt(vec.length())+' ' +   
      currency.name+'s.\n';  
}  

[TABLE]

|     |     |
|-----|-----|
|     |     |

Since the wizardry performed by SummarizeAction will have gathered up
each instance of a GiveCoinReport into vec, when it uses this function
to print the summary report, we'll get the result we want. If you don't
understand all this at a first read-through, don't worry; reach for the
nearest bottle of aspirins and read the description of anonymous
functions and callbacks in the *System Manual*. If it still doesn't make
too much sense to you first time round, you're doubtless in good
company. But even if it takes you a little time to feel reasonably
confident that you actually *understand* it, you may hopefully be able
to *use* this example by treating the relevant code as piece of
boilerplate in which you can slot in what you need for your own
purposes; hopefully it'll soon become clear enough for you to see where
you need to slot in what, even if the rest of it still seems less than
intuitively obvious. In particular, what you need to do is to (a) define
a MyReport class (substitute the name you actually use!); (b) supply the
first argument to gTranscript.summarizeTranscript as
{x: x.ofKind(MyReport)} and (c) supply the third argument as {vec:
'My description of what happens to the '  + spellInt(vec.length())+'  thingies that have been processed.\n'
}  

------------------------------------------------------------------------

*Getting Started in TADS 3*  
[\[Main\]](index.html)  
*[\[Previous\]](fillinginsomegaps.htm)
  [\[Next\]](lookingthroughthewindow.htm)*
