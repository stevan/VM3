#!perl

use v5.40;
use experimental qw[ class builtin ];

use constant DEBUG => $ENV{DEBUG} // 0;

use Test::More;

use VM::Timers;

my $x = 0;

my $timers = VM::Timers->new;
$timers->wheel->dump_wheel_info if DEBUG;

$timers->add_timer( 3, sub { DEBUG ? say "0.003" : pass('... timer fired at 0.003'); $x++ });
$timers->add_timer(10, sub { DEBUG ? say "0.010" : pass('... timer fired at 0.010'); $x++ });
$timers->add_timer(12, sub { DEBUG ? say "0.012" : pass('... timer fired at 0.012'); $x++ });
$timers->add_timer(12, sub { DEBUG ? say "0.012" : pass('... timer fired at 0.012'); $x++ });

if (DEBUG) {
    $timers->wheel->dump_wheel;
    my $z = <>;

    while (1) {
        print "\e[2J\e[H\n";
        $timers->wheel->advance_by(1);
        $timers->wheel->dump_wheel;
        my $z = <>;
    }
} else {
    $timers->wheel->advance_by(3);
    is($x, 1, '... the right amount of events fired');
    $timers->wheel->advance_by(7);
    is($x, 2, '... the right amount of events fired');
    $timers->wheel->advance_by(2);
    is($x, 4, '... the right amount of events fired');
}

done_testing;


