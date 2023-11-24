![](topbar.jpg)

[Table of Contents](toc.htm) \| [TADS 3 In Depth](depth.htm) \> Lists
and Listers  
[*Prev:* Implied Action Reports](t3imp_action.htm)     [*Next:* Tips: A
Context-Sensitive Help System](t3tips.htm)    

# Lists and Listers

*by Eric Eve*

At many points in a TADS 3 game the player will see a list of objects:
in a room description, in examining the player character's inventory, in
looking in, under or behind certain objects and so on. The default
behaviour of the TADS 3 library generally handles these lists pretty
well, but there will be probably come a point when you want to customize
one or more of these lists. This article will explore some of the ways
you can do this.

This is actually quite a complex topic, since there are so many aspects
of lists that can be customized, including:

- whether or not particular items appear in a list
- the order of items in a list
- the grouping of items in a list
- the text that introduces or concludes a list

To attempt to cover every single aspect of Lists and Listers in this
article would probably prove more confusing than helpful; it would
almost certainly prove overwhelming. Instead we shall concentrate on
those aspects of Lists and Listers that are useful for the kind of
listing tasks most likely to crop up in TADS 3 games. Even this will
prove a fairly long and complex journey, so we provide an index below so
that you can jump to a particular part of the discussion if you already
know what it is you need particular help with.

