use Test;
use Pod6;
plan 22;

my $x = q[
=for foo
];
my $r = Pod6::parse($x);

isa_ok $r, Pod6::Block, 'returns a Pod6 Block';
isa_ok $r, Pod6::Block::Named, 'returns a named Block';
is $r.content, [], 'no content, all right';

$x = q[
=for foo
some text
];
$r = Pod6::parse($x);
is $r.content[0], "some text", 'the content is all right';

$x = q[
=for foo
some
spaced   text
];
$r = Pod6::parse($x);
is $r.content[0], "some spaced text", 'additional whitespace removed ' ~
                                   'from the content';
$x = q[
=begin pod

=for got
Inside got

=for bidden
Inside bidden

Outside blocks
=end pod
];
$r = Pod6::parse($x);
isa_ok $r.content[0], Pod6::Block;
is $r.content[0].content[0], "Inside got",
   'paragraph block content ok, 1/2';
isa_ok $r.content[1], Pod6::Block;
is $r.content[1].content[0], "Inside bidden",
   'paragraph block content ok, 1/2';
isa_ok $r.content[2], Str;
is $r.content[2], "Outside blocks",
   'content outside blocks is all right';

# mixed blocks
$x = q[
=begin pod
=begin one
one, delimited block
=end one
=for two
two, paragraph block
=for three
three, still a parablock

=begin four
four, another delimited one
=end four
=end pod
];

$r = Pod6::parse($x);
is $r.content[0].content[0], "one, delimited block", "mixed blocks, 1";
is $r.content[1].content[0], "two, paragraph block", "mixed blocks, 2";
is $r.content[2].content[0], "three, still a parablock", "mixed blocks, 3";
is $r.content[3].content[0], "four, another delimited one", "mixed blocks, 4";

# tests without Albi would still be tests, but definitely very, very sad
# also, Albi without paragraph blocks wouldn't be the happiest dragon
# either
$x = q[
=begin foo
    and so,  all  of  the  villages chased
    Albi,   The   Racist  Dragon, into the
    very   cold   and  very  scary    cave

    and it was so cold and so scary in
    there,  that  Albi  began  to  cry

    =for bar
        Dragon Tears!

    Which, as we all know...

    =for bar
        Turn into Jelly Beans!
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
