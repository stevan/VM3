#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'List::Util'   => qw[ mesh ];

class VM::Timers::Wheel::State {
    use overload '""' => \&to_string;

    field $breakdowns :param :reader;

    field @units :reader;

    ADJUST {
        $self->reset;
    }

    method reset {
        @units = (0) x (scalar @$breakdowns);
    }

    method in_units ( @u ) { @units = @u; $self }

    ## -------------------------------------------------------------------------

    method advance_by ($n) {
        while ($n--) {
            my $rollover = true;
            my $i = $#units;
            while ($rollover) {
                $units[$i]++;
                if ($units[$i] == 10) {
                    $units[$i] = 0;
                    $i--;
                } else {
                    $rollover = false;
                }
            }
        }
    }

    ## -------------------------------------------------------------------------

    method calculate_future_state ($duration) {
        my $ms = $duration;

        my @decomposed;
        my @event_time;
        my $remainder = $ms;
        foreach my ($i, $size) ( indexed @$breakdowns ) {
            my $unit = int($remainder / $size);
            push @decomposed => $unit;
            my $sum = $unit + $units[$i];
            if ($sum < 10) {
                push @event_time => $sum;
            } else {
                my $val = $sum - 10;
                $event_time[-1]++;
                push @event_time => $val;
            }
            $remainder -= ($decomposed[-1] * $size);
        }

        return VM::Timers::Wheel::State->new(
            breakdowns => $breakdowns
        )->in_units(
            @event_time
        );
    }

    ## -------------------------------------------------------------------------

    method equal_to ($s) {
        my $is_equal = true;
        foreach my ($l, $r) (mesh \@units, [ $s->units ]) {
            if ($l != $r) {
                $is_equal = false;
                last;
            }
        }
        return $is_equal;
    }

    method to_string {
        sprintf 'Time[%s]', join ':' => @units;
    }
}
