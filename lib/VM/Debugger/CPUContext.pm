
use v5.40;
use experimental qw[ class ];

class VM::Debugger::CPUContext {

    method dump ($cpu, $ctx) {
        state $width = 54;

        my $pc     = $ctx->pc;
        my @frames = $ctx->frames;
        my @stack  = $ctx->stack;

        say "╭─".('─' x $width);
        say sprintf "│ ci = %s" => $cpu->ci;
        say sprintf '│ pc = %04d' => $pc;
        say         '│';
        say         '├─ frames ',('─' x 46);
        if (@frames) {
            say '│ ',join "\n│ " => map "  ${_}", @frames;
        }
        say         '├─ stack ',('─' x 47);
        if (@stack) {
            if (@frames) {
                my $idx = 0;
                foreach my $frame (@frames) {
                    my $arg_top = $idx + $frame->argc;
                    #warn "idx: $idx arg_top: $arg_top\n";
                    say '│ ',join "\n│ " => map "  ${_}", @stack[ $idx .. ($arg_top - 1) ];
                    say sprintf '│ >> call(%s)' => $frame->address;
                    $idx = $arg_top;
                }
                #warn "ended idx: $idx sp: $sp\n";
                if ($idx <= $#stack) {
                    say '│ ',join "\n│ " => map "  ${_}", @stack[ $idx .. $#stack ];
                }
            } else {
                say '│ ',join "\n│ " => map "  ${_}", @stack;
            }
        }
        say "╰─".('─' x $width);
    }
}
