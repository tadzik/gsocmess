use Test;
use Pod6;
plan 26;

my $x = q[
=foo
];
my $r = Pod6::parse($x);

isa_ok $r, Pod6::Block, 'returns a Pod6 Block';
isa_ok $r, Pod6::Block::Named, 'returns a named Block';
is $r.content, [], 'no content, all right';

$x = q[
=foo some text
];
$r = Pod6::parse($x);
is $r.content[0], "some text", 'the content is all right';

$x = q[
=foo some text
and some more
];
$r = Pod6::parse($x);
is $r.content[0], "some text and some more", 'the content is all right';

$x = q[
=begin pod

=got Inside
got

=bidden Inside
bidden

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
    =two two,
    paragraph block
    =for three
    three, still a parablock

    =begin four
    four, another delimited one
    =end four
    =head1 And just for the sake of having a working =head1 :)
=end pod
];

$r = Pod6::parse($x);
is $r.content[0].content[0], "one, delimited block", "mixed blocks, 1";
is $r.content[1].content[0], "two, paragraph block", "mixed blocks, 2";
is $r.content[2].content[0], "three, still a parablock", "mixed blocks, 3";
is $r.content[3].content[0], "four, another delimited one", "mixed blocks, 4";
is $r.content[4].content[0], "And just for the sake of having a working =head1 :)", 'mixed blocks, 5';

$x = q[
=begin foo
and so,  all  of  the  villages chased
Albi,   The   Racist  Dragon, into the
very   cold   and  very  scary    cave

and it was so cold and so scary in
there,  that  Albi  began  to  cry

    =bold Dragon Tears!

Which, as we all know...

    =bold Turn
          into
          Jelly
          Beans!
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

# from S26
$x = q[
     =table_not
         Constants 1
         Variables 10
         Subroutines 33
         Everything else 57
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block;
is $r.content.elems, 1;
is $r.content[0],
   'Constants 1 Variables 10 Subroutines 33 Everything else 57';
