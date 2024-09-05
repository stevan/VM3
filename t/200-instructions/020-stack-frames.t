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
# doubler = 0
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->LOAD_ARG,
        operand1    => 1,
    ),
    VM::Instructions::Opcode->new( instruction => VM::Instructions->DUP ),
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->CALL,
        operand1    => VM::Instructions::Values::ADDRESS->new( address => 4 ),
        operand2    => 2,
    ),
    VM::Instructions::Opcode->new( instruction => VM::Instructions->RETURN ),

# adder = 4
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->LOAD_ARG,
        operand1    => 1,
    ),
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->LOAD_ARG,
        operand1    => 0,
    ),
    VM::Instructions::Opcode->new( instruction => VM::Instructions->ADD_INT ),
    VM::Instructions::Opcode->new( instruction => VM::Instructions->RETURN ),

# main = 8
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->PUSH,
        operand1    => VM::Instructions::Values::INT->new( int => 10 ),
    ),
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->CALL,
        operand1    => VM::Instructions::Values::ADDRESS->new( address => 0 ),
        operand2    => 1,
    ),
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->PUSH,
        operand1    => VM::Instructions::Values::VOID->new,
    ),
    VM::Instructions::Opcode->new( instruction => VM::Instructions->RETURN ),

# ... = 12
    VM::Instructions::Opcode->new(
        instruction => VM::Instructions->CALL,
        operand1    => VM::Instructions::Values::ADDRESS->new( address => 8 ),
        operand2    => 0,
    ),
];

my $dbg = VM::Debugger::CPUContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $ctx = VM::Kernel::CPU::Context->new;

$ctx->pc = 12;

while ($cpu->execute($code, $ctx)) {
    $dbg->dump($cpu, $ctx);
}


done_testing;
