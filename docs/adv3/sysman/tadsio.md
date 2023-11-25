::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> tads-io Function Set\
[[*Prev:* Regular Expressions](regex.htm){.nav}     [*Next:* tads-net
Function Set](tadsnet.htm){.nav}     ]{.navnp}
:::

::: main
# tads-io Function Set

The tads-io function set provides access to the user interface provided
by the TADS 3 Interpreter host applications, as well as file
input/output functions. The tads-io function set is available only in T3
implementations that are hosted within a TADS 3 Interpreter environment,
so a program that uses this function set will only run in a TADS
Interpreter.

The tads-io function set is separate from the tads-gen function set to
allow programmers to choose an alternative input/output and user
interface function set, if desired, while still using the more general
tads-gen functions. Most programs will probably want to use the tads-gen
set because of the many data conversion and manipulation functions it
contains, even if they\'re using an alternative user interface.

To use this set of functions in your program, [#include
\<tadsio.h\>]{.code}, or simply [#include \<tads.h\>]{.code} (which
includes both [\<tadsio.h\>]{.code} and [\<tadsgen.h\>]{.code}, for the
full set of TADS intrinsics). If you\'re using the adv3 library, you can
simply [#include \<adv3.h\>]{.code}, since that automatically includes
the basic system headers.

## Banner API

The tads-io function set incorporates a set of functions known as the
Banner API. These functions let you divide the interpreter\'s
application window into several independent subwindows. The adv3 library
uses this to implement a number of special UI effects, including the
standard adventure game \"status line\" feature.

Using the Banner API requires some knowledge of the underlying display
model, which is described in detail in the [Banner Model](banners.htm)
section.

## tads-io functions

[bannerClear(*handle*)]{.code}

::: fdef
Clears the banner\'s display. Removes all text from the banner, and
moves the output position back to the upper left corner of the banner\'s
window.
:::

[bannerCreate(*parent*, *where*, *other*, *windowType*, *align*, *size*,
*sizeUnits*, *style*)]{.code}

::: fdef
Creates a new banner window with the given parameters.

*parent* is the handle of an existing banner that is to serve as the
parent of the new banner, or [nil]{.code} if the new banner is to be a
child of the main game window. The new banner\'s space is obtained by
splitting the parent window.

*where* and *other* together indicate where the banner goes in the
parent\'s list of children, which determines how the new banner is laid
out relative to the other children of the same parent (see the screen
Layout overview above). *where* can be one of the following values:

-   [BannerFirst]{.code} - indicates that the new banner is the first
    child of *parent*. *other* is not used in this case.
-   [BannerLast]{.code} - indicates that the new banner is the last
    child of *parent*. *other* is not used.
-   [BannerBefore]{.code} - indicates that the new banner should be
    inserted into the child list immediately before *other*, which must
    be the handle of an existing child of *parent*.
-   [BannerAfter]{.code} - indicates that the new banner should be
    inserted into the child list immediately after *other*, which must
    be the handle of an existing child of *parent*.

Note that the child list order specified via where and other is not
permanent; it merely determines where the new banner goes in the current
child list of the given parent. For example, specifying
[BannerFirst]{.code} does not mean that the banner will remain the first
child forever; it merely puts it at the start of the current list. If
banner A is created with [BannerFirst]{.code} specified, and later
banner B is created with [BannerFirst]{.code}, banner A will become the
second child after B.

If [BannerBefore]{.code} or [BannerAfter]{.code} is specified, and
*other* is not a valid banner handle or is not a child of the given
parent, then the system ignores *where* and *other* and inserts the
banner as the last child of the parent, as though [BannerLast]{.code}
had been specified.

The *windowType* parameter indicates the type of banner to create; this
is one of the following (see \"Banner Types\" above for more
information):

-   [BannerTypeText]{.code} - an ordinary text window. This type of
    window behaves essentially the same way as the main game window; in
    particular, it interprets HTML to the same extent that the main game
    window does.
-   [BannerTypeTextGrid]{.code} - a \"text grid\" window, which
    simulates a character-mode terminal window by displaying a
    rectangular array of characters.

The *align* value indicates how the banner\'s space is carved out of its
parent\'s space. This can have one of the following values:

-   [BannerAlignTop]{.code} - the banner goes at the top of the
    parent\'s space
-   [BannerAlignBottom]{.code} - the banner goes at the bottom of the
    parent\'s space
-   [BannerAlignLeft]{.code} - the banner goes at the left of the
    parent\'s space
-   [BannerAlignRight]{.code} - the banner goes at the right of the
    parent\'s space

The *size* parameter gives the initial size of the banner, the meaning
of which depends on *sizeUnits*:

-   [BannerSizePercent]{.code} - the size is a percentage of the
    parent\'s space as it is just before carving out this banner. *size*
    is a value from 0 to 100. The banner will remember that its size is
    a percentage; whenever the overall display area size changes (for
    example, whenever the user resizes the main application window for
    the interpreter), the size of the banner on-screen will be refigured
    as the same percentage of the new available space.
-   [BannerSizeAbsolute]{.code} - the size is given in the \"natural
    units\" of the banner, which depend upon the window type:
    -   For a text window ([BannerTypeText]{.code}), the size is given
        in character rows or columns. The size of each character can
        vary if the window uses a proportional font or can display
        multiple fonts, so for consistency we define this unit as the
        size of a \"0\" character in the window\'s default (initial)
        font. To compute the actual pixel size of the window, the system
        will take into account space needed for interior margins and
        borders; this ensures that the window will be large enough to
        show the requested number of rows or columns of text. (Note,
        however, that a banner of size 0 will not add any internal
        space, since a zero-sized banner has no screen presence at all.)
    -   For a text grid window ([BannerTypeTextGrid]{.code}), the size
        is given in rows or columns in the grid\'s fixed-pitch font. As
        with a text window, the space needed for margins and borders
        will be added to the requested row/column size.

*style* is a combination of flag values specifying the desired behavior
for the banner. Some of the style flags directly indicate particular
aspects of the on-screen appearance of the banner; other styles are
advisory, giving the interpreter some hints about how you\'re planning
to use the banner, so that the interpreter can select appearance or
behavior variations that are appropriate to the current platform. Not
all interpreters support all styles, so you have to think of the style
flags as hints to the interpreter about the desired appearance, rather
than a specification of the actual appearance. After you create the
banner, you can use [bannerGetInfo()]{.code} to retrieve the actual
style flags, which will give you some indication of how the interpreter
treated your request.

The style flags are:

-   [BannerStyleBorder]{.code} - show the banner with a border, which is
    to say a line on the banner\'s inner edge (the edge nearest the main
    text window: for a [BannerAlignTop]{.code} banner, this will be the
    banner\'s bottom edge). Most character-mode interpreters do not
    support this style, because drawing a border would consume an entire
    character row or column and would thus take up too much space
    visually.
-   [BannerStyleVScroll]{.code} - show the banner with a vertical
    scrollbar, if the system has scrollbars. Character-mode platforms
    will usually ignore this flag.
-   [BannerStyleHScroll]{.code} - show the banner with a horizontal
    scrollbar, if possible.
-   [BannerStyleAutoVScroll]{.code} - whenever new text is displayed in
    the banner, and the new text would appear outside of the on-screen
    boundaries of the banner, scroll the banner\'s contents vertically
    to bring the latest text into view. If this style isn\'t set, the
    banner won\'t automatically scroll vertically (if it has a vertical
    scrollbar, though, the user will be able to scroll it manually).
-   [BannerStyleAutoHScroll]{.code} - when new text is displayed in the
    banner, scroll the banner\'s contents horizontally if necessary to
    bring the new text into view.
-   [BannerStyleTabAlign]{.code} - the [\<TAB\>]{.code} tag is needed
    for text alignment purposes in the new window. This flag won\'t
    change the appearance of the banner in a full HTML interpreter or in
    most character-mode interpreters, but for text-only interpreters
    running on GUI systems where proportional fonts are available, this
    might force the interpreter to use a fixed-pitch font for the banner
    so that it can use spaces to implement the tab alignment.
-   [BannerStyleMoreMode]{.code} - use \"more\" mode in the banner. This
    implies the [BannerStyleAutoVScroll]{.code} style. In \"more\" mode,
    the interpreter pauses whenever new text written to the banner is
    about to force older text to scroll out of view, to ensure that the
    user has had a chance to read all of the text before it scrolls
    away. The exact user interface varies by platform; on most systems,
    the interpreter displays a prompt message, such as \"\[More\]\", in
    the window that\'s about to overflow, then waits for the user to
    press a key. This style allows a banner window to be used to display
    long passages without worrying about whether or not the text will
    fit in the user\'s available display area.
-   [BannerStyleHStrut]{.code} - makes the banner a \"horizontal strut\"
    when [bannerSizeToContents()]{.code} is used to set the parent
    banner\'s width. If the child banner is a vertical banner (i.e., it
    has left or right alignment), the width of the child\'s contents is
    added to the width of the parent\'s contents to determine the
    overall content width. If the child banner is a horizontal banner
    (top or bottom alignment), [bannerSizeToContents()]{.code} will set
    the parent\'s width to the larger of the widths of the parent\'s or
    child\'s contents.
