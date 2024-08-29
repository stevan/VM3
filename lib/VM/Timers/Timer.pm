#!perl

use v5.40;
use experimental qw[ class ];

class VM::Timers::Timer {
    field $duration :param :reader;
    field $event    :param :reader;
    field $end_time :reader;

    method calculate_end_time ($state) {
        $end_time = $state->add_duration( $duration );
    }

    method fire {
        $event->();
    }
}
