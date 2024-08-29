#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use VM::Timers::Wheel::Time;

class VM::Timers::Wheel {
    use constant DEBUG => $ENV{DEBUG} // 0;
    sub LOG ($msg) { warn "LOG: ${msg}\n" }

    use overload '""' => \&to_string;

    field $depth :param :reader;

    field $max_timer :reader;

    field @wheel;
    field @breakdowns;
    field $state;

    ADJUST {
        # initialize breakdowns
        @breakdowns = (1);
        push @breakdowns => ( $breakdowns[-1] * 10 ) foreach 1 .. ($depth - 1);
        @breakdowns = reverse @breakdowns;

        # initialize wheel
        @wheel = map { [ map { [] } 1 .. 10 ] } @breakdowns;

        # intialize the time state to zero
        $state = VM::Timers::Wheel::Time->new( breakdowns => \@breakdowns );

        # calculate the max timer
        $max_timer = $breakdowns[0] * 10;
    }

    ## -------------------------------------------------------------------------

    method advance_by ($n) {
        my @old = $state->units;

        $state->advance_by($n);

        foreach my ($i, $unit) ( indexed $state->units ) {
            my @events;

            my $old = $old[$i];

            my @indicies;
            LOG("old[$i](${old}) | unit(${unit})") if DEBUG;
            if ( $old == $unit) {
                # do nothing, no change ...
                LOG("... equal, so doing nothing") if DEBUG;
                #@indicies = ($unit);
            } elsif ($old < $unit) {
                # grab all the possible affected events
                LOG("... less than") if DEBUG;
                @indicies = ($old + 1) .. $unit;
            } elsif ($old > $unit) {
                LOG("... greater than") if DEBUG;
                @indicies = 0 .. $unit;
            }

            if (@indicies) {
                LOG("... grabbing all events from (".(join ', ' => @indicies).")") if DEBUG;
                foreach my $bucket ( $wheel[ $i ]->@[ @indicies ] ) {
                    LOG(">>> found (".(scalar @$bucket).") events wheel[$i][$unit]") if DEBUG;
                    while (@$bucket) {
                        my $event = shift @$bucket;
                        $self->move_event( $event, $i );
                    }
                }

            }
        }
    }

    method move_event ($event, $level) {
        my ($time, $cb) = @$event;

        my @units = $time->units;
        my $size  = $#breakdowns;
        my $next  = $level;

        if ($next >= $size) {
            LOG("triggering [${time}]") if DEBUG;
            $cb->();
            return;
        }

        while (++$next) {
            if ($next > $size) {
                LOG("triggering [${time}]") if DEBUG;
                $cb->();
                last;
            } elsif ($units[$next]) {
                LOG("advancing [${time}] from $level \@ ".($units[$level])
                    ." to $next \@ ".($units[$next])."") if DEBUG;
                push @{ $wheel[$next]->[ $units[$next] ] } => $event;
                last;
            }
        }
    }

    ## -------------------------------------------------------------------------

    method add_timer ($duration, $event) {
        my $event_time = $state->add_duration( $duration );

        foreach my ($i, $unit) ( indexed $event_time->units ) {
            if ($unit) {
                push @{ $wheel[$i]->[ $unit ] } => [ $event_time, $event ];
                last;
            }
        }
    }

    ## -------------------------------------------------------------------------

    method dump_wheel_info {
        say('-' x 36);
        say ' max_depth';
        say '  ├─in ms  : ',$max_timer;
        say '  ├─in sec : ',($max_timer * 0.001);
        say '  ╰─in min : ',(sprintf '%0.2f' => (($max_timer * 0.001) / 60));
        say ' breakdown : ',(join ', ' => @breakdowns);
        say('-' x 36);
    }

    method dump_wheel {

        my @units = $state->units;

        say('-' x 33);
        say '  @ ',$state->to_string;
        say('-' x 33);
        say '         ', join '.' => 0 .. 9;
        say('-' x 33);
        foreach my ($i, $spoke) ( indexed @wheel ) {

            my @spokes;
            foreach my ($j, $s) (indexed @$spoke) {
                #warn "i: $j s:".(scalar @$s)." units[$i]: ".$units[$i];

                my $x;
                if ( $j == $units[$i] ) {
                    $x = "\e[7m".(scalar @$s)."\e[0m";
                }
                else {
                    $x = scalar @$s;
                }
                push @spokes => $x;
            }

            say sprintf(' %5d > ' => $breakdowns[$i]),
                join ':' => @spokes;
        }
        say('-' x 33);
    }

    method to_string {
        $state->to_string
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




