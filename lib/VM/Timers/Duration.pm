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

    method increase_by ($milliseconds) {
        $_absolute += $milliseconds;
    }

    ## -------------------------------------------------------------------------

    method compare_to ($d) { $_absolute <=> $d->as_milliseconds }

    method equal_to     ($d) { $self->compare_to($d) ==  0 }
    method less_than    ($d) { $self->compare_to($d) == -1 }
    method greater_than ($d) { $self->compare_to($d) ==  1 }

    ## -------------------------------------------------------------------------

    method add_to ($d) {
        __CLASS__->new( _absolute => $_absolute + $d->_absolute )
    }

    method subtract_from ($d) {
        __CLASS__->new( _absolute => $_absolute - $d->_absolute )
    }

    ## -------------------------------------------------------------------------

    method to_string {
        sprintf 'Time[%0.4f]', $self->in_seconds;
    }
}