-   [BannerStyleVStrut]{.code} - makes the banner a \"vertical strut\"
    when [bannerSizeToContents()]{.code} is used to set the parent
    banner\'s width. This has the same effect on height that
    [BannerStyleHStrut]{.code} has on width.

This function returns a handle to the new banner, or [nil]{.code} if an
error occurs creating the banner. The banner handle can be used to
operate on the banner in other [bannerXxx()]{.code} functions.
:::

[bannerDelete(*handle*)]{.code}

::: fdef
Delete the given banner. This removes the banner from the display, and
recalculates the layout for all of the other banners remaining on the
screen. After this function is called, the banner handle becomes invalid
and must not be used for anything else.

Note that any children of the banner being deleted will immediately
become invisible. They will remain valid, so you can continue to pass
their handles to banner functions, but they will not have any display
presence. A banner always obtains its display space by splitting its
parent, so once the parent is gone, a child has no way of obtaining any
screen space of its own and thus becomes invisible.
:::

[bannerFlush(*handle*)]{.code}

::: fdef
Flushes the text output buffer for the given banner, immediately
updating the display with any pending text.
:::

[bannerGetInfo(*banner*)]{.code}

::: fdef
Retrieves information on the banner. This function returns a list of
values, as follows:

-   \[1\] - the window\'s alignment type (a [BannerAlignXxx]{.code}
    value)
-   \[2\] - the window\'s actual style (a bit-wise combination of
    [BannerStyleXxx]{.code} flags). This can be used to determine how
    the styles originally requested were interpreted by the local
    platform. In some cases, it might be desirable to take some special
    action if a given style flag wasn\'t honored; for example, if a
    border was requested but the actual style flags indicate that no
    border is displayed, the program might want to use a different
    background color in the banner to make the banner\'s screen area
    stand out from the adjacent window\'s.
-   \[3\] - the height of the banner\'s screen area, in text rows. For
    GUI platforms, this is an estimate only, since the size of text can
    vary on these platforms; the estimate will give the number of lines
    of text in the window\'s default font that will fit in the window\'s
    height, which might be considerably different than the number of
    lines actually displayed.
-   \[4\] - the width of the banner\'s screen area, in text columns. As
    with the height, this is only an estimate on GUI platforms, since
    the banner might use proportionally-spaced characters and might use
    several different fonts; the estimate gives the number of digit
    0\'s, in the window\'s default font, that will fit in the window\'s
    width.
-   \[5\] - the pixel height of the banner. This is meaningful only on
    GUI platforms; on character-mode platforms, this will always be
    zero.
-   \[6\] - the pixel width of the banner. This is used on GUI platforms
    only; on character-mode platforms, this will always be zero.
:::

[bannerGoTo(*handle*, *row*, *col*)]{.code}

::: fdef
Move the output position in the given text grid banner to the given row
and column. Rows and columns are numbered from 1 at the upper left
corner. This function can be used only in text grid windows; in other
types of windows, it has no effect.
:::

[bannerSay(*handle*, \...)]{.code}

::: fdef
Writes one or more text items to the banner. This function treats the
parameters following *handle* the same way that [tadsSay()]{.code} does.
:::

[bannerSetScreenColor(*handle*, *color*)]{.code}

::: fdef
Set the background color in the banner. This immediately changes the
entire window\'s background to the given color (in other words, this
doesn\'t merely affect subsequent text, but also affects everything
already displayed in the banner). The color values are the same as for
[bannerSetTextColor()]{.code}, except that [ColorTransparent]{.code} is
not meaningful here. This function can\'t be used in ordinary text
windows ([BannerTypeText]{.code}); use the HTML [\<BODY
BGCOLOR\>]{.code} tag instead.
:::

[bannerSetSize(*handle*, *size*, *sizeUnits*, *isAdvisory*)]{.code}

::: fdef
Set the size of the banner. The *size* and *sizeUnits* parameters have
the same meanings they do in [bannerCreate()]{.code}. If *isAdvisory* is
[true]{.code}, it indicates that the size setting is only an estimate,
and that a call to [bannerSizeToContents()]{.code} will be made later;
in this case, the interpreter might simply ignore this estimated size
setting entirely, to avoid unnecessary redrawing. Platforms that do not
support contents-based sizing will always set the estimated size, even
when isAdvisory is true. If *isAdvisory* is [nil]{.code}, the platform
will set the banner size as requested; set *isAdvisory* to [nil]{.code}
when you will not follow up with a call to
[bannerSizeToContents()]{.code}.
:::

[bannerSetTextColor(*handle*, *fg*, *bg*)]{.code}

::: fdef
Set the text color in the given banner to the given foreground (*fg*)
and background (*bg*) colors. The new color settings are used for text
subsequently displayed; any text already displayed is not affected. This
can\'t be used in ordinary text windows ([BannerTypeText]{.code}); use
the HTML [\<FONT COLOR\>]{.code} tag instead.

*fg* and *bg* can have the following values:

-   [ColorText]{.code} - the default text foreground color (usually a
    user preference setting)
-   [ColorTextBg]{.code} - the default text background color
-   [ColorStatusText]{.code} - the default \"status line\" text color
-   [ColorStatusBg]{.code} - the default status line background color
-   [ColorInput]{.code} - the default input text color
-   [ColorRGB(*r*, *g*, *b*)]{.code}} - the specific color given as with
    red, green, and blue component values; each component can vary from
    0 to 255. [ColorRGB(0,0,0)]{.code} is black, [and
    ColorRGB(255,255,255)]{.code} is white.
-   [ColorBlack]{.code}, [ColorWhite]{.code}, [ColorRed]{.code},
    [ColorBlue]{.code}, [ColorGreen]{.code}, [ColorYellow]{.code},
    [ColorCyan]{.code}, [ColorAqua]{.code}, [ColorMagenta]{.code},
    [ColorSilver]{.code}, [ColorGray]{.code}, [ColorMaroon]{.code},
    [ColorPurple]{.code}, [ColorFuchsia]{.code}, [ColorLime]{.code},
    [ColorOlive]{.code}, [ColorNavy]{.code}, and [ColorTeal]{.code}
    provide the standard set of HTML-defined colors. These are all
    convenience macros that simply use [ColorRGB()]{.code} with the
    corresponding HTML RGB values.

In addition, the special value [ColorTransparent]{.code} can be used for
the background color. This indicates that the text should be drawn with
a transparent background, and thus should simply be drawn against the
banner\'s current background color.
:::

[bannerSizeToContents(*handle*)]{.code}

::: fdef
Resizes the given banner based on the current contents of the banner.
For a top-aligned or bottom-aligned banner, this sets the banner\'s
height so that the banner is just tall enough to show all of the
contents as currently laid out. For a left-aligned or right-aligned
banner, this sets the banner\'s width so that the banner is just wide
enough to hold the banner\'s single widest indivisible element (such as
a single word or a picture). This routine can be used to set the
banner\'s size based on the actual size of the contents; it\'s
impossible to know the exact size of a banner\'s contents until you
actually display the contents, because the sizes of fonts and other
display elements vary from one machine to another, and can even change
on the same machine in response to user preference settings and other
factors.

Note that this routine might not be implemented on all platforms; on
platforms where it\'s not implemented, it\'s legal to call this routine,
but the function will have no effect. To ensure that a reasonable size
is always set regardless of platform, callers should always use
[bannerSetSize()]{.code} to set an approximate size, passing
[true]{.code} for the *isAdvisory* flag, and then call
[bannerSizeToContents()]{.code} to set the exact content-based size. On
platforms where [bannerSizeToContents()]{.code} is supported, this will
set the exact content-based size; on other platforms, this will at least
set the size to a suitable approximation.
:::

[clearScreen()]{.code}

::: fdef
Clear the main console window, if possible. The actual effect of this
function varies by system; some interpreters clear the window, some
display enough newlines to scroll any existing text off the top of the
window, and some ignore the call completely.
:::

[flushOutput()]{.code}

::: fdef
Immediately flushes text to the output. When you display output using
[tadsSay()]{.code}, the text you write isn\'t necessarily displayed
immediately, because the output formatter generally buffers text
internally; the exact details of the output formatter\'s internal
buffering vary by platform. The [flushOutput()]{.code} function tells
the output formatter to display any buffered text immediately. It is
never necessary to call this function, because the formatter
automatically flushes its buffers before waiting for user input. It is,
however, sometimes desirable to be able to display buffered output
explicitly; for example, if your program is going to perform some
computation that will take a while, you might want to ensure that the
user sees a \"please wait\" message before the long-running computation
begins.

This function takes no arguments and returns no value.
:::

