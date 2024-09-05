
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

    field @stack  :reader;
    field @frames :reader;

    method pc :lvalue { $pc }

    method sp { scalar @stack  }
    method fp { scalar @frames }

    method current_stack_frame { $frames[-1] }

    method push_stack_frame ($address, $argc) {
        push @frames => VM::Kernel::CPU::Context::StackFrame->new(
            address => $address,
            argc    => $argc,
            sp      => (scalar @stack),
            return  => $pc,
        );
        $pc = $address;
    }
    method pop_stack_frame     {
        my $frame = pop @frames;
        # restore stack pointer and free the args
        splice @stack, ($frame->sp - $frame->argc);
        # and go to the return address
        $pc = $frame->return;
    }

    method push ($v) { push @stack => $v }
    method pop       { pop @stack }
    method peek      { $stack[-1] }

    method get  ($i)     { $stack[$i]         }
    method set  ($i, $v) { $stack[$i] = $v    }

    method dump {
        say sprintf ' pc     : %04d' => $pc;
        if (@frames) {
            say ' frames : [';
            say join "\n" => map "    ${_}", @frames;
            say ' ]';
        } else {
            say ' frames : []';
        }
        if (@stack) {
            say ' stack  : [';
            if (@frames) {
                my $idx = 0;
                foreach my $frame (@frames) {
                    my $arg_top = $idx + $frame->argc;
                    #warn "idx: $idx arg_top: $arg_top\n";
                    say join "\n" => map "    ${_}", @stack[ $idx .. ($arg_top - 1) ];
                    $idx = $arg_top;
                    say sprintf '    ---- call: %s' => $frame->address;
                }
                #warn "ended idx: $idx sp: $sp\n";
                if ($idx <= $#stack) {
                    say join "\n" => map "    ${_}", @stack[ $idx .. $#stack ];
                }
            } else {
                say join "\n" => map "    ${_}", @stack;
            }
            say ' ]';
        } else {
            say ' stack  : []';
        }
    }
}
