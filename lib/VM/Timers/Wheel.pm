#!perl

=pod

create arrays for each of the sizes (s,d,c,m)

the s array is infinite, but the others are from 0 - 10

adding a timer:
- $end_time = clock->now + timer->duration
- @gears = decomose($end_time);

- push the timer into the lowest resolution bucket
  as this must first be met before we run anything more

if (seconds)
    push wheel[seconds][ gears[seconds] ], timer;
    last
elsif (*)
    push wheel[*][ gears[*] ], timer
    last

with each advance/tick:

    check_timers in all the spokes of the wheel:

        wheel[seconds][ $current_second ],
        wheel[*      ][ $current_*      ],

    - if the timer has higher resolution
        - move it into the next level of buckets
            - add it to the approriate index




=cut

use v5.40;
use experimental qw[ class ];

class VM::Timers::Wheel {
    use overload '""' => \&to_string;

    field $seconds      :param :reader = 0;
    field $deciseconds  :param :reader = 0;
    field $centiseconds :param :reader = 0;
    field $milliseconds :param :reader = 0;

    ## -------------------------------------------------------------------------

    my sub compose_ms ($sec, $dec, $cen, $ms) {
        return $ms         +
              ($cen * 10)  +
              ($dec * 100) +
              ($sec * 1000);
    }

    my sub decompose_ms ($ms) {
        my $sec = int($ms / 1000);
        $ms -= ($sec * 1000);

        my $dec = int($ms / 100);
        $ms -= ($dec * 100);

        my $cen = int($ms / 10);
        $ms -= ($cen * 10);

        return ($sec, $dec, $cen, $ms);
    }

    ## -------------------------------------------------------------------------

    method in_seconds      { $self->in_milliseconds * 0.001 }
    method in_milliseconds {
        compose_ms( $seconds, $deciseconds, $centiseconds, $milliseconds )
    }

    ## -------------------------------------------------------------------------

    method advance_by ($elapsed) {
        my ($sec, $dec, $cen, $ms) = decompose_ms( $elapsed );

        $seconds      += $sec;
        $deciseconds  += $dec;
        $centiseconds += $cen;
        $milliseconds += $ms;

        $self;
    }

    ## -------------------------------------------------------------------------

    method to_string {
        sprintf 'Wheel[%02d:%02d:%02d:%02d]',
            $seconds,
            $deciseconds,
            $centiseconds,
            $milliseconds;
    }
}


__END__

class Timing::Wheel {
    use overload '""' => \&to_string;

    field @sizes;
    field @rotations;
    # rotations are:
    # - milliseconds, centiseconds, deciseconds, seconds

    ADJUST {
        @sizes     = ( 10, 10, 10 );
        @rotations = ( 0, 0, 0, 0 );
    }

    method advance ($by) {
        my $i = 0;
        $rotations[$i] += $by;

        while ($i < $#rotations) {
            #say "$i : ",$rotations[$i];
            while ($rotations[$i] >= $sizes[$i]) {
                $rotations[$i] -= $sizes[$i];
                $rotations[$i + 1]++;
            }
            $i++;
        }
    }

    method to_string {
        join ':' => reverse map { sprintf '%02d', $_ } @rotations;
    }
}




