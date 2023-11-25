::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [Playing on the
Web](web.htm){.nav} \> Deploying your Web UI game\
[[*Prev:* The Web UI](webui.htm){.nav}     [*Next:* Setting up a custom
TADS Web server](webhost.htm){.nav}     ]{.navnp}
:::

::: main
# Deploying your Web UI game

When you build a TADS game with the Web UI library, there are two ways
for players to run the game: client/server, or stand-alone.

Client/server mode means that the game runs on an Internet server, and
the player accesses the game through an ordinary Web browser. This setup
is ideal for players who don\'t want to install any software, since
there\'s no need to download your game or install TADS; the player
simply clicks a hyperlink and the game loads in the browser.

Stand-alone mode works just like traditional TADS games: the player
installs the TADS interpreter, downloads your game, and runs the game
with the interpreter. This isn\'t anything separate you have to program;
it\'s handled automatically by the interpreter. When a player launches
your Web UI game locally, the interpreter automatically opens a browser
window and sets up a virtual network connection. As far as your game is
concerned, it\'s running as a network server, just as it would in true
client/server mode; but from the player\'s perspective, everything looks
and acts like a traditional downloaded TADS game.

There are trade-offs to each mode. Client/server mode requires a network
connection throughout the game session, since the game logic runs on the
server; it also tends to be a bit slower, since each command input
requires information to be sent back and forth across the Internet.
Local mode doesn\'t require a network connection during play, and it\'s
not affected by network delays; but it\'s more work for players to set
up, since they have to download both your game and the TADS interpreter.

## Deploying for client/server play

There are two options for client/server deployment.