- [Really Simple Lists](#simple)
- [Including and Excluding Items in Lists](#exclude)
- [Ordering and Grouping List Items](#ordgroup)
  - [Ordering](#ordering)
  - [Grouping](#grouping)
- [Introductory and Concluding Text](#introtext)
  - [Container Contents](#contcont)
    - [Table of Common Lister Properties](#listproptab)
    - [Openable Contents Lister](#openable)
  - [Other Lister Properties and Objects](#other)
    - [Room Contents Listings](#room)
    - [Inventory Listings](#inventory)

## Really Simple Lists

The TADS 3 Library uses a variety of Lister objects (i.e. objects
derived from the Lister class) to produce the many lists that appear in
a typical TADS 3 game. If you look at the definition of Lister and its
subclasses in the library, you'll see a bewildering array of methods,
many of which look bewilderingly complex. You may be wondering whether
it's possible to get a Lister just to display a straightforward list
from a list of objects (or even strings) passed to it. You may sometimes
wish you could just use code like this:

    objectLister.showSimpleList([orange, apple, pear]);

    stringLister.showSimpleList(['red', 'white', 'blue']);

To produce properly formatted lists like:

    an orange, an apple, and a pear

    red, white, and blue

Well, the good news is that the library now provide this; it now
defines:

    class SimpleLister: Lister
        showSimpleList(lst) { showListAll(lst, 0, 0); }
        isListed(obj) { return true; }
        makeSimpleList(lst)
        {
            return mainOutputStream.captureOutput({: showSimpleList(lst) });
        }
    ;

    objectLister: SimpleLister    
    ;

    stringLister: SimpleLister
        showListItem (str, options, pov, infoTab) { say(str); }
        getArrangedListCardinality(singles, groups, groupTab)
        {
            return singles.length();
        }    
    ;

This allows us not only to display a simple list, but also to capture it
in single-quoted string (using the makeSimpleList(lst) method).

This may not seem particularly useful when we're just passing a constant
list to the showSimpleList() method, since we could more simply have
displayed the strings "an orange, an apple and a pear" or "red, white
and blue", but these simple listers could prove more useful when we're
building the list of objects or strings programmatically, and then want
to display a neatly formatted list. An example of this might be when
we're defining a LabeledDial and want to include a list of its
validSettings in its descriptions, e.g.:

      myDial: LabeledDial, Component 'big red dial' 'big red dial'
         "The dial can be turned to a number of settings, in particular: 
          <<stringLister.showSimpleList(validSettings)>>. "
          validSettings = ['freezing', 'cold', 'tepid', 'hot', 'boiling']
      ;      

Should we then want to add a 'warm' setting, we can add this to the
validSettings property knowing that the description will be
automatically taken care of.

Most of the lists (and Listers) you will encounter are actually rather
more complex than this. The Listers in the library tend to assume that
they're producing a list of objects that can be sensed by a particular
actor in a particular context, and so they use a series of more complex
methods with more complex parameter lists. This is usually what is in
fact needed in the context of a TADS 3 game. But in addition to
providing code you can use for displaying custom lists you construct in
your own code, the above examples provide a useful introduction to
Listers. Listers are objects that take a list of objects, usually along
with other information (such as sensory information) and output a
properly formatted list. The list is displayed by calling the
appropriate method of the Lister; the showListAll() method is the
simplest, because it ignores all the sensory information; the library
more commonly calls showList(), but that's more complicated than we need
to go into here.

In what follows, we shall look at various ways in which the output from
the library's Listers can be customized. These lists are not normally
ones we build by hand (as in the simple example above), but lists of
objects in a particular place (such as a room or container) that are or
become visible to the player character at a particular time.

  

## Including and Excluding Items in Lists

The simplest way to control whether an item is or is not shown in a
particular list is to set the appropriate isListedXXX property/method:

- *isListed* — determines if the object will be listed in room
  descriptions and in descriptions of objects containing this item's
  container
- *isListedInContents* — determines if the item will be listed in
  response to explicit EXAMINE and LOOK IN commands directed at the
  item's container
- *isListedInInventory* — determines if this item is included in
  inventory listings
- *isListedAboardVehicle* — determines if the item is listed when it
  arrives aboard a vehicle (the default is nil)
- *isListedInRoomPart(part)* — determines if the item is listed as being
  located in the given room part

The library has sensible defaults for all these properties and methods,
but if you want something other than the default behaviour, it's easy
enough to override the appropriate method accordingly. For example,
supposing Myrtle is carrying a bunch of flowers and a revolver, and
wearing a red dress, but that she's somehow managed to conceal the
revolver in her dress (or in the bunch of flowers?). To prevent the
revolver being listed in Myrtle's inventory we could do this:

    myrtle: Person 'pretty myrtle/woman' 'Myrtle' @westRoom
        "You think she's very pretty. "    
        isHer = true
        isProperName = true
    ;
            
    + Thing 'bunch/flowers' 'bunch of flowers'
    ;

    + Wearable 'red dress' 'red dress'
        wornBy = myrtle    
    ;

    + Thing 'revolver/run' 'revolver'
        isListedInInventory = (!isIn(myrtle))
    ;

This will prevent the revolver being listed in Myrtle's inventory (but
not in the player character's inventory should he later acquire the
revolver). Actually, this would not be the best way to handle this
particular issue, since the player can still examine the revolver when
Myrtle's carrying it even though it's not listed; a better solution
would be to make the revolver of class Hidden and then to call its
discover() method at the appropriate moment. Nevertheless, the example
serves to illustrate the principle.

Perhaps a more realistic example might be a large black pot that
contains a small silver coin. Normally, it would be appear in a room
description as:

    You see a large black pot (which contains a small silver coin) here. 

We may think it more realistic for the player not to notice the coin
unless he explicitly examines (or looks in) the pot. We could achieve
this like so:

    + pot: Container 'large black pot' 'large black pot'
    ;

    ++ coin: Thing 'small silver coin*coins' 'small silver coin'
        isListed = (!isIn(pot))
    ;

Note how we override isListed so that it's only nil when the coin is in
the pot; once the coin is removed from the pot, we'd probably want it to
be listed normally.

It's possible that we think examining the pot is not enough to reveal
the coin, and that the player character would only notice it if he
actually looks in the pot. We then need to override isListedInContents
rather than isListed, but the complication is that we want
isListedInContents to be true for a LOOK IN command but not for an
EXAMINE command, so we'd have to do something like this:

    ++ coin: Thing 'small silver coin*coins' 'small silver coin'    
        isListedInContents = (!isIn(pot) || gActionIs(LookIn))
    ;

Note that if we override isListedInContents we don't need to override
isListed as well in this case, since by default isListed takes its value
from isListedInContents. However, the fact that the solution is
beginning to look a little convoluted is a sign that there may be a
better way of going about this. In particular, we might do better to
adjust properties of the pot rather than properties of the coin, since
it's the pot that's tending to conceal its contents. The time has come
to look at a couple of useful properties of containers:

- *contentsListed* — determines if the item's contents are listed in a
  room description
- *contentsListedInExamine* — determines if the item's contents are
  listed when the item is explicitly examined

Using these properties, we could make the pot hide its contents from a
room description, revealing them only when the pot is explictly examined
or looked in, like so:

    + pot: Container 'large black pot' 'large black pot'
        contentsListed = nil
    ;

    ++ coin: Thing 'small silver coin*coins' 'small silver coin'        
    ;

This would give us a transcript like:

    East Room
    This is the east room. An exit leads west. 

    You see a large black pot here. 

    >x pot
    It contains a small silver coin. 

    >look in pot
    The large black pot contains a small silver coin. 

If we also want the contents of the pot to remain unlisted until the
player explicitly looks in the pot, we can set contentsListedInExamine
to nil:

    + pot: Container 'large black pot' 'large black pot'
        contentsListedInExamine = nil
    ;

    ++ coin: Thing 'small silver coin*coins' 'small silver coin'        
    ;

This would result in the slightly different transcript:

    East Room
    This is the east room. An exit leads west. 

    You see a large black pot here. 

    >x pot
    You see nothing unusual about it.  

    >look in pot
    The large black pot contains a small silver coin. 

For a container that doesn't obviously display its contents until it's
explicitly examined and/or looked in, this is clearly a neater solution
than manipulating the isListedXXX properties of it contents.

Between them, the isListedXXX and contentsListedXXX properties provide
the most straightforward means of excluding items from lists, and
between them they will probably cover most cases. For more complex cases
you might need to start overriding some of the methods of the *Lister*
that's responsible for displaying the list in question. We'll discuss
Listers – including how to identify which Lister is used in which
situation – further below. In the meantime we'll just list the Lister
methods that might be useful in adjusting the contents of a list:

- *isListed(obj)* — determines whether this item to be listed in room
  descriptions. Returns true if so, nil if not. By default returns the
  value of obj.isListed.
- *contentsListed(obj)* — determines if this object's contents is to be
  listed; by default returns the value of obj.contentsListed.

One further technique that can be used to adjust the list of objects to
be displayed in a room description is to override the
adjustLookAroundTable() method of the room in question. This technique
is illustrated in the [Looking Through the
Window](../gsg/lookingthroughthewindow.htm) section of *Getting Started
in TADS 3*.

  

## Ordering and Grouping List Items

### Ordering

A typical room description might contain a list of items present in
something like the following form:

    A large box rests in the corner. 

    A table stands in the middle of the room. 

    You see a chair, a bucket of water, a pen, and a piece of paper here. On the table are a saucer, 
    a cup, and a priceless antique vase. 

    Myrtle is standing here.

In this list two items with a specialDesc (or initSpecialDesc) property
defined are listed first (the box and the table), then a list of
miscellaneous items (followed by a list of items on the table), and
finally an NPC who happens to be present. There is not a great deal we
can do to determine the order of the items within a miscellaneous list
(e.g. the chair, bucket, pen, and piece of paper) in the general case,
but in particular cases we should probably be able to achieve the effect
we want by [grouping](#grouping) (see below).

On the other hand, defining the order of items that get paragraphs to
themselves (i.e. those that have a specialDesc or initSpecialDesc
property defined) is quite straightforward; we simply need to adjust the
values of one or both of the following two properties:

- *specialDescOrder* — List order for the special description. Whenever
  there's more than one object showing a specialDesc at the same time
  (in a single room description, for example), we'll use this to order
  the specialDesc displays. We'll display in ascending order of this
  value. By default, we use the same value (100) for everything, so
  listing order is arbitrary; when one specialDesc should appear before
  or after another, this property can be used to control the relative
  ordering.
- *specialDescBeforeContents* — determines whether the item with a
  specialDesc is listed before the miscellaneous items (if true - the
  default, except for Actors), or after them (if nil - the default for
  Actors). This can effectively split items with specialDescs into two
  groups (listed before and after the miscellaneous items); in this case
  the specialDescOrder property determines the order of items separately
  within the two groups.

Suppose we wanted to arrange the listing above so that Myrtle is
mentioned first, before the table, and the box is mentioned last of all,
after all the miscellaneous items. Then we simply need to change
specialDescBeforeContents on Myrtle to true, and specialDescOrder on
Myrtle to 50 (say) to make sure she's mentioned before the table, and
then change specialDescBeforeContents on the box to nil. We'd then see
the items listed thus:

    Myrtle is standing here. 

    A table stands in the middle of the room. 

    You see a chair, a bucket of water, a pen, and a piece of paper here. On the table are a saucer,
    a cup, and a priceless antique vase. 

    A large box rests in the corner. 

  

### Grouping

There is no standard listOrder property for miscellaneous items
(analagous to specialDescOrder), but just about any custom ordering of
miscellaneous item can be achieved by grouping them. Indeed, you could
even assign every single item in your game to the same list group, and
then define a listOrder property of your own that your list group could
then be made to sort on. But let's take things one step at a time.

To group miscellaneous items in a list you need to:

1.  Define an object of class ListGroup (or rather, one of its
    subclasses)
2.  Assign the *listWith* property of all the items you want listed in
    this group to this ListGroup object

This should hopefully become much clearer with an example. Suppose we
add a pencil, a ruler, and a bottle of ink to the miscellaneous items in
the room. We might then see a listing like:

    You see a chair, a ruler, a pencil, a bucket of water, a bottle of ink, a pen, 
    and a piece of paper here.

But since the ruler, the pencil, the ink, the pen and the paper are all
writing implements of a sort, we might prefer them all to be listed
together. The first step is to create an appropriate ListGroup:

    writingMaterials: ListGroupSorted    
    ;

Then we assign each of the objects in question to this ListGroup, e.g.:

    + ruler: Thing 'ruler' 'ruler'
        listWith = [writingMaterials]
    ;

Note that the listWith property takes a *list* of ListGroups, since the
same item can belong to more than one ListGroup. We'll say a bit more
about multiple ListGroups in this property later; for now we'll keep it
simple and stick to one. Once we've defined our writingMaterials
ListGroup and assigned all the appropriate objects to it in this way,
the list will display something like:

    You see a chair; a ruler, a pencil, a bottle of ink, a pen, and a piece of paper; 
    and a bucket of water here.  

Note that we made our writingMaterials list group a *ListGroupSorted*
and not just a *ListGroup*. This is because the base ListGroup class
doesn't actually display anything when it comes to listing its members;
it's nearly always more useful, therefore, to use a subclass of
ListGroup, ListGroupSorted being perhaps the most general-purpose of
those subclasses. As its name suggest, ListGroupSorted can also sort the
items it lists. Suppose, for example, we not only wanted to group the
writing implements together, but wanted them to appear in the order:
pen, pencil, ink, paper, ruler. We can do this by first defining a
*compareGroupItems()* method on our writingMaterials list group, which
could make use of a custom *listOrder* property on the writing
implements themselves:

    writingMaterials: ListGroupSorted    
        /* 
         * Return an integer > 0 if the first item sorts after the second item;
         * Return an integer < 0 if the second item sorts after the first item;
         * Return zero if the two items are at the same sorting order.
         */
        compareGroupItems (a, b) { return a.listOrder - b.listOrder; }    
    ;

    + pencil: Thing 'pencil' 'pencil'
        listWith = [writingMaterials]
        listOrder = 20
    ;

    + ink: Thing 'bottle/ink' 'bottle of ink'
        listWith = [writingMaterials]
        listOrder = 30
    ;

    /* etc. */

Note that we could have called the listOrder property anything we liked,
so long as we use the same name in writingMaterials.compareGroupItems()
and on the items in question. With our modified writingMaterials list
group we'll now get a list like:

    You see a chair; a pen, a pencil, a bottle of ink, a piece of paper, and a ruler; 
    and a bucket of water here.

ListGroupSorted has a couple of subclasses we can also use for
particular purposes. We could use *ListGroupPrefixSuffix* to explicitly
introduce the list of writing implements as "some writing implements":

    writingMaterials: ListGroupPrefixSuffix   
        compareGroupItems (a, b)
        {
            /* Return 1 if the first item sorts after the second item */
            if(a.listOrder > b.listOrder)
                return 1;
            
            /* Return -1 if the first item sorts before the second item */
            if(a.listOrder < b.listOrder)
                return -1;
            
            /* Return 0 if the two items are at the same sorting order */
            return 0;
        }
        
        groupPrefix = "some writing materials: "
    ;

This would result in:

    You see a chair; some writing materials: a pen, a pencil, a bottle of ink, 
    a piece of paper, and a ruler; and a bucket of water here. 

Note that we could likewise use the *groupSuffix* property to append
text to the end of the list of writing materials. In a more complex
situation we could instead override the methods showGroupPrefix(pov,
lst) and showGroupSuffix(pov, lst), which by default just display the
groupPrefix and groupSuffix properties; in a more complex case we might
want to use these methods to vary the text shown according to the value
of the pov parameter (normally the actor doing the looking) or the lst
parameter (the list of items about to be listed).

We can use *ListGroupParen* to give a general description of the items
(e.g. "five writing implements" followed by the actual items listed in
parentheses:

    writingMaterials: ListGroupParen    
        compareGroupItems (a, b)
        {
            /* Return 1 if the first item sorts after the second item */
            if(a.listOrder > b.listOrder)
                return 1;
            
            /* Return -1 if the first item sorts before the second item */
            if(a.listOrder < b.listOrder)
                return -1;
            
            /* Return 0 if the two items are at the same sorting order */
            return 0;
        }  
        showGroupCountName(lst)
        {
            "<<spellInt(lst.length)>> writing implements";
        }    
    ;

Which results in:

    You see a chair, five writing implements (a pen, a pencil, a bottle of ink, 
    a piece of paper, and a ruler), and a bucket of water here.

Note that if we hadn't overridden showGroupCountName() it would simply
have used the count name of the first item in the list, so the list
would have been shown as "five pens (a pen, a pencil, ...)" intead of
"five writing implements (a pen, a pencil, ...)"

Finally, we could use *ListGroupCustom* (a subclass of ListGroup, but
not of ListGroupSorted) just to give a summary name for the pen, pencil
etc. without listing the individual items at all:


    writingMaterials: ListGroupCustom
        showGroupMsg (lst) { "some writing materials"; }
    ;

Resulting it:

    You see a chair, some writing materials, and a bucket of water here.

This is probably not a good idea unless the individual items answer to
the vocabulary "writing materials" (perhaps as a plural), since
otherwise the player won't be able to refer to them!

In summary, the ListGroup classes that are most useful, together with
the properties you'll commonly want to override on them, are:

- **ListGroupSorted**; compareGroupItems (a, b) defines the sorting
  order
- **ListGroupPrefixSuffix**; groupPrefix and groupSuffix define the text
  used to introduce and conclude the list
- **ListGroupParen**; showGroupCountName(lst) defines the collective
  name for the items about to be listed in parentheses (e.g. "five
  writing implements")
- **ListGroupCustom**; showGroupMsg (lst) defines the text used to
  summarize the list of items (in place of the items themselves), e.g.
  "some writing materials"

There are one or two other ListGroup classes defined in the library
(ListGroupEquivalent, SuggestionListGroup and RoomActorGrouper), but you
are less likely to use these in your own code; they're automatically
employed by the standard library as they're needed.

There's a couple more points to bear in mind about these ListGroups.
First, you may be wondering what happens if only one member of a group
is present; it would be ugly - or at least needlessly pedantic - to see
a list like "You see one writing implement (a pen) here". This is taken
care of by the *minGroupSize* property on the ListGroup object. By
default the value of this property is two, which means that the
ListGroup will only be used to group its members in a list if at least
two of them are present. This is the behaviour we'd normally want, but
obviously we can always change this property to something other than two
if we need to.

The other main point is the complication introduced above: the listWith
property of an object contains a *list* of ListGroup objects, and that
list can contain more than one member, meaning that an object can be
grouped in more than one way. When multiple groups are specified here,
the order is significant:

- To the extent two groups entirely overlap, which is to say that one of
  the pair entirely contains the other (for example, if every coin is a
  kind of money, then the "money" listing group would contain every
  object in the "coin" group, plus other objects as well: the coin group
  is a subset of the money group), the groups must be listed from most
  general to most specific (for our money/coin example, then, money
  would come before coin in the group list).
- When two groups do not overlap, then the earlier one in our list is
  given higher priority

One final point: the property *specialDescListWith* can be used to group
items displaying specialDescs together in the same kind of way we have
seen for ordinary items. That is, the specialDescListWith property can
contain a list of one or more ListGroup objects that will be used to
group the specialDescs. In game code, this is only likely to be at all
useful with a ListGroupSorted, which could then be used as an
alternative to specialDescOrder to group related items together and, if
desired, list them in a certain sequence. Note that any grouping
performed by this means will take precedence over the order specified by
the specialDescOrder property.

  

## Introductory and Concluding Text

### Container Contents

A room description might typically include a list of objects like the
following:

    You see a chair, a table (on which are a saucer, a cup, and a priceless antique vase), a bucket
    of water, a pen, and a piece of paper here. 

    Myrtle is standing here. 

Here the paragraph about Myrtle (an NPC) stands out separately from the
miscellaneous objects listed first. These miscellaneous objects are
introduced with the text "You see" and the list is concluded with
"here." Within the list is a bracketed sublist of items on the table,
introduced with the words "on which are" (by the way, if you wanted to
see the items on the table listed separately here, and not in a
bracketed sublist, you'd just need to set the table's
*contentsListedSeparately* property to true).

Let's start by thinking about that bracketed sublist, and the ways in
which we might want to change how it's introduced. Suppose, for example,
than instead of the relatively colourless "on which are" we wanted the
slightly more "across which are strewn". How would we go about this?

Obviously we need to know where the text "on which are" is coming from.
In fact it comes from the *Lister* object that controls how the contents
of the table (i.e. what's on the table) is displayed. Working out just
what that object is is a little complicated. The table is presumably a
Surface, and if you look up the definition of Surface in the Library
Reference Manual (or the library source code in objects.t) you'll find
it has four properties related to listers:

- *contentsLister* — the Lister object that we use to display the
  contents of this object for room descriptions, inventories, and the
  like.
- *descContentsLister* — the Lister to use when showing the contents of
  this object as part of its own description (i.e., for Examine
  commands)
- *inlineContentsLister* — the Lister object used to display the
  object's contents parenthetically as part of its list entry in a
  second-level contents listing
- *lookInContentsLister* — the Lister to use when showing the object's
  contents in response to a LookIn command

In fact, these four properties are all defined on Thing, and hence exist
on all subclasses of Thing. But they are overridden on Surface to use
Listers that are suitable for listing objects that are *on* something;
other subclasses may need listers that describe their contents as being
*in*, *under* or *behind* their parent object.

The property we're after right now is the *inlineContentsLister*, since
this is the one that's responsible for displaying the object's contents
parenthetically as part of its list entry in a second-level contents
listing (or, in other words, in producing a sublist in brackets after an
object that's itself being shown as part of a list). If we look at the
definition of inlineContentsLister on Surface, we'll find that it simply
points to the surfaceInLineContentsLister object. If we look this up in
turn we'll find that it's defined as:

    surfaceInlineContentsLister: inlineListingContentsLister
        showListPrefixWide(cnt, pov, parent)
        {
            " (on which <<cnt == 1 ? tSel('is', 'was')
                                   : tSel('are', 'were')>> ";
        }
    ;

From this we can already see where the text "(on which is/are ... \_)"
is coming from, but for the sake of completeness we might want to see
the definition of inLineContentsLister, from which
surfaceInlineContentsLister inherits:

    inlineListingContentsLister: ContentsLister
        showListEmpty(pov, parent) { }
        showListPrefixWide(cnt, pov, parent)
            { " (which contain<<parent.verbEndingSEd>> "; }
        showListSuffixWide(itemCount, pov, parent)
            { ")"; }
    ;

It should be reasonably self-evident what the methods shown here do.
First, *showListEmpty* defines what is to be shown when there's nothing
in the list (in this case, nothing; in other circumstances it may be
appropriate to display a message explicitly stating that a container is
empty). The other two methods, *showListPrefixWide* and
*showListSuffixWide* define the text with which the list is introduced
and concluded (when the list is not empty). The *cnt* or *itemCount*
parameter can be used to test whether there is one or more items in the
list, so that where a verb is used it can be made singular or plural
accordingly (e.g. 'is' or 'are'), so that we avoid seeing lists like "On
the table are a cup" or "On the table is a cup and a saucer". Note that
the case where there's a single item that looks plural (e.g. "some
flowers") is automatically taken of; in this case a plural number will
still be passed to these routines so that we'll get "On the table are
some flowers", not "On the table is some flowers." The library takes
care of this for us, so we don't need to worry about it.

So, if we want to see "across which are scattered" instead of "on which
are", we need to override the showListPrefixWide() method; but the next
question is, where exactly should we override it? Unless we want to see
"across which are scattered" introducing the list of items on top of
every Surface in our game, we probably don't want to modify
inLineListingContentsLister. We could create a special new lister object
just for our table, but if we only want to use it on our table and not
for any other object in our game this is probably best done as an
anonymous object defined on the table itself:

    + table: Surface 'table' 'table'
        inlineContentsLister: surfaceInlineContentsLister
        {
            showListPrefixWide(cnt, pov, parent)
            {
                " (scattered across which <<cnt == 1 ? tSel('is', 'was')
                  : tSel('are', 'were')>> ";
            }
            
        }
    ;

And now we'll see:

    You see a chair, a table (scattered across which are a saucer, a cup, and a priceless antique
    vase), a bucket of water, a pen, and a piece of paper here.

The main things to note here are that (1) we've subclassed our custom
inLineContentsLister from the object a Surface would otherwise have
used, to ensure that we get behaviour appropriate to a Surface for every
aspect of the Lister we haven't explicitly customized ourselves; (2) we
use the *cnt* parameter of the showListPrefixWide() method to ensure we
get the singular or plural form of the verb ("is scattered" or "are
scattered") as appropriate, and (3) we use the tSel macro to ensure we
get the present or past tense as appropriate; if we're never going to
change tense in our game (and in most games we probably won't) then this
last step won't actually be necessary. (For more information on changing
tenses in games, see the Technical Article on [Writing a Game in the
Past Tense](t3past.htm)).

Had we wanted to use this "scattered" wording on more than one object in
our game, we could instead have defined a separate custom lister object
which we then attached to the objects we wanted to use it on, e.g.:

    + smallTable: Surface 'small table*tables' 'small table'
        inlineContentsLister = scatteredSurfaceInlineContentsLister
    ;

    + largeTable: Surface 'large table*tables' 'small table'
        inlineContentsLister = scatteredSurfaceInlineContentsLister
    ;   
        
    scatteredSurfaceInlineContentsLister: surfaceInlineContentsLister    
        showListPrefixWide(cnt, pov, parent)
        {
             " (scattered across which <<cnt == 1 ? tSel('is', 'was')
               : tSel('are', 'were')>> ";
        }   
    ;

The same method can be used to customize the way what's on the table is
described when we EXAMINE or SEARCH the table. We just need to customize
the appropriate Listers in the same way:

    + table: Surface 'table' 'table'
        inlineContentsLister: surfaceInlineContentsLister
        {
            showListPrefixWide(cnt, pov, parent)
            {
                " (scattered across which <<cnt == 1 ? tSel('is', 'was')
                  : tSel('are', 'were')>> ";
            }
            
        }
        
        descContentsLister: surfaceDescContentsLister
        {
            showListPrefixWide(itemCount, pov, parent)
            {
                "Scattered across <<parent.theNameObj>>
                <<itemCount == 1 ? tSel('is', 'was')
                  : tSel('are', 'were')>> ";
            }
            
        }    
        
        lookInLister: surfaceLookInContentsLister
        {
            showListPrefixWide(itemCount, pov, parent)
            {
                "Scattered across <<parent.theNameObj>>
                <<itemCount == 1 ? tSel('is', 'was')
                  : tSel('are', 'were')>> ";
            }
            
        } 
    ;

The only thing that is new in principle here is the use of the *parent*
parameter to supply the name of the parent object (the object being
examined or searched) in the text introducing the list of its contents.

As yet, we've not seen an example of customizing the remaining Lister
property, *contentsLister*. In our table example, this would most likely
be useful if we gave the table a specialDesc or initSpecialDesc or else
made it a NonPortable (e.g. a Heavy or CustomFixture). It that case the
table is not listed among the miscellaneous items in the room, so its
own contents would then appear in a separate list, not in a sublist;
we'd then see something like this:

    You see a chair, a bucket of water, a pen, and a piece of paper here. On the table are a saucer,
    a cup, and a priceless antique vase.

Tto get the "scattered across the table" version, it's the
contentsLister property we need to override:

    + table: Surface, Heavy 'table' 'table'
        specialDesc = "A table stands in the middle of the room. "
        contentsLister: surfaceContentsLister
        {
            showListPrefixWide(itemCount, pov, parent)
            {
                "Scattered across <<parent.theNameObj>>
                <<itemCount == 1 ? tSel('is', 'was')
                  : tSel('are', 'were')>> ";
            }        
        }
    ;

Finally, we should note that we are not restricted to changing the text
that introduces the list; we can also change the text that concludes it,
which would allow us, for example, to turn the sentence round so that
the table is mentioned at the end rather than the beginning. We could
even use the lister to describe the presence of the table in the room,
rather than (also) mentioning it in the room description or giving it a
specialDesc. For example, instead of the example above, we could have
written:

    + table: Surface, Heavy 'table' 'table'
        contentsLister: surfaceContentsLister
        {
            showListPrefixWide(itemCount, pov, parent)
            {
                "\^";            
            }
            showListSuffixWide(itemCount, pov, parent)
            {
                " <<itemCount == 1 ? tSel('is', 'was') : tSel('are', 'were')>>
                scattered across the table that stands in the middle of the room. ";
            }        
        }
        
        specialDesc = "A table stands in the middle of the room. "
        useSpecialDesc { return contents.length() == 0; }
    ;

Here we override useSpecialDesc so that the specialDesc is only used if
there's nothing on the table. If there is something on the table, the
table will be mentioned in connection with the list of objects resting
on it, so rather than mentioning the table twice, here we incorporate
the full description of the table's location ("in the middle of the
room") into the list of objects scattered across the table.

One further point to note: so far all the methods we have been
customizing have had names ending in "Wide" (such as
showListPrefixWide()). These are the methods used for displaying lists
that run horizontally across the screen (the default way of listing,
used in all our examples so far). But in some contexts (e.g. where the
player has issued a command like INVENTORY TALL) items may be listed in
a vertical column down the screen; to customize the introductions and
conclusions to lists in this vertical format you need to override the
appropriate methods with names ending in "Tall", i.e.
showListPrefixTall() and showListContentsPrefixTall(). There is no
showListSuffixTall() method.

The examples used above have all applied to a Surface. The same
principles would apply when listing the contents of a Container, an
Underside, or a RearSurface/RearContainer. You'd override precisely the
same Lister *properties* on the container-type object in question, but
you'd to subclass a different lister *object* in each case. You can
always look up which Lister property uses which Lister object on which
container class in the Library Reference Manual, but you may find it
more convenient to use the table below:

**Lister Properties and Objects**

Lister Property

Container

Surface

Underside

RearContainer

contentsLister

thingContentsLister

surfaceContentsLister

undersideContentsLister

rearContentsLister

descContentsLister

thingDescContentsLister

surfaceDescContentsLister

undersideDescContentsLister

rearDescContentsLister

inlineContentsLister

inlineListingContentsLister

surfaceInlineContentsLister

undersideInlineContentsLister

rearInlineContentsLister

lookInContentsLister

thingLookInLister

surfaceLookInLister

undersideLookUnderLister

rearLookBehindLister

Notes:

1.  RearSurface uses the same lister objects as RearContainer
2.  Container uses the same lister objects as Thing (from which it
    inherits its lister properties)
3.  In the main the lister objects are named in a fairly consistent
    pattern, but note *inlineListingContentsLister* not
    thingInlineContentsLister. Note also *surfaceLookUnderLister* and
    *rearLookBehindLister*
4.  In many cases, if all you want to do is to change the preposition a
    lister uses to describe its contents (e.g. "on top of" instead of
    "on" or "beneath" instead of "under"), you don't need to override
    the lister at all; instead you can simply override objInPrep on the
    object whose contents are to be listed. This should work for all
    listers in the table above (except inLineListingContentsLister,
    which uses "contains" rather than the preposition "in").
5.  Openable overrides descContentsLister to openableContentsLister, so
    that, for example, an OpenableContainer uses openableContentsLister
    rather than thingDescContentsLister.

This last point is particularly worth noting, since OpenableContainers
are far from uncommon, and also because (which may be far from initially
obvious), openableContentsLister also reports whether an Openable object
is open or closed:

    openableContentsLister: thingContentsLister
        showListEmpty(pov, parent)
        {
            "\^<<parent.openStatus>>. ";
        }
        showListPrefixWide(itemCount, pov, parent)
        {
            "\^<<parent.openStatus>>, and contain<<parent.verbEndingSEd>> ";
        }
    ;

So, for example, if you have an OpenableContainer which is reporting
"It's closed" when the player examines it, this is where the message is
coming from (and this is the place to change it if, for example, you
only want the container to report when it's open, not when it's closed).
It's also the place where you could add an explicit "It's empty" message
to an empty, open container. e.g.:

    + box: OpenableContainer 'box' 'box'
        descContentsLister: openableContentsLister
        {
            showListEmpty(pov, parent)
            {
                if(parent.isOpen)
                    "\^<<parent.openStatus>> but empty. ";            
            }
        }
    ;

Which could give you a transcript like:

    >x box
    You see nothing unusual about it. 

    >open box
    Opened. 

    >x it
    Its open but empty. 

    >put pen in box
    (first taking the pen)
    Done. 

    >x box
    Its open, and contains a pen. 

    >close box
    Closed. 

    >x it
    You see nothing unusual about it. 

  

### Other Lister Properties and Objects (including Room and Inventory Listings)

We have now covered the four standard lister properties found on all
Things, but there are also some others that are specific to particular
classes (and which deal with specific situations). These include:

- *abandonContentsLister* — the lister used to describe the objects
  being revealed when we move a SpaceOverlay object (usually an
  Underside or RearContainer) and abandon its contents. Each concrete
  kind of SpaceOverlay must provide a lister that uses appropriate
  language; the list should be roughly of the form "Moving the armoire
  reveals a rusty can underneath." Individual objects can override this
  to customize the message further.
- *openingLister* — the lister used to show the items that are newly
  revealed when an object is opened (defined on Openable).
- *specialContentsLister* — the Lister to use to display the special
  descriptions for objects that have special descriptions when we're
  showing a room description for this object (usually specialDescLister)
- *roomContentsLister*— this is the Lister object that we use to display
  the room's contents when the room is lit; the default is roomLister
  (defined on a Room)
- *darkRoomContentsLister* — this is the Lister object we'll use to
  display the room's self-illuminating contents when the room is dark;
  the default is darkRoomLister (defined on a Room)
- *inventoryLister* — the Lister object that we use for inventory
  listings. By default, we use actorInventoryLister, but this can be
  overridden if desired to use a different listing style (defined on an
  Actor)
- *holdingDescInventoryLister* — The Lister for inventory listings, for
  use in a full description of the actor. By default, we use the "long
  form" inventory lister (actorHoldingDescInventoryListerLong ), on the
  assumption that most actors have relatively lengthy descriptive text.
  This can be overridden to use other formats; the short-form lister,
  for example, is useful for actors with only brief descriptions
  (defined on an Actor).

Note that these are the names of the *properties* that point to Lister
objects, not the lister objects themselves. For example, on an Openable
the openingLister *property* points to the openableOpeningLister
*object*.

Other commonly used Lister *objects* (some of which have just been
mentioned above) include:

- **roomLister** — the object that we use by default with showList() to
  construct the listing of the portable items in a room when displaying
  the room's description. The corresponding property that usually points
  to this object is *roomContentsLister*
- **darkRoomLister** — the basic room lister for dark rooms. The
  corresponding property that usually points to this object is
  *darkRoomContentsLister*
- **RemoteRoomLister** — This is used to describe the contents of an
  adjoining room. For example, if an actor is standing in one room, and
  can see into a second top-level room through a window, we'll use this
  lister to describe the objects the actor can see through the window.
  Note that this is a *class* and that it has a constructor, so that we
  could create an appropriate lister object with
  `new RemoteRoomLister(otherRoom)` where `otherRoom` is the name of the
  remote room whose contents we want to list. In the standard library
  this is normally called from *remoteRoomContentsLister(other)*
- **CustomRoomLister** — A simple customizable room lister. This can be
  used to create custom listers for things like remote room contents
  listings. We act just like any ordinary room lister, but we use custom
  prefix and suffix strings provided during construction, for example:
  `new CustomRoomLister('Further up the street you can see', '. ')`
- **actorInventoryLister** — the standard inventory lister for actors -
  this will work for the player character and NPC's as well. This lister
  uses a "divided" format, which segregates the listing into items being
  carried and items being worn.
- **actorSingleInventoryLister** — this shows the inventory listing as a
  single list, with worn items mixed in among the other inventory items
  and labeled "(being worn)".

#### Room Contents Listings

A couple of examples should suffice to show how these might be useful.
Suppose that instead of having a room description say "You see X, Y and
Z here" you want it to say "X, Y and Z are lying around on the floor. ".
This can be achieved by overriding the roomContentsLister property on
the Room in question, for example:

    westRoom: Room 'West Room'
        "This is the west room. An exit leads east. "
        east = eastRoom
     
        roomContentsLister: roomLister
        {
            /* show the prefix/suffix in wide mode */
            showListPrefixWide(itemCount, pov, parent) { "\^"; }
            showListSuffixWide(itemCount, pov, parent) 
            { 
                " <<itemCount > 1 ? tSel('are', 'were') : tSel('is', 'was')>>
                lying around on the floor. "; 
            }        
        }
    ;

In conjunction with the other tweaks we've already made above, this
could produce something like:

    West Room
    This is the west room. An exit leads east. 

    A chair, a bucket of water, a pen, a box, and a piece of paper are lying around on the floor. 
    A saucer, a cup, and a priceless antique vase are scattered across the table that stands in 
    the middle of the room. 

#### Inventory Listings

The standard form of an inventory listing (the listing of the player
character's inventory shown in response to an INVENTORY command)
typically looks something like this:

    >i
    You are carrying a walking stick, a map, and an iceberg lettuce, and youre wearing a 
    long overcoat and a pair of brown shoes.

You can change the format to show a single list, with worn items shown
as "(being worn)" simply by overriding the inventoryLister property on
the gPlayerChar object (typically me) to singleActorInventoryLister. For
example this:

    me: Actor
       location = westRoom   
       inventoryLister = actorSingleInventoryLister
    ;

Will give you this:

    >i
    You are carrying a long overcoat (being worn), a pair of brown shoes (being worn), a 
    walking stick, a map, and an iceberg lettuce.

To customize further, e.g. to make an inventory lister that replaces
"carrying" with "holding" and "wearing" with "sporting" requires rather
more work, since the standard lister that divides the PC's possessions
into what's being carried and what's being worn needs to define several
methods to keep track of several possibilities. By copying and adapting
the library's definition of actorInventoryLister one might come up with
something like this:

    me: Actor
        location = westRoom   
        inventoryLister: actorInventoryLister
        {
            showInventoryEmpty(parent)
            {
                /* empty inventory */
                "<<buildSynthParam('The/he', parent)>> {is} holding absolutely
                nothing. ";
            }
            showInventoryWearingOnly(parent, wearing)
            {
                /* we're carrying nothing but wearing some items */
                "<<buildSynthParam('The/he', parent)>> {is}n\'t holding anything,
                but {is} sporting <<wearing>>. ";
            }
            showInventoryCarryingOnly(parent, carrying)
            {
                /* we have only carried items to report */
                "<<buildSynthParam('The/he', parent)>> {is} holding <<carrying>>. ";
            }
            showInventoryShortLists(parent, carrying, wearing)
            {
                local nm = gSynthMessageParam(parent);
                
                /* short lists - combine carried and worn in a single sentence */
                "<<buildParam('The/he', nm)>> {is} holding <<carrying>>,
                and <<buildParam('it\'s', nm)>>{subj} sporting <<wearing>>. ";
            }
            showInventoryLongLists(parent, carrying, wearing)
            {
                local nm = gSynthMessageParam(parent);
                
                /* long lists - show carried and worn in separate sentences */
                "<<buildParam('The/he', nm)>> {is} holding <<carrying>>.
                <<buildParam('It\'s', nm)>> sporting <<wearing>>. ";
            }
            /*
             *   For 'tall' listings, we'll use the standard listing style, so we
             *   need to provide the framing messages for the tall-mode 
             *   listing.  
             */
            showListPrefixTall(itemCount, pov, parent)
                { "<<buildSynthParam('The/he', parent)>> {is} holding:"; }
            showListContentsPrefixTall(itemCount, pov, parent)
                { "<<buildSynthParam('A/he', parent)>>, who {is} holding:"; }           
        }    
    ;

This is probably slightly more complex than it needs to be. In the most
common case where the player character remains the same throughout the
game, the game remains in the present tense throughout, and is always
told in the second person, a lot of the stuff that looks like
`<<buildParam('The/he', nm)>> {is}` could be replaced with `You are`;
but if you've copied and pasted this code from the library you may just
as well leave it as it is. The effect is to give you a transcript like
this:

    >i
    You are holding a walking stick, a map, and an iceberg lettuce, and youre sporting a long
    overcoat and a pair of brown shoes. 

    >i tall
    You are holding:
        a long overcoat (being worn)
        a pair of brown shoes (being worn)
        a walking stick
        a map
        an iceberg lettuce

    >drop all
    long overcoat:
    (first taking off the long overcoat)
    Dropped. 

    pair of brown shoes:
    (first taking off the pair of brown shoes)
    Dropped. 

    walking stick: Dropped. 
    map: Dropped. 
    iceberg lettuce: Dropped. 

    >i wide
    You are holding absolutely nothing. 

    >wear shoes
    (first taking the pair of brown shoes)
    Okay, youre now wearing the pair of brown shoes. 

    >i
    You aren't holding anything, but are sporting a pair of brown shoes. 

Changing the way the inventory of an NPC is listed is similar, except
that one instead needs to override the holdingDescInventoryLister
property of the NPC. For example, one might typically see something like
this:

    >x myrtle
    You think she's very pretty. 

    Myrtle is carrying a bunch of flowers, and shes wearing a red dress. 

But here the description of Myrtle is so short, that you might want to
combine it with the descripition of what she's carrying. This can be
done by using actorHoldingDescInventoryListerShort instead:

    myrtle: Person 'pretty myrtle/woman' 'Myrtle' @westRoom
        "You think she's very pretty. "
        holdingDescInventoryLister = actorHoldingDescInventoryListerShort
        isHer = true
        isProperName = true
    ;

You'll then get:

    >x myrtle
    You think she's very pretty. She is carrying a bunch of flowers, and shes wearing a red dress.

For any more complex customization, you'll need to use the same kind of
techniques as we've already seen exemplified for listing the player
character's inventory, except that you'll be working with the NPC's
holdingDescInventoryLister property instead, and subclassing from
actorHoldingDescInventoryListerShort or
actorHoldingDescInventoryListerLong.

  

## Conclusion

There is more to lists and listers than we've covered here. We could go
on to describe every single Lister method or to give lots of convoluted
examples of listing complex groupings of objects in remote locations,
but we have now covered the basics, and that should hopefully be enough
to enable you to tweak the lists that appear in your own games in most
of the ways that are likely to prove useful. If you need to go beyond
what this article covers, then hopefully it will have covered enough
ground to enable you to find what else you need to know from the
*Library Reference Manual*. At the very least, it should have given you
a better idea where to look.

------------------------------------------------------------------------

*TADS 3 Technical Manual*  
[Table of Contents](toc.htm) \| [TADS 3 In Depth](depth.htm) \> Lists
and Listers  
[*Prev:* Implied Action Reports](t3imp_action.htm)     [*Next:* Tips: A
Context-Sensitive Help System](t3tips.htm)    
