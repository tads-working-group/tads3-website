![](topbar.jpg)

[Table of Contents](toc.htm) \| [The System Library](lib.htm) \> Basic
Tokenizer  
[*Prev:* Program Initialization](init.htm)     [*Next:* Miscellaneous
Library Definitions](libmisc.htm)    

# Basic Tokenizer

"Tokenizing" is the process of scanning a string of characters, such as
a line of text that the user types at a command prompt, and converting
the character string into a list of words and punctuation marks. Each
item in this list is called a "token." During parsing, we wish to deal
with tokens, not directly with the original character string; it's much
easier and faster to work with tokens. To parse a string, we must find
word boundaries, skip whitespace, and find matching delimiters (such as
quotes and parentheses); we do all of this work in advance, when we
tokenize the string, so that we don't have to do it repeatedly while
analyzing the syntax of the command.

TADS 3 has no built-in tokenizer. Instead, the system library provides a
class called Tokenizer that does this job. You can create a custom
tokenizer, if desired, by subclassing Tokenizer. The adv3 library does
this to provide a more elaborate set of lexical rules for the English
parser.

## Calling the Tokenizer

To use the Tokenizer class, \#include \<tok.h\> in your source code.
(You'll also have to include the library module tok.t in your build, but
you're probably already doing this indirectly by including the standard
system library file, system.tl, in your build.)

To use the default rules defined in the class, simply use the class
directly; to tokenize a string, make a call like this:

    local str, tokList;

    str = inputLine();
    tokList = Tokenizer.tokenize(str);

The tokenize() method scans the string and converts it into a list of
tokens. The return value is a list consisting of one element per token.
Information about each token can be obtained using the following macros:

- getTokVal(*tok*) returns the parsed value of the token. This is
  usually a string corresponding to the text matched by the regular
  expression, but can be another type if the token rule generated it
  with some other value type.
- getTokType(*tok*) returns the type of the token. This is a token type
  enumerator value assigned by the rule that matched the token. The
  default Tokenizer rules produce tokens of type tokPunct (punctuation
  marks), tokWord (words), tokString (strings), and tokInt (integer
  numbers).
- getTokOrig(*tok*) returns the original source text the token matched.
  This information is included because some token rules perform
  conversions on the value; for example, dictionary word tokens usually
  have their values converted to all upper-case or all lower-case for
  convenience in string comparisons. The original text is included so
  that the exact original token input can be easily reconstructed if
  needed.

The following code displays the parsed value of each token in a string:

    for (local i = 1, local cnt = tokList.length() ; i <= cnt ; ++i)
      "[<<i>>] = <<getTokVal(tokList[i])>>\n";

(For the curious, the actual representation of a token is a list
containing three elements: element 1 is the token value, element 2 is
the token type, and element 3 is the original matched text. For more
readable code and greater flexibility in case of future changes to this
format, you should always use the getTokXxx() macros rather than
referring to the list elements directly.)

## Customizing the Tokenizer

You can customize the rules the Tokenizer class uses. To do this,
subclass Tokenizer and override the rules\_ property. This property's
value must be a list of lists. Each sublist consists of five elements: a
string giving the name of the rule; a regular expression specifying a
pattern to match; a token type, which is the enum token value to assign
to tokens matching the regular expression; a conversion rule, specifying
how the token text to be stored in the result list is obtained; and a
match method property pointer, which allows a programmatic check to
determine whether or not the token matches the rule.

The name is for your use in identifying the rule. You can give a rule
whatever name you like. The tokenizer class has methods that manipulate
the rule set at run-time; rule names are used to identify which rules to
operate on with these methods.

The conversion rule can be nil, a string, or a property pointer. If the
conversion rule is nil, then the token text stored in the result list
will simply be the exact text of the input string that matches the
regular expression. If the rule is a string, it specifies a replacement
string, using the same rules as rexReplace(), that's applied to the
matching text; the result of the replacement is stored in the result
list. If the conversion rule is a property pointer, it specifies a
property (of self, which is the Tokenizer object which is doing the
work) to be evaluated to yield the value to be stored in the result
list; this property is called as follows:

