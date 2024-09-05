
use v5.40;
use experimental qw[ class ];

use importer 'Scalar::Util' => qw[ dualvar ];

use VM::Kernel::CPU::Context;
use VM::Kernel::Channel;

class VM::Kernel::Process {
    use constant READY   => dualvar(1,   'READY'); # ready to do work ...
    use constant YIELDED => dualvar(2, 'YIELDED'); # it has yielded control to the system
    use constant STOPPED => dualvar(3, 'STOPPED'); # stopped entirely

    field $entry  :param;
    field $pid    :param :reader;
    field $parent :param :reader = undef;

    field $status  :reader;
    field $context :reader;

    field $chan_in  :reader;
    field $chan_out :reader;

    ADJUST {
        $context = VM::Kernel::CPU::Context->new( pc => $entry );
        $status  = READY;

        $chan_in  = VM::Kernel::Channel->new;
        $chan_out = VM::Kernel::Channel->new;
    }

    method ready { $status = READY   }
    method yield { $status = YIELDED }
    method stop  { $status = STOPPED }

    method is_ready   { $status == READY   }
    method is_yielded { $status == YIELDED }
    method is_stopped { $status == STOPPED }
}
