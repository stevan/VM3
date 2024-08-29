#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use VM::Timers::Timer;
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
                        my $timer = shift @$bucket;
                        $self->move_timer( $timer, $i );
                    }
                }

            }
        }
    }

    method move_timer ($timer, $level) {
        my $time  = $timer->end_time;
        my @units = $time->units;
        my $size  = $#breakdowns;
        my $next  = $level;

        if ($next >= $size) {
            LOG("triggering [${time}]") if DEBUG;
            $timer->fire;
            return;
        }

        while (++$next) {
            if ($next > $size) {
                LOG("triggering [${time}]") if DEBUG;
                $timer->fire;
                last;
            } elsif ($units[$next]) {
                LOG("advancing [${time}] from $level \@ ".($units[$level])
                    ." to $next \@ ".($units[$next])."") if DEBUG;
                push @{ $wheel[$next]->[ $units[$next] ] } => $timer;
                last;
            }
        }
    }

    ## -------------------------------------------------------------------------

    method find_next_timer {
        my $n = $#breakdowns;
        my $timer;
    OUTER:
        while ($n >= 0) {
            foreach my ($i, $bucket) (indexed $wheel[$n]->@*) {
                if (@$bucket) {
                    #LOG "Found events at wheel[$n]->[$i]" if DEBUG;
                    $timer = $bucket->[0];
                    last OUTER;
                }
            }
            $n--;
        }

        return $timer;
    }

    ## -------------------------------------------------------------------------

    method add_timer ($timer) {
        my $end_time = $timer->calculate_end_time( $state );

        foreach my ($i, $unit) ( indexed $end_time->units ) {
            if ($unit) {
                push @{ $wheel[$i]->[ $unit ] } => $timer;
                last;
            }
        }
    }

    # TODO - cancel a timer (find and remove)

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

        my $next = $self->find_next_timer;

        say('-' x 33);
        say '  now: ',$state->to_string;
        say ' next: ',($next ? $next->end_time->to_string : '~');
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


