#!perl

use v5.40;
use experimental qw[ class ];

class VM::Timers::Timer {
    field $duration :param :reader;
    field $event    :param :reader;

    field $end_state :reader;

    method calculate_end_state ($state) {
        $end_state = $state->calculate_future_state( $duration );
    }

    method fire {
        $event->();
    }
}