First, you can use the public TADS server network. This is a collection
of servers set up by volunteers to run any TADS Web UI games. Deploying
with the public server network is simple: you upload your .t3 file to
the [IF Archive](http://www.ifarchive.org), and create an
[IFDB](http://ifdb.tads.org) page for it. Add a link from the IFDB page
to the IF Archive upload, marking it as a TADS 3 Web UI game. The IFDB
page will automatically display a \"play online\" button; players click
the button, and IFDB will automatically find an available public server
and launch the game.

Second, you can set up your own server specifically for your game. This
gives you full control over the server, but it\'s much more
complicated - it requires that you have your own Web server, and it
involves some software installation and configuration. The details are
covered [here](webhost.htm).

## Publishing for stand-alone play

To make your game available to players for stand-alone play, you simply
publish it the same way you publish a traditional TADS game. This
usually means uploading your .t3 file to a site such as the [IF
Archive](http://www.ifarchive.org), or, if you have a personal Web site,
posting it on your site.

## Saving games in the \"cloud\"

TADS games sometimes access external data files. The most common use for
external files is to save and restore game positions. Most games also
allow for transcript files, and some games use files for special
purposes, such as saving information that persists across multiple
sessions.

The traditional place to store all of these files was simply on the
local computer\'s hard disk. For client/server play, though, this isn\'t
suitable. We don\'t want to store files on the client computer (the
player\'s machine, where the Web browser is running), because this would
somewhat defeat one of the nicer features of Web play, which is that you
can play from any computer. If we stored saved games on the client
machine, the player couldn\'t later resume playing on another machine.
And even if we wanted to store them on the client, we really can\'t:
browsers don\'t allow servers to store arbitrary data on a client
computer, largely for security reasons, since this would make clients
too vulnerable to viruses and other malicious software.

At first glance, then, it might seem better to store saved games on the
server. But this isn\'t ideal either. First, if you\'re using the public
TADS server network, each session might run on a different server - so
if we saved files on the server, the user wouldn\'t be able to find them
again if they resumed play and happened to be assigned to a different
server. Second, even if the server were always the same, we have the
complication that the same server will be accessed by multiple users. If
we stored saved games on the server, there\'d be a jumble of files from
different players, making it difficult for each player to find their own
files. The obvious solution would be to ask users to identify
themselves, by logging in with a username and password, but this is
probably asking too much - people are already burdened with remembering
so many login details as it is that they\'d probably be quite cross with
us if we asked them to create yet another password for each new game
they want to play.

What we really want to do is store files in the \"cloud\" - somewhere on
the Internet that\'s accessible from anywhere, and where you can always
find something you saved earlier, even if you\'ve switched to another
browser device.

### [IFDB storage server]{#storageServer}

The solution we\'ve come up with is to set up a separate network server
just for file storage. This \"storage server\" is separate from the game
servers, and most importantly, there\'s just one - we always know where
to find a file, since there\'s only one place to look. (You might wonder
why we need many game servers but can make do with one storage server.
The difference is resource usage. File storage requires very little
computing power, whereas game execution requires a fairly hefty amount
of memory and CPU time. The only practical way to allow for a large
number of concurrent players is to spread the users across multiple
execution servers. In contrast, a single file server should be
sufficient for a large number of concurrent players.)

There\'s still the problem of how to tell each player\'s files apart
from those of other players. As we said earlier, the only good approach
is to require users to log in. We felt this was too much to ask on a
game-by-game basis; but with a single, centralized storage server, it
becomes a much more reasonable proposition. To make it even more
palatable to users, the TADS storage server is set up as part of IFDB,
so players simply use their existing IFDB credentials. Many people
interested in IF already have IFDB accounts; for players new to IFDB,
it\'s fairly painless to create an account, since it\'s free and
doesn\'t require divulging any personal information.

#### Connecting to the storage server

To use the IFDB storage server, the user must launch the game through
IFDB. The IFDB page for a TADS game with a Web UI will offer a \"Play
Online\" link; the user can launch the game by going to the game\'s IFDB
page and clicking this link. Alternatively, you can set up a direct link
from your own Web site to the IFDB launch page, following this template:

::: code
    <a href="http://ifdb.tads.org/t3run?id=TUID&storyfile=FILENAME">Play Online</a>
:::

In the HREF string above, replace **TUID** with your game\'s IFDB TUID -
you can find this information in the \"Details\" section of the game\'s
IFDB page. (If you haven\'t already created an IFDB page for the game,
you\'ll need to create one before you can use the storage server
system.) Replace **FILE** with the name of your .t3 file on the IF
Archive - you only need the filename portion, since the server will
assume it\'s on the IF Archive in the games/tads section. For example:

::: code
    <a href="http://ifdb.tads.org/t3run?id=sicva377zqygxcq2&storyfile=return-to-ditch-day.t3">Play Online</a>
:::

Upon reaching the \"Play Online\" page, if the user isn\'t already
logged in, IFDB displays a login screen. The user can enter her
credentials, or can opt to play without logging in. In the latter case,
the storage server won\'t be used, since all files on the storage server
are per-user.

When the user launches the game using this procedure, the storage server
creates a \"session\" that\'s specific to the game and the user, and
generates an identifying key for the session. The key is essentially a
temporary password that applies only to the particular game and user,
and only for the duration of the current session. IFDB passes the key to
the TADS interpreter. The interpreter then uses the key to perform file
operations on the storage server.

#### Saving and restoring games

The [saveGame()](tadsgen.htm#saveGame) and
[restoreGame()](tadsgen.htm#restoreGame) functions automatically use the
storage server session information that IFDB passes to the interpreter
upon launch. This is transparent to your game; you don\'t have to do
anything different.

#### Log files

The [setLogFile()](tadsio.htm#setLogFile),
[setScriptFile()](tadsio.htm#setScriptFile), and
[logConsoleCreate()](tadsio.htm#logConsoleCreate) automatically use the
storage server session information, transparently to your game.

#### File objects

The [File](file.htm) intrinsic class automatically uses the storage
server session information to manage files. When you open a file, the
File class communicates with the storage server to read or write the
file data.

#### inputFile dialog

You shouldn\'t use the inputFile() function directly in a Web UI game,
since this function isn\'t aware of the storage server. Instead, always
use the Adv3 equivalent, inputManager.getInputFile(). When a storage
server is in use, this method instructs the browser to display a dialog
managed by the storage server itself. This dialog allows the user to
select files on the server, and communicates the selection information
back to your game program as though the ordinary inputFile() function
had been used.

### Running without a storage server

If the user opts not to log in to IFDB, they can still play the game,
but they won\'t be able to take advantage of \"cloud\" storage. Instead,
the Web UI library will fall back on local storage on the user\'s PC.

When the user saves a game or creates a log file, the game will
initially store the data in a temporary file on the server. It will then
send the file to the user\'s PC as a download. Most browsers will
respond by displaying a file selector dialog so that the user can
specify where to store the downloaded data. This satisfies the security
restrictions imposed by the browsers, to guard against sites attempting
to download files without the user\'s knowledge. It also happens to be
almost identical to the workflow for saving games in the traditional
interpreter, so users should find the process readily intuitive.

When the user enters a RESTORE command to load a game, the server
displays dynamic HTML that prompts the user to select a file for upload.
Most browsers will display a button that the user can click to select a
file via a file selector dialog; some will open a file selector dialog
directly. In any case, assuming the user selects a file through the
dialog, the browser uploads the file to the server, and the server
captures the upload as a temporary file. It then performs the RESTORE
operation using the temporary file. As with SAVE, the process is very
similar to the equivalent workflow in the traditional interpreter.

Using File objects without a storage server works like SAVE and RESTORE.
When you open a file for reading, the browser interactively asks the
user to select a file for upload. When you close a writable file, the
browser prompts the user to save a downloaded file. This behavior is
different from the traditional interpreter, which performs File object
read/write operations without involving the user. The interactive
prompting is required due to browser security restrictions; browsers
don\'t allow remote Web servers to read or write client-side files
silently, since this would allow malicious sites to read your private
files and/or download potentially dangerous files without your knowledge
or consent. Because of this cumbersome user interaction procedure, it\'s
probably best to avoid using File objects in Web UI games as much as
possible. If you really need to use File objects, you should at least
warn the player that logging in to IFDB is strongly recommended; you can
determine if a storage server session is in use by checking
webSession.storageSID. Alternatively, if you\'re using File objects for
temporary storage only, you can use [TemporaryFile](tempfile.htm)
objects to create server-side temporary files without any user
interaction.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [Playing on the
Web](web.htm){.nav} \> Deploying your Web UI game\
[[*Prev:* The Web UI](webui.htm){.nav}     [*Next:* Setting up a custom
TADS Web server](webhost.htm){.nav}     ]{.navnp}
:::
