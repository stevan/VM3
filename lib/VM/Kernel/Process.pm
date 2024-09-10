
use v5.40;
use experimental qw[ class ];

use importer 'Scalar::Util' => qw[ dualvar ];

use VM::Kernel::Channel;
use VM::Kernel::Device;

use VM::Kernel::Process::StackFrame;

class VM::Kernel::Process {
    use constant READY   => dualvar(1,   'READY'); # ready to do work ...
    use constant YIELDED => dualvar(2, 'YIELDED'); # it has yielded control to the system
    use constant STOPPED => dualvar(3, 'STOPPED'); # stopped entirely

    field $pid    :param :reader;
    field $entry  :param :reader = 0;
    field $parent :param :reader = undef;

    field $status  :reader;

    field $pc :param = 0;

    field @stack  :reader;
    field @frames :reader;

    field $chan_in  :reader;
    field $chan_out :reader;

    field $sid :reader;
    field $sod :reader;

    ADJUST {
        $pc     = $entry;
        $status = READY;

        # message/signal channels
        $chan_in  = VM::Kernel::Channel->new;
        $chan_out = VM::Kernel::Channel->new;

        # i/o devices
        $sid = VM::Kernel::Device->new;
        $sod = VM::Kernel::Device->new;
    }

    method ready { $status = READY   }
    method yield { $status = YIELDED }
    method stop  { $status = STOPPED }

    method is_ready   { $status == READY   }
    method is_yielded { $status == YIELDED }
    method is_stopped { $status == STOPPED }

    method pc :lvalue { $pc }

    method sp { $#stack  }
    method fp { $#frames }

    method current_stack_frame { $frames[-1] }

    method push_stack_frame ($address, $argc) {
        my $frame = VM::Kernel::Process::StackFrame->new(
            address => $address,
            argc    => $argc,
            sp      => (scalar @stack),
            return  => $pc,
        );
        push @frames => $frame;
        $pc = $frame->address;
        return $frame;
    }

    method pop_stack_frame {
        my $frame = pop @frames;
        # restore stack pointer and free the args
        splice @stack, ($frame->sp - $frame->argc);
        # and go to the return address
        $pc = $frame->return;
        # and return the frame in case ...
        return $frame;
    }

    method push ($v) { push @stack => $v }
    method pop       { pop @stack }
    method peek      { $stack[-1] }

    method get  ($i)     { $stack[$i]      }
    method set  ($i, $v) { $stack[$i] = $v }
}
