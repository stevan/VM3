#!perl

use v5.40;
use experimental qw[ builtin ];
use builtin      qw[ export_lexically ];

use importer 'Scalar::Util' => qw[ dualvar ];

use VM::Instructions::Microcode;
use VM::Instructions::Opcode;
use VM::Instructions::Values;

package VM::Instructions {
    use constant;

    our @INSTRUCTIONS;
    BEGIN {
        @INSTRUCTIONS = qw(
            PUSH
            POP
            SWAP
            DUP

            ADD_INT
        );

        foreach my ($id, $name) (indexed @INSTRUCTIONS) {
            constant->import( $name => dualvar( $id, $name ) );
        }
    }

    our @MICROCODE;

    my sub set_microcode_for ($instr, $mc) {
        $MICROCODE[$instr] = VM::Instructions::Microcode->new(
            instruction => $instr,
            microcode   => $mc
        )
    }

    # --------------------------------------------------------------------------
    # Stack Ops
    # --------------------------------------------------------------------------

    set_microcode_for PUSH, sub ($opcode, $ctx) {
        $ctx->push( $opcode->operand1 );
    };

    set_microcode_for POP, sub ($opcode, $ctx) {
        $ctx->pop;
    };

    set_microcode_for DUP, sub ($opcode, $ctx) {
        $ctx->push( $ctx->peek );
    };

    set_microcode_for SWAP, sub ($opcode, $ctx) {
        my $v1 = $ctx->pop;
        my $v2 = $ctx->pop;
        $ctx->push( $v1 );
        $ctx->push( $v2 );
    };

    # --------------------------------------------------------------------------
    # Maths
    # --------------------------------------------------------------------------

    set_microcode_for ADD_INT, sub ($opcode, $ctx) {
        my $r = $ctx->pop;
        my $l = $ctx->pop;
        $ctx->push(
            VM::Instructions::Values::INT->new(
                int => $l->value + $r->value
            )
        );
    };

}
