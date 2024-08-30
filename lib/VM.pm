#!perl

use v5.40;
use experimental qw[ class ];

use VM::Clock;
use VM::Timers;

class VM {

    field $timers;

    ADJUST {
        $timers = VM::Timers->new;

        $timers->add_timer( 1200, sub {
            warn "1200 : ".$timers->wheel->to_string;
            $timers->add_timer( 10, sub {
                warn "1200+10 : ".$timers->wheel->to_string;
                $timers->add_timer( 100, sub {
                    warn "1200+10+100 : ".$timers->wheel->to_string;
                } );

                $timers->add_timer( 30 + $_, sub {
                    warn "1200+10+30 : ".$timers->wheel->to_string;

                    $timers->add_timer( 100, sub {
                        warn "1200+10+30+100 : ".$timers->wheel->to_string;
                    } );

                    $timers->add_timer( 350, sub {
                        warn "1200+10+30+350 : ".$timers->wheel->to_string;
                    } );

                } ) foreach 5 .. 10;

                $timers->add_timer( 25, sub {
                    warn "1200+10+25 : ".$timers->wheel->to_string;
                } );
            } );
            $timers->add_timer( 20, sub {
                warn "1200+20 : ".$timers->wheel->to_string;

                $timers->add_timer( 20, sub {
                    warn "1200+20+20 : ".$timers->wheel->to_string;
                } );

                $timers->add_timer( 200, sub {
                    warn "1200+20+200 : ".$timers->wheel->to_string;

                    #$timers->add_timer( 10000, sub {
                    #    warn "1200+20+2000+10000 : ".$timers->wheel->to_string;
                    #} );

                } );
            } );

        });
    }

    method run {
        my $tick = 0;
        while (++$tick) {
            print "\e[2J\e[H";
            $timers->wheel->dump_wheel;
            if (my $timer = $timers->wheel->find_next_timer) {
                Time::HiRes::sleep( ($timer->duration - 10) * 0.001 );
                $timers->update;
            } else {
                say "... exiting";
                last;
            }
        }
    }

}
