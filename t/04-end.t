use Test;
use Pod6;

plan 5;

my $x = q[
=foo bar

=begin END
=as many invalid pod as we want
===yay!

foo foo
=begin asd
=end wrr
];

my $r = Pod6::parse($x);
is $r.content.elems, 1;
is $r.content[0], 'bar';

$x = q[
=begin pod

=end pod
=for END
bla bla
ble ble!
=aryunfaoywpnaohao oyapoyua wpoyaw oyawhota
];

$r = Pod6::parse($x);
say $r.perl;
#isa_ok $r, Pod6::Block;
#is $r.content, [];

$x = q[
=what ever

=END ba ba ba ba
=begin END
=end FOO
];

$r = Pod6::parse($x);
isa_ok $r, Pod6::Block;
is $r.content.elems, 1;
is $r.content[0], 'ever';

# TODO: Test if =end END issues a warning
