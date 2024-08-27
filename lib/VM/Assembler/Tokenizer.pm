#!perl

use v5.40;
use experimental qw[ class ];

use importer 'Carp' => qw[ confess ];

use VM::Assembler::Tokens;

class VM::Assembler::Tokenizer {
    use constant DEBUG => $ENV{DEBUG} // 0;
    sub LOG ($msg) { warn "LOG: ${msg}\n" }

    method tokenize ($source) {
        LOG("Tokenizing ...") if DEBUG;
        my @tokens;

        my @lines = split /\n/ => $source;
        LOG("Tokenizing ".(scalar @lines)." lines") if DEBUG;

        foreach my $line (@lines) {
            push @tokens => $self->tokenize_line( $line );
        }

        return @tokens, VM::Assembler::Tokens->EOF;
    }

    method tokenize_line ($line) {
        LOG("Tokenizing line ...") if DEBUG;

        my @tokens;

        my @chars = split '' => $line;

        while (@chars) {
            my $c = $chars[0];

            my $token;
            if ($c eq ' ') {
                shift @chars;
                next;
            } elsif ($c eq ',') {
                $token = VM::Assembler::Tokens->Comma; shift @chars;
            } elsif ($c eq '=') {
                $token = VM::Assembler::Tokens->Assign; shift @chars;
            } elsif ($c eq '(') {
                $token = VM::Assembler::Tokens->StartList; shift @chars;
            } elsif ($c eq ')') {
                $token = VM::Assembler::Tokens->EndList; shift @chars;
            } elsif ($c =~ /^[0-9]$/) {
                $token = $self->tokenize_number( \@chars );
            } elsif ($c eq '.') {
                $token = $self->tokenize_label( \@chars );
            } elsif ($c eq '^') {
                $token = $self->tokenize_tag( \@chars );
            } elsif ($c eq '/') {
                $token = $self->tokenize_namespace( \@chars );
            } elsif ($c eq '&') {
                $token = $self->tokenize_address( \@chars );
            } elsif ($c eq '%') {
                $token = $self->tokenize_signal( \@chars );
            } elsif ($c eq '$') {
                $token = $self->tokenize_variable( \@chars );
            } elsif ($c =~ /^[A-Z]$/) {
                $token = $self->tokenize_opcode( \@chars );
            } elsif ($c =~ /^#$/) {
                $token = $self->tokenize_comment( \@chars );
            } elsif ($c =~ /^\@$/) {
                $token = $self->tokenize_directive( \@chars );
            } elsif ($c =~ /^[ifcs]$/ && $chars[1] eq '(') {
                $token = $self->tokenize_literal( \@chars );
            } elsif ($c eq ':') {
                if ($chars[1] eq ':') {
                    $token = $self->tokenize_syscall( \@chars );
                } else {
                    $token = $self->tokenize_structure( \@chars );
                }
            } else {
                confess "Unknown start char: $c";
            }

            LOG("Got Token: $token") if DEBUG;

            push @tokens => $token;
        }

        return @tokens, VM::Assembler::Tokens->EOL;
    }

    method tokenize_literal ( $chars ) {
        LOG("Tokenizing literal") if DEBUG;

        my $value = shift @$chars;
        while (@$chars && $chars->[0] ne ')') {
            $value .= shift @$chars;
        }
        $value .= shift @$chars; # discard closing paren

        return VM::Assembler::Tokens->Literal( $value );
    }

    method tokenize_number ( $chars ) {
        LOG("Tokenizing number") if DEBUG;
        my $number = '';
        while (@$chars && $chars->[0] =~ /^[0-9]$/) {
            $number .= shift @$chars;
        }
        return VM::Assembler::Tokens->Number( $number );
    }

    method tokenize_syscall ( $chars ) {
        LOG("Tokenizing syscall") if DEBUG;
        my $syscall = (shift @$chars) . (shift @$chars) ;
        while (@$chars && $chars->[0] =~ /^[A-Za-z0-9_]$/) {
            $syscall .= shift @$chars;
        }
        return VM::Assembler::Tokens->SysCall( $syscall );
    }

    method tokenize_structure ( $chars ) {
        LOG("Tokenizing structure") if DEBUG;
        my $structure = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[a-z_]$/) {
            $structure .= shift @$chars;
        }
        return VM::Assembler::Tokens->Structure( $structure );
    }

    method tokenize_directive ( $chars ) {
        LOG("Tokenizing directive") if DEBUG;
        my $directive = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[a-z_]$/) {
            $directive .= shift @$chars;
        }
        return VM::Assembler::Tokens->Directive( $directive );
    }

    method tokenize_variable ( $chars ) {
        LOG("Tokenizing variable") if DEBUG;
        my $variable = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[A-Za-z0-9_]$/) {
            $variable .= shift @$chars;
        }
        return VM::Assembler::Tokens->Variable( $variable );
    }

    method tokenize_label ( $chars ) {
        LOG("Tokenizing label") if DEBUG;
        my $label = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[A-Za-z0-9._]$/) {
            $label .= shift @$chars;
        }
        return VM::Assembler::Tokens->Label( $label );
    }

    method tokenize_tag ( $chars ) {
        LOG("Tokenizing tag") if DEBUG;
        my $tag = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[A-Za-z._\/]$/) {
            $tag .= shift @$chars;
        }
        return VM::Assembler::Tokens->Tag( $tag );
    }

    method tokenize_signal ( $chars ) {
        LOG("Tokenizing signal") if DEBUG;
        my $signal = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[A-Z_]$/) {
            $signal .= shift @$chars;
        }
        return VM::Assembler::Tokens->Signal( $signal );
    }

    method tokenize_namespace ( $chars ) {
        LOG("Tokenizing namespace") if DEBUG;
        my $namespace = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[A-Za-z-\/]$/) {
            $namespace .= shift @$chars;
        }
        return VM::Assembler::Tokens->Namespace( $namespace );
    }

    method tokenize_address ( $chars ) {
        LOG("Tokenizing address") if DEBUG;
        my $address = shift @$chars;
        while (@$chars && $chars->[0] =~ /^[A-Za-z0-9._]$/) {
            $address .= shift @$chars;
        }
        return VM::Assembler::Tokens->Address( $address );
    }

    method tokenize_opcode ( $chars ) {
        LOG("Tokenizing opcode") if DEBUG;
        my $opcode = '';
        while (@$chars && $chars->[0] =~ /^[A-Z_]$/) {
            $opcode .= shift @$chars;
        }
        return VM::Assembler::Tokens->Opcode( $opcode );
    }

    method tokenize_comment ( $chars ) {
        LOG("Tokenizing comment") if DEBUG;
        my $comment = join '' => @$chars;
        @$chars = ();
        return VM::Assembler::Tokens->Comment( $comment );
    }

}

