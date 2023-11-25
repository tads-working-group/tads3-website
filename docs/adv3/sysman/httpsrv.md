::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> HTTPServer\
[[*Prev:* HTTPRequest](httpreq.htm){.nav}     [*Next:*
IntrinsicClass](icic.htm){.nav}     ]{.navnp}
:::

::: main
# HTTPServer

The HTTPServer intrinsic class implements an HTTP network server. HTTP
is the protocol that Web browsers use to communicate with Web sites, so
this class lets you write a TADS program that can be accessed via a Web
browser, which in turn lets you use a Web browser as the user interface
for your game. It also makes it possible to create a multi-user
applications with TADS, since the server is designed to handle multiple
simultaneous connections.

## Headers and library files

To use the HTTPServer class, you must [#include \<httpsrv.h\>]{.code} in
your program. In addition, we recommend that you add the library file
[tadsnet.t]{.code} to your build (by adding it to your project .t3m
file), since this file defines some helper classes often used with
HTTPServer.

## Starting a server

Setting up a Web server is easy: you simply create an HTTPServer object,
specifying the network address that clients use to connect. Once you
create the HTTPServer object, it runs autonomously, handling network
connections in the background while your program runs.

The constructor looks like this:

::: code
    local server = new HTTPServer(hostname, port, uploadLimit);
:::

The *hostname* argument gives the network address of the server. This is
the address on which the server will accept incoming connections, so
it\'s the address that clients will use to connect to the server. The
*port* is an optional integer value giving the port number where the
server will listen for connections. *port* can be omitted entirely, or
given as [nil]{.code}, which means that you want the operating system to
select a port number for you. We\'ll go into more detail on the host
name and port number below.

*uploadLimit* is an optional size limit, in bytes, for each uploaded
request body. If this is [nil]{.code} or is omitted, there\'s no size
limit. Some HTTP requests can include uploaded content; for example, a
POST request includes a message body that describes the HTML form data
being posted, and can also include uploaded file attachments. The
protocol itself doesn\'t have any limit to these uploaded messages, so
if you don\'t set a limit via this argument, the client will be able to
upload arbitrarily large objects. Uploads consume memory and disk space
on the server, so it\'s a good idea to set a size limit when possible,
to prevent errant or malicious clients from overwhelming the server with
very large uploads.

If the server is started successfully, the [new]{.code} operator returns
a new HTTPServer object representing the server. If an error occurs, it
throws a [NetException]{.code} error.

### Selecting the address and port number

The host name and port number determine the network address where your
server will accept connections.

For the standard TADS Web UI setup, simply use
[[getLaunchHostAddr()]{.code}](tadsnet.htm#getLaunchHostAddr) as the
host name and [nil]{.code} as the port number. This creates a listener
on a free port on the same address that the client used to connect to
the external Web server that launched the program, or simply on
\"localhost\" if the user launched the program locally as a stand-alone
application. We know that this address is reachable from the client
because the client had to connect to it to trigger the program launch in
the first place.

If you\'re creating some other kind of application rather than using the
TADS Web UI conventions, you might have reasons to choose some other
host address and port number.

The host name can be given either as the human-readable name for the
computer, or as a decimal IP address, in the form \'1.2.3.4\'. The host
name for the server must always be a name or address that\'s associated
with the *same machine* where the program is running: in other words,
you can\'t run the program on one machine and start the server on
another machine just by entering the other machine\'s address. The name
or address must also *already* be configured in the operating system:
you can\'t create new host names for the computer just by starting a
server on an invented name.

Given all these restrictions, it might seem redundant to make you
specify the host name. After all, if you can only use an existing,
pre-configured name, why can\'t the system just look up that
pre-configured name for you? The reason is that there might be more than
one valid host name and address. The host address isn\'t actually
associated with the computer itself; it\'s associated with a network
adapter, which is the hardware that physically connects the computer to
the network. Most modern computers can handle multiple network adapters
at once; each adapter has its own network address, so a computer with
multiple adapters attached will have multiple network addresses. So the
reason that HTTPServer makes you specify the host address is that doing
so gives you control over which address to use when multiple adapters
are present.

There are three main ways of selecting a custom host address:

-   You can use the default name or IP address for the computer, as
    configured in the operating system. This is the most common case,
    because most computers only have one network address, meaning
    there\'s only the one address to choose from anyway. You can get the
    default host name with the
    [[getHostName()]{.code}](tadsnet.htm#getHostName) function. You can
    also get the default IP address with the
    [[getLocalIP()]{.code}](tadsnet.htm#getHostName) function.
-   In some cases, you\'ll only want the program to accept *local*
    connections - that is, clients running on the same machine. You
    might want to do this for testing purposes, or if you\'re setting up
    the program as a local service only and you don\'t want external
    clients to connect for security reasons. In this case, you can use
    [nil]{.code} or [\'localhost\']{.code} as the host name. The only
    connections possible will be from the local machine, connecting to
    the address \"http://localhost:*port*/\".
-   If you\'re running your program on a big network server that has
    multiple network adapters, you might actually want to run a separate
    server on each adapter, or at least choose the suitable adapter for
    this particular server. In this case, you\'ll want to manually
    configure your program. One way of doing this is to specifically
    write the program for a particular host, in which case you\'d just
    hard-code the host name right into the [new HTTPServer()]{.code}
    call. More likely, though, you\'d set up the program to get the host
    name from some external source, such as the command-line parameters
    or an external configuration file. This scenario is only for
    sophisticated users, obviously, so we\'ll assume you can figure it
    out on your own if this applies to you.

The port number is how the networking system tells apart different
servers running on the same computer. Each server has its own port
number: a given port can only be used by only one server at a time.

From the client\'s perspective, the port number is part of the HTTP URL.
For example, to connect to port 9155 on IP address 1.2.3.4, you\'d enter
the URL \"http://1.2.3.4:9155/\". You probably haven\'t that \":port\"
portion very often in everyday Web browsing, because most ordinary Web
servers run on the standard HTTP port, port 80. When you don\'t include
a \":port\" element in the address, the browser simply assumes \":80\"
by default.

There are two ways to select a port number. One is to use a \"well
known\" port. With this approach, you select the port number in advance,
when you write your program, choosing a number in the range 0 to 1023.
You can then tell users that to connect to your server, they will always
use that number you select. The difficulty of this approach is that a
given port number can only be used by one server at a time on a given
machine, so if you choose a port that some other program happens to be
using, one or the other program won\'t be able to use the port. You can
reduce the chances of this by consulting a list of commonly used ports
(for example, see the [Wikipedia
list](http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers))
and choosing an unused port - but there\'s still no guarantee, because
these lists obviously only include prominent, widely-used software.

The other approach is to let the operating system assign an available
port, by specifying [nil]{.code} as the *port* parameter. This
guarantees that you\'ll get a port, because the OS will always choose an
available port. The complication is that the port number will be
different each time you run your program, because the OS assigns port
numbers arbitrarily. This means that you can\'t just tell your users in
advance which port to use: you\'ll need some way to communicate the port
number to users each time you run the server program.

### Handling server requests

The [HTTPServer]{.code} object handles all of the low-level networking
details automatically for you, running in separate background threads.
However, your program has full control over the high-level services
provided by the server. This means that it\'s up to you to respond to
each client request.

HTTP is a simple protocol in which clients connect to the server and
send requests; the server answers each request with a reply. Each
request/reply pair is essentially a stand-alone unit of conversation.

The [HTTPServer]{.code} object handles each incoming request by creating
an [[HTTPRequest]{.code}](httpreq.htm) object, and placing this in the
network event queue. Your program receives these by calling the
[getNetEvent()](tadsnet.htm#getNetEvent) function, which waits for and
returns the next network event. The [HTTPRequest]{.code} object provides
methods that let you retrieve the request information and send the
reply. The basic structure of a TADS program that serves HTTP requests
is as follows:

::: code
    #include <tads.h>
    #include <tadsnet.h>
    #include <httpsrv.h>
    #include <httpreq.h>

    main(args)
    {
        // start the server
        local server = new HTTPServer(getLocalIP(), nil);
        "HTTP Server listening on port <<server.getPortNum()>>\n";

        // process requests
        for (;;)
        {
            local evt = getNetEvent();
            if (evt.evType == NetEvRequest && evt.evRequest.ofKind(HTTPRequest))
            {
                // send the reply
                evt.evRequest.sendReply('It worked! You asked for <<
                   evt.evRequest.getQuery()>>.', 'text/plain', 200);
            }
        }

        // shut down the server
        server.shutdown();
    }
:::

This is obviously missing a few things you\'d want in a real server (it
doesn\'t have any error handling, for example), but it will actually
work as written. You can type it in and run it, and it\'ll serve pages
to your browser. To expand this into a real server, you\'d add code to
inspect the request parameters to determine what the client is asking
for, process the request accordingly, and send a suitable reply. You\'d
also want to add some error handling so that the server doesn\'t abort
at the first lost network connection. (HTTP is by design a stateless
protocol, so dropped connections are common, and shouldn\'t faze a
server.)

As you can see, the design makes it quite easy to write the skeleton of
a server, while providing you with essentially unlimited flexibility.
The TADS infrastructure doesn\'t make any assumptions about what the
client will request or what the reply will look like - that\'s all up to
you.

## HTTPServer methods

[getAddress()]{.code}

::: fdef
Returns a string giving the original binding address specified when the
object was constructed. This is the address on which the server is
listening for incoming connection requests from clients. This returns
the same format originally specified in the constructor, which can be
either a host name or a numeric IP address. Returns [nil]{.code} if no
address is available.
:::

[getIPAddress()]{.code}

::: fdef
Returns a string giving the numeric IP address on which the server is
listening for connections. This is in the usual decimal format, as in
\'127.0.0.1\'. Returns [nil]{.code} if no address is available.
:::

[getPortNum()]{.code}

::: fdef
Returns an integer giving the port number on which the server is
listening.
:::

[shutdown(*wait*?)]{.code}

::: fdef
Shuts down the server. This closes the network port on which the server
listens for connections, terminates the listener thread, and terminates
any session threads that the server launched.

If *wait* is [true]{.code}, the method doesn\'t return until all of the
server threads have exited. This ensures that you can immediately reuse
the server\'s port number with a new server object. If you omit *wait*
specify [nil]{.code}, the method signals the server to shut down, but
then returns immediately, allowing the the server to carry out its
termination in the background. You can use this option if you won\'t
need to reuse the port number.

Calling the [shutdown()]{.code} method is optional. If your program
simply exits, the system will automatically shut down any servers that
are still active.
:::

## Save, restore, undo

HTTPServer objects are inherently [transient](objdef.htm#transient).
This is because they\'re associated with live operating system resources
(threads and network sockets) that can\'t be saved in a file. This means
that any object properties that refer to HTTPServer objects will be
[nil]{.code} when you restore a previously saved session. Also,
HTTPServer objects are not affected by Undo operations.

## Automatic shutdown

HTTPServer objects work like any others with respect to garbage
collection: if an HTTPServer object becomes unreachable, the system will
delete it during the next garbage collection pass. When this happens,
the object automatically shuts down the listener and any session threads
started by the server. This means that you have to ensure that each
HTTPServer instance remains reachable for as long as you want the server
to continue running. You can accomplish this by storing a reference to
the HTTPServer object in a named object\'s property, for example.

If the server has posted any requests to the network event queue, and
the garbage collector deletes the server object after those events have
been posted but before you retrieve them via [getNetEvent()]{.code}, the
events will *not* be deleted from the queue - they\'ll be returned as
normal from [getNetEvent()]{.code}. If you use the [getServer()]{.code}
method on one of these request objects, it will return [nil]{.code},
since the server object no longer exists. If you send a response to the
request, it will fail with a network exception.

## Network safety levels

The VM enforces a user-specified security setting called the \"network
safety level\". The user interface for setting the level varies by
interpreter; for command-line interpreters, for example, it\'s
controlled by the [-ns]{.code} option when starting the program.

The HTTPServer class is subject to the \"server\" component of the
network safety level. The VM enforces the safety level when you attempt
to create an HTTPServer object with operator [new]{.code}. If the safety
level doesn\'t allow the type of server you\'re trying to create, the
[new]{.code} operator throws a NetSafetyException instead of creating
the HTTPServer object.

When the server component of the net safety level is set to 0 (\"minimum
safety\"), network access is unrestricted. When the safety level is 1,
an HTTPServer can only be created if the host name is \"localhost\" or
\"127.0.0.1\"; in other words, the server can only be created with local
access, from applications on the same machine only. Higher safety levels
prohibit creating an HTTPServer at all.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> HTTPServer\
[[*Prev:* HTTPRequest](httpreq.htm){.nav}     [*Next:*
IntrinsicClass](icic.htm){.nav}     ]{.navnp}
:::
