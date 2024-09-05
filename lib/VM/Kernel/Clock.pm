
use v5.40;
use experimental qw[ class ];

use importer 'List::Util'   => qw[ max ];
use importer 'Time::HiRes'  => qw[ clock_gettime ];
use importer 'Carp'         => qw[ confess ];

class VM::Kernel::Clock {
    use overload '""' => \&to_string;

    use const SCALE_BY   => $ENV{CLOCK_SCALE} || 1;
    use const RESOLUTION => 100_000;
    use const PRECISION  => 0.01;

    field $scale_by :param :reader = SCALE_BY;

    field $epoch   :reader;
    field $elapsed :reader;

    my sub now {
        state $MONO = Time::HiRes::CLOCK_MONOTONIC();
        return int(((clock_gettime($MONO) * RESOLUTION) * PRECISION));
    }

    ADJUST {
        $epoch   = now();
        $elapsed = 0;
    }

    method calculate_expiry_time ($timeout) {
        $epoch + $timeout;
    }

    method update {
        my $now  = now();
        $elapsed = max(0, (($now - $epoch) * $scale_by));
        $epoch   = $now;
        $self;
    }

    method to_string {
        sprintf 'Clock[%d/%d]' => $epoch, $elapsed;
    }
}
