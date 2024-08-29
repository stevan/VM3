#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

class VM::Timers::Wheel::Time {
    use overload '""' => \&to_string;

    field $breakdowns :param :reader;

    field @units :reader;

    ADJUST {
        @units = (0) x (scalar @$breakdowns);
    }


    ## -------------------------------------------------------------------------

    method in_units ( @u ) { @units = @u; $self }

    method in_seconds ($sec) {
        $self->in_milliseconds( $sec * 1000 );
        $self;
    }

    method in_milliseconds ($ms) {
        @units = ();
        my $remainder = $ms;
        foreach my $size ( @$breakdowns ) {
            push @units => int($remainder / $size);
            $remainder -= ($units[-1] * $size);
        }
        $self;
    }

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

    method add_duration ($duration) {
        my $ms = $duration->as_milliseconds;

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

        return VM::Timers::Wheel::Time->new(
            breakdowns => $breakdowns
        )->in_units(
            @event_time
        );
    }

    ## -------------------------------------------------------------------------

    method to_string {
        sprintf 'Time[%s]', join ':' => @units;
    }
}
