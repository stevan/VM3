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


my $c = VM::Clock->new;

my $e;

$e = $c->update->elapsed;
is($e, 0, "... elapsed is 0 ($e)");

foreach (0 .. 100) {
    sleep(0.001);
    $e = $c->update->elapsed;
    ok(within_threshold($e, 1), "... 0.001 elapsed is within threshold ($e)");
    sleep(0.01);
    $e = $c->update->elapsed;
    ok(within_threshold($e, 10), "... 0.01 elapsed is within threshold ($e)");
}

foreach (0 .. 10) {
    my $rand = rand();
    sleep( $rand );
    $e = $c->update->elapsed;
    ok(within_threshold($e, int($rand * 1000)), "... ".(sprintf '%0.3f' => $rand)." elapsed is within threshold ($e)");

    sleep(0.2);
    $e = $c->update->elapsed;
    ok(within_threshold($e, 200), "... 0.2 elapsed is within threshold ($e)");
}

sleep(2.2);
$e = $c->update->elapsed;
ok(within_threshold($e, 2200), "... 2.2 elapsed is within threshold ($e)");

foreach (0 .. 10_000) {
    $e = $c->update->elapsed;
    ok(within_threshold($e, 0), "... 0 elapsed is within threshold ($e)");
}


done_testing;
