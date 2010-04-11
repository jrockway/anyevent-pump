package AnyEvent::Pump;
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => ['pump'],
};

sub pump($$){
    my ($from, $to) = @_;
    my $pusher; $pusher = sub {
        my $h = shift;
        my $data = delete $h->{rbuf};
        $to->push_write($data) if $data;
        $h->push_read($pusher);
        return 0;
    };
    $from->push_read($pusher);
    return 1;
}

1;
