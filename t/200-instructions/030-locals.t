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
# foo = 0
    op(LOAD_ARG, 1),
    op(STORE_LOCAL, 0),
    op(LOAD_LOCAL, 0),
    op(DUP),
    op(ADD_INT),
    op(STORE_LOCAL, 1),
    op(LOAD_LOCAL, 0),
    op(LOAD_LOCAL, 1),
    op(ADD_INT),
    op(RETURN),

# main = 10
    op(PUSH, i32(10)),
    op(CALL, addr(0), 1),
    op(PUSH, void),
    op(RETURN),

# ... = 12
    op(CALL, addr(10), 0),
];

my $dbg = VM::Debugger::CPUContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $ctx = VM::Kernel::CPU::Context->new;

$ctx->pc = 14;

while ($cpu->execute($code, $ctx)) {
    $dbg->dump($cpu, $ctx);
}


done_testing;
