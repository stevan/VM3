
use v5.40;
use experimental qw[ class ];

use VM::Loader::Format;

class VM::Loader {

    method load ($cpu, $context, $exe) {
        $context->pc = $exe->entry;
        $cpu->load_context( $context );
        $cpu->load_code( $exe->code );
    }
}
