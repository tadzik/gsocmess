use Test;
use Pod6;
plan 7;

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
