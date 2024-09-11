#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Data::Dumper' => qw[ Dumper ];

use Test::More;
use Test::Differences;

use VM::Kernel::Process;
use VM::Kernel::CPU;
use VM::Instructions;

use VM::Assembly::SimpleOpcodeBuilder;
use VM::Debugger::ProcessContext;


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
    op(PUSH, u32(10)),
    op(CALL, addr(0), 1),
];

my $dbg = VM::Debugger::ProcessContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $prc = VM::Kernel::Process->new( pid => 1, entry => 8 );

while ($cpu->execute($code, $prc)) {
    $dbg->dump($cpu, $prc);
}

my $result = $prc->peek;
isa_ok($result, 'VM::Instructions::Values::INT');
is($result->value, 20, '... got the expected end value');


done_testing;
