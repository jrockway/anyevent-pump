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

my $result = AnyEvent->condvar;
my $done = AnyEvent->condvar;

pump $from, $to, sub {
    my $char = shift;
    if($char =~ /X/){
        $done->send(1);
        return;
    }
    return $char;
};

$out->push_read( line => sub { $result->send($_[1]) } );
$in->push_write('hello');
delay(); # force the event loop to run
$in->push_write('X');
delay();
$in->push_write(" world\n");

ok $done->recv, 'got X';
is $result->recv, 'hello world', 'no X made it through';

done_testing;

sub delay {
    my $cv = AnyEvent->condvar;
    my $t; $t = AnyEvent->timer( after => 0.1, cb => sub { undef $t; $cv->send } );
    $cv->recv;
}
