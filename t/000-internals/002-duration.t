#!perl

use v5.40;
use experimental qw[ class builtin ];

use Test::More;
use Test::Differences;

use VM::Timers::Duration;


subtest '... simple duration object' => sub {
    my $d = VM::Timers::Duration->from_milliseconds( 1234 );
    isa_ok($d,'VM::Timers::Duration');

    is($d->in_milliseconds, 1234, '... got the expected absolute number of milliseconds');

    subtest '... test equality' => sub {
        my $d2 = VM::Timers::Duration->from_milliseconds( $d->in_milliseconds );
        isa_ok($d2, 'VM::Timers::Duration');

        ok($d->equal_to($d2), '... the durations are equal');
        ok($d2->equal_to($d), '... the durations are equal');
    };

    subtest '... test inequality' => sub {
        my $d2 = VM::Timers::Duration->from_milliseconds( $d->in_milliseconds + 10 );
        isa_ok($d2, 'VM::Timers::Duration');

        ok(!$d->equal_to($d2), '... the durations are not equal');
        ok(!$d2->equal_to($d), '... the durations are not equal');
    };
};

subtest '... simple duration object in milliseconds' => sub {
    my $d = VM::Timers::Duration->from_milliseconds( 2056 );
    isa_ok($d,'VM::Timers::Duration');

    is($d->in_milliseconds, 2056, '... got the expected absolute number of milliseconds');

    subtest '... test adding' => sub {
        my $d2 = VM::Timers::Duration->from_milliseconds( 100 );
        isa_ok($d2, 'VM::Timers::Duration');

        is($d2->in_milliseconds, 100, '... the new duration is as expected');
        is($d->in_milliseconds, 2056, '... the old duration is as expected');

        my $d3 = $d->add_to( $d2 );
        isa_ok($d3, 'VM::Timers::Duration');

        is($d3->in_milliseconds, 2156, '... the resulting duration is as expected');
    };

    subtest '... test subtraction' => sub {
        my $d2 = VM::Timers::Duration->from_milliseconds( 1730 );
        isa_ok($d2, 'VM::Timers::Duration');

        is($d2->in_milliseconds, 1730, '... the new duration is as expected');
        is($d->in_milliseconds, 2056, '... the old duration is as expected');

        my $d3 = $d->subtract_from( $d2 );
        isa_ok($d3, 'VM::Timers::Duration');

        is($d3->in_milliseconds, 326, '... the resulting duration is as expected');
    };

    subtest '... test subtraction' => sub {
        $d->increase_by( 231 );
        is($d->in_milliseconds, 2287, '... the old duration is as expected');
    };
};

subtest '... simple duration object in seconds' => sub {
    my $d = VM::Timers::Duration->from_seconds( 0.32 );
    isa_ok($d,'VM::Timers::Duration');

    is($d->in_milliseconds, 320, '... got the expected absolute number of milliseconds');
};

subtest '... sorting duration objects (seconds)' => sub {
    my @seconds = (map rand(5), 0 .. 10);

    my @durations = map {
        VM::Timers::Duration->from_seconds( $_ )
    } @seconds;

    my @sorted = sort { $a->compare_to($b) } @durations;

    eq_or_diff(
        [ map $_->in_seconds, @sorted ],
        [ sort { $a <=> $b } @seconds ],
        '... sorted the list correctly'
    );
};

subtest '... sorting duration objects (milliseconds)' => sub {
    my @seconds = (map int(rand(500)), 0 .. 10);

    my @durations = map {
        VM::Timers::Duration->from_milliseconds( $_ )
    } @seconds;

    my @sorted = sort { $a->compare_to($b) } @durations;

    eq_or_diff(
        [ map $_->in_milliseconds, @sorted ],
        [ sort { $a <=> $b } @seconds ],
        '... sorted the list correctly'
    );
};










done_testing;
