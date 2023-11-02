{% highlight javascript %}
#charset "us-ascii"
#include <tads.h>
#include "advlite.h"

gameMain: GameMainDef
    initialPlayerChar = me
;

versionInfo: GameID
    // This will vary per game, and
    // is automatically generated.
    // For more info: https://www.tads.org/ifidgen/ifidgen
    IFID = '6ea612f2-758e-46d3-a8b5-5b7c21089b5d'

    // Your game name goes here.
    //     e.g. 'Mary Smith'
    name = ''

    // Your name goes here.
    //     e.g. 'by Mary Smith'
    byline = 'by '

    // Your email name goes here.
    //     e.g. 'by <a href="mailto:marysmith@address.com">
    //                  Mary Smith
    //              </a>'
    htmlByline = 'by <a href="mailto:yourmail@address.com"></a>'

    // Your game version number goes here.
    version = '1'

    // Your email address goes here.
    //     e.g. ' marysmith@address.com'
    authorEmail = ' yourmail@address.com'

    // A plain-text description of your game goes here.
    //     e.g. 'A quickstart game. '
    desc = ''

    // An html-styled description of your game goes here.
    //     e.g. 'A <b>quickstart</b> game. '
    htmlDesc = ''
;

startRoom: Room 'startRoom'
    ""
;

+me: Actor
    person = 2
;
{% endhighlight %}