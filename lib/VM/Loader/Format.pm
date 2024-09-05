
use v5.40;
use experimental qw[ class ];

class VM::Loader::Format {
    field $entry :param :reader = 0;
    field $code  :param :reader;
}
