#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Scalar::Util' => qw[ dualvar ];

class VM::Kernel::Process::Status {
    use constant READY   => dualvar(1, 'READY');   # ready to do work ...
    use constant YIELDED => dualvar(2, 'YIELDED'); # it has yielded control to the system
    use constant STOPPED => dualvar(3, 'STOPPED'); # stopped entirely
}

class VM::Kernel::Process::Identity {
    field $pid    :param :reader;
    field $parent :param :reader;
    field $status :param :reader;
}

class VM::Kernel::Process::State {
    field $pc :reader;

    field $fp    :reader;
    field $sp    :reader = -1;
    field @stack :reader;

    field $chan_in  :reader;
    field $chan_out :reader;

    field $heap :reader; # pointer to Devices.memory
}

class VM::Kernel::Process::Devices {
    field $sid :reader;
    field $sod :reader;

    field $memory;
}

class VM::Kernel::Process {

    field $ident;
    field $state;
    field $devices;


}
