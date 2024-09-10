
use v5.40;
use experimental qw[ class ];

class VM::Kernel::Process::StackFrame {
    use overload '""' => \&to_string;
    field $address :param :reader;
    field $argc    :param :reader;
    field $sp      :param :reader;
    field $return  :param :reader;

    field @locals :reader;

    method get_local ($idx)     { $locals[$idx]      }
    method set_local ($idx, $v) { $locals[$idx] = $v }

    method to_string {
        sprintf 'Call{addr: %04d, argc: %d, sp: %04d, return: %04d }',
                 $address, $argc, $sp, $return;
    }
}
