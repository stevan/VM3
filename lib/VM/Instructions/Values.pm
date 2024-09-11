
use v5.40;
use experimental qw[ class ];

use importer 'List::Util' => qw[ max min ];

package VM::Instructions::Values {

    # values provide a bridge between
    # the internal values in the VM
    # and the opcodes

    class VM::Instructions::Values::Value {
        use overload '""' => 'to_string';
        method type      { (split '::' => __CLASS__)[-1] }
        method value;
        method to_string { sprintf '%.1s(%s)' => lc $self->type, $self->value }
        method copy { __CLASS__->new }
    }

    # an undefined value
    class VM::Instructions::Values::NULL :isa(VM::Instructions::Values::Value) {
        method value { undef }
        method to_string { '#n' }
    }

    # used for returning nothing from a function
    class VM::Instructions::Values::VOID :isa(VM::Instructions::Values::Value) {
        method value { undef }
        method to_string { '()' }
    }

    # two instances of this, TRUE and FALSE
    class VM::Instructions::Values::BOOL :isa(VM::Instructions::Values::Value) {
        field $bool :param :reader(value);
        method to_string { $self->value ? '#t' : '#f' }
        method copy { __CLASS__->new( bool => $bool ) }
    }

    # a single character, this is still a numeric type
    class VM::Instructions::Values::CHAR :isa(VM::Instructions::Values::Value) {
        field $char :param :reader(value);
        method copy { __CLASS__->new( char => $char ) }
    }

    # basic integer, with support for 8, 16 and 32 bits and signed-ness
    class VM::Instructions::Values::INT :isa(VM::Instructions::Values::Value) {
        field $int    :param :reader(value);
        field $size   :param :reader(size) = 32;
        field $signed :param :reader       = false;

        field $min :reader(min_value);
        field $max :reader(max_value);

        ADJUST {
            if ($signed) {
                $max = (2 ** $size) / 2;
                $min = -($max - 1);
            } else {
                $max = 2 ** $size;
                $min = 0;
            }
            $int = max($min, min($int, $max));
        }

        method to_string { sprintf '%s%d(%s)' => ($signed ? 'i':'u'), $size, $self->value }
        method copy { __CLASS__->new( int => $int ) }
    }

    # basic float, the only size is 32, so we ignore it (for now)
    class VM::Instructions::Values::FLOAT :isa(VM::Instructions::Values::Value) {
        field $float :param :reader(value);
        method copy { __CLASS__->new( float => $float ) }
    }

    # Some kind of address that points to something else
    class VM::Instructions::Values::ADDRESS :isa(VM::Instructions::Values::Value) {
        field $address :param :reader(value);
        method copy { __CLASS__->new( address => $address ) }
    }

    # this is just an INT underneath, but the
    # name is also associated with it and both
    # must match. This is for tags and singals.
    class VM::Instructions::Values::TAG :isa(VM::Instructions::Values::Value) {
        field $tag :param :reader(value);
        method copy { __CLASS__->new( tag => $tag ) }
    }

    # this is just a enum from the set of signals
    # available via the instruction set
    class VM::Instructions::Values::SIGNAL :isa(VM::Instructions::Values::Value) {
        field $signal :param :reader(value);
        method copy { __CLASS__->new( signal => $signal ) }
    }

    # this is really a compound type, but can be treated
    # as a single value
    class VM::Instructions::Values::STRING :isa(VM::Instructions::Values::Value) {
        field $string :param :reader(value);
        method copy { __CLASS__->new( string => $string ) }
    }

    # this is a ref for a Process
    class VM::Instructions::Values::PROCESS :isa(VM::Instructions::Values::Value) {
        field $process :param :reader(value);
        method copy { __CLASS__->new( process => $process ) }
    }
}
