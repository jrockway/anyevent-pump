package AnyEvent::Pump;
use strict;
use warnings;

use Scalar::Util qw(refaddr);
use Guard;

use Sub::Exporter -setup => {
    exports => ['pump'],
};

sub pump($$){
    my ($from, $to) = @_;
    my $pusher; $pusher = sub {
        my $h = shift;
        my $data = delete $h->{rbuf};
        return 0 unless $data;

        $to->push_write($data);
        $from->push_read($pusher);
        return 1;
    };
    $from->push_read($pusher);

    return guard {
        # remove this pusher from the queue.
        $from->{_queue} = [
            grep { refaddr $pusher != refaddr $_ } @{$from->{_queue} || []}
        ];
    } if defined wantarray;

    return;
}

1;
