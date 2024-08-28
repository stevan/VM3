#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'Time::HiRes'  => qw[ sleep ];

use const S => 0;
use const D => 1;
use const C => 2;
use const M => 3;

my @wheel = (
    [ map { [] } 0 .. 10 ], # seconds
    [ map { [] } 0 .. 10 ], # deciseconds
    [ map { [] } 0 .. 10 ], # centiseconds
    [ map { [] } 0 .. 10 ], # milliseconds
);

sub dump_wheel ($at) {
    say('-' x 25);
    say '  @ ',join ':' => @$at;
    say('-' x 25);
    foreach my $spoke ( @wheel ) {
        say '  ', join ':' => map scalar @$_, @$spoke;
    }
    say('-' x 25);
}

sub add_timer ( $at, $cb ) {
    if ($at->[S]) {
        push @{ $wheel[S]->[ $at->[S] ] } => [ $at, $cb ];
    } elsif ($at->[D]) {
        push @{ $wheel[D]->[ $at->[D] ] } => [ $at, $cb ];
    } elsif ($at->[C]) {
        push @{ $wheel[C]->[ $at->[C] ] } => [ $at, $cb ];
    } elsif ($at->[M]) {
        push @{ $wheel[M]->[ $at->[M] ] } => [ $at, $cb ];
    }
}

sub check_timers ( $at ) {
    my $moved = false;

    foreach my $i ( S, D, C, M ) {
        # if this level has a value to check ...
        if ( $at->[$i] ) {
            # get the set of timers
            my @timers = @{ $wheel[$i]->[ $at->[$i] ] };
            @{ $wheel[$i]->[ $at->[$i] ] } = ();
            foreach my $timer (@timers) {
                # and see if we need to move them
                move_timer( $timer, $i );
                $moved = true;
            }
        }
    }

    return $moved;
}

sub move_timer ($timer, $level) {
    my ($at, $cb) = @$timer;
    my $next = $level;

    if ($next > M) {
        $timer->[1]->();
        return;
    }

    while (++$next) {
        if ($next > $#{$at}) {
            say "triggering [".(join ':' => $timer->[0]->@*)."]";
            $cb->();
            last;
        } elsif ($at->[$next]) {
            say "advancing [".(join ':' => $timer->[0]->@*)."] from $level \@ ".($at->[$level])." to $next \@ ".($at->[$next]);
            push @{ $wheel[$next]->[ $at->[$next] ] } => $timer;
            last;
        }
    }
}

my sub decompose_ms ($ms) {
    my $sec = int($ms / 1000);
    $ms -= ($sec * 1000);

    my $dec = int($ms / 100);
    $ms -= ($dec * 100);

    my $cen = int($ms / 10);
    $ms -= ($cen * 10);

    return ($sec, $dec, $cen, $ms);
}

my $x = 0;

add_timer( [ 0, 0, 3, 3 ], sub { say "0.033"; $x++ } );

add_timer( [ 1, 0, 1, 0 ], sub { say "1.010"; $x++ } );

add_timer( [ 1, 0, 2, 2 ], sub { say "1.022"; $x++ } );
add_timer( [ 1, 0, 2, 2 ], sub { say "1.022"; $x++ } );

add_timer( [ 1, 0, 3, 1 ], sub { say "1.031"; $x++ } );
add_timer( [ 1, 0, 3, 1 ], sub { say "1.031"; $x++ } );

add_timer( [ 1, 0, 3, 7 ], sub { say "1.037"; $x++ } );

add_timer( [ 1, 1, 3, 1 ], sub { say "1.131"; $x++ } );

add_timer( [ 2, 0, 3, 6 ], sub { say "2.036"; $x++ } );

dump_wheel( [ 0, 0, 0, 0 ] );

foreach my $i (0 .. 2050) {
    my $time = [ decompose_ms($i) ];
    check_timers( $time ) && dump_wheel( $time );
}

say "$x callbacks fired (9)";

