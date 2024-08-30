#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Time::HiRes' => qw[ sleep ];
use importer 'List::Util'  => qw[ max ];

use Test::More;

use ok 'VM::Clock';

sub within_threshold ($got, $start) {
    $got >= $start && $got <= ($start + max(10, ($start * 0.25)))
}

subtest '... testing clock scaling ()' => sub {
    my $c = VM::Clock->new;
    isa_ok($c, 'VM::Clock');
    $c->start;
    sleep(0.1);
    $c->update;
    ok(within_threshold($c->elapsed, 100), "... got the expected elapsed (100) ($c)");
};

subtest '... testing clock scaling (0.5)' => sub {
    my $c = VM::Clock->new( scale_by => 0.5 );
    isa_ok($c, 'VM::Clock');
    $c->start;
    sleep(0.1);
    $c->update;
    ok(within_threshold($c->elapsed, 50), "... got the expected elapsed (50) ($c)");
};

subtest '... testing clock scaling (0.3)' => sub {
    my $c = VM::Clock->new( scale_by => 0.3 );
    isa_ok($c, 'VM::Clock');
    $c->start;
    sleep(0.1);
    $c->update;
    ok(within_threshold($c->elapsed, 30), "... got the expected elapsed (30) ($c)");
};

subtest '... testing clock scaling (0.1)' => sub {
    my $c = VM::Clock->new( scale_by => 0.1 );
    isa_ok($c, 'VM::Clock');
    $c->start;
    sleep(0.1);
    $c->update;
    ok(within_threshold($c->elapsed, 10), "... got the expected elapsed (10) ($c)");
};

subtest '... testing clock scaling (0.01)' => sub {
    my $c = VM::Clock->new( scale_by => 0.01 );
    isa_ok($c, 'VM::Clock');
    $c->start;
    sleep(0.1);
    $c->update;
    ok(within_threshold($c->elapsed, 1), "... got the expected elapsed (1) ($c)");
};

done_testing;
