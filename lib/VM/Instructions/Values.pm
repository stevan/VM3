#!perl

use v5.40;
use experimental qw[ class ];

package VM::Instructions::Values {

    # values provide a bridge between
    # the internal values in the VM
    # and the opcodes

    class VM::Instructions::Values::Value {
        use overload '""' => 'to_string';
        method type      { (split '::' => __CLASS__)[-1] }
        method value;
        method to_string { sprintf '%.1s(%s)' => lc $self->type, $self->value }
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
    }

    # a single character, this is still a numeric type
    class VM::Instructions::Values::CHAR :isa(VM::Instructions::Values::Value) {
        field $char :param :reader(value);
    }

    # basic integer, we ignore sizes for now
    class VM::Instructions::Values::INT :isa(VM::Instructions::Values::Value) {
        field $int :param :reader(value);
    }

    # basic float, also ignore sizes for now
    class VM::Instructions::Values::FLOAT :isa(VM::Instructions::Values::Value) {
        field $float :param :reader(value);
    }

    # Some kind of address that points to something else
    class VM::Instructions::Values::ADDRESS :isa(VM::Instructions::Values::Value) {
        field $address :param :reader(value);
    }

    # this is just an INT underneath, but the
    # name is also associated with it and both
    # must match. This is for tags and singals.
    class VM::Instructions::Values::TAG :isa(VM::Instructions::Values::Value) {
        field $tag :param :reader(value);
    }

    # this is really a compound type, but can be treated
    # as a single value
    class VM::Instructions::Values::STRING :isa(VM::Instructions::Values::Value) {
        field $string :param :reader(value);
    }

    # this is a ref for a Process
    class VM::Instructions::Values::PROCESS :isa(VM::Instructions::Values::Value) {
        field $process :param :reader(value);
    }
}
