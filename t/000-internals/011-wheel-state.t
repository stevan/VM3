#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;

use VM::Timers::Wheel::State;

my @breakdowns = (10000, 1000, 100, 10, 1);

my $state = VM::Timers::Wheel::State->new( breakdowns => \@breakdowns );

my $expected = $state->decompose(1234);

my @to_check = (
    $state->normalize(0, 1, 0,   0,  234),
    $state->normalize(0, 0, 10,  0,  234),
    $state->normalize(0, 0, 0,   0, 1234),
    $state->normalize(0, 0, 12,  0,   34),
    $state->normalize(0, 0, 12,  3,    4),
    $state->normalize(0, 0, 0, 123,    4),
    $state->normalize(0, 1, 1,  13,    4),
    $state->normalize(0, 0, 0, 122,   14),
    $state->normalize(0, 0, 8,  42,   14),
    $state->normalize(0, 0, 8,  32,  114),
    $state->normalize(0, 0, 0,  73,  504),
);

foreach my $s ( @to_check ) {
    ok($expected->equal_to( $s ), "... easy: ${expected} == ${s}");
}

my @to_add = (
    $state->decompose(1234),   0,
    $state->decompose(1230),   4,
    $state->decompose(1130), 104,
    $state->decompose( 730), 504,
);

foreach my ($x, $ms) ( @to_add ) {
    my $s = $x->add_milliseconds($ms);
    ok($expected->equal_to( $s ), "... add($ms) : ${expected} == ${s}");
}

done_testing;
