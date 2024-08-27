#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'Carp'         => qw[ confess ];

use Test::More;
use Test::Differences;
use Test::VM::Assembler;

my $t = Test::VM::Assembler->new(
    path => './examples/tests/'
);

subtest '... testing 000-hello-world', sub {
    my $src = $t->load_source('000-hello-world');

    #say $src->JSONize($src->tokenize);
    eq_or_diff(
        $src->tokenize,
        $src->expected_tokens,
        '... got the expected tokens'
    );

    #say $src->JSONize($src->parse_tree);
    eq_or_diff(
        $src->parse_tree,
        $src->expected_parse_tree,
        '... got the expected parse tree'
    );
};

done_testing;


