use Test;
use Pod6;
plan 50;

my ($x, $r);

$x = q[
=begin pod
This ordinary paragraph introduces a code block:

    $this = 1 * code('block');
    $which.is_specified(:by<indenting>);
=end pod
];

$r = Pod6::parse($x);
is $r.content[0], 'This ordinary paragraph introduces a code block:';
isa_ok $r.content[1], Pod6::Block::Code;
ok $r.content[1].content.Str
   ~~ /'this = 1' .+ 'specified(:by<indenting>);'/;

# more fancy code blocks
$x = q[
=begin pod
This is an ordinary paragraph

    While this is not
    This is a code block

    =head1 Mumble mumble

    Suprisingly, this is a code block again
        (with fancy indentation too)

But this is just a text. Again

=end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 5;
is $r.content[0], 'This is an ordinary paragraph';
isa_ok $r.content[1], Pod6::Block::Code;
is $r.content[1].content, "While this is not\nThis is a code block";
isa_ok $r.content[2], Pod6::Block;
is $r.content[2].content, 'Mumble mumble';
isa_ok $r.content[3], Pod6::Block::Code;
is $r.content[3].content, "Suprisingly, this is a code block again\n"
                        ~ "    (with fancy indentation too)";
is $r.content[4], "But this is just a text. Again";

$x = q[
=begin pod

Tests for the feed operators

    ==> and <==
    
=end pod
];

$r = Pod6::parse($x);
is $r.content[0], 'Tests for the feed operators';
isa_ok $r.content[1], Pod6::Block::Code;
is $r.content[1].content, "==> and <==";

$x = q[
=begin pod
Fun comes

    This is code
  Ha, what now?

 one more block of code
 just to make sure it works
  or better: maybe it'll break!
=end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 4;
is $r.content[0], 'Fun comes';
isa_ok $r.content[1], Pod6::Block::Code;
is $r.content[1].content, 'This is code';
isa_ok $r.content[2], Pod6::Block::Code;
is $r.content[2].content, 'Ha, what now?';
isa_ok $r.content[3], Pod6::Block::Code;
is $r.content[3].content, "one more block of code\n"
                        ~ "just to make sure it works\n"
                        ~ " or better: maybe it'll break!";

$x = q[
    =begin pod

    =head1 A heading

    This is Pod too. Specifically, this is a simple C<para> block

        $this = pod('also');  # Specifically, a code block

    =end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 3;
isa_ok $r.content[0], Pod6::Block;
is $r.content[0].content, 'A heading';
is $r.content[1],
   'This is Pod too. Specifically, this is a simple C<para> block';
isa_ok $r.content[2], Pod6::Block::Code;
is $r.content[2].content,
   q[$this = pod('also');  # Specifically, a code block];

$x = q[
    =begin pod
    not a code
  still not a code

      a code
 and not a code
    =end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 3;
is $r.content[0], 'not a code still not a code';
isa_ok $r.content[1], Pod6::Block::Code;
is $r.content[1].content, 'a code';
is $r.content[2], 'and not a code';

$x = q[
=begin pod
    this is code

    =for podcast
        this is not

    this is code

    =begin itemization
        this is not
    =end itemization

    =begin quitem
        and this is not
    =end quitem

    =item
        and this is!
=end pod
];

$r = Pod6::parse($x);
is $r.content.elems, 6;
isa_ok $r.content[0], Pod6::Block::Code;
is $r.content[0].content, 'this is code';

isa_ok $r.content[1], Pod6::Block::Named;
is $r.content[1].name, 'podcast';
is $r.content[1].content, 'this is not';

isa_ok $r.content[2], Pod6::Block::Code;
is $r.content[2].content, 'this is code';

isa_ok $r.content[3], Pod6::Block::Named;
is $r.content[3].name, 'itemization';
is $r.content[3].content, 'this is not';

isa_ok $r.content[4], Pod6::Block::Named;
is $r.content[4].name, 'quitem';
is $r.content[4].content, 'and this is not';

isa_ok $r.content[5].content[0], Pod6::Block::Code;
is $r.content[5].content[0].content, 'and this is!';
