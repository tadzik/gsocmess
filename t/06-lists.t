use Test;
use Pod6;

my ($x, $r);

$x = q[
=begin pod
     The seven suspects are:

     =item  Happy
     =item  Dopey
     =item  Sleepy
     =item  Bashful
     =item  Sneezy
     =item  Grumpy
     =item  Keyser Soze
=end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 8;
for 1..7 {
    isa_ok $r.content[$_], Pod6::Item;
}

is $r.content[1].content, 'Happy', 'content is happy :)';
is $r.content[2].content, 'Dopey';
is $r.content[7].content, 'Keyser Soze';
todo 'damned Junctions';
nok $r.content[4].level.defined, 'no level information';

$x = q[
=begin pod
     =item1  Animal
     =item2     Vertebrate
     =item2     Invertebrate

     =item1  Phase
     =item2     Solid
     =item2     Liquid
     =item2     Gas
     =item2     Chocolate
=end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 8;
for 0..7 {
    isa_ok $r.content[$_], Pod6::Item;
}

$r.content[0].content, 'Animal';
$r.content[0].level,   1;
$r.content[2].content, 'Invertebrate';
$r.content[2].level,   2;
$r.content[3].content, 'Phase';
$r.content[3].level,   1;
$r.content[4].content, 'Solid';
$r.content[4].level,   2;

$x = q[
=begin pod
    =comment CORRECT...
    =begin item1
    The choices are:
    =end item1
    =item2 Liberty
    =item2 Death
    =item2 Beer
=end pod
];
$r = Pod6::parse($x);
is $r.content.elems, 5;
for 1..4 {
    isa_ok $r.content[$_], Pod6::Item;
}

# XXX Those items are :numbered in S26, but we're waiting with block
# configuration until we're inside Rakudo, otherwise we'll have to
# pretty much implement Pair parsing in gsocmess only to get rid of
# it later.

$x = q[
=begin pod
     Let's consider two common proverbs:

     =begin item
     I<The rain in Spain falls mainly on the plain.>

     This is a common myth and an unconscionable slur on the Spanish
     people, the majority of whom are extremely attractive.
     =end item

     =begin item
     I<The early bird gets the worm.>

     In deciding whether to become an early riser, it is worth
     considering whether you would actually enjoy annelids
     for breakfast.
     =end item

     As you can see, folk wisdom is often of dubious value.
=end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 4;
is $r.content[0], "Let's consider two common proverbs:";
ok $r.content[1].content ~~ /:s This is a common .+ are extremely attractive/;
ok $r.content[2].content ~~ /:s In deciding .+ annelids for breakfast/;
is $r.content[3], "As you can see, folk wisdom is often of dubious value.";

done;
