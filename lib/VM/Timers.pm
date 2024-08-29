#!perl

use v5.40;
use experimental qw[ class ];

use VM::Timers::Timer;
use VM::Timers::Wheel;

class VM::Timers {
    # FIXME: this should be configurable
    use constant WHEEL_DEPTH => 5;

    field $wheel :reader;

    ADJUST {
        $wheel = VM::Timers::Wheel->new( depth => WHEEL_DEPTH );
    }

    method add_timer ($ms, $event) {
        my $timer = VM::Timers::Timer->new(
            duration => $ms,
            event    => $event
        );

        $wheel->add_timer( $timer );
        return $timer;
    }
}
