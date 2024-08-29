#!perl

use v5.40;
use experimental qw[ class ];

use VM::Timers::Timer;
use VM::Timers::Duration;
use VM::Timers::Wheel;

class VM::Timers {

    field $wheel :reader;

    ADJUST {
        $wheel = VM::Timers::Wheel->new( depth => 5 );
    }

    method add_timer ($ms, $event) {
        my $timer = VM::Timers::Timer->new(
            duration => VM::Timers::Duration->new->in_milliseconds( $ms ),
            event    => $event
        );

        $wheel->add_timer( $timer );
        return $timer;
    }
}
