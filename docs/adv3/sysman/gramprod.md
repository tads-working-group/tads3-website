::: topbar
![](topbar.jpg){border="0"}
:::

::: nav
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> GrammarProd\
[[*Prev:* FileName](filename.htm){.nav}     [*Next:*
HTTPRequest](httpreq.htm){.nav}     ]{.navnp}
:::

::: main
# GrammarProd

The GrammarProd intrinsic class is a specialized pattern-matching class
that\'s designed to be used for implementing parsers. GrammarProd stands
for \"grammar production\", which we\'ll define in a moment.

GrammarProd provides a \"parser\", but it\'s not what we think of as
\"the parser\" in an IF context. GrammarProd\'s parser is essentially a
robotic sentence diagrammer, a la elementary school grammar lessons. Its
function is to take some concrete input text from the user and match it
up to an abstract grammar. Elementary school sentence diagramming is
exactly the same thing: you take a sentence, and you identify how it
divides into phrases and how the phrases combine to form the overall
structure of the sentence. A GrammarProd parser is a useful tool for
building an IF parser, but it\'s only a small part of the overall
parsing process; the rest of the parser must take the sentence diagrams
that GrammarProd produces and imbue them with meaning.

When we talk about a \"grammar\", we\'re using the word in the
computerese sense of a formal description of a language\'s structural
syntax. In concrete terms, a grammar in TADS is a collection of
[grammar]{.code} statements. Each [grammar]{.code} statement defines one
element of a grammar, and how that element is composed of finer elements
defined in other [grammar]{.code} statements. A collection of
inter-related [grammar]{.code} statements amounts to a grammar.

GrammarProd objects are run-time objects representing the parts of the
grammar. Each GrammarProd object corresponds to a set of
[grammar]{.code} statements with the same object name.

