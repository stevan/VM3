#!perl

use v5.40;
use experimental qw[ class ];

use VM::Clock;
use VM::Timers;

class VM {

    field $system_clock;
    field $timers;

    ADJUST {
        $system_clock = VM::Clock->new;
        $timers       = VM::Timers->new;

        $timers->add_timer( 1200, sub {
            warn "1. waited 1200 : ".(1200)." -> ".$system_clock->update;

            $timers->add_timer( 10, sub {
                warn "2. waited 1200+10 : ".(1200+10)." -> ".$system_clock->update;

                $timers->add_timer( 100, sub {
                    warn "6. waited 1200+10+100 : ".(1200+10+100)." -> ".$system_clock->update;
                });

                $timers->add_timer( 30, sub {
                    warn "5a. waited 1200+10+30 : ".(1200+10+30)." -> ".$system_clock->update;

                    $timers->add_timer( 100, sub {
                        warn "7. waited 1200+10+30+100 : ".(1200+10+30+100)." -> ".$system_clock->update;
                    });

                    $timers->add_timer( 350, sub {
                        warn "9. waited 1200+10+30+350 : ".(1200+10+30+350)." -> ".$system_clock->update;
                    });

                });

                $timers->add_timer( 25, sub {
                    warn "4. waited 1200+10+25 : ".(1200+10+25)." -> ".$system_clock->update;
                });
            });

            $timers->add_timer( 20, sub {
                warn "3. waited 1200+20 : ".(1200+20)." -> ".$system_clock->update;

                $timers->add_timer( 20, sub {
                    warn "5b. waited 1200+20+20 : ".(1200+20+20)." -> ".$system_clock->update;
                });

                $timers->add_timer( 200, sub {
                    warn "8. waited 1200+20+200 : ".(1200+20+200)." -> ".$system_clock->update;

                });
            });

        });
    }

    method run {
        $system_clock->start;

        my $tick = 0;
        while (++$tick) {
            print "\e[2J\e[H";
            $timers->wheel->dump_wheel;
            if (my $timer = $timers->wheel->find_next_timer) {
                Time::HiRes::sleep( 0.001 );
                $timers->update;
            } else {
                say "... exiting";
                last;
            }
        }
    }

}
