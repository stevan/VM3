
use v5.40;
use experimental qw[ builtin ];
use builtin      qw[ export_lexically ];

use VM::Instructions;

package VM::Assembly::SimpleOpcodeBuilder {

    sub import ($) {
        state %instructions = map {
            my $instr = $_;
            ('&'.$instr) => sub :prototype() () { $instr }
        } @VM::Instructions::INSTRUCTIONS;

        export_lexically(
            # values ...
            '&t'     => \&t,
            '&f'     => \&f,
            '&null'  => \&null,
            '&void'  => \&void,

            '&i8'    => \&i8,
            '&i16'   => \&i16,
            '&i32'   => \&i32,

            '&u8'    => \&u8,
            '&u16'   => \&u16,
            '&u32'   => \&u32,

            '&f32'   => \&f32,

            '&char'  => \&char,
            '&str'   => \&str,
            '&addr'  => \&addr,
            # ops ...
            '&op'    => \&op,
            %instructions,
        );
    }

    sub t     ()   { VM::Instructions::Values::BOOL->new( bool => true ) }
    sub f     ()   { VM::Instructions::Values::BOOL->new( bool => false ) }

    sub null  ()   { VM::Instructions::Values::NULL->new }
    sub void  ()   { VM::Instructions::Values::VOID->new }

    sub i8    ($i) { VM::Instructions::Values::INT->new( int => $i, size => 8,  signed => true ) }
    sub i16   ($i) { VM::Instructions::Values::INT->new( int => $i, size => 16, signed => true ) }
    sub i32   ($i) { VM::Instructions::Values::INT->new( int => $i, size => 32, signed => true ) }

    sub u8    ($i) { VM::Instructions::Values::INT->new( int => $i, size => 8  ) }
    sub u16   ($i) { VM::Instructions::Values::INT->new( int => $i, size => 16 ) }
    sub u32   ($i) { VM::Instructions::Values::INT->new( int => $i, size => 32 ) }

    sub f32   ($f) { VM::Instructions::Values::FLOAT->new( float => $f ) }
    sub char  ($c) { VM::Instructions::Values::CHAR->new( char => $c ) }
    sub str   ($s) { VM::Instructions::Values::STRING->new( string => $s ) }
    sub addr  ($a) { VM::Instructions::Values::ADDRESS->new( address => $a ) }

    sub op ($c, $o1=undef, $o2=undef) {
        VM::Instructions::Opcode->new(
            instruction => VM::Instructions->$c,
            (defined $o1 ? (operand1 => $o1) : ()),
            (defined $o2 ? (operand2 => $o2) : ()),
        )
    }

}
