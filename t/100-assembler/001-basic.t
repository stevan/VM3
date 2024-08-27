#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'Carp'         => qw[ confess ];

use JSON::XS;

use VM::Assembler::Parser;

my $CODE = join '' => <DATA>;

my $p = VM::Assembler::Parser->new;

my @results = $p->parse( $CODE );

say JSON::XS->new->pretty->canonical->encode( [ map $_->to_JSON, @results ] );

__DATA__

.signal
    DUP
    NUM_SIGNALS
    LT_INT
    JUMP_IF_TRUE &_NO_SIG_MATCH
    PUSH i(2)
    MUL_INT
    ADVANCE_BY
        JUMP &STARTING
        JUMP &RESTARTING
    ._NO_SIG_MATCH
        SIG_IGNORE
    .STARTING
        PUSH i(0)
        SET_LOCAL $pings
        SIG_RESUME
    .RESTARTING
        PUSH i(0)
        SET_LOCAL $pings
        GET_LOCAL $restarts
        INC_INT
        SET_LOCAL $restarts
        SIG_RESUME
