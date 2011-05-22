use Test;
use Pod6;
plan 15;

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
is $r.content[0].content[0], "Inside got";
isa_ok $r.content[1], Pod6::Block;
is $r.content[1].content[0], "Inside bidden";
isa_ok $r.content[2], Str;
is $r.content[2], "Outside blocks";

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
