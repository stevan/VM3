#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use Test::More;
use Test::Differences;

use VM::Loader;
use VM::Kernel::CPU;
use VM::Instructions;

use VM::Debugger::CPUContext;


my $exe = VM::Loader::Format->new(
    entry => 8,
    code  => [
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
    ]
);

my $dbg = VM::Debugger::CPUContext->new;

my $ld  = VM::Loader->new;
my $cpu = VM::Kernel::CPU->new;
my $ctx = VM::Kernel::CPU::Context->new;

$cpu->load_microcode( \@VM::Instructions::MICROCODE );

$ld->load($cpu, $ctx, $exe);

while ($cpu->execute) {
    $dbg->dump($cpu, $ctx);
}


done_testing;
