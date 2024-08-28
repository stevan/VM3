#!perl

use v5.40;
use experimental qw[ class ];

use importer 'List::Util'   => qw[ max ];
use importer 'Time::HiRes'  => qw[ clock_gettime ];

class VM::Clock {
    use const RESOLUTION => 100_000;
    use const PRECISION  => 0.01;

    field $seconds :reader;
    field $elapsed :reader = 0;

    ADJUST {
        $seconds = $self->now;
    }

    method now {
        state $MONO = Time::HiRes::CLOCK_MONOTONIC();
        return int((clock_gettime($MONO) * RESOLUTION) * PRECISION);
    }

    method update {
        my $now  = $self->now;
        $elapsed = max(0, ($now - $seconds));
        $seconds = $now;
        $self;
    }
}
