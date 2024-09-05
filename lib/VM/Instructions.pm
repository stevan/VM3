
use v5.40;
use experimental qw[ builtin ];
use builtin      qw[ export_lexically ];

use importer 'Scalar::Util' => qw[ dualvar ];
use importer 'Sub::Util'    => qw[ set_subname ];

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

            LOAD_ARG
            CALL
            RETURN
        );

        foreach my ($id, $name) (indexed @INSTRUCTIONS) {
            constant->import( $name => dualvar( $id, $name ) );
        }
    }

    our @MICROCODE;

    my sub set_microcode_for ($instr, $mc) {
        $MICROCODE[$instr] = VM::Instructions::Microcode->new(
            instruction => $instr,
            microcode   => set_subname( "$instr", $mc ),
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

    # --------------------------------------------------------------------------
    # Function Calls
    # --------------------------------------------------------------------------

    set_microcode_for LOAD_ARG, sub ($opcode, $ctx) {
        my $offset = $opcode->operand1;
        $ctx->push( $ctx->get( ($ctx->fp - 3) - $offset ) );
    };

    set_microcode_for CALL, sub ($opcode, $ctx) {
        my $addr = $opcode->operand1; # func address to go to
        my $argc = $opcode->operand2; # number of args the function has ...
        # stash the context ...
        $ctx->push($argc);
        $ctx->push($ctx->fp);
        $ctx->push($ctx->pc);

        # set the new context ...
        $ctx->fp = $ctx->sp;     # set the new frame pointer
        $ctx->pc = $addr->value; # and the program counter to the func addr
    };

    set_microcode_for RETURN, sub ($opcode, $ctx) {
        my $return_val = $ctx->pop;  # pop the return value from the stack

        $ctx->sp = $ctx->fp;          # restore stack pointer
        $ctx->pc = $ctx->pop;         # get the stashed program counter
        $ctx->fp = $ctx->pop;         # get the stashed program frame pointer

        my $argc = $ctx->pop;         # get the number of args
        $ctx->sp = $ctx->sp - $argc ; # decrement stack pointer by num args

        $ctx->push($return_val); # push the return value onto the stack
    };

}
