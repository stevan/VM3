#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'Time::HiRes'  => qw[ sleep ];

class Timer {
    use overload '""' => \&to_string;
    field $expiry :param :reader;
    field $event  :param :reader;

    method to_string {
        sprintf 'Timer[%d]' => $expiry;
    }
}

class Wheel::State {
    use constant DEBUG => $ENV{DEBUG} // 0;

    use overload '""' => \&to_string;
    field $num_gears :param :reader;

    field $time    :reader =  0;
    field @gears   :reader = (0) x $num_gears;
    field @changes :reader = (0) x $num_gears;

    method advance {
        $time++;

        @changes = (0) x $num_gears;

        my $i = 0;
        DEBUG && say "i($i) num_gears($num_gears) @ time($time)";
        while ($i < $num_gears) {
            DEBUG && say ".. i($i) num_gears($num_gears) @ time($time)";
            DEBUG && say "gears[$i] = ",$gears[$i];
            if ($gears[$i] < 9) {
                $gears[$i]++;
                DEBUG && say "inc gears[$i] = ",$gears[$i];
                $changes[$i] = $gears[$i];
                last;
            } else {
                DEBUG && say "... rolled over i($i) to zero @ time($time)";
                $gears[$i] = 0;
                $i++;
            }
        }
    }

    method to_string {
        sprintf 'State[%s](%d)' => (join ':', @gears), $time;
    }
}

class Wheel {
    use constant DEBUG => $ENV{DEBUG} // 0;
    use constant DEPTH => 5;

    field @wheel = map +[], 1 .. (DEPTH * 10);

    field $state = Wheel::State->new( num_gears => DEPTH - 1 );

    method advance_by ($n) {
        while ($n) {
            $state->advance;

            my @changes = $state->changes;
            foreach my ($i, $change) (indexed @changes) {
                if ($change) {
                    my $index = $change + ($i * 10);
                    say "check index: ",$index;
                    $self->check_timers( $index, $i );
                }
            }

            $n--;
        }
    }

    method check_timers ($index, $depth) {
        my $bucket = $wheel[$index];
        if (@$bucket) {
            DEBUG && say "checking wheel[$index] found ".(scalar @$bucket)." timer(s)";
            while (@$bucket) {
                my $timer = shift @$bucket;
                if ($timer->expiry == $state->time) {
                    DEBUG && say "Got a timer($timer) event to fire! ";
                    $timer->event->();
                } else {
                    DEBUG && say "Got an timer($timer) to move from depth($depth) to depth(".($depth - 1).")";

                    my $t   = $timer->expiry;
                    my $exp = $depth;

                    while ($exp < $depth) {
                        my $e1 = (10 ** $exp);
                        my $e2 = ($e1 / 10);

                        if (DEBUG) {
                            say sprintf "t(%d) (e: %d e-1: %d)", $t, $e1, $e2;
                            say sprintf "((%d %% %d) - (%d %% %d)) / %d", $t, $e1, $t, $e2, $e2;
                            say sprintf "((%d) - (%d)) / %d", $t % $e1, $t % $e2, $e2;
                            say sprintf "%d / %d", ($t % $e1) - ($t % $e2), $e2;
                            say sprintf "%d", (($t % $e1) - ($t % $e2)) / $e2;
                        }

                        my $x = (($t % $e1) - ($t % $e2)) / $e2;
                        if ($x == 0) {
                            say "x($x) == 0, so dec depth($depth)";
                            $depth++;
                            next;
                        }

                        my $next_index = (($exp - 1) * 10) + $x;
                        DEBUG && say "Moving timer($timer) to index($next_index)";
                        push $wheel[$next_index]->@* => $timer;
                        last;
                    }
                }
            }
        } else {
            say "no timers to check ...";
        }
    }

    method calculate_first_index_for_time ($t) {
        DEBUG && say "Calculating index for time($t)";
        return $t if $t < 10;

        my $exp = 1;
        while ($exp < DEPTH) {
            my $e1 = (10 ** $exp);
            if ($t < $e1) {
                my $e2 = ($e1 / 10);
                if (DEBUG) {
                    say sprintf "t: %d => (e: %d e-1: %d)", $t, $e1, $e2;
                    say sprintf "((%d %% %d) - (%d %% %d)) / %d", $t, $e1, $t, $e2, $e2;
                    say sprintf "((%d) - (%d)) / %d", $t % $e1, $t % $e2, $e2;
                    say sprintf "%d / %d", ($t % $e1) - ($t % $e2), $e2;
                    say sprintf "%d", (($t % $e1) - ($t % $e2)) / $e2;

                    say sprintf "(%d - 1) * 10", $exp;
                    say sprintf "(%d)", (($exp - 1) * 10);
                }
                my $index = (($exp - 1) * 10) + ((($t % $e1) - ($t % $e2)) / $e2);
                DEBUG && say sprintf "found index: %d", $index;
                return $index;
            } else {
                $exp++;
            }
        }
        die "Wheel Overflow !! ($t)";
    }

    method calculate_timeout_for_index ($index) {
        DEBUG && say "Calculating timeout for index($index)";
        return $index if $index < 10;
        if (DEBUG) {
            say "index % 10 = ",($index % 10);
            say "index / 10 = ",int($index / 10);
            say "timeout = ",(($index % 10) * (10 ** int($index / 10)));
        }
        return (($index % 10) * (10 ** int($index / 10)));
    }

    method find_next_timeout {
        foreach my ($i, $bucket) (indexed @wheel) {
            return $self->calculate_timeout_for_index($i)
                if scalar @$bucket;
        }
    }

    method add_timer_at($t, $event) {
        push @{ $wheel[ $self->calculate_first_index_for_time($t) ] } => Timer->new(
            expiry => $t,
            event  => $event,
        );
    }

    method dump_wheel {
        say "-- wheel ----------------";
        say "     ".(join ':' => map { sprintf '%02d' => $_ } 0 ..  9);
        say "mil: ".(join ':' => map { sprintf '%02d' => scalar @$_ } @wheel[  0 ..  9 ]);
        say "cen: ".(join ':' => map { sprintf '%02d' => scalar @$_ } @wheel[ 10 .. 19 ]);
        say "dec: ".(join ':' => map { sprintf '%02d' => scalar @$_ } @wheel[ 20 .. 29 ]);
        say "sec: ".(join ':' => map { sprintf '%02d' => scalar @$_ } @wheel[ 30 .. 39 ]);
        say "-------------------------";
        say "state = ",$state;
        say "      : ",(join ', ', $state->changes);
        say "-------------------------";
        foreach my ($i, $x) (indexed @wheel) {
            if (scalar @$x) {
                say "wheel[$i] = [",(join ', ' => @$x),"]";
            }
        }
        say "-------------------------";
    }
}


my $w = Wheel->new;

my $max = 1000;

my @expected = map { int(rand($max)) } 0 .. 100;
my @got;

foreach my $t (103) { #@expected) {
    my $x = $t;
    $w->add_timer_at($t, sub { push @got => $x });
}

$w->advance_by( 90 );

my $i = $max + 10;
while ($i--) {
    print "\e[2J\e[H";
    $w->advance_by( 1 );
    $w->dump_wheel;
    my $x = <>;
    #sleep(0.01);
}




