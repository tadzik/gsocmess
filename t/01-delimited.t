use Test;
use Pod6;
plan 24;

my $x = q[
=begin foo
=end foo
];
my $r = Pod6::parse($x);

isa_ok $r, Pod6::Block, 'returns a Pod6 Block';
isa_ok $r, Pod6::Block::Named, 'returns a named Block';
is $r.content, [], 'no content, all right';

$x = q[
=begin foo
some text
=end foo
];
$r = Pod6::parse($x);
is $r.content[0], "some text", 'the content is all right';

$x = q[
=begin foo
some
spaced   text
=end foo
];
$r = Pod6::parse($x);
is $r.content[0], "some spaced text", 'additional whitespace removed ' ~
                                   'from the content';

$x = q[
=begin foo
paragraph one

paragraph
two
=end foo
];
$r = Pod6::parse($x);
is $r.content[0], "paragraph one", 'paragraphs ok, 1/2';
is $r.content[1], "paragraph two", 'paragraphs ok, 2/2';

# nesting
$x = q[
    =begin something
        =begin somethingelse
        toot tooot!
        =end somethingelse
    =end something
];
$r = Pod6::parse($x);
isa_ok $r.content[0], Pod6::Block, "nested blocks work";
is $r.content[0].content[0], "toot tooot!", "and their content";

# Albi
$x = q[
=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =begin bar
    Dragon Tears!
    =end bar

Which, as we all know...

    =begin bar
    Turn into Jelly Beans!
    =end bar
=end foo
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block;
is $r.content.elems, 5, '5 sub-nodes in foo';
is $r.content[0],
   'and so, all of the villages chased Albi, The Racist Dragon, ' ~
   'into the very cold and very scary cave',
   '...in the marmelade forest';
is $r.content[1],
   'and it was so cold and so scary in there, that Albi began to cry',
   '...between the make-believe trees';
is $r.content[2].content[0], "Dragon Tears!",
   '...in a cottage cheese cottage';
is $r.content[3], "Which, as we all know...",
   '...lives Albi! Albi!';
is $r.content[4].content[0], "Turn into Jelly Beans!",
   '...Albi, the Racist Dragon';

$x = q[
=begin pod

someone accidentally left a space
 
between these two paragraphs

=end pod
];
$r = Pod6::parse($x);
isa_ok $r, Pod6::Block;
is $r.content[0], 'someone accidentally left a space',
   'accidental space, 1/2';
is $r.content[1], 'between these two paragraphs',
   'accidental space, 2/2';

# various things which caused the spectest to fail at some point
$x = q[
=begin kwid

= DESCRIPTION
bla bla

foo
=end kwid
];

$r = Pod6::parse($x);
is $r.content[0], '= DESCRIPTION bla bla';
is $r.content[1], 'foo';

$x = q[
=begin pod

Tests for the feed operators

    ==> and <==
    
=end pod
];

$r = Pod6::parse($x);
is $r.content[0], 'Tests for the feed operators';
is $r.content[1], '==> and <==';

$x = q[
=begin more-discussion-needed

XXX: chop(@array) should return an array of chopped strings?
XXX: chop(%has)   should return a  hash  of chopped strings?

=end more-discussion-needed
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block;
