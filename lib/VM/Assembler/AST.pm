#!perl

use v5.40;
use experimental qw[ class ];

package VM::Assembler::AST {

    class VM::Assembler::AST::Node {
        use overload '""' => 'to_string';
        method type { (split '::' => __CLASS__)[-1] }
        method to_string;
    }

    class VM::Assember::AST::Number :isa(VM::Assembler::AST::Node) {
        field $number :param :reader;

        method to_string {
            sprintf "Num{ %s }", $number->value;
        }
    }

    class VM::Assember::AST::Namespace :isa(VM::Assembler::AST::Node) {
        field $namespace :param :reader;

        method to_string {
            sprintf "Namespace{ %s }", $namespace->value;
        }
    }

    class VM::Assember::AST::Signal :isa(VM::Assembler::AST::Node) {
        field $signal :param :reader;

        method to_string {
            sprintf "Signal{ %s }", $signal->value;
        }
    }

    class VM::Assember::AST::Variable :isa(VM::Assembler::AST::Node) {
        field $var :param :reader;

        method to_string {
            sprintf "Var{ %s }", $var->value;
        }
    }

    class VM::Assember::AST::Address :isa(VM::Assembler::AST::Node) {
        field $address :param :reader;

        method to_string {
            sprintf "Address{ %s }", $address->value;
        }
    }

    class VM::Assember::AST::Tag :isa(VM::Assembler::AST::Node) {
        field $tag :param :reader;

        method to_string {
            sprintf "Tag{ %s }", $tag->value;
        }
    }

    class VM::Assember::AST::SysCall :isa(VM::Assembler::AST::Node) {
        field $syscall :param :reader;

        method to_string {
            sprintf "SysCall{ %s }", $syscall->value;
        }
    }

    class VM::Assember::AST::StructureBlock :isa(VM::Assembler::AST::Node) {
        field $structure :param :reader;
        field $name      :param :reader = undef;
        field $body      :param :reader;

        method to_string {
            sprintf "Structure {\n\ttype = %s\n\tname = %s\n\tbody = (\n\t\t%s\n\t)\n}",
                    $structure->value,
                    ($name ? $name->value : '~'),
                    (join "\n\t\t" => map $_->to_string, @$body)
        }
    }

    class VM::Assember::AST::LabelBlock :isa(VM::Assembler::AST::Node) {
        field $label :param :reader;
        field $body  :param :reader;

        method to_string {
            sprintf "LabelBlock {\n\tlabel = %s\n\tbody = (\n\t\t%s\n\t)\n}",
                    $label->value,
                    (join "\n\t\t" => map $_->to_string, @$body)
        }
    }

    class VM::Assember::AST::TagBlock :isa(VM::Assembler::AST::Node) {
        field $tag :param :reader;
        field $body  :param :reader;

        method to_string {
            sprintf "TagBlock {\n\ttag = %s\n\tbody = (\n\t\t%s\n\t)\n}",
                    $tag->value,
                    (join "\n\t\t" => map $_->to_string, @$body)
        }
    }

    class VM::Assember::AST::Op :isa(VM::Assembler::AST::Node) {
        field $op :param :reader;

        method to_string {
            sprintf "Op{ op = %s }", $op->value;
        }
    }

    class VM::Assember::AST::UnOp :isa(VM::Assembler::AST::Node) {
        field $op   :param :reader;
        field $oper :param :reader;

        method to_string {
            sprintf "UnOp{ op = %s, oper[0] = %s }", $op->value, $oper->to_string;
        }
    }

    class VM::Assember::AST::BinOp :isa(VM::Assembler::AST::Node) {
        field $op    :param :reader;
        field $oper1 :param :reader;
        field $oper2 :param :reader;

        method to_string {
            sprintf "BinOp{ op = %s, oper[0] = %s, oper[1] = %s }", $op->value, $oper1->to_string, $oper2->to_string;
        }
    }

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
    }

}
