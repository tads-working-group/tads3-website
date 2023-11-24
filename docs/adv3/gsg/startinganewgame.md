[![](topbar.jpg)](index.html)

[\[Main\]](index.html)  
*[\[Previous\]](makingtheitemsdosomething.htm)
  [\[Next\]](definingourfirstroom.htm)*

# Chapter 3 - Starting Out Again

## Starting a New Game

In the previous chapter we saw how to create a very simple TADS 3 game.
In this chapter we shall start creating a somewhat more complex game,
which will occupy us for the remainder of this guide. Although in the
initial stages there will be some overlap with what has gone before, it
is important to ensure that the foundations of understanding are
securely laid, and in any case we shall shortly be introducing new ways
of accomplishing seemingly familiar tasks.  

[TABLE]

|     |     |
|-----|-----|
|     |     |

The basis for the game we shall be developing is once again the
so-called 'advanced' starter game starta3.t, which should be located in
the samples subdirectory of your TADS 3 directory. If you are using the
TADS 3 Workbench, select New Project, choose the 'advanced' rather than
the 'beginner' option, call the new file you are about to create
'heidi.t' and locate it in whichever directory you want to work (it's
probably a good idea to create a new directory called Heidi for the
purpose). Otherwise, if you are not using Workbench, copy starta3.t to
your new Heidi directory and rename it heidi.t.  
  
Now open the file in your text editor of choice (either through
Workbench or through the editor) and remove the definition of startroom,
i.e. the lines that read:  

[TABLE]

|     |     |
|-----|-----|
|     |     |

startRoom: Room 'Start Room'  
    "This is the starting room. "  
;  
  
Next, change the line location = startRoom (after the comment
/\* the initial location \*/) so that it reads
location = outsideCottage. You might also like to fill in the other
fields with something a bit more meaningful, so that the edited file
looks something like:  
  
  
\#charset "us-ascii"  
\#include \<adv3.h\>  
\#include \<en_us.h\>  
  
versionInfo: GameID  
IFID = '573a8b18-1008-ca66-9580-9a156f82eefa'  
    name = 'The Further Adventures of Heidi'  
    byline = 'by An Author'  
    htmlByline = 'by \<a href="mailto:whatever@nospam.org"\>  
                  ERIC EVE\</a\>'  
    version = '1.0'  
    authorEmail = 'ERIC EVE \<whatever@nospam.org\>'  
    desc = 'This is an unexciting tutorial game based loosely on  
       The Adventures of Heidi by Roger Firth and Sonja Kesserich.'  
    htmlDesc = 'This is an unexciting tutorial game based loosely on  
       \<i\>The Adventures of Heidi\</i\> by Roger Firth and Sonja Kesserich.'  
  
    showCredit()  
    {  
        /\* show our credits \*/  
        "The TADS 3 language and library were created by Michael J.   

[TABLE]

|     |     |
|-----|-----|
|     |     |

        The original \<i\>Adventures of Heidi\</i\> was a simple tutorial game   

[TABLE]

|     |     |
|-----|-----|
|     |     |

  
        
        "\b";  
    }  
    showAbout()  
    {  
        "\<i\>The Further Adventures of Heidi\</i\>\<.p\>  
        A Tutorial Game for TADS 3";  
    }  
;  
  
me: Actor  
    /\* the initial location \*/  
    location = outsideCottage  
;  
  
gameMain: GameMainDef  
     initialPlayerChar = me  
     showIntro()  
     {  
       "Welcome to the Further Adventures of Heidi!\b";  
     }  
     showGoodbye()  
     {  
       "\<.p\>Thanks for playing!\b";  
     }  
     maxScore = 7       
     beforeRunsBeforeCheck = nil       
;  
  

------------------------------------------------------------------------

*Getting Started in TADS 3*  
[\[Main\]](index.html)  
*[\[Previous\]](makingtheitemsdosomething.htm)
  [\[Next\]](definingourfirstroom.htm)*
