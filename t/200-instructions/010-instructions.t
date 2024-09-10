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
    op(PUSH, i32(10)),
    op(PUSH, i32(20)),
    op(ADD_INT),
    op(PUSH, i32(30)),
    op(ADD_INT),
];

my $dbg = VM::Debugger::CPUContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $ctx = VM::Kernel::CPU::Context->new;

while ($cpu->execute($code, $ctx)) {
    $dbg->dump($cpu, $ctx);
}


done_testing;
