#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'Carp'         => qw[ confess ];

use VM::Assembler::Parser;

my $CODE = join '' => <DATA>;

my $p = VM::Assembler::Parser->new;

my @tokens = $p->parse( $CODE );

say join "\n" => grep { !($_ isa VM::Assembler::Token::Comment) } @tokens;

__DATA__

:function .spawn
    LOAD_ARG 0
    JUMP &foo
.foo
    JUMP &bar
.bar
    RETURN
:end

:function .despawn
    FREE_PROCESS

    RETURN
:end


