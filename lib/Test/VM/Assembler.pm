
use v5.40;
use experimental qw[ class ];

use importer 'Path::Tiny' => qw[ path ];

use Test::VM::Assembler::Source;

class Test::VM::Assembler {
    field $path :param :reader;

    field $root_dir;
    field $asm_dir;
    field $json_dir;

    field $tokenizer_dir;
    field $parser_dir;

    field %sources;

    ADJUST {
        $root_dir = path($path);
        $asm_dir  = $root_dir->child('asm');
        $json_dir = $root_dir->child('json');

        $tokenizer_dir = $json_dir->child('tokenizer');
        $parser_dir    = $json_dir->child('parser');
    }

    method load_source ($filename) {
        $sources{ $filename } = Test::VM::Assembler::Source->new(
            filename   => $filename,
            asm_file   => $asm_dir->child( "${filename}.asm" ),
            token_file => $tokenizer_dir->child( "${filename}.json" ),
            parse_file => $parser_dir->child( "${filename}.json" ),
        );
    }
}
