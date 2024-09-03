#!perl

use v5.40;
use experimental qw[ class ];

class VM::Kernel::CPU::Context {
    field $pc :param = 0;

    field $fp = 0;
    field $sp = -1;
    field @stack :reader;

    method pc :lvalue { $pc }
    method fp :lvalue { $fp }
    method sp :lvalue { $sp }

    method push ($v)     { $stack[++$sp] = $v }
    method pop           { $stack[$sp--]      }
    method peek          { $stack[$sp]        }

    method get  ($i)     { $stack[$i]         }
    method set  ($i, $v) { $stack[$i] = $v    }

    method dump {
        +{
            pc    => $pc,
            fp    => $fp,
            sp    => $sp,
            stack => \@stack
        }
    }
}
