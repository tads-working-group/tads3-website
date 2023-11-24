![](topbar.jpg)

[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
StringComparator  
[*Prev:* StringBuffer](strbuf.htm)     [*Next:* TadsObject](tadsobj.htm)
   

# StringComparator

The [Dictionary](dict.htm) intrinsic class allows the program to
customize how strings in the dictionary are compared to input strings
using a "comparator" object. StringComparator provides an implementation
of the comparator interface that's fast and efficient, since it's
implemented natively in the interpreter.

StringComparator objects can be customized in several ways:

- Case sensitivity: you can control whether or not case is significant.
  In other words, you can specify whether or not a lower-case letter in
  one string can match the corresponding upper-case letter in another
  string.
- Truncation: you can specify whether or not words can be shortened, and
  the minimum length if so. If truncation is allowed, then an input word
  will match a reference (dictionary) word if the input word is at least
  as long as the minimum truncation length, and the input word matches
  the leading substring of the dictionary word of the same length as the
  input word. Hence, if the truncation length is 6, then "flashl" and
  "flashlig" will match "flashlight" (although "flashlamp" will not, as
  it's not a leading substring of "flashlight").
- Character equivalences: you can specify a set of equivalence mappings
  that allow a given sequence of input characters to match one or more
  dictionary characters. This mechanism is specifically designed to
  allow input strings to use approximations of accented letters,
  ligatures, and other special characters, while still retaining full
  information on the actual characters in the input string. See below
  for details.

StringComparator objects are immutable once created, so you cannot
change any of the comparison rules after creating one of these objects.
This is important, because it conforms to the Dictionary class's
requirement that the comparison rules of a comparator must never change
once a comparator is installed. If you want to change a dictionary's
comparison rules dynamically, simply create a new StringComparator (or a
custom comparator object of your own) and install it in the dictionary.

When using the StringComparator class, you must \#include \<strcomp.h\>
in your source files.

## Equivalence mappings

The StringComparator class lets you specify that certain sequences of
characters in an input string can match other characters in reference
(dictionary) strings. This is done through "equivalence mappings," which
specify characters that are considered equivalent for the purposes of
matching strings.

Equivalence mappings are designed primarily to make things easier for
authors and players in games written in languages using accented and
other special characters. Here are the specific cases that went into the
StringComparator's design:

- A player might want to run a German game on a computer localized for
  the US, where it's not convenient to enter accented characters. The
  player might thus want to type simply "o" instead of "ö" or "u"
  instead of "ü".
- In French, it's conventional to elide accents on capitalized letters,
  so we might want "Elan" to match "élan" in the dictionary.
- In German, a pair of lower-case s's is usually, but not always,
  written with the "ess-zet" or sharp-s ligature, "ß". So, we might want
  the input "gross" to match "groß" in the dictionary.
- We might want to allow writing "æ" as "ae".

The simplest way to allow this sort of approximation would be to add a
dictionary entry for each alternative spelling; so in a French game, if
we put "élan" in the dictionary, we'd also include "elan". This approach
has two disadvantages, though. First, it's obviously a lot of extra work
for the author. Second, in cases where accents are significant in
differentiating one word from another, which are common in languages
that use accented letters, the extra words create ambiguity when two
different objects have names that differ only in accents; this ambiguity
is unavoidable if the accent elisions are to be allowed, but adding the
words to the dictionary makes it impossible to turn off the accent
ambiguity, which a player using a properly localized keyboard might want
to do.

Equivalence mappings address these problems by allowing an author to
enter only the exact form of a word into the dictionary, using all of
the proper accents, but still match unaccented characters (or other
approximations) in player input. The dictionary is not affected by the
approximations, so the dictionary retains full information on the
correct form of each word; the input isn't affected, either, so we can
tell whether the user typed an approximation or an exact match.

A StringComparator object can define many equivalence mappings. Each
mapping defines an association between one "reference character" and a
corresponding "input string." A reference character is a single
character that can appear in reference strings; when a StringComparator
is used with a Dictionary object, reference strings are simply the
strings that are stored in the dictionary. An input string defines the
character or characters that will be considered equivalent to the
reference character when the input string appears in input. Each mapping
also defines two "result flags" values: one for an upper-case input
string and one for a lower-case input string; these are bit flag values
that are combined into a matchValues() result when the mapping is
actually used.

For example, in a French game, we might want to allow unaccented
characters in input to match the corresponding accented characters in
dictionary words. To do this, we could provide a mapping of reference
character "à" to "a", from "á" to "a", from "â" to "a", from "é" to "e",
from "è" to "e", and so on.

There are two important constraints on the allowed mappings:

- Each mapping's reference character must be a single character.
- Each reference character can have only one mapping. If the same
  reference character appears in multiple mappings, only the last such
  mapping is used; all of the others are ignored.

## Result flags

The result flags values are used to convey information about the
occurrence of an equivalence mapping to a matchValues() caller. These
are important because they provide a simple way for the caller to
determine whether an input string matched its dictionary word exactly or
using equivalence mappings; furthermore, since each mapping has its own
separate result flags, these allow different mappings to indicate
different results. For example, in a German game, we might want to allow
unaccented character to be used in input to match accented dictionary
words, but count these as weaker matches than if the exact accents were
used; we could do this by adding in a bit flag to each
accented-to-unaccented equivalence mapping, and then test for that flag
in the matchValues() result. However, we might want to consider "ss" as
exactly equivalent to "ß"; to do this, we would use 0 as the
equivalence's result flags, so that as far as the matchValues() caller
is concerned, the a match from "ss" to "ß" is exact.

The result flags differentiate upper-case and lower-case input strings.
Each mapping has an upper-case result flags value, and a lower-case
result flags value. When an equivalence mapping is used to match a
string, only one of the flags is used, based on the first character of
the matching input string: if the first character is an upper-case
letter, the upper-case result flags value is used; otherwise, the
lower-case value is used. (Note that this means that if a non-alphabetic
character is the first character of the input string, the lower-case
value is used.) This distinction is meant to allow mappings to assign
different strengths based on the case of the input. This is useful in
French, for example: accents are typically removed in French writing
when a letter is capitalized, hence we would not want to flag an
unaccented capital as a weak match for an accented letter, as we would
for an unaccented minuscule.

Important: the StringComparator class reserves the low-order 8 bits of
the result flags for its own use. Therefore, any flags defined in
equivalence mappings should use values 0x0100 and above.

## Construction

To create a StringComparator, use the new operator:

new StringComparator(*truncLen*, *caseSensitive*, *mappings*)

The parameters are:

- *truncLen* specifies the minimum truncation length. This is the
  minimum length that an input string must have in order to match a
  longer dictionary string. For example, if you set the truncation
  length to 6, then "flashl" will match "flashlight," because "flashl"
  meets the minimum length requirement and is a leading substring of
  "flashlight"; however, "flash" will not match "flashlight," because,
  at five characters, it doesn't meet the minimum length for truncated
  matches. Specify 0 (zero) or nil if you do not want to allow truncated
  matches at all.
- *caseSensitive* is a flag indicating whether or not the matches are to
  be sensitive to case. If this flag is true, then matches are sensitive
  to case, which means that each character must match exactly. If this
  flag is nil, then matches are insensitive to case, which means that an
  upper-case letter in one string matches the corresponding lower-case
  letter in the other.
- *mappings* is a list (or [list-like object](opoverload.htm#listlike))
  giving the equivalence mappings. This is an empty list, or simply nil,
  if there are no mappings. Each mapping is a sublist, with elements as
  follows: \[*refChar*, *inputStr*, *upperCaseFlags*, *lowerCaseFlags\]*
  - *refChar* is a one-character string giving the "reference"
    character. This is a character from the reference string.
  - *inputStr* is a string of one or more characters giving the "input"
    string that matches the reference character. When this sequence of
    characters occurs in an input string, it will match refChar in the
    reference string.
  - *upperCaseFlags* is an integer value to be OR'd into the result
    flags when this mapping is used to match an upper-case letter in the
    input string. (When the input string is more than one character
    long, then the case of the first letter matched is used to select
    which set of flags to use.)
  - *lowerCaseFlags* is an integer value to be OR'd into the result
    flags when this mapping is used to match a lower-case letter in the
    input string, or to match a non-alphabetic character in the input
    string.

## StringComparator Methods

For more information on how the Dictionary class uses comparators, refer
to the [Dictionary](dict.htm) section.

In addition to the standard Object methods, StringComparator provides
the following methods:

calcHash(*str*)

Calculate a hash value for the given string. Returns an integer giving
the hash value. The hash calculation conforms to the requirement that,
for two strings *s1* and *s2*, if matchValues(s1, s2) indicates a match,
then calcHash(s1) will equal calcHash(s2).

matchValues(*inputStr*, *refStr*)

Compares the two strings, and returns a non-zero integer if the two
strings match, according to the rules defined when the StringComparator
was constructed, or 0 (the integer zero) if the strings do not match.
*inputStr* is the "input" string, which typically will come from user
input or a similar source; *refStr* is the "reference" string, which is
the string against which the input is to be tested. When used with a
Dictionary, the reference string is the string stored in the dictionary.

The return value for a match will always be a non-zero integer. This
value is formed by combining, using bitwise OR, all of the applicable
flags for the match, including the pre-defined flags and the result
flags for all equivalence mappings used to make the match. The following
flag values are pre-defined:

- StrCompMatch (0x0001) - this flag is set for all matching values,
  simply to ensure that, even in the absence of any other flags, a
  non-zero value is returned from matchValues().
- StrCompCaseFold (0x0002) - indicates that the match used "case
  folding," which is to say that one or more upper-case letters in the
  input matched corresponding lower-case letters in the reference
  string, or vice versa. This flag can only be returned when
  case-insensitive matches were selected in the constructor, since a
  case-sensitive comparator will not match strings that differ in case.
- StrCompTrunc (0x0004) - the match was truncated; in other words, the
  input string was a leading substring of the reference string, was
  shorter than the reference string, and was at least the truncation
  length specified when the comparator was created. If truncation was
  disabled when the comparator was created (by setting the truncation
  length to zero or nil), this flag will never be returned, because
  truncated matches will never be allowed.

Note that, in addition to the pre-defined flags listed above,
StringComparator reserves all flag values from 0x0001 to 0x0080, to
allow for future expansion; equivalence mappings should use flag values
0x0100 and above.

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The Intrinsics](builtins.htm) \>
StringComparator  
[*Prev:* StringBuffer](strbuf.htm)     [*Next:* TadsObject](tadsobj.htm)
   
