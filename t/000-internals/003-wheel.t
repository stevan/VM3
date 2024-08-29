#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'Time::HiRes'  => qw[ sleep ];

use VM::Timers::Wheel;
use VM::Timers::Duration;

my $x = 0;

my $w = VM::Timers::Wheel->new( depth => 5 );
$w->dump_wheel_info;

$w->add_timer(
    VM::Timers::Duration->new->in_milliseconds(3),
    sub { say "0.003"; $x++ }
);

$w->add_timer(
    VM::Timers::Duration->new->in_milliseconds(10),
    sub { say "0.010"; $x++ }
);

$w->add_timer(
    VM::Timers::Duration->new->in_milliseconds(12),
    sub { say "0.012"; $x++ }
);

$w->add_timer(
    VM::Timers::Duration->new->in_milliseconds(12),
    sub { say "0.012"; $x++ }
);

$w->dump_wheel;
my $z = <>;

while (1) {
    print "\e[2J\e[H\n";
    $w->advance_by(2);
    $w->dump_wheel;
    my $z = <>;
}

$w->dump_wheel;

warn '=======================================',"\n";

$w->advance_by(9);
$w->dump_wheel;
$w->advance_by(1);
$w->dump_wheel;
$w->advance_by(36);
$w->dump_wheel;

__END__

$w->add_timer(
    VM::Timers::Duration->new->in_milliseconds(33),
    sub { say "0.033"; $x++ }
);

$w->advance_by(21);
$w->dump_wheel;
$w->advance_by(1);
$w->dump_wheel;
$w->advance_by(1);
$w->dump_wheel;

__END__



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
    #                    10s,  sec, 10th, 100th, ms
    my @breakdown = ( 1000,  100,    10,  1 );
    my @values;

    my $remainder = $ms;
    foreach my $size ( @breakdown ) {
        push @values => int($remainder / $size);
        $remainder -= ($values[-1] * $size);
    }

    return @values;
}

#die Dumper [ decompose_ms( 999999 ) ];

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

