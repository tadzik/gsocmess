use Test;
use Pod6;
plan *;
my ($x, $r);

#you can create tables compactly, line-by-line

$x = q[
=begin pod
=begin table
        The Shoveller   Eddie Stevens     King Arthur's singing shovel
        Blue Raja       Geoffrey Smith    Master of cutlery
        Mr Furious      Roy Orson         Ticking time bomb of fury
        The Bowler      Carol Pinnsler    Haunted bowling ball
=end table
=end pod
];

$r = Pod6::parse($x);
my $t = $r.content[0];
isa_ok $t, Pod6::Block::Table;
is $t.content[0][0], 'The Shoveller';
is $t.content[0][1], 'Eddie Stevens';
is $t.content[0][2], "King Arthur's singing shovel";
is $t.content[1][0], 'Blue Raja';
is $t.content[1][1], 'Geoffrey Smith';
is $t.content[1][2], 'Master of cutlery';
is $t.content[2][0], 'Mr Furious';
is $t.content[2][1], 'Roy Orson';
is $t.content[2][2], 'Ticking time bomb of fury';
is $t.content[3][0], 'The Bowler';
is $t.content[3][1], 'Carol Pinnsler';
is $t.content[3][2], 'Haunted bowling ball';

$x = q[
     =table
         Constants           1
         Variables           10
         Subroutines         33
         Everything else     57
];
$r = Pod6::parse($x);
is $r.content[0][0], 'Constants';
is $r.content[1][0], 'Variables';
is $r.content[2][0], 'Subroutines';
is $r.content[3][0], 'Everything else';
is $r.content[0][1], '1';
is $r.content[1][1], '10';
is $r.content[2][1], '33';
is $r.content[3][1], '57';

done;
