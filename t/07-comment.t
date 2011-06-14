use Pod6;
use Test;
plan 15;

my ($x, $r);

$x = q[
=begin comment
foo foo
=begin invalid pod
=as many invalid pod as we want
===yay!
=end comment
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block;
is $r.content.elems, 1;
is $r.content[0], "foo foo\n=begin invalid pod\n"
                ~ "=as many invalid pod as we want\n===yay!\n";

$x = q[
=for comment
foo foo
bla bla    bla

This isn't a comment
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block::Comment;
is $r.content.elems, 1;
is $r.content[0], "foo foo\nbla bla    bla\n";

$x = q[
=comment foo foo
bla bla    bla

This isn't a comment
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block::Comment;
is $r.content.elems, 1;
is $r.content[0], "foo foo\nbla bla    bla\n";

# just checking if Code works too
$x = q[
=begin pod
=code foo foo
bla bla    bla

This isn't a comment
=end pod
];

$r = Pod6::parse($x);
isa_ok $r.content[0], Pod6::Block::Code;
is $r.content[0].elems, 1;
is $r.content[0].content, "foo foo\nbla bla    bla\n";

# from S26
$x = q[
=comment
This file is deliberately specified in Perl 6 Pod format
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block::Comment;
is $r.content.elems, 1;
is $r.content[0],
   "This file is deliberately specified in Perl 6 Pod format\n";
