#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;


class VM::Wheel {

    field $depth :param :reader;

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
        $state = 0;
    }

    ## -------------------------------------------------------------------------

    method advance_by ($ms) {

        my @events;

        while ($ms) {
            $state++;
            $ms--;

            my $remainder = $state;
            foreach my ($i, $size) (indexed @breakdowns) {

                my $value = int($remainder / $size);

                #say "State of wheel[$i][$value]";
                if (my @timers = $wheel[$i][$value]->@*) {
                    say "Found (".(scalar @timers).") timers at wheel[$i][$value]";
                    foreach my $timer (@timers) {
                        my ($expiry, $timeout, $event) = @$timer;
                        if ($i == $#breakdowns || $expiry <= $state) {
                            say "triggering ... expiry($expiry) lte state($state)";
                            push @events => $event;
                            $timer_count--;
                        } elsif ( $expiry > $state ) {
                            say "moving ... expiry($expiry) gt state($state)";
                            $self->move_timer( $timer, $i );
                        } else {
                            die "WTF!";
                        }
                    }
                    $wheel[$i][$value]->@* = ();
                }

                $remainder -= ($value * $size);
            }
        }

        $_->() foreach @events;
    }

    method move_timer( $timer, $level ) {
        my ($expiry) = @$timer;
        $level++;
        my $idx = $expiry - $state;
        say "adding timer(expiry($expiry)) to wheel[$level][$idx]";
        push $wheel[ $level ][ $idx ]->@* => $timer;
    }

    ## -------------------------------------------------------------------------

    method add_timer ($timeout, $event) {
        my $expiry = $state + $timeout;

        foreach my ($i, $size) (indexed @breakdowns) {
            next if $size > $expiry;
            say "Timer($timeout) -> expiry($expiry) : $size at $i = ".int($expiry / $size);
            my $value = int($expiry / $size);
            if ($value != 0) {
                push $wheel[$i][$value]->@* => [ $expiry, $timeout, $event ];
                $timer_count++;
                last;
            }
        }
    }

    method find_next_timer {
        my ($index, $timer);

        foreach my $i ( reverse 0 .. $#breakdowns ) {
            foreach my $spoke ($wheel[$i]->@*) {
                if (@$spoke) {
                    $index = $i;
                    $timer = $spoke->[0];
                    last;
                }
            }
        }

        return ($index, $timer);
    }

    ## -------------------------------------------------------------------------

    method dump_wheel {
        my @units;
        {
            my $remainder = $state;
            foreach my ($i, $size) ( indexed @breakdowns ) {
                my $unit = int($remainder / $size);
                push @units => $unit;
                $remainder -= ($units[-1] * $size);
            }
        }

        say('-' x 33);
        say '  now: ',$state;
        say 'count: ',$timer_count;
        say('-' x 33);
        say '         ', join '.' => 0 .. 9;
        say('-' x 33);
        foreach my ($i, $spoke) ( indexed @wheel ) {
            my @spokes;
            foreach my ($j, $s) (indexed @$spoke) {
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
            say sprintf(' %5d > ' => $breakdowns[$i]), join ':' => @spokes;
        }
        say('-' x 33);
    }
}

my $w = VM::Wheel->new( depth => 5 );
$w->add_timer(15, sub {
    warn ">> 15 @ ".$w->state."\n";

    $w->add_timer(10, sub { warn ">> 15+10=25 @ ".$w->state."\n" });
    $w->add_timer(13, sub { warn ">> 15+13=28 @ ".$w->state."\n" });

});
$w->add_timer( 5, sub {
    warn ">> 5 @ ".$w->state."\n";
    $w->add_timer(10, sub {
        warn ">> 5+10=15 @ ".$w->state."\n";
    });
});

while (1) {
    $w->dump_wheel;
    my $x = <>;
    print "\e[2J\e[H";
    $w->advance_by(10);
}


done_testing;
