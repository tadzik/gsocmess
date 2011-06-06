use Test;
use Pod6;
plan 15;

my $x = q[
=begin comment
foo foo
=begin invalid pod
=as many invalid pod as we want
===yay!
=end comment
];

my $r = Pod6::parse($x);
isa_ok $r, Pod6::Block;
is $r.content.elems, 1;
is $r.content[0], "foo foo\n=begin invalid pod\n"
                ~ "=as many invalid pod as we want\n===yay!\n";

$x = q[
=for comment
foo foo
=begin invalid pod
=as many invalid pod as we want
===yay!

This isn't a comment
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block::Comment;
is $r.content.elems, 1;
is $r.content[0], "foo foo\n=begin invalid pod\n"
                ~ "=as many invalid pod as we want\n===yay!\n";

$x = q[
=comment foo foo
=begin invalid pod
=as many invalid pod as we want
===yay!

This isn't a comment
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block::Comment;
is $r.content.elems, 1;
is $r.content[0], "foo foo\n=begin invalid pod\n"
                ~ "=as many invalid pod as we want\n===yay!\n";

# just checking if Code works too
$x = q[
=code foo foo
=begin invalid pod
=as many invalid pod as we want
===yay!

This isn't a comment
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block::Code;
is $r.content.elems, 1;
is $r.content[0], "foo foo\n=begin invalid pod\n"
                ~ "=as many invalid pod as we want\n===yay!\n";

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
