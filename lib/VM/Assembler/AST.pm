
use v5.40;
use experimental qw[ class ];

package VM::Assembler::AST {

    class VM::Assembler::AST::Node {
        use overload '""' => 'to_string';
        method type { (split '::' => __CLASS__)[-1] }
        method to_string;
        method to_JSON;
    }

    ## --------------------------------------------------------------
    ## Values
    ## --------------------------------------------------------------

    class VM::Assember::AST::Number :isa(VM::Assembler::AST::Node) {
        field $number :param :reader;

        method to_string {
            sprintf "Num{ %s }", $number->value;
        }

        method to_JSON {
            +{ '@node' => 'Number', value => $number->value }
        }
    }

    class VM::Assember::AST::Namespace :isa(VM::Assembler::AST::Node) {
        field $namespace :param :reader;

        method to_string {
            sprintf "Namespace{ %s }", $namespace->value;
        }

        method to_JSON {
            +{ '@node' => 'Namespace', value => $namespace->value }
        }
    }

    class VM::Assember::AST::Signal :isa(VM::Assembler::AST::Node) {
        field $signal :param :reader;

        method to_string {
            sprintf "Signal{ %s }", $signal->value;
        }

        method to_JSON {
            +{ '@node' => 'Signal', value => $signal->value }
        }
    }

    class VM::Assember::AST::Variable :isa(VM::Assembler::AST::Node) {
        field $var :param :reader;

        method to_string {
            sprintf "Var{ %s }", $var->value;
        }

        method to_JSON {
            +{ '@node' => 'Variable', value => $var->value }
        }
    }

    class VM::Assember::AST::Address :isa(VM::Assembler::AST::Node) {
        field $address :param :reader;

        method to_string {
            sprintf "Address{ %s }", $address->value;
        }

        method to_JSON {
            +{ '@node' => 'Address', value => $address->value }
        }
    }

    class VM::Assember::AST::Tag :isa(VM::Assembler::AST::Node) {
        field $tag :param :reader;

        method to_string {
            sprintf "Tag{ %s }", $tag->value;
        }

        method to_JSON {
            +{ '@node' => 'Tag', value => $tag->value }
        }
    }

    class VM::Assember::AST::SysCall :isa(VM::Assembler::AST::Node) {
        field $syscall :param :reader;

        method to_string {
            sprintf "SysCall{ %s }", $syscall->value;
        }

        method to_JSON {
            +{ '@node' => 'SysCall', value => $syscall->value }
        }
    }

    ## --------------------------------------------------------------
    ## Structures
    ## --------------------------------------------------------------

    class VM::Assember::AST::Function :isa(VM::Assembler::AST::Node) {
        field $body :param :reader;

        field $name;

        ADJUST {
            $name = $body->[0]->label;
        }

        method to_string {
            sprintf "Function { name = %s body = ( %s ) }",
                    $name->value,
                    (join "; " => map $_->to_string, @$body)
        }

        method to_JSON {
            +{ '@node' => 'Function', _name => $name->value, body => [ map $_->to_JSON, @$body ] }
        }
    }

    ## --------------------------------------------------------------
    ## Labeled Blocks
    ## --------------------------------------------------------------

    class VM::Assember::AST::LabeledBlock :isa(VM::Assembler::AST::Node) {
        field $label :param :reader;
        field $body  :param :reader;

        method to_string {
            sprintf "LabeledBlock { label = %s body = ( %s ) }",
                    $label->value,
                    (join "; " => map $_->to_string, @$body)
        }

        method to_JSON {
            +{ '@node' => 'LabeledBlock', _label => $label->value, body => [ map $_->to_JSON, @$body ] }
        }
    }

    ## --------------------------------------------------------------
    ## Opcodes
    ## --------------------------------------------------------------

    class VM::Assember::AST::Op :isa(VM::Assembler::AST::Node) {
        field $op :param :reader;

        method to_string {
            sprintf "Op{ op = %s }", $op->value;
        }

        method to_JSON {
            +{ '@node' => 'Op', _op => $op->value }
        }
    }

    class VM::Assember::AST::UnOp :isa(VM::Assembler::AST::Node) {
        field $op   :param :reader;
        field $oper :param :reader;

        method to_string {
            sprintf "UnOp{ op = %s, oper[0] = %s }", $op->value, $oper->to_string;
        }

        method to_JSON {
            +{ '@node' => 'UnOp', _op => $op->value, oper => $oper->to_JSON }
        }
    }

    class VM::Assember::AST::BinOp :isa(VM::Assembler::AST::Node) {
        field $op    :param :reader;
        field $oper1 :param :reader;
        field $oper2 :param :reader;

        method to_string {
            sprintf "BinOp{ op = %s, oper[0] = %s, oper[1] = %s }", $op->value, $oper1->to_string, $oper2->to_string;
        }

        method to_JSON {
            +{ '@node' => 'BinOp', _op => $op->value, oper1 => $oper1->to_JSON, oper2 => $oper2->to_JSON }
        }
    }

    ## --------------------------------------------------------------
    ## Literals
    ## --------------------------------------------------------------

    class VM::Assember::AST::Literal :isa(VM::Assembler::AST::Node) {
        field $literal :param :reader;

        field $type;
        field $value;

        ADJUST {
            ($type, $value) = ($literal->value =~ /^(.)\((.*)\)/);
        }

        method to_string {
            sprintf "Literal{ type = %s value = %s }", $type, $value
        }

        method to_JSON {
            +{ '@node' => 'Literal', _type => $type, value => $value }
        }
    }

    class VM::Assember::AST::Const :isa(VM::Assembler::AST::Node) {
        field $const :param :reader;

        method to_string {
            sprintf "%s{}", $const->type
        }

        method to_JSON {
            +{ '@node' => $const->type }
        }
    }

}
