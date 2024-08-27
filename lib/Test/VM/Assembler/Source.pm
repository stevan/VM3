#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Path::Tiny' => qw[ path ];

use JSON::XS ();

use VM::Assembler::Tokenizer;
use VM::Assembler::Parser;

class Test::VM::Assembler::Source {
    field $filename   :param :reader;
    field $asm_file   :param :reader;
    field $token_file :param :reader;
    field $parse_file :param :reader;

    field $asm_src;
    field $token_json;
    field $parse_json;

    ADJUST {
        $asm_src = $asm_file->slurp;
    }

    our $JSON = JSON::XS->new->pretty->canonical->utf8;

    method expected_tokens     { $token_json //= $JSON->decode( $token_file->slurp ) }
    method expected_parse_tree { $parse_json //= $JSON->decode( $parse_file->slurp ) }

    method tokenize {
        [ map $_->to_JSON, VM::Assembler::Tokenizer->new->tokenize( $asm_src ) ]
    }

    method parse_tree {
        [ map $_->to_JSON, VM::Assembler::Parser->new->parse( $asm_src ) ]
    }

    method JSONize ($ref) { $JSON->encode($ref) }
}