self.(*prop*)(*txt*, *typ*, *results*)

In this argument list, *txt* is a string giving the text that was
matched for the token; *typ* is the token type enum value from the rule
list; and *results* is a Vector containing the token output list under
construction. This method simply adds any number of token entries to the
results list by calling results.append(). The method need not add any
tokens; the default tokenizer rule for whitespace, for example, uses a
processor method called tokCvtSkip(), which doesn't do anything at all,
which means that whitespace characters in the input result in no tokens
in the results list.

The match method can be nil or a property pointer. If it's nil, the
regular expression solely determines what text matches the rule. If the
match method is a property pointer, though, the tokenizer calls the
property (on self, the Tokenizer object which is doing the work) as
follows:

self.(*prop*)(*txt*)

This method can examine the text to determine if it's really a match for
the rule; the method returns true if the text matches the rule, nil if
not. The match method can be used for more complex checks that cannot be
performed with the regular expression pattern; for example, a match
method can check to see if the token is a known dictionary word, so that
a rule only matches known dictionary words.

## Rule Processing Order

The rules are specified in order of priority. The tokenizer starts with
the first rule; if the first rule's regular expression matches (and the
rule's match method, if present, returns true), the tokenizer uses the
match and ignores all of the remaining rules. If the first rule's
regular expression does not match (or its match method returns nil), the
tokenizer tries the second rule, and so on until it runs out of rules.

Each time the tokenizer finds a matching rule, it adds the result of
applying the conversion rule to the result list, along with the token
type specified by the rule. The tokenizer then removes the matching text
from the input string. If that leaves the input string empty, the
tokenizer returns the result list to the caller. If the input string is
not yet empty, the tokenizer starts over, searching from the first rule
to find a match to the remainder of the string. The tokenizer repeats
this process until the input string is empty.

If the tokenizer exhausts its list of rules, it throws a TokErrorNoMatch
exception. This exception object has a property, remainingStr\_, which
gives the text of the remainder of the string at the point at which the
tokenizer could find no matching rule.

## Customization Example

Suppose we wished to build a simple four-function calculator, which
reads arithmetic expressions typed by the user and displays the results.
For this calculator, we'd need to recognize two types of tokens:
operators, and numbers. There's already a tokInt type defined by the
Tokenizer class, but we'd have to define our own token type for
operators:

    enum token tokOp;

The default tokenizer rules won't work for the calculator because they
don't accept all of the punctuation marks we'd need to use for operators
(and besides, the default rules classify the punctuation marks they do
recognize as type tokPunct, when we want tokOp tokens).

We'll need the following token rules:

- Whitespace, which we want to ignore so that the user can use spaces
  freely to format expressions.
- Integers, which consist of a series of one or more digits.
- Operators, which are the special punctuation marks that indicate
  arithmetic operations.

Here's how our subclass would look to implement these rules:

    CalcTokenizer: Tokenizer
      rules_ =
      [
        /* skip whitespace */
        ['whitespace', R'[ \t]+', nil, &tokCvtSkip, nil],

        /* integer numbers */
        ['integer', R'[0-9]+', tokInt, nil, nil],

        /* operators */
        ['operator', R'[()+*-/]', tokOp, nil, nil]
      ]
    ;

To tokenize using our customized rules, we'd simply call our subclasses
tokenizer rather than the default tokenizer:

    tokList = CalcTokenizer.tokenize(str);

------------------------------------------------------------------------

*TADS 3 System Manual*  
[Table of Contents](toc.htm) \| [The System Library](lib.htm) \> Basic
Tokenizer  
[*Prev:* Program Initialization](init.htm)     [*Next:* Miscellaneous
Library Definitions](libmisc.htm)    
