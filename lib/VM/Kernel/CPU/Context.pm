
use v5.40;
use experimental qw[ class ];

class VM::Kernel::CPU::Context::StackFrame {
    use overload '""' => \&to_string;
    field $address :param :reader;
    field $argc    :param :reader;
    field $sp      :param :reader;
    field $return  :param :reader;
    method to_string {
        sprintf 'Call{addr: %04d, argc: %d, sp: %04d, return: %04d }',
                 $address, $argc, $sp, $return;
    }
}

class VM::Kernel::CPU::Context {
    field $pc :param = 0;

    field $fp = -1;
    field $sp = -1;

    field @stack  :reader;
    field @frames :reader;

    method pc :lvalue { $pc }
    method sp :lvalue { $sp }
    method fp :lvalue { $fp }

    method push_stack_frame ($address, $argc) {
        $frames[++$fp] = VM::Kernel::CPU::Context::StackFrame->new(
            address => $address,
            argc    => $argc,
            sp      => $sp,
            return  => $pc,
        );
    }
    method pop_stack_frame     { $frames[$fp--] }
    method current_stack_frame { $frames[$fp]   }

    method push ($v) { $stack[++$sp] = $v }
    method pop       { $stack[$sp--]      }
    method peek      { $stack[$sp]        }

    method get  ($i)     { $stack[$i]         }
    method set  ($i, $v) { $stack[$i] = $v    }

    method dump {
        say sprintf ' pc     : %04d' => $pc;
        say sprintf ' fp     : %04d' => $fp;
        say sprintf ' sp     : %04d' => $sp;
        if ($fp >= 0) {
            say ' frames : [';
            say join "\n" => map "    ${_}", @frames[ 0 .. $fp ];
            say ' ]';
        } else {
            say ' frames : []';
        }
        if ($sp >= 0) {
            say ' stack  : [';
            if ($fp >= 0) {
                my $idx = 0;
                foreach my $frame (@frames[ 0 .. $fp ]) {
                    my $arg_top = $idx + $frame->argc;
                    #warn "idx: $idx arg_top: $arg_top\n";
                    say join "\n" => map "    ${_}", @stack[ $idx .. ($arg_top - 1) ];
                    $idx = $arg_top;
                    say sprintf '    ---- call: %s' => $frame->address;
                }
                #warn "ended idx: $idx sp: $sp\n";
                if ($idx <= $sp) {
                    say join "\n" => map "    ${_}", @stack[ $idx .. $sp ];
                }
            } else {
                say join "\n" => map "    ${_}", @stack[ 0 .. $sp ];
            }
            say ' ]';
        } else {
            say ' stack  : []';
        }
    }
}
