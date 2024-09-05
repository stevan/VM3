#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use Test::More;
use Test::Differences;

use VM::Loader;
use VM::Kernel::CPU;
use VM::Instructions;

my $exe = VM::Loader::Format->new(
    entry => 0,
    code  => [
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
    ]
);

my $ld  = VM::Loader->new;
my $cpu = VM::Kernel::CPU->new;
my $ctx = VM::Kernel::CPU::Context->new;

$cpu->load_microcode( \@VM::Instructions::MICROCODE );

$ld->load($cpu, $ctx, $exe);

while ($cpu->execute) {
    warn "Current Instruction: ".$cpu->ci;
    $ctx->dump;
    say '-' x 80;
}


done_testing;
