#!perl

use v5.40;
use experimental qw[ class ];

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

    method load_microcode ($mc)  { $microcode = $mc;  $self }
    method load_code      ($c)   { $code      = $c;   $self }
    method load_context   ($ctx) { $context   = $ctx; $self }

    method next_op { $code->[ $context->pc++ ] }

    method execute {
        $ci = $context->pc;
        return if $ci < scalar @$code;
        my $opcode = $self->next_op;
        $microcode[ $opcode ]->( $self );
        return ++$ic;
    }
}
