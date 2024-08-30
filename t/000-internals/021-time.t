#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use importer 'Data::Dumper' => qw[ Dumper ];

class Timer {
    use overload '""' => \&to_string;
    field $timeout :param :reader;
    field $expiry  :param :reader;
    field $event   :param :reader;
    method to_string { sprintf 'Timer[to:%d, xp:%d]' => $timeout, $expiry }
}

class Wheel {
    use constant DEBUG => $ENV{DEBUG} // 0;
    sub LOG (@msg) { warn "\e[0;32m INFO \e[0;34m║ \e[0;33m",@msg,"\e[0m\n" }

    my @names = qw[ sec dec cen mil ];
    my $depth = scalar @names;

    my @high2low = 0 .. ($depth - 1);
    my @low2high = reverse @high2low;
    my @powers10 = reverse map { 10 ** $_ } 0 .. $depth;

    if (DEBUG) {
        LOG("WHEEL CONFIG (");
        LOG("     depth : ${depth}");
        LOG("  powers10 : ",join ', ' => @powers10);
        LOG("  high2low : ",join ', ' => @high2low);
        LOG("  low2high : ",join ', ' => @low2high);
        LOG(")");
    }

    field $state;
    field @wheel;

    ADJUST {
        @wheel = map +[], 0 .. ($depth * 10);
        $state = 0;
    }

    method advance_by ($ms) {
        $state += $ms;
    }

    method add_timer ($timeout, $event) {
        $self->insert_timer(
            Timer->new(
                timeout => $timeout,
                expiry  => $timeout + $state,
                event   => $event,
            )
        );
    }

    method insert_timer ($timer) {
        LOG("... inserting timer $timer") if DEBUG;

        my $t = $timer->expiry;

        my $idx;
        foreach my $i ( @high2low ) {
            LOG(sprintf "t(%d) < powers10[%d + 1]", $t, $i) if DEBUG >= 10;
            LOG(sprintf "t(%d) < %d", $t, $powers10[ $i + 1 ]) if DEBUG >= 10;
            next if $t < $powers10[ $i + 1 ];
            LOG("Calculate Index at i: $i for t: $t") if DEBUG >= 5;
            $idx = $self->calculate_index($i, $t);
            push $wheel[$idx]->@* => $timer;
            last;
        }

        LOG("inserted timer $timer at $idx") if DEBUG;

        return $timer;
    }

    # ╭──╮
    # │  │
    # ├──┤
    # ╰──╯

    method calculate_index ($col, $t) {
        LOG("__ CALCULATING INDEX FOR $t at $col") if DEBUG >= 5;
        my ($e1, $e2) = @powers10[ $col, $col + 1 ];
        LOG(sprintf "t: %d (%s) => (e: %5d e-1: %5d)",
                    $t, $names[$col], $e1, $e2) if DEBUG >= 5;
        LOG(sprintf "((%d %% %d) - (%d %% %d)) / %d",
                    $t, $e1, $t, $e2, $e2) if DEBUG >= 10;
        LOG(sprintf "((%d) - (%d)) / %d",
                    $t % $e1, $t % $e2, $e2) if DEBUG >= 10;
        LOG(sprintf "%d / %d",
                    ($t % $e1) - ($t % $e2), $e2) if DEBUG >= 10;
        LOG(sprintf "%d",
                    (($t % $e1) - ($t % $e2)) / $e2) if DEBUG >= 10;
        my $row = (($t % $e1) - ( $t % $e2 )) / $e2;
        my $idx = ($col * 10) + $row;
        LOG("__ GOT INDEX: $idx") if DEBUG >= 5;
        return $idx;
    }

    method dump_wheel {
        state $hor = '─' x 25;
        state $top = '╭─'.$hor.'─╮';
        state $mid = '├─'.$hor.'─┤';
        state $bot = '╰─'.$hor.'─╯';

        state $cell_fmt = "\e[0;9%dm%d\e[0m";
        state $time_fmt = "\e[0;9%dm\e[7m%d\e[0m";
        state $line_fmt = "│ %-25s │";

        my %indicies = map {
            $self->calculate_index($_, $state), 1
        } @high2low;

        say $top;
        say sprintf $line_fmt, $state;
        say $mid;
        say sprintf $line_fmt, '      '.join '.' => 0 .. 9;
        foreach my $i ( @low2high ) {
            my $start = $i * 10;
            my $end   = $start + 9;

            my @line;
            foreach my $j ( $start .. $end ) {
                my $bucket = $wheel[$j];
                my $amount = scalar @$bucket;
                push @line => sprintf(
                    (exists $indicies{$j} ? $time_fmt : $cell_fmt),
                    ($amount) x 2
                );
            }
            say sprintf $line_fmt, join ' - ', $names[$i], (join ':' => @line);
        }
        say $bot;
    }
}

my $w = Wheel->new;

$w->dump_wheel;

$w->advance_by(321);
$w->dump_wheel;

$w->add_timer( 1300, sub { say 421 } );
$w->dump_wheel;

$w->advance_by(800);
$w->dump_wheel;

done_testing;
