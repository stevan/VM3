#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use VM::Kernel::CPU::Context;

subtest '... manipuating pointers and counters' => sub {
    my $ctx = VM::Kernel::CPU::Context->new;

    is($ctx->pc,  0, '... pc is the expected value');
    is($ctx->sp, -1, '... sp is the expected value');
    is($ctx->fp, -1, '... fp is the expected value');

    is(scalar $ctx->stack, 0, '... the stack is empty');

    subtest '... manipulating the program counter as lvalue' => sub {
        $ctx->pc++;
        is($ctx->pc,    1, '... pc is the expected value');
        is($ctx->pc++,  1, '... pc is the expected value (post-inc)');
        is($ctx->pc,    2, '... pc is the expected value');
        is(++$ctx->pc,  3, '... pc is the expected value (pre-inc)');
        is($ctx->pc,    3, '... pc is the expected value');

        $ctx->pc = 10;
        is($ctx->pc, 10, '... pc is the expected value (assign)');
    };

};

subtest '... manipuating the stack' => sub {
    my $ctx = VM::Kernel::CPU::Context->new;

    is($ctx->pc,  0, '... pc is the expected value');
    is($ctx->sp, -1, '... sp is the expected value');
    is($ctx->fp, -1, '... fp is the expected value');

    is(scalar $ctx->stack, 0, '... the stack is empty');

    $ctx->push(10);

    is(scalar $ctx->stack, 1, '... the stack is not empty');
    is($ctx->sp, 0, '... sp is the expected value');

    is($ctx->get(0), 10, '... got the expected stack value');

    is($ctx->peek, 10, '... peek gives the expected value');
    is($ctx->sp, 0, '... sp is the expected value');

    $ctx->set(0, 20);
    is($ctx->get(0), 20, '... got the expected stack value');

    is($ctx->pop, 20, '... pop gives the expected value');
    is($ctx->sp, -1, '... sp is the expected value');

    $ctx->push(20);
    $ctx->push(30);
    $ctx->push(40);

    is(scalar $ctx->stack, 3, '... the stack is not empty');
    is($ctx->sp, 2, '... sp is the expected value');

    is($ctx->get(0), 20, '... got the expected stack value');
    is($ctx->get(1), 30, '... got the expected stack value');
    is($ctx->get(2), 40, '... got the expected stack value');

    is($ctx->peek, 40, '... peek gives the expected value');
    is($ctx->sp, 2, '... sp is the expected value');

    $ctx->set(0, 10);
    is($ctx->get(0), 10, '... got the expected stack value');
    is($ctx->get(1), 30, '... got the expected stack value');
    is($ctx->get(2), 40, '... got the expected stack value');

    is($ctx->pop, 40, '... pop gives the expected value');
    is($ctx->sp, 1, '... sp is the expected value');
    is($ctx->peek, 30, '... peek gives the expected value');

    is($ctx->pop, 30, '... pop gives the expected value');
    is($ctx->sp, 0, '... sp is the expected value');
    is($ctx->peek, 10, '... peek gives the expected value');

    is($ctx->pop, 10, '... pop gives the expected value');
    is($ctx->sp, -1, '... sp is the expected value');

};

done_testing;
