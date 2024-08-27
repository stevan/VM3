#!perl

use v5.40;
use experimental qw[ class ];

package VM::Assembler::Tokens {

    sub Label     ($, $value) { VM::Assembler::Token::Label     ->new( value => $value ) }
    sub Address   ($, $value) { VM::Assembler::Token::Address   ->new( value => $value ) }
    sub Signal    ($, $value) { VM::Assembler::Token::Signal    ->new( value => $value ) }
    sub Tag       ($, $value) { VM::Assembler::Token::Tag       ->new( value => $value ) }
    sub Namespace ($, $value) { VM::Assembler::Token::Namespace ->new( value => $value ) }
    sub Variable  ($, $value) { VM::Assembler::Token::Variable  ->new( value => $value ) }
    sub Structure ($, $value) { VM::Assembler::Token::Structure ->new( value => $value ) }
    sub Directive ($, $value) { VM::Assembler::Token::Directive ->new( value => $value ) }
    sub SysCall   ($, $value) { VM::Assembler::Token::SysCall   ->new( value => $value ) }
    sub Opcode    ($, $value) { VM::Assembler::Token::Opcode    ->new( value => $value ) }
    sub Literal   ($, $value) { VM::Assembler::Token::Literal   ->new( value => $value ) }
    sub Number    ($, $value) { VM::Assembler::Token::Number    ->new( value => $value ) }
    sub Comment   ($, $value) { VM::Assembler::Token::Comment   ->new( value => $value ) }

    sub Comma     ($)         { VM::Assembler::Token::Comma     ->new( value => ','   ) }
    sub Assign    ($)         { VM::Assembler::Token::Assign    ->new( value => '='   ) }
    sub StartList ($)         { VM::Assembler::Token::StartList ->new( value => '('   ) }
    sub EndList   ($)         { VM::Assembler::Token::EndList   ->new( value => ')'   ) }
    sub EOL       ($)         { VM::Assembler::Token::EOL       ->new( value => 'EOL' ) }
    sub EOF       ($)         { VM::Assembler::Token::EOF       ->new( value => 'EOF' ) }

    class VM::Assembler::Token {
        use overload '""' => 'to_string';
        field $value :param :reader;

        method type { (split '::' => __CLASS__)[-1] }

        method to_string {
            sprintf 'TOKEN(%s, %s)' => $self->type, $self->value;
        }
    }

    class VM::Assembler::Token::Label     :isa(VM::Assembler::Token) {} # .label
    class VM::Assembler::Token::Address   :isa(VM::Assembler::Token) {} # &label

    class VM::Assembler::Token::Signal    :isa(VM::Assembler::Token) {} # %SIGNAL
    class VM::Assembler::Token::Tag       :isa(VM::Assembler::Token) {} # ^tag
    class VM::Assembler::Token::Namespace :isa(VM::Assembler::Token) {} # /name/space
    class VM::Assembler::Token::Variable  :isa(VM::Assembler::Token) {} # $var
    class VM::Assembler::Token::Structure :isa(VM::Assembler::Token) {} # :structure
    class VM::Assembler::Token::Directive :isa(VM::Assembler::Token) {} # @directive
    class VM::Assembler::Token::SysCall   :isa(VM::Assembler::Token) {} # ::syscall

    class VM::Assembler::Token::Opcode    :isa(VM::Assembler::Token) {} # PUSH, etc.
    class VM::Assembler::Token::Literal   :isa(VM::Assembler::Token) {} # i(), f(), c(), str(), etc.}

    class VM::Assembler::Token::Comma     :isa(VM::Assembler::Token) {} # ,
    class VM::Assembler::Token::Assign    :isa(VM::Assembler::Token) {} # =
    class VM::Assembler::Token::StartList :isa(VM::Assembler::Token) {} # (
    class VM::Assembler::Token::EndList   :isa(VM::Assembler::Token) {} # )
    class VM::Assembler::Token::Number    :isa(VM::Assembler::Token) {} # raw number, usually an operand

    class VM::Assembler::Token::EOL       :isa(VM::Assembler::Token) {} # \n
    class VM::Assembler::Token::EOF       :isa(VM::Assembler::Token) {} #

    class VM::Assembler::Token::Comment   :isa(VM::Assembler::Token) {} # anything after an `#` character till end of line
}
