#!perl

use v5.40;
use experimental qw[ class ];

class VM::Timers::Duration {
    use overload '""' => \&to_string;

    field $_absolute :param :reader = 0;

    method as_seconds      { $_absolute * 0.001 }
    method as_milliseconds { $_absolute }

    ## -------------------------------------------------------------------------

    method in_seconds ($sec) {
        $_absolute = $sec * 1000;
        $self;
    }

    method in_milliseconds ($ms) {
        $_absolute = $ms;
        $self;
    }

    ## -------------------------------------------------------------------------

    method to_string {
        sprintf 'Time[%0.4f]', $self->in_seconds;
    }
}
