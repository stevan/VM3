#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use VM::Clock;
use VM::Timers::Timer;
use VM::Timers::Wheel::State;

class VM::Timers::Wheel {
    use constant DEBUG => $ENV{TIMERS_DEBUG} // 0;
    sub LOG ($msg) { warn "LOG: ${msg}\n" }

    use overload '""' => \&to_string;

    field $depth :param :reader;

    field $max_timeout :reader;

    field @wheel      :reader;
    field @breakdowns :reader;
    field $state      :reader;

    field $timer_count = 0;

    ADJUST {
        # initialize breakdowns
        @breakdowns = (1);
        push @breakdowns => ( $breakdowns[-1] * 10 ) foreach 1 .. ($depth - 1);
        @breakdowns = reverse @breakdowns;

        # initialize wheel
        @wheel = map { [ map { [] } 1 .. 10 ] } @breakdowns;

        # intialize the time state to zero
        $state = VM::Timers::Wheel::State->new( breakdowns => \@breakdowns );

        # calculate the max timer
        $max_timeout = $breakdowns[0] * 10;
    }

    ## -------------------------------------------------------------------------

    method advance_by ($n) {
        LOG("-- starting ADVANCE_BY ($n) ------------------------------------");

        LOG("++ before advance: ${state}") if DEBUG;
        $state->advance_by($n);
        LOG("++ after advance: ${state}") if DEBUG;

        foreach my ($i, $unit) ( indexed $state->units ) {
            my @events;

            LOG("... checking all events from [$i]") if DEBUG;
            foreach my $bucket ( $wheel[ $i ]->@* ) {
                next unless @$bucket;

                LOG(">>> found (".(scalar @$bucket).") events wheel[$i]") if DEBUG;
                my @keep;
                while (@$bucket) {
                    my $timer     = shift @$bucket;
                    my $end_state = $timer->end_state;

                    if ($end_units[$i] > $unit) {
                        LOG("no need to move [${end_state}] from ${unit}") if DEBUG;
                        push @keep => $timer;
                    } else {
                        LOG("moving [${end_state}] from ${unit}") if DEBUG;
                        $self->_move_timer( $timer, $i );
                    }
                }
                @$bucket = @keep;
            }
        }

        LOG("-- ending ADVANCE_BY ($n) --------------------------------------");
    }

    method _move_timer ($timer, $level) {
        my $end_state  = $timer->end_state;
        my @units      = $end_state->units;

        my $max_level  = $#breakdowns;
        my $next_level = $level;

        if ($next_level >= $max_level) {
            LOG("triggering [${end_state}]") if DEBUG;
            $timer_count--;
            $timer->fire;
            return;
        }

        while (++$next_level) {
            if ($next_level > $max_level) {
                LOG("triggering [${end_state}]") if DEBUG;
                $timer_count--;
                $timer->fire;
                last;
            } elsif ($units[$next_level]) {
                LOG("advancing [${end_state}] from $level \@ ".($units[$level])
                    ." to $next_level \@ ".($units[$next_level])."") if DEBUG;
                push @{ $wheel[$next_level]->[ $units[$next_level] ] } => $timer;
                last;
            }
        }
    }

    ## -------------------------------------------------------------------------

    method calculate_timeout {
        return if $timer_count == 0;

        my $n = $#breakdowns;
        my $idx;
    OUTER:
        while ($n >= 0) {
            foreach my ($i, $bucket) (indexed $wheel[$n]->@*) {
                if (@$bucket) {
                    LOG('... got timer '.$bucket->[0]->end_state) if DEBUG;
                    $idx = $i;
                    last OUTER;
                }
            }
            $n--;
        }

        return unless defined $idx;

        LOG("... found Timer at [$n][$idx] =(".$breakdowns[$n].")=".($breakdowns[$n] * $idx)) if DEBUG;

        return $breakdowns[$n] * $idx;
    }

    ## -------------------------------------------------------------------------

    method add_timer ($timer) {
        my $end_state = $timer->calculate_end_state( $state );

        LOG("Adding Timer at ${end_state}") if DEBUG;

        my @state = $state->units;

        foreach my ($i, $unit) ( indexed $end_state->units ) {
            LOG("Checking ${unit} >= ".$state[$i]) if DEBUG;
            if ($unit && $unit > $state[$i]) {
                push @{ $wheel[$i]->[ $unit ] } => $timer;
                LOG("... Added Timer at [$i][$unit] for ${end_state}") if DEBUG;
                $timer_count++;
                last;
            }
        }
    }

    # TODO - cancel a timer (find and remove)

    ## -------------------------------------------------------------------------

    method dump_wheel_info {
        say('-' x 36);
        say ' max_depth';
        say '  ├─in ms  : ',$max_timeout;
        say '  ├─in sec : ',($max_timeout * 0.001);
        say '  ╰─in min : ',(sprintf '%0.2f' => (($max_timeout * 0.001) / 60));
        say ' breakdown : ',(join ', ' => @breakdowns);
        say('-' x 36);
    }

    method dump_wheel {

        my @units = $state->units;

        say('-' x 33);
        say '  now: ',$state->to_string;
        say 'count: ',$timer_count;
        say('-' x 33);
        say '         ', join '.' => 0 .. 9;
        say('-' x 33);
        foreach my ($i, $spoke) ( indexed @wheel ) {

            my @spokes;
            foreach my ($j, $s) (indexed @$spoke) {
                #warn "i: $j s:".(scalar @$s)." units[$i]: ".$units[$i];

                my $x;
                if ( $j == $units[$i] ) {
                    $x = "\e[0;102m".(scalar @$s)."\e[0m";
                }
                else {
                    $x = scalar @$s;
                    $x = "\e[0;9${x}m".($x ? "\e[7m" : '').$x."\e[0m";
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


