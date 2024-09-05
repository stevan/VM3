
use v5.40;
use experimental qw[ class ];

class VM::Debugger::CPUContext {

    method dump ($cpu, $ctx) {
        state $width = 80;

        my $pc     = $ctx->pc;
        my @frames = $ctx->frames;
        my @stack  = $ctx->stack;

        my $indent = '  ' x (scalar @frames);

        say $indent,"╭─".('─' x $width);
        say $indent,sprintf "│ ci = %s" => $cpu->ci;
        say $indent,sprintf '│ pc = %04d' => $pc;
        say $indent,        '│';
        say $indent,        '├─ frames ',('─' x 66);
        if (@frames) {
            say $indent,'│ ',join "\n${indent}│ " => map "  ${_}", @frames;
        }
        say $indent,        '├─ stack ',('─' x 67);
        if (@stack) {
            if (@frames) {
                my $idx = 0;
                foreach my $frame (@frames) {
                    my $arg_top = $idx + $frame->argc;
                    #warn "idx: $idx arg_top: $arg_top\n";
                    say $indent,'│ ',join "\n${indent}│ " => map "  ${_}", @stack[ $idx .. ($arg_top - 1) ];
                    say $indent,sprintf "│ >> call(%s)" => $frame->address;
                    $idx = $arg_top;
                }
                #warn "ended idx: $idx sp: $sp\n";
                if ($idx <= $#stack) {
                    say $indent,'│ ',join "\n${indent}│ " => map "  ${_}", @stack[ $idx .. $#stack ];
                }
            } else {
                say $indent,'│ ',join "\n${indent}│ " => map "  ${_}", @stack;
            }
        }
        say $indent,"╰─".('─' x $width);
    }
}
