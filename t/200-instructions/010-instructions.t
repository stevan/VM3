#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use Test::More;
use Test::Differences;

use VM::Kernel::CPU;
use VM::Instructions;

my @code = (
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
);

my $cpu = VM::Kernel::CPU->new;
my $ctx = $cpu->create_new_context;

$cpu->load_microcode( \@VM::Instructions::MICROCODE )
    ->load_code( \@code )
    ->load_context( $ctx );

while ($cpu->execute) {
    warn "Current Instruction: ".$cpu->ci;
    $ctx->dump;
    say '-' x 80;
}


done_testing;
