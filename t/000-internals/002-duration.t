#!perl

use v5.40;
use experimental qw[ class builtin ];

use Test::More;
use Test::Differences;

use VM::Timers::Duration;


subtest '... simple duration object' => sub {
    my $d = VM::Timers::Duration->new->in_milliseconds( 1234 );
    isa_ok($d,'VM::Timers::Duration');

    is($d->as_milliseconds, 1234, '... got the expected absolute number of milliseconds');
};

subtest '... simple duration object in seconds' => sub {
    my $d = VM::Timers::Duration->new->in_seconds( 0.32 );
    isa_ok($d,'VM::Timers::Duration');

    is($d->as_milliseconds, 320, '... got the expected absolute number of milliseconds');
};

done_testing;
