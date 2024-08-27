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

:actor /greeter
    ^hello
        RECV                          # [ ^hello ]                                         MP = -1
        MSG_ACCEPT                    # [ "World", 1, \&main, ^hello ]                     MP = 3
        MSG_GET 0                     # [ "World", 1, \&main, ^hello, "World" ]            MP = 3
        PUSH s("Hello ")              # [ "World", 1, \&main, ^hello, "World", "Hello " ]  MP = 3
        SYS_CALL ::say, 2             # [ "World", 1, \&main, ^hello ]                     MP = 3
        MSG_DISCARD                   # []                                                 MP = -1
        STOP                          # []                                                 MP = -1
:end

.main
    SPAWN /greeter, 0             # [ \&greeter ]
    DUP                           # [ \&greeter, \&greeter ]
    PUSH s("World")               # [ \&greeter, \&greeter, "World" ]
    SWAP                          # [ \&greeter, "World", \&greeter ]
    SEND ^/greeter/hello, 1       # [ \&greeter ]
    WAIT                          # []

    PUSH s("Goodbye ")            # [ "Goodbye!" ]
    SYS_CALL ::say, 2             # []
    EXIT


