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
        @units = (0) x (scalar @$breakdowns);
    }

    method set_state ( @u ) { @units = @u; $self }

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

    method normalize (@args) {
        #say "start ",join ':' => @args;
        my $remainder = 0;
        foreach my $i ( reverse 0 .. $#args ) {
            #say "checking unit[$i] = ".$args[$i];

            if ($remainder) {
                #say "... got remainder(${remainder})";
                $args[$i] += $remainder;
                #say "updated unit[$i] = ".$args[$i];
                $remainder = 0;
            }

            my $u = $args[$i];
            if ($u >= 10) {
                #say "unit[$i] is greater than 10";
                $remainder  = int($u / 10);
                #say "calculated remainder(${remainder})";
                $args[$i] = int($u % 10);
                #say "updated unit[$i] = ".$args[$i];
            }
        }
        #say "end ",join ':' => @args;
        return VM::Timers::Wheel::State->new(
            breakdowns => $breakdowns
        )->set_state(
            @args
        );
    }

    method decompose ($ms) {
        my @decomposed;

        my $remainder = $ms;
        foreach my ($i, $size) ( indexed @$breakdowns ) {
            my $unit = int($remainder / $size);
            push @decomposed => $unit;
            $remainder -= ($decomposed[-1] * $size);
        }

        return VM::Timers::Wheel::State->new(
            breakdowns => $breakdowns
        )->set_state(
            @decomposed
        );
    }

    method add_milliseconds ($ms) {
        my @new = @units;
        $new[-1] += $ms;
        return $self->normalize(@new);
    }

    method calculate_future_state ($duration) {
        $self->add_milliseconds($duration);
    }

    ## -------------------------------------------------------------------------

    method less_than    ($s) { (join ':' => @units) lt (join ':' => $s->units) }
    method greater_than ($s) { (join ':' => @units) gt (join ':' => $s->units) }
    method equal_to     ($s) { (join ':' => @units) eq (join ':' => $s->units) }

    method to_string {
        sprintf 'Time[%s]', join ':' => @units;
    }
}
