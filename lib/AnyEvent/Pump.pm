package AnyEvent::Pump;
use strict;
use warnings;

use Scalar::Util qw(refaddr);
use Guard;

use Sub::Exporter -setup => {
    exports => ['pump'],
};

sub pump($$;&){
    my ($from, $to, $filter) = @_;
    my $from_is_ah = $from->isa('AnyEvent::Handle');
    $filter ||= sub { $_[0] }; # identity function

    my $pusher; $pusher = sub {
        my $_from = shift;
        my $data = $from_is_ah ? delete $_from->{rbuf} : $_from->consume;
        return 0 unless defined $data;

        my $filtered = $filter->($data);
        return 0 unless defined $filtered;

        $to->push_write($filtered);
        $_from->push_read($pusher);
        return 1;
    };
    $from->push_read($pusher);

    return guard {
        if($from_is_ah){
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
