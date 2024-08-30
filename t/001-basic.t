#!perl

use v5.40;
use experimental qw[ class ];

use VM;

my $vm = VM->new;

$vm->run;
