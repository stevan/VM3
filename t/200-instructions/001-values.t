#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use VM::Instructions::Values;

my $PROCESS = 'PID[001]';

my @values = (
    VM::Instructions::Values::NULL->new,
    VM::Instructions::Values::VOID->new,
    VM::Instructions::Values::BOOL->new( bool => true ),
    VM::Instructions::Values::CHAR->new( char => 'c' ),
    VM::Instructions::Values::INT->new( int => 10 ),
    VM::Instructions::Values::FLOAT->new( float => 2.5 ),
    VM::Instructions::Values::ADDRESS->new( address => 1234 ),
    VM::Instructions::Values::TAG->new( tag => 12 ),
    VM::Instructions::Values::SIGNAL->new( tag => 1 ),
    VM::Instructions::Values::PROCESS->new( process => $PROCESS )
);

my @expected_types = qw(
    NULL
    VOID
    BOOL
    CHAR
    INT
    FLOAT
    ADDRESS
    TAG
    SIGNAL
    PROCESS
);

my @expected_values = (
    undef,
    undef,
    true,
    'c',
    10,
    2.5,
    1234,
    12,
    1,
    $PROCESS
);

eq_or_diff(
    [ map $_->value, @values ],
    [ @expected_values ],
    '... got the expected values'
);

eq_or_diff(
    [ map $_->type, @values ],
    [ @expected_types ],
    '... got the expected types'
);

done_testing;
