
use v5.40;
use experimental qw[ class ];

use VM::Kernel::Clock;
use VM::Kernel::Timer::Wheel;

use VM::Kernel::Timer;

class VM::Kernel {

    field $clock :reader; # clock
    field $wheel :reader; # timer wheel

    field $cpu   :reader; # the bootstrap CPU
    field @procs :reader; # set of active processes
    field @bus   :reader; # msg/signal bus
    field @irq   :reader; # interrupt queue

    field @waiting   :reader; # queue for waiting processes
    field @despawned :reader; # queue for despawned processes

    # --------------------------------------------------------------------------
    # Loading code
    # --------------------------------------------------------------------------

    method load ($entry, $code) {
        $clock = VM::Kernel::Clock->new;        # start the clock
        $wheel = VM::Kernel::Timer::Wheel->new; # start the wheel
        $cpu   = VM::Kernel::CPU->new;          # load the CPU

        # clear all internal values
        @procs     = ();
        @bus       = ();
        @irq       = ();
        @waiting   = ();
        @despawned = ();

        # load the code into the CPU
        $cpu->load_code( $code );

        # create the root process with
        # the .main entry point
        $self->spawn_new_process( $entry );

        $self;
    }

    # --------------------------------------------------------------------------
    # Runloop
    # --------------------------------------------------------------------------

    method run {

        # while we have active processes
        while (@procs) {
            # update clock
            # update timer wheel

            while (@irq) {
                # process interrupts into signals
            }

            while (@bus) {
                # deliver messages/signals
            }

            my @ready; # construct queue of processes to run

            foreach my $process (@ready) {
                # run each process for it's alloted time slice
            }

            foreach my $process (@ready) {
                # collect any output and send it to the bus
                # NOTE:
                # this should happen after the above loop
                # because we want them to be delivered in
                # the next tick and now in this one.
            }

            @despawned;
            # remove all the stopped processes from the procs list

            @waiting;
            # check for waiting processes and respond accordingly
        }
    }

    # --------------------------------------------------------------------------
    # Timers
    # --------------------------------------------------------------------------

    method add_timer($timeout, $event) {
        my $timer = VM::Kernel::Timer->new(
            expiry => $clock->calculate_expiry_time($timeout),
            event  => $event,
        );
        $wheel->add_timer( $timer );
        return $timer;
    }

    # --------------------------------------------------------------------------
    # Processes
    # --------------------------------------------------------------------------

    method spawn_new_process ($entry, $parent=undef) {
        my $p = VM::Kernel::Process->new(
            # TODO ...
        );
        push @procs => $p;
        return $p;
    }

    method despawn_process ($proc) {
        @procs = grep { $_->pid != $proc->pid } @procs;
        push @despawned => $proc;
    }

    method wait_for_children ($proc) {
        push @waiting => $proc;
    }

    # --------------------------------------------------------------------------
}

