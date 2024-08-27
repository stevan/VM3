#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Carp' => qw[ confess ];

use VM::Assembler::Tokenizer;
use VM::Assembler::AST;

class VM::Assembler::Parser {
    use constant DEBUG => $ENV{DEBUG} // 0;
    sub LOG ($msg) { warn "LOG: ${msg}\n" }

    field $tokenizer;

    ADJUST {
        $tokenizer = VM::Assembler::Tokenizer->new;
    }

    method parse ($source) {
        LOG("Parsing ...") if DEBUG;

        my @tokens = $tokenizer->tokenize( $source );

        my @stack;

        while (@tokens && !($tokens[0] isa VM::Assembler::Token::EOF)) {
            my $t = $tokens[0];

            if ($t isa VM::Assembler::Token::EOL) {
                shift @tokens;
            } elsif ($t isa VM::Assembler::Token::Structure) {
                push @stack => $self->parse_structure( \@tokens );
            } elsif ($t isa VM::Assembler::Token::Label) {
                push @stack => $self->parse_label_block( \@tokens );
            } else {
                confess "Top Level must be either Structure of Label, not $t";
            }
        }

        return @stack;
    }


    method parse_structure ($tokens) {
        LOG("Parsing Structure ...") if DEBUG;
        my $structure = shift @$tokens;

        if ($structure->value eq ':header') {

            confess "Implement Header Directive";

        } elsif ($structure->value eq ':behavior') {

            confess "Implement Behavior Directive";

        } elsif ($structure->value eq ':actor') {

            confess "Implement Actor Directive";

        } elsif ($structure->value eq ':module') {

            confess "Implement Directive";

        } elsif ($structure->value eq ':function') {
            my @body;

            while (@$tokens) {
                my $t = $tokens->[0];

                if ($t isa VM::Assembler::Token::Structure && $t->value eq ':end') {
                    shift @$tokens;
                    last;
                } else {
                    if ($t isa VM::Assembler::Token::Comment ||
                        $t isa VM::Assembler::Token::EOL     ){
                        shift @$tokens;
                        next;
                    } elsif ($t isa VM::Assembler::Token::Label) {
                        push @body => $self->parse_label_block( $tokens );
                    } else {
                        confess "WTF: $t";
                    }
                }
            }

            return VM::Assember::AST::Function->new( body => \@body );
        }

    }

    method parse_label_block ($tokens) {
        LOG("Parsing LabelBlock ...") if DEBUG;

        my $label = shift @$tokens;

        my @body;
        while (@$tokens) {
            if ($tokens->[0] isa VM::Assembler::Token::Comment ||
                $tokens->[0] isa VM::Assembler::Token::EOL     ){
                shift @$tokens;
            } elsif ($tokens->[0] isa VM::Assembler::Token::Label ||
                     $tokens->[0] isa VM::Assembler::Token::EOF   ){
                last;
            } elsif ($tokens->[0] isa VM::Assembler::Token::Opcode) {
                push @body => $self->parse_opcode( $tokens );
            } else {
                last;
            }
        }

        return VM::Assember::AST::LabelBlock->new(
            label => $label,
            body  => \@body,
        );
    }

    method parse_opcode ($tokens) {
        LOG("Parsing Opcode ...") if DEBUG;
        my $op = shift @$tokens;
        my @operands;

        while (@$tokens) {
            my $t = shift @$tokens;

            last if $t isa VM::Assembler::Token::EOL;

            next if $t isa VM::Assembler::Token::Comment;
            next if $t isa VM::Assembler::Token::Comma;

            if ($t isa VM::Assembler::Token::Literal) {
                push @operands => VM::Assember::AST::Literal->new( literal => $t );
            } elsif ($t isa VM::Assembler::Token::Number) {
                push @operands => VM::Assember::AST::Number->new( number => $t );
            } elsif ($t isa VM::Assembler::Token::Namespace) {
                push @operands => VM::Assember::AST::Namespace->new( namespace => $t );
            } elsif ($t isa VM::Assembler::Token::Tag) {
                push @operands => VM::Assember::AST::Tag->new( tag => $t );
            } elsif ($t isa VM::Assembler::Token::SysCall) {
                push @operands => VM::Assember::AST::SysCall->new( syscall => $t );
            } elsif ($t isa VM::Assembler::Token::Address) {
                push @operands => VM::Assember::AST::Address->new( address => $t );
            } elsif ($t isa VM::Assembler::Token::Signal) {
                push @operands => VM::Assember::AST::Signal->new( signal => $t );
            } elsif ($t isa VM::Assembler::Token::Variable) {
                push @operands => VM::Assember::AST::Variable->new( var => $t );
            } else {
                push @operands => $t;
            }
        }

        my $node;
        my $num_operands = scalar @operands;

        if ($num_operands == 0) {
            $node = VM::Assember::AST::Op->new( op => $op );
        } elsif ($num_operands == 1) {
            $node = VM::Assember::AST::UnOp->new(
                op   => $op,
                oper => $operands[0]
            );
        } elsif ($num_operands == 2) {
            $node = VM::Assember::AST::BinOp->new(
                op    => $op,
                oper1 => $operands[0],
                oper2 => $operands[1]
            );
        }

        return $node;
    }
}
