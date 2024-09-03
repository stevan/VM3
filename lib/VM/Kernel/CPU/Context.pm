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

    method push  ($v) { push @stack => $v }
    method pop        { pop @stack        }
    method peek       { $stack[-1]        }

    method get  ($i)     { $stack[$i]         }
    method set  ($i, $v) { $stack[$i] = $v    }

    method dump {
        say sprintf ' pc    : %04d' => $pc;
        say sprintf ' fp    : %04d' => $fp;
        say sprintf ' sp    : %04d' => $sp;
        if (@stack) {
            say ' stack : [';
            say join ",\n" => map "    ${_}", @stack;
            say ' ]';
        } else {
            say ' stack : []';
        }
    }
}
