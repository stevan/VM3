#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use Test::More;
use Test::Differences;

use VM::Kernel::CPU;
use VM::Instructions;

use VM::Assembly::SimpleOpcodeBuilder;
use VM::Debugger::CPUContext;


my $code = [
# doubler = 0
    op(LOAD_ARG, 1),
    op(DUP),
    op(CALL, addr(4), 2),
    op(RETURN),

# adder = 4
    op(LOAD_ARG, 1),
    op(LOAD_ARG, 0),
    op(ADD_INT),
    op(RETURN),

# main = 8
    op(PUSH, i32(10)),
    op(CALL, addr(0), 1),
    op(PUSH, void),
    op(RETURN),

# ... = 12
    op(CALL, addr(8), 0),
];

my $dbg = VM::Debugger::CPUContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $ctx = VM::Kernel::CPU::Context->new;

$ctx->pc = 12;

while ($cpu->execute($code, $ctx)) {
    $dbg->dump($cpu, $ctx);
}


done_testing;
