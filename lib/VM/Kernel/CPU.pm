#!perl

use v5.40;
use experimental qw[ class ];

use VM::Kernel::CPU::Context;

class VM::Kernel::CPU {
    use constant DEBUG => $ENV{DEBUG} // 0;
    use overload '""' => \&to_string;

    field $code      :reader;
    field $microcode :reader;
    field $context   :reader;

    field $ic :reader = 0;
    field $ci :reader = undef;

    method reset {
        $ic = 0;
        $ci = undef;
        $self;
    }

    method create_new_context { VM::Kernel::CPU::Context->new }

    method load_microcode ($mc)  { $microcode = $mc;  $self }
    method load_code      ($c)   { $code      = $c;   $self }
    method load_context   ($ctx) { $context   = $ctx; $self }

    method execute {
        return if $context->pc > $#{$code};
        #warn $context->pc;
        my $opcode = $code->[ $context->pc++ ];
        $ci = $opcode->instruction;
        #warn $context->pc;
        #warn $opcode;
        $microcode->[ $opcode->instruction ]->microcode->( $opcode, $context );
        return ++$ic;
    }
}
