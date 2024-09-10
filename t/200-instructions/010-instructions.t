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
    op(PUSH, i32(10)),
    op(PUSH, i32(20)),
    op(ADD_INT),
    op(PUSH, i32(30)),
    op(ADD_INT),
];

my $dbg = VM::Debugger::ProcessContext->new;

my $cpu = VM::Kernel::CPU->new( microcode => \@VM::Instructions::MICROCODE );
my $prc = VM::Kernel::Process->new( pid => 1 );

while ($cpu->execute($code, $prc)) {
    $dbg->dump($cpu, $prc);
}

my $result = $prc->peek;
isa_ok($result, 'VM::Instructions::Values::INT');
is($result->value, 60, '... got the expected end value');

done_testing;
