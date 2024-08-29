#!perl

use v5.40;
use experimental qw[ class ];

use VM::Clock;
use VM::Timers;

class VM {

    field $clock;
    field $timers;

    ADJUST {
        $clock  = VM::Clock->new;
        $timers = VM::Timers->new;
    }

    method run {
        $clock->start;

        while (1) {
            print "\e[2J\e[H\n";
            $timers->wheel->dump_wheel;
            $timers->wheel->advance_by(
                $clock->sleep(1)->elapsed
            );
        }
    }

}