For the most part, you won\'t create or manipulate GrammarProd objects
directly. You\'ll usually create them implicitly using the compiler\'s
[grammar]{.code} statement. At run-time, the most common way to use a
GrammarProd object is to carry out a sentence diagramming operation,
which you do by calling the [[parseTokens()]{.code}](#parseTokens)
method on the root GrammarProd object of your grammar.

Starting in TADS 3.1, it\'s possible to create and modify the elements
of a grammar dynamically at run-time. We\'ll see more on this
[later](#dynamics).

You should [#include \<gramprod.h\>]{.code} in your source files that
use GrammarProd objects and methods.

## \"Production\" defined

We use the term \"production\" a lot in this chapter (not surprising,
since it\'s part of the name of the class we\'re talking about!). This
is a technical term in computer parsing. A *production* is an element of
a grammar that\'s composed of smaller parts. For example, if we were
creating a grammar for English, we might include a \"sentence\"
production that consists of a subject, a predicate, and one or more noun
phrases. Each of those parts would in turn be a production, consisting
of smaller word groups. We\'d eventually get down to the level of
individual words (which are usually called \"terminal\" elements of the
grammar, since they don\'t decompose into any finer parts).

Productions are so named because computer parsers are frequently
designed to build grammatical structures by starting at individual words
and working up through sequentially larger structures. Each time a set
of words is recognized as a functional group, the parser produces the
larger structure from the constituent parts, thus the larger structure
is called a production.

One of the most important things about productions is that a production
almost always has more than one way of being built. This is really the
entire point of defining productions, because it allows us to recognize
the different forms a particular syntactic element can take. For
example, in English, there are many different kinds of noun phrases: a
simple noun, an adjective followed by a noun, a pronoun, a possessive
pronoun followed by a noun, a possessive pronoun followed by an
adjective followed by a noun, a possessive prounoun followed by an
adjective followed by another adjective followed by a noun; we could go
on all day. Despite all of these different syntactic forms a noun phrase
can take, though, we can label them all with the generic term \"noun
phrase\". We can then plug the general notion of a \"noun phrase\" into
structures, such as verb phrases or whole sentences. The point is that
the larger structures don\'t have to worry about all the different noun
phrase formats - we don\'t have to define \"verb with possessive noun
phrase\", \"verb with adjective noun phrase\", \"verb with prepositional
noun phrase\", etc - we just define \"verb with noun phrase\", and we
magically have all of those variations by virtue of defining \"noun
phrase\" as the collection of all of them.

## The [grammar]{.code} statement

A grammar rule is defined using the [grammar]{.code} keyword. A
[grammar]{.code} statement is mostly like an ordinary object or class
definition, but with a few added elements:

::: syntax
    grammar prodName [ ( tag ) ]  : rules : superclass [ , superclass ... ] 
      propsAndMethods
    ;
:::

The optional *tag* is a symbol or number token enclosed in parentheses.
This isn\'t required - but if it\'s present, it provides a way to
distinguish the rule from other rules associated with the same
*prodName* at run-time, and to refer to the rule in [modify]{.code} and
[replace]{.code} statements. This *tag* is also included in the string
in the first element returned by the [grammarInfo()]{.code} method, to
distinguish a particular matched rule from other rules for the same
production.

If the tag is present, the combination of the production name, tag, and
parentheses forms the full name of the object. This combination must be
globally unique, just as any other object name must be.

The list of superclasses and the list of properties and methods
(*propsAndMethods*) are defined in exactly as for ordinary objects. The
reason there\'s a superclass list and a property/method list is that the
[grammar]{.code} statement actually does define an ordinary class, in
addition to defining a GrammarProd object. The ordinary class that\'s
defined has no name, but is otherwise like any other class.

The *prodName* specifies the name of the GrammarProd object. A given
production name can occur in any number of [grammar]{.code} statements;
a [grammar]{.code} statement does not uniquely define a production
object, but simply adds one or more alternative syntax rules to the
production. (That\'s why the *tag* is so useful - it lets us identify
the individual [grammar]{.code} statements making up a single
GrammarProd object.)

The *rules* section is a set of one or more syntax rules to be
associated with the production. Each alternative list looks like this:

::: syntax
    itemList [ | itemList ... ] 
:::

The vertical bar \"\|\" (the same symbol used for the bitwise-OR
operator) separates multiple item lists. Using a bar is equivalent to
writing a separate [grammar]{.code} statement for each item list. The
\"\|\" syntax is usually a lot more concise than writing each rule as a
separate statement, since all of the properties and methods you define
for this [grammar]{.code} statement apply to each rule in the item list.

Each item list specifies a syntax rule for the production. An item list
looks like this:

::: syntax
      [ qualifiers ]  [ item [ item ... ]  ]  [ * ] 
:::

Each *item* in the list can be one of the following:

-   A literal string, enclosed in single quotes. This simply matches the
    the text of an input token. If a default Dictionary object is in
    effect at compile-time when the rule is defined (via a
    [dictionary]{.code} statement), the compiler automatically enters
    the text into the Dictionary, associating it with the production
    object and the [miscVocab]{.code} property. Literals are matched
    using the same comparison rule as the Dictionary object used at the
    time of parsing; this means that any case folding, truncation,
    accent elisions, and other special matching rules that the
    Dictionary uses are applied in the same manner to grammar literals.
-   A literal string, enclosed in double quotes. This is identical to a
    string in single quotes. (Double quotes don\'t have their usual
    special meaning here, because there\'s only one kind of string in
    this context. This is intended mostly as a convenience for
    [addAlt()]{.code}, where the whole rule text is given as a
    single-quoted string: using double quotes for the quoted tokens
    within the string avoids the hassle of backslash-escaping the quote
    marks.)
-   A token type name - that is, an [enum token]{.code} symbol. A token
    type item tells the parser to match any input token of the given
    type. For example, the standard library tokenizer defines
    [tokInt]{.code} as the integer token type, so you can match any
    integer in the input with a [tokInt]{.code} item.
-   A dictionary property - a property previously declared with the
    [dictionary property]{.code} statement. This matches an input token
    that appears in the dictionary under the given property.
-   A list of dictionary properties enclosed in angle brackets ([\<
    \>]{.code}), and separated by spaces. This matches an input token
    that appears in the Dictionary under any of the listed properties.
-   A production object (a *prodName* symbol from another grammar
    statement, or even the name of the current statement\'s production
    object). This matches if any of the alternatives defined for the
    sub-production match. Note that you must **not** use the \"tagged\"
    version of the name here: you must use only the *prodName* part. The
    reason is that a reference to a sub-production inherently
    incorporates *all* of the different rules associated with the
    sub-production.
-   A group of alternative sub-lists enclosed in parentheses, with the
    alternative sub-lists separated by vertical bars ([\|]{.code}).

Each item type can optionally be followed by an arrow symbol,
[-\>]{.code} (a hyphen followed by a greater-than sign), then a property
name. If this sequence is present, it indicates that, when the parser
successfully matches the item, it will store the matching value in the
given property of the object created to represent the production match.
For a token type or dictionary property item, the value stored in the
property is simply the token value of the input token that matches the
item. For a sub-production item, the value stored in the property is the
object created to represent the sub-production match.

If an asterisk ([\*]{.code}) is present, it must be the last element of
the item list. This symbol indicates that any input tokens that remain
in the input after the tokens that match the syntax rule up to this
point should simply be ignored. In a sense, the [\*]{.code} is a
\"wildcard\" symbol that matches everything remaining in the input token
list; however, you shouldn\'t think of it this way, because that\'s not
really how it works. The [\*]{.code} doesn\'t actually match anything;
instead, it simply indicates that any remaining tokens should be
ignored. If an alternative of the root production does not end with a
[\*]{.code} symbol, either directly in the rule of the alternative in
the root production or indirectly in the last subproduction, the parser
will match the alternative only if the root alternative matches the
entire input token list. If the root alternative does end (directly or
indirectly) with the [\*]{.code} symbol, however, the parser will match
the alternative even if extra input tokens remain after matching the
alternative\'s items. The [\*]{.code} symbol, if present, must always be
the last item in an alternative\'s list.

The optional *qualifiers*, if present, specify additional information
about the alternative. Only one qualifier is currently valid:

::: syntax
    [ badness integer ]
:::

This qualifier assigns the alternative a \"badness\" rating, which can
be used to create catch-all syntax patterns that you don\'t want to use
except as a last resort. The *integer* value gives the degree of
badness; this value is meaningful only relative to other \"badness\"
values assigned to other productions. When GrammarProd is considering
more than one rule with badness for a possible match, it picks the one
with the lowest badness first.

Assigning a badness rating tells the parser that the alternative should
be ignored until all other alternatives are exhausted. This is
especially useful for handling syntax errors in the user input, because
it allows you to create alternatives that match anything in particular
parts of the input, which helps pinpoint where the problem is, which in
turn lets you give the user better feedback about the problem.

## Using [modify]{.code} and [replace]{.code} with grammar rules

A grammar rule object can be replaced or modified by another grammar
rule, just as a normal object can be replaced or modified, using the
[replace]{.code} and [modify]{.code} keywords. For example, you might
want to modify or replace a grammar rule when you\'re using a library,
since the library might define general-purpose rules that don\'t exactly
fit your needs.

To use [modify]{.code} with a grammar rule, use this syntax:

::: syntax
    modify grammar prodName ( tag ) : rules :
      propsAndMethods
    ;
:::

This is *almost* the same as the normal [grammar]{.code} syntax, but
note that no class list follows the colon after the rule list. No
superclasses are specified with [modify]{.code}, because a modified
object always has the same superclass or superclasses as the original
object being modified. Note also that the *tag* is required, because
this provides the unique name for the match object that distinguishes it
from other match objects defined for the same production name.

Note that the *rules* list is optional: if you leave it out (so you just
put two colons in a row after the name), then the compiler retains the
original rule list for the object being modified. This lets you override
just the properties or methods of the grammar rule object, without
changing any of the grammar it matches.

To use [replace]{.code} with a grammar rule, use this syntax:

::: syntax
    replace grammar prodName ( tag ) : rules : superclass [ , superclass ... ] 
      propsAndMethods
    ;
:::

This is exactly the same as a normal [grammar]{.code} definition, except
that the [replace]{.code} keyword precedes the definition.

If you use [replace]{.code} or [modify]{.code} with a grammar rule, the
original grammar rule is completely replaced by the new grammar rule. In
this respect, [replace]{.code} and [modify]{.code} behave exactly the
same way. The differences between the two are their treatment of the
original object\'s property list (in the case of [replace]{.code}, the
original list is completely lost; in the case of [modify]{.code}, the
original properties are inherited by the modified object) and of the
original\'s superclass ([replace]{.code} specifies a brand new
superclass, and [modify]{.code} uses the original object\'s superclass).

If you want to delete an existing grammar rule entirely, you can use the
[replace]{.code} syntax, and specify an unmatchable rule list. A rule
list is unmatchable if it contains a token string that the tokenizer
will never produce; for example, in most cases, tokenizers do not return
spaces as tokens, so you can use the string [\' \']{.code} as an
unmatchable alternative:

::: code
    replace grammar nounPhrase(1): ' ': object;
:::

## [grammar]{.code} defines *two* objects

The [grammar]{.code} statement is unusual in that it defines not one,
but two separate objects.

First, a [grammar]{.code} statement defines - or adds to - a GrammarProd
object. This object\'s name is given by the *prodName* in the
[grammar]{.code} statement.

A [grammar]{.code} statement can \"add to\" a GrammarProd object. It\'s
legal to write multiple [grammar]{.code} statements that define the same
*prodName*, as long as they have distinct *tag* names. The compiler
automatically gathers together all of these different definitions and
rolls them into a single GrammarProd object in the final program.

Second, the statement defines a separate class called the *match object
class*. This class doesn\'t have a symbol name that you can refer to in
your program, so you can\'t, for example, define a subclass of it.
However, for the purposes of [modify]{.code} and [replace]{.code}, its
name is *prodName*(*tag*), and at run-time the same name is used in
string form to identify the rule.

At run-time, you can call methods on the GrammarProd object. For
example, the [parseTokens()]{.code} method is used to match an input
string to the GrammarProd\'s rules. The [parseTokens()]{.code} method in
turn returns a description of the match, if it can find one, that uses
instances of the *match object class* to represent the precise
[grammar]{.code} rules that the input was found to match. []{#dynamics}

## Changing the grammar at run-time

Starting in TADS 3.1, you can add new grammar rules and change existing
rules at run-time.

You can create an entirely new production object with the [new]{.code}
operator:

::: code
    local prod = new GrammarProd();
:::

This creates an unnamed production with no rules. You can add rules to
the new production with the [addAlt()](#addAlt) method. For example:

::: code
    prod.addAlt('noun->n1', new NounPhraseProd(), cmdDict, symtab);
:::

Once you have a new production set up, you can use it as the root of the
grammar for parsing purposes, simply by calling
[parseTokens()](#parseTokens) on the production:

::: code
    prod.parseTokens(toks, cmdDict);
:::

In many cases, after you create a new production, you\'ll want to refer
to it as a sub-production within other rules. Newly created rules are
always defined symbolically, so the question is, how do we refer to an
unnamed new object symbolically? The trick is that you can manually add
the new object to your copy of the symbol table. A symbol table is just
a LookupTable, after all, so you\'re free to invent new symbol names.

::: code
    symtab['myNewProd'] = prod;
    nounPhrase.addAlt('myNewProd->p1', new NounPhraseProd(), cmdDict, symtab);
:::

[addAlt()]{.code} isn\'t limited to working with newly created
productions. As you can see above, you can also use it to add to the
grammar of productions defined statically in the program\'s source code,
with [grammar]{.code} statements. What\'s more, the
[[deleteAlt()]{.code}](#deleteAlt) and
[[clearAlts()]{.code}](#clearAlts) methods let you remove rules from an
existing production. You can combine these methods to rewrite any part
of the grammar on the fly. []{#dynamicMatchObj}

### Match objects for new rules

When you define rules statically with [grammar]{.code}, remember that
the compiler automatically creates a \"match object class\" for you.
This object is unnamed, but it\'s not completely invisible: whenever
[parseTokens()]{.code} matches input to that [grammar]{.code} rule, it
creates an instance of the match object, and returns that instance in
the tree of objects representing the parsing match.

When you use [addAlt()]{.code} to create a new rule dynamically,
there\'s no [grammar]{.code} statement involved, and the system doesn\'t
automatically create a match object for you. But a match object is still
needed - without a match object, there\'d be no way to represent a match
to the new rule in [parseTokens()]{.code} results. So where does the
match object come from? It\'s up to you to create one, and pass it to
[addAlt()]{.code} as a parameter.

You can in principle use any object for the match object in
[addAlt()]{.code}, but there are two special guidelines you should keep
in mind:

-   First, you should **create a new object for each [addAlt()]{.code}
    call**. [addAlt()]{.code} automatically adds some information to the
    match object to describe the alternatives it\'s associated with.
    It\'s important to keep this information separate for each
    [addAlt()]{.code} call. In particular, [addAlt()]{.code} adds a
    [grammarAltProps]{.code} property, containing a list of the
    \"[-\>]{.code}\" properties used in the rules being added.
-   Second, each dynamic match object should **inherit from
    DynamicProd**, which is a class defined in the library file
    [gramprod.t]{.code}. (You should include this file in your project.)
    DynamicProd is a simple mix-in class, so you can inherit from other
    classes as well. DynamicProd is important because it defines a
    [grammarInfo()]{.code} method for dynamic match objects parallel to
    the one that the compiler automatically builds for statically
    defined match objects.

## GrammarProd methods

[]{#addAlt}

[addAlt(*alt*, *matchObj*, *dict*?, *symtab*?)]{.code}

::: fdef
Add an alternative or set of alternatives to the production.

*alt* is a string containing the alternative(s) to add. This uses the
same syntax as \"rules\" list in a [grammar]{.code} statement. You can
define multiple alternatives as usual using \"\|\" symbols within the
string.

*matchObj* is the match object class for the new rule(s). In a static
[grammar]{.code} statement, the compiler creates the match object class
automatically, as an unnamed object with the superclasses listed in the
[grammar]{.code} statement. When you add rules with [addAlt()]{.code},
you must explicitly supply the match object. See
[above](#dynamicMatchObj) for guidelines on how to create this object.

The method adds the property [grammarAltProps]{.code} to *matchObj*.
This property is set to a list of all \"[-\>]{.code}\" properties used
within the alternatives defined for the match object. The method
*doesn\'t* add [grammarTag]{.code} or [grammarInfo]{.code} properties,
but if *matchObj* inherits from DynamicProd as
[recommended](#dynamicMatchObj), it will inherit a [grammarInfo]{.code}
method that works the same as in a statically defined match object. You
can explicitly add a [grammarTag]{.code} property if you wish (it can be
useful for debugging, for example), but it\'s not required.

*dict* is an optional [Dictionary](dict.htm) object, giving the
dictionary associated with this grammar. If this is provided, and the
new alternatives contain literal tokens, [addAlt()]{.code} automatically
adds those literals to the dictionary. This keeps the dictionary in sync
with the vocabulary used in dynamically added rules.

*symtab* is an optional lookup table containing the compiler\'s global
symbols. If you use any symbol names in the alternative (such as
property names or other GrammarProd object names as sub-productions),
the symbol table is required for resolving those symbols. In most cases,
you should simply use the same symbol table that
[t3GetGlobalSymbols()](t3vm.htm#t3GetGlobalSymbols) returns during
preinit, since that reflects the global symbols defined in the
program\'s source code.
:::

[]{#clearAlts}

[clearAlts(*dict*?)]{.code}

::: fdef
Delete all existing alternatives (token rules) in the production. This
is equivalent to calling deleteAlt() for each alternative.

*dict* is an optional [Dictionary](dict.htm) object to be updated for
the deletion. If this is provided and not [nil]{.code}, the dictionary
will be updated to remove literal tokens associated with the production
that are being deleted by this method. This keeps the dictionary in sync
with the changes to the grammar.
:::

[]{#deleteAlt}

[deleteAlt(*id*, *dict*?)]{.code}

::: fdef
Delete one or more alternatives (token rules) from the production. *id*
specifies which alternative(s) to delete:

-   By tag: if *id* is a string, the method deletes each alternative
    whose match object\'s [grammarTag]{.code} property equals *id*. The
    compiler automatically sets the [grammarTag]{.code} property for
    each match object defined in a [grammar]{.code} statement to the
    statement\'s tag, so this makes it easy to delete all of the rules
    defined in a single [grammar]{.code} statement.
-   By match object class: if *id* is an object, the method deletes each
    alternative whose match object is either equal to *id* or is a
    subclass of *id*.
-   By index: if *id* is an integer, it gives the index of the
    alternative to delete. This corresponds to an index in the list
    returned by [getGrammarInfo()]{.code}; the first alternative\'s
    index is 1. This deletes one alternative.

*dict* is an optional [Dictionary](dict.htm) object to be updated for
the deletion. If this is provided and not [nil]{.code}, the dictionary
will be updated to remove any literal tokens associated with the
production that are being deleted by this method. This keeps the
dictionary in sync with the changes to the grammar.
:::

[getGrammarInfo()]{.code}

::: fdef
The GrammarProd class provides access to the internal definition of a
grammar production object via the [getGrammarInfo()]{.code} method. This
gives you complete information on the [grammar]{.code} statements in the
program. You could in principle use this information to write a
replacement for [parseTokens()]{.code}, since the method provides access
to all of the information available to the intrinsic class.

You\'ll notice as you read through the descriptions below of the data
structures that the data structures map directly to the parts of the
[grammar]{.code} statement. This is no accident;
[getGrammarInfo()]{.code} in essence just returns a run-time
representation of the same information that you define in source code
using the grammar statement.

This method returns a list, containing zero or more objects of class
GrammarAltInfo (this name isn\'t actually anything special to the
intrinsic class; it\'s rather an \"imported\" class that the basic
run-time library defines in the source file gramprod.t). Each
GrammarAltInfo object in the list defines one alternative in the
production\'s alternative list.

(Recall that an alternative consists of a qualifier (such as a
[\[badness\]]{.code} value) and a series of tokens, and that multiple
alternatives can be associated with one production, either by separating
them with [\|]{.code} symbols or by writing multiple grammar statements
associated with the same named production. Each GrammarAltInfo object
represents one complete group of tokens-a run of tokens between
[\|]{.code} symbols. Note that the compiler automatically \"flattens\"
any parenthesized token groups to construct equivalent completely
un-parenthesized token lists. For example, if you write a rule that says
[\'a\' (\'b\' \| \'c\')]{.code}, the compiler automatically converts
this to the equivalent [\'a\' \'b\' \| \'a\' \'c\']{.code}, leaving no
parenthesized groups. This is why you won\'t find any representation of
parenthesized groups in what getGrammarInfo() returns-there simply
isn\'t any such thing after the compiler has finished processing the
source code. This greatly simplifies the information representation at
run-time.)

Here\'s what a GrammarAltInfo object looks like:

::: code
    class GrammarAltInfo: object
      gramBadness = 0
      gramMatchObj = nil
      gramTokens = []
    ;
:::

The [gramBadness]{.code} property gives the \"badness\" value for the
alternative; this is the value specified in the [\[badness\]]{.code}
qualifier in the grammar statement that defined the alternative. If no
[\[badness\]]{.code} qualifier is present, this value will be zero.

The [gramMatchObj]{.code} property gives the \"match object\" for the
alternative. This is the class that [parseTokens()]{.code} will
instantiate to represent the match when the input token list is found to
match the alternative - that is, this is the object that\'s defined
directly by the [grammar]{.code} statement itself. (Recall that each
grammar statement actually defines two objects: the GrammarProd object
and the match class. The GrammarProd object is only indirectly defined,
in that multiple grammar statements can add alternatives to the same
GrammarProd object, hence any one grammar statement only partially
defines the associated GrammarProd object. The match object is a
TadsObject class that\'s uniquely defined by the [grammar]{.code}
statement.)

The [gramTokens]{.code} property gives a list of the token slots making
up the alternative. This is a list of GrammarAltTokInfo objects (as with
GrammarAltInfo, this class name isn\'t anything special to the intrinsic
class; it\'s simply imported from the library, which defines the class
in gramprod.t). The list is in the same order as the tokens appear in
the grammar statement, which is the order in which they\'re matched to
an input token list.

Each GrammarAltTokInfo object describes one token slot. These correspond
to the \"items\" in the \"item lists\" making up an alternative in a
grammar statement. Here\'s what a GrammarAltTokInfo object looks like:

::: code
    class GrammarAltTokInfo: object
      gramTargetProp = nil
      gramTokenType = nil
      gramTokenInfo = nil
    ;
:::

The [gramTargetProp]{.code} property gives the property ID of the
\"target\" property for the token slot. This is simply the property that
appears following a [-\>]{.code} symbol in a grammar statement. When
GrammarProd.parseTokens() finds a match to a production, it constructs a
match object to represent the match and then sets the property indicated
here in the match object to the actual matched value for the token slot.

The [gramTokenType]{.code} property gives the type of value this token
slot matches, and gramTokenInfo gives extra information that depends on
the type. This type will be one of the following (these values are
defined in the system header file gramprod.h):

-   [GramTokTypeProd]{.code}: the token slot is a reference to a
    sub-production (that is, another GrammarProd object), and the slot
    matches the corresponding part of the input token list if and only
    if the sub-production matches the input tokens. For this type of
    token slot, gramTokenInfo contains a reference to the sub-production
    (a GrammarProd object).
-   [GramTokTypeSpeech]{.code}: the token slot matches a specific \"part
    of speech.\" This means that the token slot matches a single input
    token, and matches if and only if the input token has the same part
    of speech as the token slot. A part of speech is simply a
    \"dictionary property\" value, and a token has a given part of
    speech if it appears in the Dictionary passed to
    [parseTokens()]{.code} under the same dictionary property value. The
    [gramTokenInfo]{.code} in this case will be the property ID of the
    dictionary property (e.g., [&noun]{.code}).
-   [GramTokTypeNSpeech]{.code}: the token slot matches any of several
    parts of speech. This is just like [GramTokTypeSpeech]{.code}, but
    the slot will match any one of a list of property values. The
    [gramTokenInfo]{.code} value in this case will be a list of property
    IDs.
-   [GramTokTypeLiteral]{.code}: the token slot matches a literal
    string. In this case, an input token will match the token slot only
    if the input token compares equal to the literal, using the
    Dictionary\'s string comparator. In this case, the
    [gramTokenInfo]{.code} value is a string giving the literal text to
    be matched.
-   [GramTokTypeTokEnum]{.code}: the token slot matches a token type.
    This means that an input token will match the token slot only if the
    input token has the given token type. A token type is simply an
    \"enum\" value defined with the \"enum token\" syntax; each token in
    an input list has a token type, assigned by the tokenizer and stored
    in the standard token list format. In this case, the
    [gramTokenInfo]{.code} value will be the \"enum\" value giving the
    token type that the slot matches.
-   [GramTokTypeStar]{.code}: the token slot matches all remaining input
    tokens. This is used to create an alternative that allows a match
    with more tokens left after the end of the alternative\'s explicitly
    listed tokens. There\'s no extra information for this token slot
    type, so [gramTokenInfo]{.code} is simply [nil]{.code} in this case.

You might be wondering what the difference is between
[GrammarProd.getGrammarInfo()]{.code} and the match object\'s
[grammarInfo()]{.code} method. The difference is that
[GrammarProd.getGrammarInfo()]{.code} gives you information on the
grammar itself, whereas the match object\'s [grammarInfo()]{.code} gives
you information on the *matched* syntax - that is, it tells you how a
particular input token list matched a particular grammar using
[parseTokens()]{.code}.

So, the match object\'s [grammarInfo()]{.code} gives you information on
the syntax of a *particular input token list*. In contrast,
[GrammarProd.getGrammarInfo()]{.code} tells you about the grammar
itself, independent of any input token list; it returns a direct
representation of the information defined in [grammar]{.code} statements
that appeared in the source code.
:::

[]{#parseTokens}

[parseTokens(*tokenList*, *dict*)]{.code}

::: fdef
This method matches input, in the form of a list of tokens, to the
GrammarProd object\'s rule list.

*tokenList* is a list of input tokens to match to the rule. (This can be
a list, a vector, or a [list-like object](opoverload.htm#listlike).)
Each entry in the list is a token specifier, which is a sublist
consisting of at least two elements: the first element is the value of
the token, and the second element is the type of the token. Each
token\'s sublist can include more elements if desired; the parser will
preserve the additional elements, but doesn\'t currently use any beyond
the first two. This format is compatible with the format produced by the
system library\'s Tokenizer class, so you can simply feed a token list
produced by a Tokenizer object directly into the [parseTokens()]{.code}
method.

*dict* is a Dictionary object, or [nil]{.code} if no dictionary is to be
used. If this argument is not [nil]{.code}, it must be an object of
intrinsic class Dictionary. If any of the syntax rules that the parser
encounters include dictionary property items, the parser will look up
the corresponding token in the given dictionary to determine the
properties under which the word is defined. A dictionary is not required
if no dictionary properties are used in the syntax rules to be examined.
The dictionary also specifies how literals in grammar rules are matched
to tokens: literals are matched using the Dictionary\'s \"comparator\"
object, so that literals are matched using the same rules that the
Dictionary uses to match tokens against dictionary words.

You always call this method on the \"root\" production of the grammar
you wish to match. There\'s nothing special about a root production
object - you can use any production here. For example, if you want to
parse just a noun phrase, you can call [parseTokens()]{.code} on your
noun phrase production object, even if the noun phrase production is
used as a sub-production in other rules.

This method returns a list of matches. If the return list is empty, it
indicates that there were no matches at all. Otherwise, each entry in
the list is the top object of a \"match tree.\"

A match tree is a tree of objects that the parser dynamically creates to
represent the syntax structure of the match. Each object is an instance
of one of the *match object classes* defined in a [grammar]{.code}
statement. Each of these objects has the properties that appear after
arrow symbols ([-\>]{.code}) in the grammar item list set to the actual
values from the input token list.
:::

## Finding the original tokens

As [parseTokens()]{.code} builds the match tree, it sets properties of
each match object to indicate the indices of the first and last tokens
involved in the match; these bounds are inclusive. The properties the
parser sets are called [firstTokenIndex]{.code} and
[lastTokenIndex]{.code}.

In addition, [parseTokens()]{.code} automatically sets the
[tokenList]{.code} property of each match tree object to a reference to
the original token list passed into [parseTokens()]{.code}. So, for a
given match tree object match, the tokens matching the production can be
obtained as follows:

::: code
    toks = match.tokenList.sublist(
       match.firstTokenIndex, 
       match.lastTokenIndex - match.firstTokenIndex + 1);
:::

In addition to the token list, [parseTokens()]{.code} stores a list of
\"match results\" in each object in the match tree, in the property
[tokenMatchList]{.code}. This list gives the result of the
[matchValues()]{.code} method in the Dictionary\'s comparator object for
each token that matched a literal in a grammar rule. Each element of
this list gives the match result for the corresponding element of the
token list, so [tokenMatchList\[3\]]{.code} gives the
[matchValues()]{.code} result for the third token. If a token matches a
dictionary property rather than a literal, its [tokenMatchList]{.code}
entry will be [nil]{.code}, since [matchValues()]{.code} is not used to
match such tokens.

The [tokenMatchList]{.code} information can be used to find out how well
a particular token matched a grammar literal. For example, this can be
used to determine if the token matched with truncation, or with accent
substitution using an equivalence mapping (see the [StringComparator
class](strcomp.htm) for more details on these types of matches).

(Note: to be precise, the parser uses the properties exported under the
global names \"GrammarProd.firstTokenIndex\" and
\"GrammarProd.lastTokenIndex\" for the indices,
\"GrammarProd.tokenList\" for the token list, and
\"GrammarProd.tokenMatchList\" for the token match result list. Since
the GrammarProd header file, [\<gramprod.h\>]{.code}, defines these
exports, most users can ignore this detail.)

## grammarTag

Each match object class defines the property [grammarTag]{.code} as a
string value containing the \"tag\" for the grammar rule that defined
it. This property definition is automatically supplied by the compiler
for each match object defined by a [grammar]{.code} statement.

Note that when you add a grammar rule dynamically with the
[addAlt()]{.code} method, this property isn\'t automatically added to
the match object class you supply. You can manually define the property
on the match object if you wish.

## grammarInfo

The compiler automatically generates a method called
[grammarInfo()]{.code} for each match object class. This method provides
information that allows the program to traverse a match tree without
knowing anything about the structure of the tree, which is useful for
debugging as well as for searching a tree for particular types of
matches.

Note that when you add a grammar rule dynamically with the
[addAlt()]{.code} method, the [grammarInfo()]{.code} method isn\'t
automatically added to the match object class you supply. You must
manually define this method if you want it to be available for a
dynamically added rule.

The [grammarInfo()]{.code} method returns a list. The first element in
the list is the name of the match, which is simply the name of the
production, plus the tag if one was specified. Each subsequent element
is the value of one of the properties used after an arrow ([-\>]{.code})
in the production\'s rule or rules; the properties appear in the list in
the same order they are specified in the rule. If the rule contains
multiple alternatives, each property appears only once in the list.

For example, suppose we define a rule like this:

::: code
    grammar nounPhrase(1): adjective->adj_ noun->noun_ : object;
:::

Now, suppose this rule matched the input \"magic book.\" The
[grammarInfo()]{.code} method for the match object would look like this:

::: code
    ['nounPhrase(1)', 'magic', 'book']
:::

The first element is the production name with its tag. The second
element is the value of the [adj\_]{.code} property, which in this case
is the literal token matched; likewise, the third element is the value
of the [noun\_]{.code} property, which is another literal token.

The [grammarInfo()]{.code} method can be used to write generic routines
that traverse arbitrary match trees. For example, we could write a
simple routine to display, for debugging purposes, the contents of a
match tree:

::: code
    showGrammar(match, indent)
    {
      local info;

      /* indent by the desired amount (two spaces per level) */
      for (local i = 0 ; i < indent ; ++i)
        "\ \ ";

      /* if it's not a sub-production, treat it specially */
      if (match == nil)
      {
        /* this tree element isn't used - skip it */
        return;

      }
      else if (dataType(match) == TypeSString)
      {
        /* it's a literal token match - show it */
        "'<<match>>'\n";
        return;
      }

      /* get the grammar info for the object */
      info = match.grammarInfo();

      /* show the production rule name, and the original text it matched */
      "<<info[1]>> [<<showGrammarText(match)>>]\n";

      /* show each sub-match */
      for (local i = 2 ; i <= info.length ; ++i)
        showGrammar(info[i], indent + 1);
    }

    /* show the text of a match tree item */
    showGrammarText(match)
    {
      for (local i = match.firstTokenIndex ; i <= match.lastTokenIndex ; ++i)
      {
        /* show a space before each entry except the first */
        if (i != match.firstTokenIndex)
          " ";

        /* show this token's text */
        "<<match.tokenList[i]>>";
      }
    }
:::

## Sample Grammar Rules

Let\'s define some grammar rules for a very simple noun phrase parser.
For the purposes of this example, we\'ll keep things very simple: our
noun phrases will consist of a noun, or an adjective and a noun, or an
adjective and an adjective and a noun, or so on.

The simplest way we could define these rules is by enumerating all of
the different phrasings we could use. So, we could write something like
this:

::: code
    grammar nounPhrase: noun->noun_: object;
    grammar nounPhrase: adjective->adj_ noun->noun_: object;
    grammar nounPhrase: adjective->adj1_ adjective->adj2_ noun->noun_:
      object;
    grammar nounPhrase: adjective->adj1_ adjective->adj2_
      adjective->adj3_ noun->noun_: object;
:::

And so on, up to some fixed limit to the number of adjectives we\'ll
allow.

Now, this will work, but it\'s not very flexible. If we stop at six
adjectives, users might complain that they can\'t use eight. We could
add phrasings for seven and eight adjectives, but then users might
complain about ten. Our work would never end.

Fortunately, there is a more general approach. The recursion-minded
reader might have by now observed that we could in principle express a
rule for an unlimited number of adjectives by saying that a noun phrase
is a noun, or an adjective followed by a noun phrase. This neatly
subsumes any number of adjectives: with one adjective, we have a noun
phrase consisting of an adjective followed by a noun phrase consisting
of a noun; with two adjectives, we have an adjective followed by a noun
phrase which consists of an adjective followed by a noun phrase which
consists of a noun; and so on.

Not only can we express our noun phrase syntax this way in principle, we
can express it this way in fact. This is precisely the kind of thing at
which our production scheme excels. Here\'s the simpler and much more
flexible noun phrase grammar:

::: code
    grammar nounPhrase: noun->noun_: object;
    grammar nounPhrase: adjective->adj_ nounPhrase->np_: object;
:::

That\'s it - this completely solves our problem, no matter how many
adjectives our verbose user types. Suppose the user types \"little red
wagon\": we first match the second alternative (with adjective
\"little\"), leaving \"red wagon\" still to be parsed; we then match the
second alternative again (with adjective \"red\"), leaving just
\"wagon\" remaining; and finally we match the first alternative (with
noun \"wagon\"). Here\'s how we actually call the parser to parse this:

::: code
    match = nounPhrase.parseTokens(tokList, gDict);
:::

(Where do we get the [tokList]{.code} value to pass into the method? We
can use the standard run-time library class Tokenizer, or a subclass,
and call its [tokenize()]{.code} method to produce a token list from a
simple string we want to parse.)

So, what good is all of this? Yes, we\'ve built a set of rules that
define a syntax structure, and we know how to call the parser to scan
the rules. However, how do we actually use this for anything? What do we
know, apart from whether or not an input token list matches the syntax?
It turns out we know a great deal.

When the parser matches our syntax lists, it creates \"match trees\"
that give us the details of exactly how the input tokens are structured,
according to our grammar. The match tree consists of objects that the
parser creates dynamically; these objects are instances of our grammar
objects-not of the production objects, but of the unnamed \"processor\"
objects that go with the grammar statement.

Let us, for the moment, assign some arbitrary labels to our processor
objects. These aren\'t really class names - we\'re just using these to
keep track of what\'s going on:

::: code
    grammar nounPhrase: noun->noun_: object; // pseudo-class "A"
    grammar nounPhrase: adjective->adj_ nounPhrase->np_: 
      object; // pseudo-class "B"
:::

When we call the [parseTokens()]{.code} method, the parser builds up
match trees consisting of instances of \"A\" and \"B\". For our \"little
red wagon\" example, here\'s what the match tree looks like, assigning
arbitrary names to the objects (which wouldn\'t really happen, since
they\'re dynamically created):

::: code
    obj1: B  adj_ = 'little'  np_ = obj2 ;
    obj2: B  adj_ = 'red'     np_ = obj3 ;
    obj3: A  noun_ = 'wagon' ;
:::

The \"root\" of the match tree is obj1. This example might make it more
apparent why we call this a \"tree\": obj1 is the root, with an
adjective on one branch and obj2 on the other; obj2 in turn branches to
an adjective and obj3; and obj3 has a noun.

The next step in making these match trees useful is to give them some
methods.

The fact that a nounPhrase can be used in syntax anywhere a noun phrase
is required means that all of the different alternative forms of noun
phrases should provide a common interface. Clearly, they don\'t right
now: each alternative has its own set of properties. However, these
properties are not meant as a public interface; they\'re intended only
for the use of the specific alternative processor object. What we must
now do is define a public interface, which provides a common set of
functionality for every nounPhrase alternative, and then specify an
alternative-specific implementation of the public interface; the
implementation effectively provides the bridge from the
alternative-specific properties to the common information that any noun
phrase must provide. For now, though, let\'s define a very simple public
interface that simply provides a debugging display of the object. To do
this, we\'ll define a method, debugPrint(), that any nounPhrase
processor object must provide. Here\'s how we could implement this:

::: code
    grammar nounPhrase: noun->noun_: object
      debugPrint() { "noun phrase: noun = <<noun_>>\n"; }
    ;
    grammar nounPhrase: adjective->adj_ nounPhrase->np_: object
      debugPrint()
      {
        "noun phrase: adjective = <<adj_>>, nounPhrase = {\n";
        np_.debugPrint();
        "}\n";

      }
    ;
:::

Note how the public interface method is implemented in every noun phrase
processor object, but the actual implementation varies according to the
underlying information in the processor object. We actually take
advantage of this in the recursive call to np\_.debugPrint() in the
second alternative: we know for a fact that np\_ refers to a noun phrase
processor object, because our syntax says so, so we can call its
debugPrint() method without having to know what kind of nounPhrase it
is. This is important in our \"little red wagon\" example, because
we\'ll actually have both kinds of nounPhrase alternatives present.

Here\'s some code that will parse a noun phrase and then show the
debugging display for the result:

::: code
    local str;
    local toks;
    local match;

    /* ask for a string of input */
    ">";
    str = inputLine();

    /* tokenize the string with the standard tokenizer */
    toks = Tokenizer.tokenize(str);

    /* parse the tokens */
    match = nounPhrase.parseTokens(toks, gDict);

    /* display the match tree */
    for (local i = 1, local cnt = match.length() ; i <= cnt ; ++i)
    {
      "Match #<<i>>:\n";
      match[i].debugPrint();
    }
:::

For our \"little red wagon\" example, we\'ll see something like this:

::: code
    Match #1:
    noun phrase: adjective = little, nounPhrase = {
    noun phrase: adjective = red, nounPhrase = {
    noun phrase: noun = wagon
    }
    }
:::

## Exported class construction

The [getGrammarInfo()]{.code} method depends upon the program to export
the GramAltInfo and GramAltTokInfo classes. In most cases, you won\'t
have to write these classes yourself, because you can simply use the
implementations provided in the basic run-time library, in the source
file gramprod.t. For reference purposes, we\'ll describe what
GrammarProd requires of these classes.

First, the classes must be exported under the names
\'GrammarProd.GrammarAltInfo\' and \'GrammarProd.GrammarAltTokInfo\',
respectively. Second, GrammarProd requires the classes to define
constructors that accept particular argument lists, because
getGrammarInfo() uses the constructors to pass the grammar description
information to the classes. The parameter lists for the constructors are
as follows:

[GrammarAltInfo.construct(*score*, *badness*, *matchObj*,
*tokList*)]{.code}\
[GrammarAltTokInfo.construct(*prop*, *typ*, *info*)]{.code}

The arguments are:

-   *score*: an integer value; this isn\'t currently used and can be
    discarded
-   *badness*: an integer giving the \[badness\] attribute for the
    alternative
-   *matchObj*: an object reference giving the match object class for
    the alternative
-   *tokList*: a list of GrammarAltTokInfo objects
-   *prop*: a property ID giving the target property of the token slot
-   *typ*: an integer giving the token slot type (one of the
    [GramTokTypeXxx]{.code} values)
-   *info*: extra information that depends on the token slot type; this
    is the same information described earlier for the
    [GrammarAltTokInfo.gramTokenInfo]{.code} property

To ensure compatibility with any future extensions to the GrammarProd
class, the implementations in the run-time library use variable argument
lists in their constructors-they use the argument lists shown above, but
add a \"\...\" symbol at the end so that they\'ll accept arbitrary
additional arguments. This ensures that code compiled with the current
version of the library will continue to run under any future VMs that
include updated GrammarProd classes that pass additional arguments to
the GrammarAltInfo and/or GrammarAltTokInfo constructors.

In the run-time library implementation of the classes, the constructors
simply store the argument values in the corresponding instance
properties, so that program code can refer to it as needed.
:::

------------------------------------------------------------------------

::: navb
*TADS 3 System Manual*\
[Table of Contents](toc.htm){.nav} \| [The
Intrinsics](builtins.htm){.nav} \> GrammarProd\
[[*Prev:* FileName](filename.htm){.nav}     [*Next:*
HTTPRequest](httpreq.htm){.nav}     ]{.navnp}
:::
