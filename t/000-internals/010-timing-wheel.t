#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'List::Util'   => qw[ min max sum ];

use constant SECOND       => 1000;
use constant MINUTE       => (60 * SECOND);
use constant HOUR         => (60 * MINUTE);
use constant DAY          => (24 * HOUR);
use constant WEEK         => (7  * DAY);

class Timing::Wheel {
    use overload '""' => \&to_string;

    field @sizes;
    field @rotations;

    ADJUST {
        @sizes     = ( 10, 10, 10, 60, 60 );
        @rotations = ( 0, 0, 0, 0, 0, 0 );
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


my $w = Timing::Wheel->new;


say 'hr:mi:se:ds:cs:ms';
say $w;
$w->advance( (3 * HOUR) + (20 * SECOND) + (5 * MINUTE) + 17 );
say $w;
