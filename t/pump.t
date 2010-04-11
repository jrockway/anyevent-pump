use strict;
use warnings;
use Test::More;

use AnyEvent::Pump qw(pump);
use AnyEvent::Util qw(portable_pipe);
use AnyEvent::Handle;

my ($r1, $w1) = portable_pipe;
my ($r2, $w2) = portable_pipe;

my $from = AnyEvent::Handle->new(
    fh => $r1,
);

my $to = AnyEvent::Handle->new(
    fh => $w2,
);

my $in = AnyEvent::Handle->new(
    fh => $w1,
);

my $out = AnyEvent::Handle->new(
    fh => $r2,
);

my $done = AnyEvent->condvar;

$out->push_read( line => sub { $done->($_[1]) } );
$in->push_write('hello');
$in->push_write(' ');

pump $from, $to;

$in->push_write('world');
$in->push_write("\n");

is $done->recv, 'hello world', 'pumped those pipes';

done_testing;
