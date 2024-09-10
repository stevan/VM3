
use v5.40;
use experimental qw[ class ];

class VM::Kernel::CPU {
    use constant DEBUG => $ENV{DEBUG} // 0;
    use overload '""' => \&to_string;

    field $microcode :param :reader;

    field $ic :reader = 0;
    field $ci :reader = undef;

    method execute ($code, $process) {
        return if $process->pc > $#{$code};
        #warn $process->pc;
        my $opcode = $code->[ $process->pc++ ];
        $ci = $opcode->instruction;
        #warn $process->pc;
        #warn $opcode;
        $microcode->[ $ci ]->microcode->( $opcode, $process );
        return ++$ic;
    }
}
