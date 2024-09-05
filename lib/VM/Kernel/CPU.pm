
use v5.40;
use experimental qw[ class ];

use VM::Kernel::CPU::Context;

class VM::Kernel::CPU {
    use constant DEBUG => $ENV{DEBUG} // 0;
    use overload '""' => \&to_string;

    field $microcode :param :reader;

    field $ic :reader = 0;
    field $ci :reader = undef;

    method execute ($code, $context) {
        return if $context->pc > $#{$code};
        #warn $context->pc;
        my $opcode = $code->[ $context->pc++ ];
        $ci = $opcode->instruction;
        #warn $context->pc;
        #warn $opcode;
        $microcode->[ $ci ]->microcode->( $opcode, $context );
        return ++$ic;
    }
}
