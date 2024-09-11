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
    op(PUSH, u32(10)),
    op(CALL, addr(0), 1),
];

my $dbg = VM::Debugger::ProcessContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $prc = VM::Kernel::Process->new( pid => 1, entry => 10 );

while ($cpu->execute($code, $prc)) {
    $dbg->dump($cpu, $prc);
}

my $result = $prc->peek;
isa_ok($result, 'VM::Instructions::Values::INT');
is($result->value, 30, '... got the expected end value');

done_testing;
