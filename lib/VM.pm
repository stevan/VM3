#!perl

use v5.40;
use experimental qw[ class ];

use VM::Clock;
use VM::Timers::Wheel;
use VM::Timers::Timer;

class VM {
    # FIXME: this should be configurable
    use constant WHEEL_DEPTH => 5;

    field $clock :reader;
    field $wheel :reader;


    ADJUST {
        $clock = VM::Clock->new;
        $wheel = VM::Timers::Wheel->new( depth => WHEEL_DEPTH );
    }

    method add_timer ($ms, $event) {
        my $timer = VM::Timers::Timer->new(
            duration => $ms,
            event    => $event
        );

        $wheel->add_timer( $timer );

        return $timer;
    }

    method run {
        $clock->start;

        $self->test;

        $wheel->dump_wheel;

        my $tick = 0;
        while (++$tick) {
            print "\e[2J\e[H";
            say '=' x 120;
            #$wheel->dump_wheel;
            $wheel->advance_by( $clock->update->elapsed );
            $wheel->dump_wheel;
            warn "/// ",$clock," : ",$wheel,"\n";
            if (my $timeout = $wheel->calculate_timeout) {
                say "waiting for $timeout ...";
                warn "TIMEOUT : ${timeout}ms\n";
                Time::HiRes::sleep( ($timeout * 0.001) );
            } else {
                say "... exiting";
                last;
            }
            say '=' x 120;
        }
    }

    method test {
        warn "\e[2J\e[H\n";

        $self->add_timer( 1200, sub ($t) {
            warn "1. waited 1200 : ".(1200)." -> ".$clock." timer(0x".(refaddr $t).")";

            $self->add_timer( 10, sub ($t) {
                warn "2. waited 1200+10 : ".(1200+10)." -> ".$clock." timer(0x".(refaddr $t).")";

                $self->add_timer( 100, sub ($t) {
                    warn "6. waited 1200+10+100 : ".(1200+10+100)." -> ".$clock." timer(0x".(refaddr $t).")";
                });

                $self->add_timer( 30, sub ($t) {
                    warn "5a. waited 1200+10+30 : ".(1200+10+30)." -> ".$clock." timer(0x".(refaddr $t).")";

                    $self->add_timer( 100, sub ($t) {
                        warn "7. waited 1200+10+30+100 : ".(1200+10+30+100)." -> ".$clock." timer(0x".(refaddr $t).")";
                    });

                    $self->add_timer( 350, sub ($t) {
                        warn "9. waited 1200+10+30+350 : ".(1200+10+30+350)." -> ".$clock." timer(0x".(refaddr $t).")";
                    });

                });

                $self->add_timer( 25, sub ($t) {
                    warn "4. waited 1200+10+25 : ".(1200+10+25)." -> ".$clock." timer(0x".(refaddr $t).")";
                });
            });

            $self->add_timer( 20, sub ($t) {
                warn "3. waited 1200+20 : ".(1200+20)." -> ".$clock." timer(0x".(refaddr $t).")";

                $self->add_timer( 20, sub ($t) {
                    warn "5b. waited 1200+20+20 : ".(1200+20+20)." -> ".$clock." timer(0x".(refaddr $t).")";
                });

                $self->add_timer( 200, sub ($t) {
                    warn "8. waited 1200+20+200 : ".(1200+20+200)." -> ".$clock." timer(0x".(refaddr $t).")";

                });
            });

        });
    }

}
