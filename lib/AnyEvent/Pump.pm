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
        if($from->isa('AnyEvent::Handle')){
            $from->{_queue} = [
                grep { refaddr $_ != refaddr $pusher } @{$from->{_queue} || []}
            ];
        }
        elsif($from->can('kill_reader')){
            $from->kill_reader($pusher);
        }
        else {
            warn "Can't properly destroy $from: don't know how to shift watchers.";
        }
    } if defined wantarray;

    return;
}

1;
