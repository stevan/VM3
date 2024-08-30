#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;

use VM::Timers::Wheel::State;

my @breakdowns = (10000, 1000, 100, 10, 1);

my $state1 = VM::Timers::Wheel::State->new( breakdowns => \@breakdowns );
my $state2 = VM::Timers::Wheel::State->new( breakdowns => \@breakdowns );

ok($state1->equal_to($state2), '... the states1 is equal to state2');
ok(!$state1->greater_than($state2), '... state1 is not greater than');
ok(!$state1->less_than($state2), '... state1 is not less than');

ok($state2->equal_to($state1), '... the state2 is equal to state1');
ok(!$state2->greater_than($state1), '... state2 is not greater than');
ok(!$state2->less_than($state1), '... state2 is not less than');

$state1->advance_by(3);

ok(!$state1->equal_to($state2), '... the states1 is not equal to state2');
ok($state1->greater_than($state2), '... state1 is now greater than');
ok(!$state1->less_than($state2), '... state1 is still not less than');

ok(!$state2->equal_to($state1), '... the state2 is not equal to state1');
ok(!$state2->greater_than($state1), '... state2 is not greater than');
ok($state2->less_than($state1), '... state2 is now less than');

$state2->advance_by(5);

ok(!$state1->equal_to($state2), '... the states1 is not equal to state2');
ok(!$state1->greater_than($state2), '... state1 is no longer greater than');
ok($state1->less_than($state2), '... state1 is now less than');

ok(!$state2->equal_to($state1), '... the state2 is not equal to state1');
ok($state2->greater_than($state1), '... state2 is now greater than');
ok(!$state2->less_than($state1), '... state2 is no longer less than');

$state2->advance_by(1234);

ok(!$state1->equal_to($state2), '... the states1 is not equal to state2');
ok(!$state1->greater_than($state2), '... state1 is not greater than');
ok($state1->less_than($state2), '... state1 is still less than');

ok(!$state2->equal_to($state1), '... the state2 is not equal to state1');
ok($state2->greater_than($state1), '... state2 is now greater than');
ok(!$state2->less_than($state1), '... state2 is no longer less than');

$state1->advance_by(1236);

ok($state1->equal_to($state2), '... the states1 is now equal to state2');
ok(!$state1->greater_than($state2), '... state1 is not greater than');
ok(!$state1->less_than($state2), '... state1 is not less than');

ok($state2->equal_to($state1), '... the state2 is now equal to state1');
ok(!$state2->greater_than($state1), '... state2 is not greater than');
ok(!$state2->less_than($state1), '... state2 is not less than');

$state1->advance_by(700);

ok(!$state1->equal_to($state2), '... the states1 is not equal to state2');
ok($state1->greater_than($state2), '... state1 is now greater than');
ok(!$state1->less_than($state2), '... state1 is still not less than');

ok(!$state2->equal_to($state1), '... the state2 is not equal to state1');
ok(!$state2->greater_than($state1), '... state2 is not greater than');
ok($state2->less_than($state1), '... state2 is now less than');

done_testing;
