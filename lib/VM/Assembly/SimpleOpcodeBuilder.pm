
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
            '&i'    => \&i,
            '&addr' => \&addr,
            '&void' => \&void,
            # ops ...
            '&op' => \&op,
            %instructions,
        );
    }

    sub i    ($i) { VM::Instructions::Values::INT->new( int => $i ) }
    sub addr ($a) { VM::Instructions::Values::ADDRESS->new( address => $a ) }
    sub void ()   { VM::Instructions::Values::VOID->new }

    sub op ($c, $o1=undef, $o2=undef) {
        VM::Instructions::Opcode->new(
            instruction => VM::Instructions->$c,
            (defined $o1 ? (operand1 => $o1) : ()),
            (defined $o2 ? (operand2 => $o2) : ()),
        )
    }

}
