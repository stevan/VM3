
use v5.40;
use experimental qw[ class ];

# these generate the microcode routines

class VM::Instructions::Microcode {
    field $instruction :param :reader;
    field $microcode   :param :reader;
}
