#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use VM::Instructions::Values;

my $PROCESS = 'PID[001]';

subtest '... check all values' => sub {
    my @values = (
        VM::Instructions::Values::NULL->new,
        VM::Instructions::Values::VOID->new,
        VM::Instructions::Values::BOOL->new( bool => true ),
        VM::Instructions::Values::CHAR->new( char => 'c' ),
        VM::Instructions::Values::INT->new( int => 10 ),
        VM::Instructions::Values::FLOAT->new( float => 2.5 ),
        VM::Instructions::Values::ADDRESS->new( address => 1234 ),
        VM::Instructions::Values::TAG->new( tag => 12 ),
        VM::Instructions::Values::SIGNAL->new( signal => 1 ),
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
};

subtest '... check unsigned int max_values' => sub {
    my @input = (
        8  => 256,
        16 => 65_536,
        32 => 4_294_967_296
    );

    foreach my ($size, $expected_max) (@input) {
        my $i = VM::Instructions::Values::INT->new( int => 1, size => $size );
        is($i->max_value, $expected_max, "... got the expected($expected_max) max value (".$i->max_value.")");
    }
};

subtest '... check signed int max_values' => sub {
    my @input = (
        8  => 128,
        16 => 32768,
        32 => 2_147_483_648
    );

    foreach my ($size, $expected_max) (@input) {
        my $i = VM::Instructions::Values::INT->new( int => 1, size => $size, signed => true );
        is($i->max_value, $expected_max, "... got the expected($expected_max) max value (".$i->max_value.")");
    }
};

subtest '... check unsigned int min_values' => sub {
    my @input = (
        8  => 0,
        16 => 0,
        32 => 0,
    );

    foreach my ($size, $expected_min) (@input) {
        my $i = VM::Instructions::Values::INT->new( int => 1, size => $size );
        is($i->min_value, $expected_min, "... got the expected($expected_min) min value (".$i->min_value.")");
    }
};

subtest '... check signed int min_values' => sub {
    my @input = (
        8  => -127,
        16 => -32767,
        32 => -2_147_483_647
    );

    foreach my ($size, $expected_min) (@input) {
        my $i = VM::Instructions::Values::INT->new( int => 1, size => $size, signed => true );
        is($i->min_value, $expected_min, "... got the expected($expected_min) min value (".$i->min_value.")");
    }
};

subtest '... check unsigned int sizes' => sub {
    my @input = (
        # size, set, expected
    # 8
         8,   0,    0,
         8,  10,   10,
         8, 255,  255,
         8, 256,  256,
         8, 276,  256,
    # 16
        16,     0,     0,
        16,    10,    10,
        16,   255,   255,
        16,   256,   256,
        16, 65536, 65536,
        16, 65566, 65536,
    # 32
        32,          0,          0,
        32,         10,         10,
        32,        255,        255,
        32,        256,        256,
        32,      65536,      65536,
        32,      65566,      65566,
        32, 4294967296, 4294967296,
        32, 4294967300, 4294967296,
    );

    foreach my ($size, $set, $expected) (@input) {
        my $i = VM::Instructions::Values::INT->new( int => $set, size => $size );
        is($i->value, $expected, "... int($set) gave the expected($expected) value (".$i->value.") for int${size}");
    }
};

subtest '... check signed int sizes' => sub {
    my @input = (
        # size, set, expected
    # 8
         8,    0,    0,
         8,   10,   10,
         8,  127,  127,
         8,  128,  128,
         8,  129,  128,
         8,  255,  128,
         8,  256,  128,
         8,  276,  128,
         8,  -10,  -10,
         8, -127, -127,
         8, -128, -127,
         8, -129, -127,
         8, -255, -127,
         8, -256, -127,
         8, -276, -127,
    # 16
        16,      0,      0,
        16,     10,     10,
        16,    255,    255,
        16,    256,    256,
        16,  32767,  32767,
        16,  32768,  32768,
        16,  32769,  32768,
        16,  65536,  32768,
        16,  65566,  32768,
        16,    -10,    -10,
        16,   -255,   -255,
        16,   -256,   -256,
        16, -32767, -32767,
        16, -32768, -32767,
        16, -32769, -32767,
        16, -65536, -32767,
        16, -65566, -32767,
    # 32
        32,           0,           0,
        32,          10,          10,
        32,         255,         255,
        32,         256,         256,
        32,       65536,       65536,
        32,       65566,       65566,
        32,  2147483647,  2147483647,
        32,  2147483648,  2147483648,
        32,  2147483649,  2147483648,
        32,  4294967296,  2147483648,
        32,  4294967300,  2147483648,
        32,         -10,         -10,
        32,        -255,        -255,
        32,        -256,        -256,
        32,      -65536,      -65536,
        32,      -65566,      -65566,
        32, -2147483647, -2147483647,
        32, -2147483648, -2147483647,
        32, -2147483649, -2147483647,
        32, -4294967296, -2147483647,
        32, -4294967300, -2147483647,
    );

    foreach my ($size, $set, $expected) (@input) {
        my $i = VM::Instructions::Values::INT->new( int => $set, size => $size, signed => true );
        is($i->value, $expected, "... int($set) gave the expected($expected) value (".$i->value.") for int${size}");
    }
};

done_testing;
