![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \> Input
Scripts  
[*Prev:* Network Safety](netsec.htm)     [*Next:* Byte
Packing](pack.htm)    

# Input Scripts

The TADS Interpreter normally reads its input directly from the
computer's human input devices - primarily the keyboard, but sometimes
also the mouse, if one is present and the local Interpreter supports it.

Sometimes, though, it's useful to be able to read from a previously
prepared list of inputs rather than from the user. One situation where
this is helpful is during development: you can use a script to enter all
of the commands needed to reach the part of the game you're actively
working on, saving you the trouble of re-entering those commands
manually every time you start a new test run after making changes.
Another situation is testing: you can use a script to run through the
game to make sure that it produces the correct output.

The Interpreter provides "script" files for this purpose. A script file
is simply a text file with a list of command inputs. When you tell the
Interpreter to read from a script file, it reads the commands from the
file, and returns them to the game as though they were coming directly
from the keyboard. The game doesn't know the difference; as far as the
game is concerned, the user is typing the commands.

## Replaying a script

There are two way to replay a script: via the interpreter command line,
or through a call to the setScriptFile() function.

### Replaying via the interpreter command line

You can start reading a script immediately when you start the game by
using the Interpreter's -i option. Refer to [Running Programs](terp.htm)
for information on this option.

The Interpreter -i option causes the game to read from the script
starting with the very first command line. On operating systems with
"batch" or "command script" features, this lets you create automated
processes, such as test suites, that run without any user intervention.

### Replaying via setScriptFile()

The intrinsic function setScriptFile() lets you start reading from a
script under program control. Refer to [the tads-io Function
Set](tadsio.htm) for details on this function.

The adv3 library uses setScriptFile() to implement the REPLAY command,
which you can use to invoke a script from the game's command prompt.

## Recording a script

The Interpreter has a couple of features that let you record a session
as you play through a game manually. The interpreter creates a file
containing the commands and events you enter as you play.

To create a script from an entire session, use the Interpreter's -o
option. This causes the Interpreter to write events throughout the
session to the file. See [Running Programs](terp.htm) for details on
Interpreter options.

If your game is based on the adv3 library, you can use the RECORD
command to record a script. This command starts recording events
starting with the next command line.

You can also start recording a script under program control, using the
setLogFile() function with the LogTypeCommand or LogTypeEvent type
codes. LogTypeCommand creates a Command-line script, and LogTypeEvent
creates an Event script (see below). The adv3 RECORD command uses this
function internally.

## Script file structure

This section explains how to create a script file manually. In most
cases, you'll probably want to create your script files using one of the
"recording" features (such as the -o Interpreter option, or the adv3
RECORD command), but you might sometimes want to create a script file on
your own, or edit a script you recorded.

There are two kinds of script files: Command-line scripts and Event
scripts. Interpreters prior to 3.0.13 only support Command-line scripts;
3.0.13 and later versions support both kinds of script.

### Command-line scripts

A command-line script contains regular input lines. This means that when
the Interpreter is reading from a command-line script, it must still
pause for user input, directly from the keyboard or mouse, whenever the
game attempts to read any other kind of input event - inputEvent(),
inputDialog(), inputFile(), and so on.

Each line of a command-line script is either a comment or an input line.

An input line starts with a \> character (a greater-than sign) as its
very first character; the rest of the line is the text of the input. The
interpreter reads the line and returns it to the game as though the user
had typed it at the keyboard and pressed Enter.

Any line that doesn't start with \> is a comment line. The interpreter
simply ignores these lines.

Here's a sample Command-line script.

    This is a comment, since it doesn't start with ">"

    >look
    >inventory
    >quit
    >yes

### Event script

Unlike a Command-line script, an Event script can contain any type of
input event that the game can read. This means that an Event script can
run without any user input.

Event scripts are supported only in version 3.0.13 and later of the
Interpreter.

An event script is identified with this text as its very first line:

    <eventscript>

When the Interpreter starts reading a script, it checks the first line
to see if it contains this text. If so, it treats it as an Event script;
if not, it treats the script as a regular Command-line script.

After the initial \<eventscript\> line, the rest of the file contains
event lines and comment lines. An event line starts with an event type
tag; everything else is a comment line. The Interpreter ignores comment
lines.

An "event tag" is one of the following:

- \<line\> - a command line input event. The rest of the line is the
  text of the line input. This type of event is returned by inputLine()
  and inputLineTimeout(); all other input functions ignore (and skip)
  these events.
- \<endqs\> - a quiet script ending event. This type of event is
  returned by inputLine() and inputLineTimeout(); other input functions
  ignore (and skip) these events.
- \<key\> - a keyboard key event. The rest of the line is the key name.
  The key names are exactly as returned from inputKey(), **except** that
  the keys that inputKey() returns as ASCII control codes are
  represented as \[ctrl-x\] characters: '\n' (newline) represented as
  \[enter\], '\t' (tab) is represented as \[tab\], and ' '(space) as
  \[space\]. This type of event is returned by inputKey() and
  inputEvent(); all other input functions ignore (and skip) these
  events.
- \<dialog\> - a dialog button event. The rest of the line is a number
  giving the index of the button pressed in a dialog. This is returned
  by inputDialog(); other input functions ignore (and skip) these
  events.
- \<file\> - a file dialog event. The rest of the line is the name of
  the file selected, or is empty is the dialog was canceled. This is
  returned by inputFile(); other input functions ignore (and skip) these
  events.
- \<href\> - a hyperlink click event. The rest of the line is the HREF
  value for the hyperlink. This is returned by inputEvent() only; all
  other input functions ignore (and skip) these events.
- \<timeout\> - a timeout event. This indicates that a call to
  inputEvent() or inputLineTimeout() terminated with a timeout. The rest
  of the line is the text of the partial input line that was entered
  before the timeout occurred; this is used only in inputLineTimeout().
  This type of event is returned by inputLineTimeout() and inputEvent();
  all other input function ignore (and skip) these events.
- \<notimeout\> - a timeout-not-available error event. This can be
  returned from inputLineTimeout() and inputEvent(); other functions
  ignore (and skip) these events.
- \<eof\> - an end-of-file error event. This can be returned from most
  of the input functions. Note that this is *not* an indication that the
  script file has ended, so this isn't necessary as the last entry in a
  script; rather, this indicates that an end-of-file error occurred
  reading from the actual user interface when the script was recorded.
  An end-of-file error usually means that the user closed the
  Interpreter window before quitting the game, or disconnected or closed
  a terminal session.

Here's a sample Event script.

    <eventscript>
    <line>look
    <line>inventory
    <line>save
    <file>test.t3v
    <line>help
    <key>[down]
    <key>[enter]
    <key>[esc]
    <line>quit
    <line>y

## Overwrite warnings in \<file\> events

When inputFile() reads a \<file\> event from a script, the function
checks the following conditions:

- the file named in the event already exists
- the *dialogType* parameter to inputFile() is InFileSave
- the \<file\> element does not include the "overwrite" attribute

If all of these conditions are true, then inputFile() momentarily
suspends the script playback and displays a warning dialog to the user.
This dialog is displayed interactively, even though a script is being
played back, and the user must respond before script playback can
continue.

The dialog warns that the script might be about to overwrite the named
file, and asks if you'd like to proceed. You have three options: Yes,
No, or Cancel:

- If you select Yes, the script playback will continue as-is, and the
  filename read from the script will be returned to the game, which
  might then overwrite the file.
- If you select No, the Interpreter will display an interactive file
  selector dialog, allowing you to select a different filename. If you
  enter another filename, script playback will continue, using the new
  filename you entered in place of the one read from the script. If you
  cancel the file dialog, script playback will be canceled immediately,
  with no further events played back, and the game will return to
  interactive play. The inputFile() function will return a Cancel result
  code to the game.
- If you select Cancel, script playback will be canceled immediately,
  with no further events played back, and the game will return to
  interactive play. The inputFile() function will return a Cancel result
  code to the game.

The reason for this extra interactive prompt is to prevent script
playback from overwriting a file without the user's knowledge or
consent. The whole point of script playback is to reproduce the same
sequence of events repeatedly, but this can be problematic when one of
the events supplies a filename that's then used to create a new file: if
the script is run more than once, the file will be created anew on each
subsequent run, overwriting any data written to the file on previous
runs.

In some cases, you might want to skip the interactive prompt, but still
overwrite any existing copy of the file. This is especially likely if
you're using a script for automated testing. In such a case, you
probably specifically designed the test to create the same output file
on each run, so you specifically intend for the test to overwrite the
file each time; and you want the test to run automatically, with no user
intervention. In such a case, you can put instructions directly in the
script that the overwrite is to proceed without a prompt. To do this,
edit the script file, and add the "overwrite" attribute to the \<file\>
element:

    <file overwrite>myfile.txt

This tells the script reader that you explicitly intend to overwrite the
file on each run, so no interactive prompt is necessary. Note that
adding the "overwrite" attribute doesn't *require* the file to exist -
it merely suppresses the warning if it does.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \> Input
Scripts  
[*Prev:* Network Safety](netsec.htm)     [*Next:* Byte
Packing](pack.htm)    
