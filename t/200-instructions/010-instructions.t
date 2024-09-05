#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use Test::More;
use Test::Differences;

use VM::Kernel::CPU;

use VM::Instructions;

use VM::Debugger::CPUContext;

my $code = [
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->PUSH,
        operand1    => VM::Instructions::Values::INT->new( int => 10 ),
    ),
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->PUSH,
        operand1    => VM::Instructions::Values::INT->new( int => 20 ),
    ),
    VM::Instructions::Opcode->new( instruction => VM::Instructions->ADD_INT ),
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->PUSH,
        operand1    => VM::Instructions::Values::INT->new( int => 30 ),
    ),
    VM::Instructions::Opcode->new( instruction => VM::Instructions->ADD_INT ),
];

my $dbg = VM::Debugger::CPUContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $ctx = VM::Kernel::CPU::Context->new;

while ($cpu->execute($code, $ctx)) {
    $dbg->dump($cpu, $ctx);
}


done_testing;
