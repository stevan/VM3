#!perl

use v5.40;
use experimental qw[ class ];

use importer 'List::Util'   => qw[ max ];
use importer 'Time::HiRes'  => qw[ clock_gettime ];
use importer 'Carp'         => qw[ confess ];

class VM::Clock::Time {
    use overload '""' => \&to_string;
    field $epoch :param :reader;
    method to_string { sprintf 'Time[%d]' => $epoch }
}

class VM::Clock {
    use overload '""' => \&to_string;

    use const SCALE_BY   => $ENV{CLOCK_SCALE} || 1;
    use const RESOLUTION => 100_000;
    use const PRECISION  => 0.01;

    field $scale_by :param :reader = SCALE_BY;

    field $seconds :reader;
    field $elapsed :reader = 0;

    method get_current_time { VM::Clock::Time->new( epoch => $seconds ) }

    my sub now {
        state $MONO = Time::HiRes::CLOCK_MONOTONIC();
        return int(((clock_gettime($MONO) * RESOLUTION) * PRECISION));
    }

    method start { $seconds = now() }
    method stop  { $seconds = undef }

    method is_started {   defined $seconds }
    method is_stopped { ! defined $seconds }

    method update {
        confess 'Clock must be started before updating'
            if not defined $seconds;
        my $now  = now();
        $elapsed = max(0, (($now - $seconds) * $scale_by));
        $seconds = $now;
        $self;
    }

    method to_string {
        sprintf 'Clock[%d/%d]' => $seconds, $elapsed;
    }
}