[]{#getLocalCharSet}

[getLocalCharSet(*which*)]{.code}

::: fdef
Returns a string giving the name of the active local character set
selected by *which*, which can have one of the following values:

-   [CharsetDisplay]{.code} - returns the name of the character set
    displayed on the monitor and read from the keyboard. If the
    interpreter was started with an explicit character set option (the
    \"-cs\" option in the command-line interpreter, for example), the
    character set name so specified is returned; otherwise, the local
    default display character set name is returned.
-   [CharsetFileName]{.code} - returns the name of the character set
    used in the file system for filenames. In some cases, this might
    differ from the display character set; for example, a system might
    have a global file system character set used by all applications,
    but allow individual terminal or window sessions to use separate
    character sets for the user interface.
-   [CharsetFileCont]{.code} - returns the name of the character set
    typically used for the contents of text files on the local system.
    Note that this is only a default; a particular file could be in any
    character set, determined at the time the file was created. However,
    on most systems, there\'s a character set that\'s used by convention
    for most text files.

If *which* is not one of the above values, the function returns
[nil]{.code}.

The character set name returned can be used to create a
[[CharacterSet]{.code}](charset.htm) object to perform character-to-byte
and byte-to-character mappings.
:::

[inputDialog(*icon*, *prompt*, *buttons*, *defaultButton*,
*cancelButton*)]{.code}

::: fdef
Displays an \"alert box\" dialog (also known as a \"message box\"), and
waits for the user to respond. This displays a dialog that includes a
short message for the user to read, an icon indicating the general
nature of the condition that gave rise to the dialog (an error, a
warning, a choice for the user to make, etc.), and a set of push-buttons
that dismiss the dialog and (in some cases) let the user choose among
options.

On GUI systems, this will use a standard system dialog if the OS
provides. On character-mode systems, this will generally not display a
GUI-style dialog, but will simply display the prompt string and let the
user type a response.

*icon* gives the type of icon to show in the dialog, if any; *prompt* is
the message string to display; *buttons* gives the set of buttons to
display; *defaultButton* is the index (starting at 1) among the buttons
of the default button; and *cancelButton* is the index of the
cancellation button.

The *icon* value can be one of the following:

-   [InDlgIconNone]{.code} - no icon
-   [InDlgIconWarning]{.code} - \"warning\" icon; indicates a possible
    problem but not a serious error
-   [InDlgIconInfo]{.code} - \"information\" icon; indicates that the
    message is for information only, and doesn\'t indicate an error or
    warning
-   [InDlgIconQuestion]{.code} - \"question\" icon; indicates that the
    program is requesting information from the user
-   [InDlgIconError]{.code} - \"error\" icon; indicates that an error
    has occurred

The *buttons* value can be one of the constants listed below, to select
a standard set of buttons:

-   [InDlgOk]{.code} - show only an \"OK\" button
-   [InDlgOkCancel]{.code} - show \"OK\" and \"Cancel\" buttons
-   [InDlgYesNo]{.code} - show \"Yes\" and \"No\" buttons
-   [InDlgYesNoCancel]{.code} - show \"Yes\", \"No\", and \"Cancel\"
    buttons

Alternatively, *buttons* can be a list (or a [list-like
object](opoverload.htm#listlike)) specifying a custom set of buttons.
Each element of the list is either a string giving a custom label for
the button, or one of the [InDlgLblXxx]{.code} values listed below to
select a standard label. The standard labels should be used when
possible, as these will be automatically localized; labels given
explicitly as strings will be used exactly as given. If a list of custom
button labels is given, the buttons are displayed in the dialog in the
order of the list (usually left to right, but this could vary according
to system conventions and localization).

Each custom button label string can incorporate an ampersand
([&]{.code}). The letter immediately following the ampersand, if
provided, is used as the keyboard shortcut for the button. This is
particularly important on character-mode systems, where the \"dialog\"
is typically shown merely as a text prompt, and the user responds by
selecting the letter of the desired option. Typically, you should use
the first character of a button label as its keyboard shortcut, but this
obviously won\'t work when two button labels have the same first letter;
in these cases, you should choose another letter from the button label,
preferably something like the first letter of the second word of the
button label, or the first letter of the stressed syllable of the most
important word of the label.

The button label constants are:

-   [InDlgLblOk]{.code} - \"OK\" button
-   [InDlgLblCancel]{.code} - \"Cancel\"
-   [InDlgLblYes]{.code} - \"Yes\"
-   [InDlgLblNo]{.code} - \"No\"

The return value is the index among the buttons of the button that the
user selects to dismiss the dialog. The function doesn\'t return until
the user selects one of the buttons.

If an error occurs, the return value is 0. In most cases, this means
that the user has closed the game window or disconnected the terminal
session. It can also indicate a resource error, such as the system being
too low on memory to display the dialog, although this is rare on modern
systems. (There\'s no way to distinguish end-of-file and resource
errors, but that\'s not too important because in either case the best
course of action for the game is simply to exit.)
:::

[inputEvent(*timeout*?)]{.code}

::: fdef
Wait for an event, with the optional *timeout*, given in milliseconds.
If the *timeout* value is omitted or [nil]{.code}, there is no timeout,
so the function waits indefinitely for an event.

The function returns when either an event occurs or the timeout expires.
The return value is a list containing one or more elements. The first
element of the list is a constant that indicates the type of event that
occurred; the remaining elements of the list vary according to the event
type. The event type codes are:

-   [InEvtKey]{.code} - the user pressed a key. The second element of
    the list is a string giving the key pressed. The string returns
    varies according to the type of key.

    For a regular character key, this is simply the character. For
    example, if the user presses the A key with no Shift key or Caps
    Lock in effect, the returned string is simply [\'a\']{.code}. If the
    user holds down the Shift key and presses B, the returned string is
    [\'B\']{.code}.

    For the standard non-printing keys, the corresponding ASCII control
    character is returned: for the Tab key, [\'\\t\']{.code}; for the
    Return or Enter key, [\'\\n\']{.code}. Note that [\'\\n\']{.code} is
    returned for Return or Enter *regardless* of the local system\'s
    newline conventions, so you don\'t have to worry about the different
    conventions used on different systems.

    For \"special\" keys - cursor arrows, \"F\" keys, and the like - the
    returned string is a portable name for the key. The special key
    names are assigned by TADS, so they\'re the same on every system -
    you don\'t have to worry about the hardware or OS-specific
    representations of these keys, because TADS maps the local
    representation into these universal key names. Special key names are
    always enclosed in square brackets, so you can easily distinguish
    them from ordinary character keys. The key names are:

    [\[alt-a\]]{.code}

    Alt-A (i.e., the \"Alt\" key plus the letter A); likewise for
    [\[alt-b\]]{.code}, [\[alt-1\]]{.code}, etc.

    [\[ctrl-a\]]{.code}

    Ctrl-A (i.e., the \"Ctrl\" or \"Control\" key plus the letter A);
    likewise for [\[ctrl-b\]]{.code}, [\[ctrl-c\]]{.code}, etc.

    [\[esc\]]{.code}

    the \"Escape\" or \"Esc\" key

    [\[up\]]{.code}

    the \"up\" cursor arrow

    [\[down\]]{.code}

    the \"down\" cursor arrow

    [\[right\]]{.code}

    the \"right\" cursor arrow

    [\[left\]]{.code}

    the \"left\" cursor arrow

    [\[home\]]{.code}

    the \"Home\" key

    [\[end\]]{.code}

    the \"End\" key

    [\[del-word\]]{.code}

    the \"Delete Word\" key

    [\[del-eol\]]{.code}

    the \"delete to end of line\" key

    [\[del-line\]]{.code}

    the \"delete line\" key

    [\[insert\]]{.code}

    the \"Insert\" or \"Ins\" key

    [\[del\]]{.code}

    the \"Delete\" or \"Del\" key

    [\[scroll\]]{.code}

    the \"scroll lock\" key

    [\[page up\]]{.code}

    the \"Page Up\" or \"Previous Page\" key

    [\[page down\]]{.code}

    the \"Page Down\" or \"Next Page\" key

    [\[top\]]{.code}

    the \"Top of Document\" key

    [\[bottom\]]{.code}

    the \"Bottom of Document\"

    [\[f1\]]{.code}

    function key F1; likewise for [\[f2\]]{.code}, [\[f3\]]{.code}, etc.

    [\[bksp\]]{.code}

    the Backspace key

    [\[word-left\]]{.code}

    the \"Word Left\" or \"Previous Word\" key

    [\[word-right\]]{.code}

    the \"Word Right\" or \"Next Word\" key

    [\[eof\]]{.code}

    the \"End of File\" key

    [\[break\]]{.code}

    the \"Break\" key

    [\[?\]]{.code}

    any other key

    Note that you can\'t count on any of the special keys to be
    available on every machine. Some keyboards simply have no
    equivalents for some of these keys. Furthermore, even on systems
    that do have all of these keys, some of them might have special
    meanings, due to hardware, the operating system, or other software;
    so a keystroke might be intercepted before it ever reaches
    [inputEvent()]{.code}. For example, certain Ctrl+Letter keys and
    F-keys have special meanings in the Windows HTML TADS interpreter
    because they\'re assigned as menu command keys (also known as
    \"accelerators\" or \"shortcuts\"); Windows intercepts these keys
    and activates their special meanings before [inputEvent()]{.code}
    has a chance to read them, so they\'ll never generate events that
    [inputEvent()]{.code} can read.

    Because you can\'t count on any given special key to be available to
    every user, you should avoid hard-wiring these keys into your
    program. For maximum portability, you should either (a) give users a
    way of customizing the keyboard layout, so that they can select the
    special keys that work properly on their keyboards, or (b) provide
    ordinary letter or number key equivalents for any special keys you
    use. The menu system module (menusys.t) in the Adv3 library uses the
    latter approach: it lets the user use the cursor arrow keys to
    navigate menu screens, but also assigns alphabetic equivalents:
    \"U\" for up, \"D\" for down, \"P\" for previous menu.

-   [InEvtTimeout]{.code} - the timeout expired

-   [InEvtHref]{.code} - the user clicked on a hyperlink (i.e., text or
    graphics displayed in a window with an HTML [\<A
    HREF=xxx\>\>]{.code} tag). The second element of the list is a
    string giving the text of the [HREF]{.code} attribute of the
    hyperlink that was clicked.

-   [InEvtNoTimeout]{.code} - this isn\'t an event, but rather an error
    code: it indicates that the platform doesn\'t support the timeout
    feature of [inputEvent()]{.code}. When [inputEvent()]{.code} is
    called with a timeout value on a platform that doesn\'t support the
    timeout feature, the function simply returns this result code
    immediately.

-   [InEvtEof]{.code} - an \"end of file\" error has occurred. This
    indicates that the program is in the process of terminating. This
    happens, for example, when the user explicitly terminates the
    interpreter program (by closing its main window in the GUI, for
    example), or when the OS is terminating programs in preparation for
    shutting down the computer. This event type indicates that no
    further input will be available.

Note that new events could be added in the future, so be aware that your
code might receive events that aren\'t on this list. It should always be
safe to simply ignore an event you don\'t recognize or don\'t want to
process; the purpose of events is to notify the program that something
has happened, so the interpreter should always be able to carry on with
its own processing whether or not your code does anything in response to
a particular event.
:::

[]{#inputFile}

[inputFile(*prompt*, *dialogType*, *fileType*, *flags*)]{.code}

::: fdef
Display a file selector dialog and wait for the user to respond. On GUI
systems, this displays a standard system file selector dialog; on
text-only platforms, this generally just displays the prompt text and
waits for the user to type a filename.

*prompt* is the message string to display in the dialog, to let the user
know the purpose of the file selection. On many GUI systems, the
physical display area allotted for this message is fairly small, so
it\'s best to keep it short: \"Saved game file\" or \"Log file,\" for
instance. There\'s usually not any need for a long, detailed message
anyway, since in most cases the user will already know what the dialog
is for simply because they just initiated the action that triggered the
dialog. For example, if the user types SAVE, they\'ll expect to be asked
for a name for the saved game.

*dialogType* is one of the [InFileXxx]{.code} constants below,
specifying whether the request is to select an existing file or to
specify the name for a new file. *fileType* is one of the
[FileTypeXxx]{.code} constants below, giving the format of the file
being requested; this is used on some systems to filter the displayed
list of existing files so that only files of the same format are
included, to reduce clutter.

*flags* is reserved for future use and should be set to zero.

The constants for *dialogType* are:

-   [InFileOpen]{.code} - \"open\" dialog: selects an existing file
-   [InFileSave]{.code} - \"save\" dialog: selects a name for a file to
    be created

The constants for *fileType* are:

-   [FileTypeLog]{.code} - log (transcript) file
-   [FileTypeData]{.code} - TADS 2 private binary data format
-   [FileTypeCmd]{.code} - command input file
-   [FileTypeText]{.code} - text
-   [FileTypeBin]{.code} - unknown binary data
-   [FileTypeUnknown]{.code} - unknown type
-   [FileTypeT3Image]{.code} - TADS 3 image file (i.e., a compiled TADS
    3 program, a .t3 file)
-   [FileTypeT3Save]{.code} - TADS 3 saved state file

The return value is a list. The first element is an integer giving the
status, and additional elements vary according to the status code. The
status codes are:

-   [InFileSuccess]{.code} indicates that the user successfully selected
    a file. The following additional elements are in the returned list:

    -   \[2\] = the selected file name, as a [FileName](filename.htm)
        object
    -   \[3\] = [nil]{.code} (reserved for future use)
    -   \[4\] = warning message string, or [nil]{.code}

    The warning message string in element \[4\] is non-nil only if the
    file selection was read from a script, *and* the script reader
    detected a possible error condition for the file name, *and* the
    script reader didn\'t display the warning itself. The script reader
    checks the selection from an Open dialog to make sure the file
    exists, and checks the selection from a Save dialog to make sure the
    file *doesn\'t* already exist (to protect against accidentally
    overwriting an existing file) and that it\'s possible to create and
    write to the file. If any of these tests fail for scripted input,
    the script reader generates a suitable warning message. In the
    conventional console UI, the script reader automatically displays
    these warning messages itself, so games built for the traditional UI
    don\'t have to concern themselves with this. However, in the Web UI,
    it\'s not possible for the script reader to display these warnings
    itself, since the script reader doesn\'t have access to the Web UI
    communications channels. Instead, it returns the warning text to the
    caller via this return list element. The caller is responsible for
    displaying the warning to the user in this case.

    To allow for localization, the error message starts with a
    two-letter error code, followed by a space, followed by the English
    text of the message. Localized libraries can replace the message
    text based on the two-letter error code:

    -   OV - the script might overwrite an existing file (Save dialog)
    -   WR - the file can\'t be created/written (Save dialog)
    -   RD - the file doesn\'t exist (Open dialog)

-   [InFileFailure]{.code} indicates a system error of some kind showing
    the dialog. There are no additional return list elements.

-   [InFileCancel]{.code} indicates that the user explicitly canceled
    the dialog (such as by clicking a \"Cancel\" button in the UI).
    There are no additional return list elements.

Files selected with inputFile() are granted special permissions that
bypass the [file safety](terp.htm#file-safety) settings. The program is
allowed to read a file selected with an Open dialog, and is allowed to
write a file selected with a Save dialog, even if the file safety
settings would normally prohibit access to the same file. The special
extra permissions are granted because of the direct interaction with the
user; the user is asked to select a file to read or write, so the act of
selecting the file expresses an intention to allow that operation. (The
visual presentation of the dialog is under system control, so the game
program can\'t deceive the user about the basic read or write operation
being proposed. It could use the prompt message to lie about the purpose
of the file access, but it can\'t lie about the basic nature of the
access.) The special permission is stored as an internal attribute of
the [FileName](filename.htm) object returned by inputFile() function, so
you have to use the actual FileName object returned to exercise the
special permission. For example, converting the FileName to a string and
then attempting to open the file via the string will revert to the
ordinary file safety rules for the file.
:::

[inputKey()]{.code}

::: fdef
Read a keystroke from the user. Waits for the user to press a key, then
returns a string with the key the user pressed.

This function returns a string indicating which key the user pressed.
The key strings have the same meaning as for an [InEvtKey]{.code} event
from [inputEvent()]{.code}.
:::

[inputLine()]{.code}

::: fdef
Read a line of text input from the user. Returns the text of the input
as a string. (The returned string will **not** contain a newline
character.) Returns [nil]{.code} if an \"end of file\" error occurs,
which usually indicates that the user has closed the interpreter
application.
:::

[inputLineCancel(*reset*)]{.code}

::: fdef
Cancels an editing session interrupted by a timeout. This function must
be called after [inputLineTimeout()]{.code} returns the
[InEvtTimeout]{.code} event code if any display input or output is to be
performed before the next call to [inputLineTimeout()]{.code}. This
function terminates the editing session, making any changes to the
visual display that would have occurred if the user had terminated the
command entry by pressing the Return key or some equivalent action. For
example, this function changes the display by starting a new line of
text after the line that was being edited.

The *reset* argument indicates whether or not
[inputLineTimeout()]{.code} should forget the editing state that was in
effect when the timeout occurred. If *reset* is [true]{.code}, then the
next call to [inputLineTimeout()]{.code} will start with a blank input
line; if reset is [nil]{.code}, then the next call to
[inputLineTimeout()]{.code} will re-display the line of text that was
under construction when the timeout occurred, and will restore the
editing state (cursor position, selected text range, and so on) that was
in effect.
:::

[inputLineTimeout(*timeout*?)]{.code}

::: fdef
Read a line of text input from the user, with an optional *timeout*
given in milliseconds. See the section on real-time input
[below](#rtinput) for examples of how to use this function. If *timeout*
is missing or is [nil]{.code}, there is no time limit on the input.

This function might not be implemented on every platform, because some
platforms do not have the necessary operating system features to support
it. If a platform does not support the timeout feature, this function
will return an [InEvtNoTimeout]{.code} pseud-event immediately upon
invocation if *timeout* is given as a non-[nil]{.code} value.

The return value is a list, the first element of which gives an event
code. Additional elements vary according to the event type. The event
codes are:

-   [InEvtEof]{.code} - end of file reading the input. This indicates
    that the application is being terminated or that an error occurred
    reading the keyboard. The result list has no additional elements.
-   [InEvtLine]{.code} - a line of input was successfully read from the
    keyboard. This event is returned when the user expressly enters the
    line of text by pressing the Return key or performing some other
    action that terminates the editing, such as clicking on a hyperlink
    or selecting a command from a menu. When this event code is
    returned, the second element of the result list contains a string
    giving the text entered.
-   [InEvtTimeout]{.code} - the timeout interval expired before the user
    finished editing the line of text. The second element of the result
    list is a string giving the line of text under construction.
-   [InEvtNoTimeout]{.code} - indicates that the timeout feature is not
    supported on the local system. The timeout feature is not
    universally supported. The caller will have to use
    [inputLine()]{.code} in this case; real-time input interruptions
    will not be available.
-   [InEvtEndQuietScript]{.code} - indicates that the input reader had
    been returning text from a \"quiet\" input script file, such as a
    script being read using the \"-i\" option of the command-line
    interpreter. When a script is read in \"quiet\" mode, the
    interpreter suppresses all text display while the script is being
    processed, so no input or output is displayed on the console. The
    interpreter returns a specific event for this case because any
    prompting text previously displayed for this input line will not
    have been shown, since the quiet mode will have suppressed the
    prompt text along with any other output; this event allows the
    caller to re-display the prompt now that script input has ended and
    regular keyboard input will be resumed, so that the user will see a
    command-line prompt and thus know that the interpreter is waiting
    for new input.

When this function returns the [InEvtTimeout]{.code} event code, the
caller must not perform any display input or output operations in the
same window until after calling [inputLineCancel()]{.code}, with the
single exception that the caller can call [inputLineTimeout()]{.code}
again with no intervening call to [inputLineCancel()]{.code}.

After a timeout occurs, if [inputLineTimeout()]{.code} is called again
with no intervening call to [inputLineCancel()]{.code}, then
[inputLineTimeout()]{.code} resumes editing the interrupted command
line. In this case, there is no visible effect of the timeout; from the
user\'s perspective, the timeout never occurred. This allows the program
to carry out background operations silently while the user edits a
command line.

If a timeout occurs and [inputLineCancel(nil)]{.code} is subsequently
called, then [inputLineTimeout()]{.code} is called again, the new call
to [inputLineTimeout()]{.code} re-displays the command line as it was at
the time of interruption, and then allows the user to resume editing
where they left off. In this case, there is a visible change to the
display, in that the command line is re-displayed; however, all of the
editing state (cursor position, selected text range, history recall
position, and so on) is duplicated from the previous editing session.
So, although the user will see that editing was interrupted, the user
can continue editing the command line exactly where they left off.

When this function is called without the *timeout* argument, or with
[nil]{.code} as the timeout value, it is similar to
[inputLine()]{.code}, in that it allows the user to edit a line of text,
with no upper limit on how long to wait until the user finishes.
However, this function differs from [inputLine()]{.code} in one
important respect: if the preceding call to [inputLineTimeout()]{.code}
ended with the timeout expiring, and no intervening call to
[inputLineCancel(true)]{.code} was made since the timeout occurred, this
function will resume editing of the interrupted command line.
:::

[logConsoleClose(*handle*)]{.code}

::: fdef
Closes the given console. This function closes the operating system
file, so no further text can be written to the console after this
function is called.
:::

[]{#logConsoleCreate}

[logConsoleCreate(*filename*, *charset*, *width*)]{.code}

::: fdef
Creates a \"log console.\" A log console is a special system object that
behaves much like the main game window, except that all of the text
written to a log console is captured in a text file rather than being
displayed.

*filename* is a string giving the name of the file to write, a
[FileName](filename.htm) object, or a [TemporaryFile](tempfile.htm)
object; any existing file with the same name will be overwritten.
*charset* can be a [CharacterSet]{.code} object, a string giving the
name of a character set, or [nil]{.code} to use the default log file
character set. The text in the log file will be written in the selected
character set. [width]{.code} is the maximum width, in text columns, for
the text written to the file; the console will automatically word-wrap
the written text to this width.

The return value is a \"handle,\" which identifies the new console in
calls to other logConsoleXxx functions; if the return value is
[nil]{.code}, the system was unable to create the console.

If the given file cannot be created (because the name is invalid, for
example, or because there\'s no space on disk), a
[FileCreationException]{.code} is thrown. The \"file safety\" level must
allow the operation, otherwise a [FileSafetyException]{.code} is thrown.

Log consoles are in some ways similar to text files based on the
[File]{.code} intrinsic class. The difference is that text written to a
[File]{.code} object is written character-for-character exactly as you
specify. In contrast, the text written to a log console is processed the
same way as text displayed to the player: HTML markups are processed
(although, in a log console, only the text-only subset of HTML can be
used, regardless of the kind of interpreter being used), the text is
word-wrapped (to the fixed width given when the log console is created),
excess whitespace is removed, and so on.

Log consoles are also similar to the log files created with
[setLogFile()]{.code}. The only difference is that [setLogFile()]{.code}
can only capture text that is also displayed to the main game window; a
log console has no display component at all, so you can use a log
console to capture text exclusively to a file, without also showing it
to the user.

Starting in 3.1.1, the [file safety](terp.htm#file-safety) settings must
allow write access to the target file. [FileName](filename.htm) objects
obtained from [inputFile()](tadsio.htm#inputFile) \"save\" dialogs are
always accessible.
:::

[logConsoleSay(*handle*, \...)]{.code}

::: fdef
Writes the given arguments to the given log console. This behaves just
like [tadsSay()]{.code}, but writes the text to the given log console
instead of to the main game window. The handle is a log console handle
previously returned from [logConsoleCreate()]{.code}.

You can also pass the special value [MainWindowLogHandle]{.code} for
*handle*. Doing this writes the text to the main game window\'s
transcript file, if any - this is the log file that\'s created by
[setLogFile(filename, LogTypeTranscript)]{.code}. If you pass this
special handle value when there isn\'t an active transcript for the main
game window, the function is simply ignored; it\'s legal to call it in
this case, but it will have no effect. (You can\'t use
[logConsoleClose()]{.code} to close this special handle; to close the
main game window\'s log file, you must call [setLogFile(nil,
LogTypeTranscript)]{.code}.)

Note that you can also write text to the main game window\'s
transcript - without having the text show up in the main window itself -
by writing the text to the main window and enclosing the text in
[\<LOG\>\...\</LOG\>]{.code} tags. These tags hide the text from the
display window, but include it in the transcript file. They\'re the
complement of the [\<NOLOG\>\...\</NOLOG\>]{.code} tags, which you can
use to show text in the game window but exclude it from any transcript
file. The [\<LOG\>\...\</LOG\>]{.code} sequence is often a better way
than [logConsoleSay()]{.code} to add text to the main transcript, since
it lets you write the text through the library\'s standard stack of
output filters. Calling [logConsoleSay(MainWindowLogHandle, val)]{.code}
is best for situations where you specifically want to bypass the normal
output stream handling for the main game window, and instead go directly
to the file.
:::

[morePrompt()]{.code}

::: fdef
Display the MORE prompt on the main console window, and wait for the
user to respond. This can be used when you want to pause execution and
wait for the user to acknowledge some output before proceeding.
:::

[resExists(*resname*)]{.code}

::: fdef
Check to see if the given resource can be found. Returns true if the
resource is present, nil if not. For HTML TADS 3, this looks for an HTML
resource; text-only TADS 3 interpreters always return [nil]{.code} for
this function, since they don\'t use multi-media resources at all.

The resource name *resname* should be specified as a URL-style name
string. The interpreter will look for the resource using the same
searching rules that it uses for normal resource loading; the HTML
interpreter will thus look for the resource bundled into the image file,
in any external resource files (image.3r0 through image.3r9), and
finally in an external file whose name is derived from the URL according
to local system conventions.
:::

[]{#setLogFile}

[setLogFile(*fname*, *logType*?)]{.code}

::: fdef
Log console output to a file, or stop logging.

If *fname* is not [nil]{.code}, this starts logging to the specified
file. *fname* can be a string giving the name of the file for saving the
log, a [FileName](filename.htm) object, or a
[TemporaryFile](tempfile.htm) object. If *fname* refers to an existing
file, the existing file will be overwritten by the new log output.

If *fname* is [nil]{.code}, the function turns off the specified type of
logging, closing the current log file.

logType specifies the type of logging to perform:

-   [LogTypeTranscript]{.code} - create a transcript. All of the text
    displayed to the main console (including text read via command line
    input) is copied to the file. Any HTML markups are processed before
    the text is written to the file; note, though, that the text-only
    HTML subset is used, regardless of what kind of interpreter is
    running. This is the default log type if the logType parameter is
    omitted.
-   [LogTypeCommand]{.code} - create a command log. Only the input
    commands are copied to the log file. This creates a command-line
    script, suitable for later replay (such as with
    [setScriptFile()]{.code}).
-   [LogTypeEvent]{.code} - create an event script. Command lines, keys,
    hyperlink clicks, dialog button clicks, and file dialog selections
    are captured to the script, which can later be replayed (with
    [setScriptFile()]{.code}, for example).

The return value is [true]{.code} if the operation succeeded,
[nil]{.code} if the file couldn\'t be opened. Opening a file can fail
due to the usual file system errors, such as an invalid filename,
insufficient disk space, or file permission errors. When closing a file
(by passing [nil]{.code} for *fname*), the function always returns
[true]{.code}.

You can record a \"transcript\" and a \"script\" file simultaneously,
but only one of each type can be recorded at a time. If you start a new
transcript file (LogTypeTranscript), any previous transcript will be
closed. Similarly, if you start a new script file (LogTypeCommand or
LogTypeScript), any previous script file will be closed. Recordings
don\'t nest; starting a new recording simply stops any previous
recording of the same type.

Refer to [Input Scripts](scripts.htm) for more details on scripts,
including the differences between Command-line and Event scripts.

Starting in 3.1.1, the [file safety](terp.htm#file-safety) settings must
allow write access to the target file. [FileName](filename.htm) objects
obtained from [inputFile()](tadsio.htm#inputFile) \"save\" dialogs are
always accessible.
:::

[]{#setScriptFile}

[setScriptFile(*filename*, *flags*?)]{.code}

::: fdef
Start reading commands from a script file, or cancel existing script
input.

If *filename* is not [nil]{.code}, this starts reading from the given
file. *filename* can be a string containing the name of a file in the
local file system, a [FileName](filename.htm) object, or a
[TemporaryFile](tempfile.htm) object.

If *filename* is [nil]{.code}, this cancels input from the current
script, as though the end of the file had been reached. If the current
script file is nested within another script, this returns to the
enclosing script.

The optional *flags* value lets you specify how to read the script file.
The following values can be combined (with the bitwise OR operator
\"[\|]{.code}\"):

-   [ScriptFileQuiet]{.code} - do not display any output while reading
    the script file. If this flag isn\'t set, the input lines read from
    the script file and the resulting output will be displayed as though
    the user had typed the lines of text at the keyboard.
-   [ScriptFileNonstop]{.code} - turn off the MORE prompt while reading
    the script file; output will scroll by without any user
    intervention. If this flag isn\'t used, the MORE prompt will be
    displayed each time the screen fills up with text, and the user will
    have to acknowledge the prompt before more output will be displayed.

If the *flags* argument is omitted, a default value of 0 will be used,
so none of the flags will be set.

The function returns [true]{.code} on success, [nil]{.code} on error. An
error return means that the script file doesn\'t exist or couldn\'t be
opened. The function always returns [true]{.code} if *filename* is
[nil]{.code}.

When the interpreter reaches the end of a script file, it automatically
closes the file and returns to normal keyboard input, so calling this
function with *filename* set to [nil]{.code} isn\'t necessary unless you
want to explicitly interrupt the script before reaching the end of the
file.

Input scripts can be nested. If [setScriptFile()]{.code} is called with
a non-nil filename when a script file is already in effect, the
interpreter will remember the position in the old script file, then
start reading from the new script file; upon reaching the end of the new
script file, or upon an explicit [setScriptFile(nil)]{.code} call, the
interpreter will resume reading from the old script file. Scripts can be
nested in this manner to any depth. This allows one script file to
\"include\" another, for example.

See [Script Files](scripts.htm) for information on how input scripts are
interpreted.

**Status queries:** In version 3.0.17 and later, this function can also
query the current script playback status. To get the status, use
[setScriptFile(ScriptReqGetStatus)]{.code}. If input is currently being
read from the keyboard, the return value is nil. If a script is being
played back, the return value is an integer giving a combination of
[ScriptFileXxx]{.code} flags describing the playback mode. Note that a
return value of 0 (zero) indicates that a script **is** being played
back, but that none of the mode flags apply.

In addition to the flags defined above, the flag
[ScriptFileEvent]{.code} is included in the status value if the current
script is an event script rather than a command-line script. Note that
this flag is ignored if you include it in the \'flags\' argument when
calling [setScriptFile()]{.code} to start playback of a new script; the
script reader automatically determines whether the new script is an
event script or a command-line script by examining the file\'s contents.
The purpose of this additional flag is to let you find out what the
script reader decided about the current script.

If you call the function in this form on VM versions prior to 3.0.17,
the function will throw a RuntimeError, because earlier implementations
only accepted a string or nil for the first argument. You can use
try-catch to handle this situation: if the function throws a
RuntimeError (with errno\_ == 2019), it means that you\'re running on a
version of the VM that doesn\'t support the function.

Starting in 3.1.1, the [file safety](terp.htm#file-safety) settings must
allow read access to the target file. [FileName](filename.htm) objects
obtained from [inputFile()](tadsio.htm#inputFile) \"open\" dialogs are
always accessible.
:::

[statusMode(*mode*)]{.code}

::: fdef
Set the \"status line mode.\" This can be used to control the status
line in non-HTML mode and for older text-only interpreters that don\'t
support the Banner API. The *mode* setting controls where text is
displayed; this can be one of the following:

-   [StatModeNormal]{.code} - text is displayed in the main text area
-   [StatModeStatus]{.code} - text is displayed to the left portion of
    the status line

To write to the status line in non-HTML mode and on text-only
interpreters, set the status mode to [StatModeStatus]{.code}, write the
status line text as though it were ordinary display output, and finally
set the status mode back to [StatModeNormal]{.code}:

::: code
    statusMode(StatModeStatus);
    "Loud Room";
    statusMode(StatModeNormal);
:::
:::

[statusRight(*txt*)]{.code}

::: fdef
Write the text string *txt* to the right half of the status line. This
can be used to control the right portion of the status line on older
text-only interpreters that don\'t support the Banner API.
:::

[systemInfo(*infoType*, \...)]{.code}

::: fdef
Retrieve information about the TADS 3 application environment. This
retrieves information on the interpreter and operating system that\'s
running the program.

*infoType* is one of the [SysInfoXxx]{.code} constants listed below; it
specifies the type of information being requested. Additional parameters
vary according to the *infoType* value; unless otherwise specified, no
additional parameters are used. The return value contains the
information requested; the type and meaning vary according to the
*infoType* code.

This API is designed to allow for future [SysTypeXxx]{.code} codes to be
added in future versions, as follows. In particular, it\'s legal to pass
an arbitrary integer value for *infoType*; if the interpreter doesn\'t
recognize the selector value, it will always return [nil]{.code} as the
result of the function. This allows a newer game to use a recently added
selector code, and still get meaningful results from an older
interpreter that was released before that selector code was added.
Therefore, [nil]{.code} is a special return value for this function: it
always means either that the selector isn\'t recognized, or that the
selector is recognized but the feature it asks about isn\'t present; in
either case, it tells the caller that the feature being queried can\'t
be used.

The *infoType* codes are:

-   [SysInfoInterpClass]{.code} - get the interpreter \"class,\" which
    indicates the broad capabilities of the interpreter. The following
    classes are defined:
    -   [SysInfoIClassText]{.code} - character-mode text-only
        interpreter, such as Unix TADS or MS-DOS TADS. These
        interpreters use a single, fixed-pitch font, cannot display any
        graphics, and support only the text-only HTML subset.

    -   [SysInfoIClassTextGUI]{.code} - GUI text-only interpreter, such
        as WinTADS or MacTADS. These interpreters behave essentially the
        same as character-mode interpreters, but run on graphical
        operating systems and thus might use proportional fonts,
        boldface text, and so on. These interpreters can\'t display
        graphics explicitly, but might use some graphics automatically
        (for drawing window borders, for example). These support only
        the text-only HTML subset.

    -   [SysInfoIClassHTML]{.code} - a full HTML interpreter running on
        a graphical platform, such as HTML TADS for Windows, CocoaTADS
        for Mac OS X, or QTads for Linux, Unix, and Mac OS X. These
        interpreters can use multiple fonts of varying sizes, including
        proportional fonts, can display graphics and play sounds, and
        recognize the full HTML TADS markup language.

        Note that the advent of the Web UI in TADS 3.1 clouds the
        picture a little bit. With the Web UI, the game\'s user
        interface runs in a browser that\'s separate from the
        interpreter, and the *browser* always uses HTML even if the
        interpreter doesn\'t. The interpreter class indicates the
        capabilities of the *built-in user interface* in the
        interpreter, which Web UI games generally don\'t use at all. If
        you\'re writing for the Web UI, the actual user interface is
        always a browser, and is therefore always HTML capable,
        regardless of the interpreter class. Note that you don\'t need
        to worry about whether or not the interpreter supports the Web
        UI, because this is handled at load time: a game that uses the
        Web UI simply won\'t load on an interpreter that doesn\'t
        support the Web UI, since that interpreter won\'t have the
        necessary intrinsic classes and functions that the game
        requires.
-   [SysInfoVersion]{.code} - get the interpreter version information.
    The return value is a string of the form \'3.0.10\' giving the
    major, minor, and point-release numbers.
-   [SysInfoOsName]{.code} - get the OS name. This returns a string
    giving a short name for the operating system \'MSDOS\', \'WIN32\',
    \'Mac OS\', etc.
-   [SysInfoJpeg]{.code} - can the renderer display JPEG images? Returns
    1 if so, 0 if not.
-   [SysInfoPng]{.code} - can the renderer display PNG images? Returns 1
    if so, 0 if not.
-   [SysInfoWav]{.code} - can the system play WAVE sounds? Returns 1 if
    so, 0 if not.
-   [SysInfoMidi]{.code} - can the system play MIDI sounds? Returns 1 if
    so, 0 if not.
-   [SysInfoWavMidiOvl]{.code} - can the system play WAVE and MIDI
    sounds simultaneously? Returns 1 if so, 0 if not.
-   [SysInfoWavOvl]{.code} - can the system play multiple WAVE sounds
    simultaneously? Returns 1 if so, 0 if not.
-   [SysInfoPrefImages]{.code} - do the user\'s preferences allow images
    to be displayed? Returns 1 if so, 0 if not.
-   [SysInfoPrefSounds]{.code} - do the user\'s preferences allow sound
    effects to be played? Returns 1 if so, 0 if not.
-   [SysInfoPrefMusic]{.code} - do the user\'s preferences allow music
    to be played? Returns 1 if so, 0 if not.
-   [SysInfoPrefLinks]{.code} - do the user\'s preferences allow
    hyperlinks to be displayed distinctively (i.e., not as ordinary
    text, but using a special style to indicate that they\'re links)?
    Returns 1 if so, 0 if not.
-   [SysInfoMpeg]{.code} - can the system play MPEG sounds of any kind?
    Returns 1 if so, 0 if not.
-   [SysInfoMpeg1]{.code} - can the system play MPEG layer 1 (MP1)
    sounds? Returns 1 if so, 0 if not.
-   [SysInfoMpeg2]{.code} - can the system play MPEG layer 2 (MP2)
    sounds? Returns 1 if so, 0 if not.
-   [SysInfoMpeg3]{.code} - can the system play MPEG layer 3 (MP3)
    sounds? Returns 1 if so, 0 if not.
-   [SysInfoLinksHttp]{.code} - can the system follow hyperlinks that
    use the \"http:\" scheme? Returns 1 if so, 0 if not.
-   [SysInfoLinksFtp]{.code} - can the system follow hyperlinks that use
    the \"ftp:\" scheme? Returns 1 if so, 0 if not.
-   [SysInfoLinksNews]{.code} - can the system follow hyperlinks that
    use the \"news:\" scheme? Returns 1 if so, 0 if not.
-   [SysInfoLinksMailto]{.code} - can the system follow hyperlinks that
    use the \"mailto:\" scheme? Returns 1 if so, 0 if not.
-   [SysInfoLinksTelnet]{.code} - can the system follow hyperlinks that
    use the \"telnet:\" scheme? Returns 1 if so, 0 if not.
-   [SysInfoPngTrans]{.code} - can the system properly display
    transparent PNG\'s overlayed on their backgrounds? Returns 1 if so,
    0 if not.
-   [SysInfoPngAlpha]{.code} - can the system use alpha-channel (partial
    transparency) blending in PNG\'s? Returns 1 if so, 0 if not.
-   [SysInfoOgg]{.code} - can the system play Ogg Vorbis sounds? Returns
    1 if so, 0 if not.
-   [SysInfoMng]{.code} - can the system display MNG images? Returns 1
    if so, 0 if not.
-   [SysInfoMngTrans]{.code} - can the system properly display
    transparent MNG\'s overlayed on their backgrounds? Returns 1 if so,
    0 if not.
-   [SysInfoMngAlpha]{.code} - can the system use alpha-channel (partial
    transparency) blending in MNG\'s? Returns 1 if so, 0 if not.
-   [SysInfoTextHilite]{.code} - can the system render highlighted text
    (text in [\<B\>\...\</B\>]{.code} tags) distinctively? Returns 1 if
    so, 0 if not.
-   [SysInfoTextColors]{.code} - does the system provide control text
    colors (via [\<FONT COLOR=xxx\>]{.code} tags)? Returns one of the
    following codes indicating the level of support provided:
    -   [nil]{.code} - the [SysInfoTextColors]{.code} code is not
        recognized by the system
    -   [SysInfoTxcNone]{.code} - no text color control is provided;
        [\<FONT COLOR\>]{.code} is ignored
    -   [SysInfoTxcParam]{.code} - some or all of the parameterized
        color names [(BGCOLOR]{.code}, [TEXT]{.code}, [STATUSBG]{.code},
        [STATUSTEXT]{.code}, etc.) can be used with [\<FONT
        COLOR=xxx\>]{.code}, but specific colors will be ignored
    -   [SysInfoTxcAnsiFg]{.code} - the ANSI colors (black, white, red,
        green, blue, yellow, cyan, magenta) can be used as foreground
        colors, but background colors cannot be set
    -   [SysInfoTxcAnsiFgBg]{.code} - the ANSI colors can be used as
        foreground and background colors.
    -   [SysInfoTxcRGB]{.code} - any RGB color can be used for
        foreground and background colors. (This is the code normally
        returned by the HTML interpreters. This doesn\'t necessarily
        indicate that the user is running in a 24-bit graphic mode; it
        simply indicates that the system accepts arbitrary RGB colors
        and will display them with the best fidelity possible.)
-   [SysInfoBanners]{.code} - does the system support the banner window
    API?
-   [SysInfoAudioFade]{.code} - does the system support audio fades?
    This returns nil or 0 if fades aren\'t supported at all; otherwise
    it returns an integer giving a bitwise combination of the codes
    [SysInfoFadeMPEG]{.code}, [SysInfoFadeOGG]{.code},
    [SysInfoFadeWAV]{.code}, and [SysInfoFadeMIDI]{.code} indicating
    which formats can be used with audio fades. (Audio fading is an HTML
    TADS feature, accessed through the [\<SOUND\>]{.code} tag.
-   [SysInfoAudioCrossfade]{.code} - does the system support audio
    cross-fades? This returns nil or 0 if cross-fades aren\'t supported
    at all; otherwise it returns an integer giving a bitwise combination
    of codes indicating which formats allow cross-fades. The codes have
    the same meanings as the codes returns for
    [SysInfoAudioFade]{.code}.
:::

[]{#tadsSay}

[tadsSay(*val*, \...)]{.code}

::: fdef
Display one or more values. Each value is displayed on the console,
starting with the first argument; the displayed values are not separated
by any spaces or other delimiters. The formatting for each value depends
upon its type:

-   string: the text of the string is displayed
-   integer: the decimal representation of the number is displayed
-   BigNumber: the number is displayed with the default formatting
-   list or Vector: the elements of the list or Vector are displayed in
    order, separated by commas
-   nil: nothing is displayed
-   objects with implicit string conversions (e.g., a
    [ByteArray](bytearr.htm) or [Date](date.htm) object) are converted
    to strings using their default string formatting, and the the
    results are displayed; see the [toString()](tadsgen.htm#toString)
    function
-   any other type is invalid; a run-time error is generated (\"invalid
    type for built-in function\")

The function has no return value.
:::

[timeDelay(*delay*)]{.code}

::: fdef
Pause execution for the given number of milliseconds. The precision of
system timers varies, so the actual delay might differ somewhat from the
exact time specified on some systems according to the available hardware
timer precision.
:::

## []{#rtinput}Real-time input

A real-time event is an event that occurs at a particular point in
\"wall-clock\" time; for example, an event programmed to occur at 9:00
PM is a real-time event, because it\'s scheduled according to time in
the real world. It\'s more typical to schedule a real-time event to
occur after some number of seconds or minutes has elapsed than to
schedule one for a particular time on the clock on the wall, but
elapsed-time events are also real-time events, because they depend on
the passage of time on the clock.

In most programs that take their input from a command line (say, text
adventure games), reading a command line from the user stops everything
until the user finishes entering the command by pressing Enter. This is
known as a \"blocking\" operation, because the operation blocks the
program\'s progress until the command line is finished: the program
simply waits as long as it takes for the user to type the command line
and press the Enter key. For this reason, command-line programs don\'t
usually incorporate real-time events, and most programs with real-time
events don\'t use command lines.

TADS 3 has the ability to mix command-line input and real-time events,
thanks to the [inputLineTimeout()]{.code} function. This section
describes how to use this feature.

Note that the information below applies to the low-level system API. If
you\'re using the adv3 library, you won\'t have to worry about any of
these details, because adv3\'s input and output managers work together
with its real-time event manager to handle all of this for you
automatically. With adv3, you simply create real-time event objects
describing the event timeline, and the library\'s input manager handles
everything else.

The [inputLineTimeout()]{.code} function works a lot like the ordinary
[inputLine()]{.code} function, which reads a line of text from the
keyboard and returns a string containing the text, but
[inputLineTimeout()]{.code} has the additional feature of letting you
specify a time limit, called a \"timeout.\" A timeout is simply a
maximum real-time interval; when the interval expires,
[inputLineTimeout()]{.code} returns, even if the user hasn\'t finished
editing the command line. The function returns information that lets you
tell whether or not the user finished editing the command before the
timeout expired. (If the user finished entering the command and presses
Enter *before* the timeout expires, the function returns immediately -
the timeout is the *longest* the function will wait to return, but it
can return sooner if the user types fast enough.)

At the simplest level, you could imagine a game that imposes a time
limit for typing certain commands. For example, a sadistic game designer
might want to design a traditional adventure game maze, with the novel
twist that the player has to move out of each room within ten seconds of
real time or face some penalty, such as being moved back to the start of
the maze. To do this, you could use [inputLineTimeout()]{.code} with a
timeout value of 10000 (ten thousand milliseconds equals ten seconds),
imposing the penalty if the function ever returns with a timeout.

This type of use of [inputLineTimeout()]{.code} wouldn\'t win many
admirers, but fortunately it\'s not at all the scenario for which this
function was designed. In fact, the key feature of the function is that
it not only allows you to interrupt a command line, but also allows you
to *resume* an interrupted command line. This is crucial: because you
can resume an interrupted command line, you can write your program so
that it continues to process events in real time, even while the user is
editing a command; the user\'s editing and your real-time events can
proceed in parallel, with neither blocking the other.

There are three possible ways to use [inputLineTimeout()]{.code}.

**Scenario 1: Limited-time input.** This is the real-time-maze scenario
described above, where the program solicits command-line input from the
user, but only allows the user a limited amount of time to complete the
input. In this scenario, when the time limit expires, the user\'s chance
to enter a command has ended: the program does not allow the user to
resume editing the command later.

This is the simplest scenario, because the program unconditionally
cancels the input when it times out. To do this, you simply call the
function [inputLineCancel()]{.code} when a timeout occurs. Here\'s how
this looks:

::: code
    /* read a command, with a 10-second time limit */
    local result = inputLineTimeout(10000);
    if (result[1] == InEvtTimeout)
    {
      /* timed out - cancel input and forget the buffer */
      inputLineCancel(true);

      /*
       *  gloat about defeating the user with our clever time
       *  limit ruse, using the spelling enjoyed by usenet
       *  posters everywhere
       */
      "Ha, ha!  You LOOSE!";
      // etc
    }
    else
    {
      /* darn, they were fast enough */
      // move to the new location, etc
    }
:::

**Scenario 2: Internal computation only, with resumed editing.**
Sometimes you\'ll want to perform some operation at a particular time,
but the operation won\'t perform any display operations. For example,
suppose you\'re writing a detective game, and you have one character in
the game who moves around according to a real-time schedule. When
you\'re about to read an input line, you can check the character\'s
schedule, calculate the delay until the character\'s next move, and then
use that delay as the timeout value for [inputLineTimeout()]{.code}.

If [inputLineTimeout()]{.code} returns a timeout event, you\'d move your
character according to the schedule. Now, suppose the character isn\'t
in sight of the player character at any point during the scheduled
travel. In this case, you wouldn\'t want to display anything about the
character\'s travel: everything happens behind the scenes. So, you need
to perform the event in real time, so that the character moves to its
new location on schedule, but as far as the player is concerned, nothing
happened.

In this case, you\'d simply call [inputLineTimeout()]{.code} again after
moving the character. The function would pick up where it left off, with
absolutely no effects visible to the player. Nothing on the display
changes in this case, so the player simply thinks they\'ve been editing
the same command all along.

The code for this is easy, as long as we can take for granted that we
know when the character\'s next move occurs.

::: code
    /* show the initial prompt */
    ">";

    /* keep looping forever */
    for (;;)
    {
      local delay;
      local result;

      /* calculate the interval until the next travel */
      delay = actor.nextMoveTime - getTime(GetTimeTicks);

      /* ask for input, waiting no longer than the timeout */
      evt = inputLineTimeout(delay);

      /* if we timed out, move the character */
      if (result[1] == InEvtTimeout)
      {
        /* time to go */
        actor.performNextTravel();
      }
      else
      {
        /* they entered a command - handle it */
        processCommand(result[2]);

        /* show the prompt again */
        ">";

      }
    }
:::

Note that it\'s legal to update banner windows during interrupted input.
You could use code just like the example above, substituting banner
window displays for the [performNextTravel()]{.code} call. For example,
you could keep a running real-time clock in a banner window, updating it
at each input timeout. As long as you\'re not updating the main window,
where the input editing session is taking place, it\'s not necessary to
cancel input editing (as described in the next scenario).

**Scenario 3: Interruption with a displayed message, then resumed
editing.** This is the most complex situation, but in many ways the most
interesting. In this scenario, we want to tell the user about something
that happened during the real-time event, but we still want to let the
user go back to editing the command line after we finish processing the
event.

Our detective example above fits this scenario when the traveling actor
is in sight of the player character, because in this case we want to
tell the user that the traveling actor has departed or arrived. Once
we\'ve described the departure or arrival, though, we want to let the
user continue editing the command, because the interruption doesn\'t
necessarily change what they would have typed, and (unlike Scenario 1)
doesn\'t take away the user\'s chance to type a command.

In this situation, we have to use the [inputLineCancel()]{.code}
function, passing [nil]{.code} as the *reset* argument. This function
tells the system that we are **not** processing Scenario 2; in
particular, it tells the system that it won\'t be able to pretend that
the interruption never happened. The reason we have to differentiate
this case from Scenario 2 is that when [inputLineTimeout()]{.code}
returns with a timeout, the system optimistically keeps everything on
the screen and in memory in a state where it could resume editing the
same command later. This means that any display operations - even
something as simple as displaying a string of text - would leave things
terribly confused, because the system is holding everything ready for
more command line editing. To tell the system that we wish to give up
our right to resume editing with complete transparency, and in exchange
receive the right to perform other display operations, we use
[inputLineCancel(nil)]{.code}.

Note that we use [nil]{.code} for reset argument to
[inputLineCancel()]{.code} in this scenario. This is because we wish to
resume editing the command line later. This might seem confusing - if we
want to resume editing the command later, why are we canceling in the
first place? The solution to this seeming contradiction is that
canceling and resetting are not the same thing. Canceling, which is what
[inputLineCancel()]{.code} does regardless of the *reset* argument,
simply tells the system to give up hope for transparently resuming
editing. Resetting, which only occurs when the *reset* argument to
[inputLineCancel()]{.code} is true, tells the system to throw away all
information about editing. So, when you cancel without resetting, you
tell the system that you won\'t transparently resume editing, but that
you still wish to resume editing later, albeit not transparently.

Here\'s what this looks like to the user. First, here\'s the way the
screen looks when the user is first presented with the command line:

::: cmdline
    What do you, the detective, want to do next?
    >|
:::

(That vertical bar, [\|]{.code}, is meant to represent the cursor, where
text the user types is inserted.) Now, the user starts typing a command,
and the screen looks like this after a bit:

::: cmdline
    What do you, the detective, want to do next?
    >look at the v|
:::

Now, at this point, our timeout expires, and we discover that it\'s time
to move Miss Marmalade into the same room where the player character is
located. We call [inputLineCancel(nil)]{.code} to tell the system that
we wish to perform some output operations in lieu of resuming editing
transparently, then we add our displayed messages. Finally, we call
[inputLineTimeout()]{.code} again to resume editing. Here\'s what the
user sees:

::: cmdline
    What do you, the detective, want to do next?
    >look at the v

    Miss Marmalade enters from the north.  She pretends
    not to see you, busying herself with rummaging for
    something in her purse.

    >look at the v|
:::

Notice that the partially-constructed command line now appears twice on
the screen - once before the interruption, and again after. The first
copy is no longer the active command line; it\'s left on screen only to
maintain continuity, so that the user isn\'t startled by the text
suddenly disappearing. After this, we see the text displayed during the
real-time interruption, and finally we see the new command line, where
we\'ve reinstated the text the user has entered so far, as well as the
original cursor position.

This is what we mean by \"non-transparent\" resumption of editing. The
resumption isn\'t transparent, in that the user can plainly see on the
screen that the editing was interrupted. We are nonetheless resuming the
editing session fairly seamlessly. If the user had their eyes closed,
they could keep editing the command without knowing that we interrupted
them, because the text on the line, the cursor position, and all other
editing state is the same as it was before the interruption; the only
thing that has changed is that more text is on the screen than when we
started.

The code for this case is almost exactly the same as the example code in
Scenario 2, with two changes. First, we must call
[inputLineCancel(nil)]{.code} before we display the message about Miss
Marmalde moving; we\'d put this call just before the call to
[actor.performNextTravel()]{.code}. Second, we\'d have to re-display the
[\>]{.code} prompt before we resume editing the command; we could do
this before the call to [inputLineTimeout()]{.code}.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> tads-io Function Set\
[[*Prev:* Regular Expressions](regex.htm){.nav}     [*Next:* tads-net
Function Set](tadsnet.htm){.nav}     ]{.navnp}
:::
