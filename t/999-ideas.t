#!perl

use v5.40;
use experimental qw[ class builtin ];

use importer 'Data::Dumper' => qw[ Dumper ];
use importer 'Carp'         => qw[ confess ];
use importer 'List::Util'   => qw[ first all ];

use Test::More;
use Test::Differences;

use VM::Assembly::SimpleOpcodeBuilder;

class VM::Memory::Pointer {
    field $id     :param :reader;
    field $size   :param :reader;
    field $offset :param :reader;
    field $page   :param;

    field $freed :reader = false;

    field $i :reader(idx) = 0;

    my sub check_i ($i, $size) {
        ($i <= $size) || die "BUFFER OVERFLOW: i = $i size = $size";
        ($i >= 0)     || die "BUFFER UNDERFLOW: i = $i size = $size";
    }

    method at ($idx) { $i = $idx; check_i($i, $size); $self }
    method inc       { $i++;      check_i($i, $size); $self }
    method dec       { $i--;      check_i($i, $size); $self }

    method get      { $page->get_cell($offset + $i)     }
    method set ($v) { $page->set_cell($offset + $i, $v) }

    method can_inc { $i < $size }
    method can_dec { $i >     0 }

    method free { $freed = true }

    method copy {
        __CLASS__->new(
            id     => $id,
            size   => $size,
            offset => $offset,
            page   => $page,
        )
    }
}

class VM::Memory::Page {
    field $id   :param :reader;
    field $size :param :reader;
    field $page :param :reader;

    field @allocated :reader;
    field @freed     :reader;
    field $free_ptr  :reader = 0;

    my $PTR_ID_SEQ = 0;

    method all_cells         { @$page           }
    method get_cell ($i)     { $page->[$i]      }
    method set_cell ($i, $v) { $page->[$i] = $v }

    method allocate ($size) {
        my $ptr = VM::Memory::Pointer->new(
            id     => $PTR_ID_SEQ++,
            size   => $size,
            offset => $free_ptr,
            page   => $self,
        );
        push @allocated => $ptr;
        $free_ptr += $size;
        return $ptr;
    }

    method free ($ptr) {
        my $start = $ptr->offset;
        my $size  = $ptr->size;
        my $end   = $start + ($size - 1);

        foreach my $i ($start .. $end) {
            $self->set_cell($i, null());
        }

        $ptr->free;

        @allocated = grep !$_->freed, @allocated;
        push @freed => $ptr;
    }

    method reclaim {
        #warn "BEFORE ".(scalar @freed);

        my @sorted = sort { $b->offset <=> $a->offset } @freed;
        @freed = ();


        my @reclaimed;
        while (@sorted) {
            my $ptr = shift @sorted;
            my $end = $ptr->offset + ($ptr->size - 1);
            if ($end == ($free_ptr - 1)) {
                $free_ptr = $ptr->offset;
                push @reclaimed => $ptr;
            } else {
                push @freed => $ptr;
            }
        }

        #warn "AFTER ".(scalar @freed);
    }
}

class VM::Memory {

    field $used = 0;
    field @pages :reader;

    my $PAGE_ID_SEQ = 0;

    method total_used { $used }
    method page_count { scalar @pages }

    method allocate_page ($size) {
        my @block = (null()) x $size;
        $used += $size;
        my $page = VM::Memory::Page->new(
            id   => $PAGE_ID_SEQ++,
            size => $size,
            page => \@block
        );
        push @pages => $page;
        return $page;
    }
}

class VM::Debugger::MemoryView {
    field $width  :param :reader = 80;
    field $memory :param :reader;

    method draw {
        say '+=',('=' x $width),'=+';
        say '| ',(sprintf "%-${width}s" => sprintf "RAM page-count: %04d total-used: %04d" => $memory->page_count, $memory->total_used),' |';
        say '+=',('=' x $width),'=+';
        foreach my $page ($memory->pages) {
            say '+-',('-' x $width),'-+';
            say '| ',(sprintf "%-${width}s" => sprintf "PAGE id: %04d size: %04d free-ptr: %04d" => $page->id, $page->size, $page->free_ptr),' |';
            say '+-',('-' x $width),'-+';
            foreach my $pointer (sort { $a->id <=> $b->id } ($page->freed, $page->allocated)) {
                my $type = $pointer->freed ? 'FREED' : 'POINTER';
                say '| ',(sprintf "%-${width}s" => sprintf "$type id: %04d offset: %04d size: %04d" => $pointer->id, $pointer->offset, $pointer->size),' |';
                say '|.',('.' x $width),'.|';
                my $p = $pointer->copy;
                while ($p->can_inc) {
                    say '| ',(sprintf "%-${width}s" => (sprintf '%04d : %s' => ($p->idx + $p->offset), $p->get)),' |';
                    $p->inc;
                }
                say '|.',('.' x $width),'.|';
            }
            foreach my $i ($page->free_ptr .. ($page->size - 1)) {
                say '| ',(sprintf "%-${width}s" => (sprintf '%04d : %s' => $i, $page->get_cell($i))),' |';
            }
            say '+-',('-' x $width),'-+';
        }
        say '+=',('=' x $width),'=+';
        say "\n";
    }
}



my $mem = VM::Memory->new;
my $dbg = VM::Debugger::MemoryView->new( memory => $mem );
$dbg->draw;

my $page = $mem->allocate_page(10);
$dbg->draw;

my $ptr = $page->allocate(6);
$dbg->draw;

my $ptr2 = $page->allocate(2);
$dbg->draw;

$ptr->set(i32(10));
$ptr->inc->set(i32(20));
$ptr->inc->set(i32(30));
$ptr->inc->inc->set(i32(50));
$ptr->dec->set(i32(40));
$ptr->inc->inc->set(i32(60));
$ptr2->set(i32(1));
$ptr2->inc->set(i32(2));
$dbg->draw;


$page->free($ptr);
$dbg->draw;

$page->reclaim;
$dbg->draw;

$page->free($ptr2);
$dbg->draw;

$page->reclaim;
$dbg->draw;

done_testing;


