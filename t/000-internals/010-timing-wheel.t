#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'List::Util'   => qw[ min max sum ];
use importer 'Time::HiRes'  => qw[ sleep ];

use VM::Clock;

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

my $c = VM::Clock->new;
my $w = Timing::Wheel->new;

say 'se:ds:cs:ms';
$w->advance( $c->update->elapsed );
say $w;

sleep(0.001);
$w->advance( $c->update->elapsed );
say $w;

sleep(0.033);
$w->advance( $c->update->elapsed );
say $w;

sleep(0.15);
$w->advance( $c->update->elapsed );
say $w;

sleep(0.2);
$w->advance( $c->update->elapsed );
say $w;

sleep(2.2);
$w->advance( $c->update->elapsed );
say $w;







