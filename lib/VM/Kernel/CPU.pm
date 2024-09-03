#!perl

use v5.40;
use experimental qw[ class ];

class VM::Kernel::CPU {
    use constant DEBUG => $ENV{DEBUG} // 0;
    use overload '""' => \&to_string;

    field $code;
    field $context;

    field $ic :reader = 0;
    field $ci :reader = undef;

    method load_code ($c) {
        $code = $c;
        $ic   = 0;
        $ci   = undef;
        $self;
    }

    method load_context ($ctx) {
        $context = $ctx;
    }
}
