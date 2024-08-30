#!perl

use v5.40;
use experimental qw[ class builtin ];

use constant DEBUG => $ENV{DEBUG} // 0;

use Test::More;

use VM;

my $x = 0;

my $vm = VM->new;
$vm->wheel->dump_wheel_info if DEBUG;

$vm->add_timer( 3, sub { DEBUG ? say "0.003" : pass('... timer fired at 0.003'); $x++ });
$vm->add_timer(10, sub { DEBUG ? say "0.010" : pass('... timer fired at 0.010'); $x++ });
$vm->add_timer(12, sub { DEBUG ? say "0.012" : pass('... timer fired at 0.012'); $x++ });
$vm->add_timer(12, sub { DEBUG ? say "0.012" : pass('... timer fired at 0.012'); $x++ });

if (DEBUG) {
    $vm->wheel->dump_wheel;
    my $z = <>;

    #for (0 .. 20) {
    #    print "\e[2J\e[H\n";
    #    $vm->wheel->advance_by(1);
    #    $vm->wheel->dump_wheel;
    #    my $z = <>;
    #}
    #$vm->add_timer(10, sub { DEBUG ? say "0.010" : pass('... timer fired at 0.010'); $x++ });
    #$vm->add_timer(12, sub { DEBUG ? say "0.012" : pass('... timer fired at 0.012'); $x++ });
    #$vm->add_timer(12, sub { DEBUG ? say "0.012" : pass('... timer fired at 0.012'); $x++ });

    while (1) {
        print "\e[2J\e[H\n";
        $vm->wheel->advance_by(1);
        $vm->wheel->dump_wheel;
        my $z = <>;
    }

} else {
    $vm->wheel->advance_by(3);
    is($x, 1, '... the right amount of events fired');
    $vm->wheel->advance_by(7);
    is($x, 2, '... the right amount of events fired');
    $vm->wheel->advance_by(2);
    is($x, 4, '... the right amount of events fired');
}

done_testing;


