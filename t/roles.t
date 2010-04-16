use strict;
use warnings;

use Test::More;
use AnyEvent::Pump qw(pump);

my @in = qw(t h i s i s a t e s t);
my @out = ();

{ package From;
  use Moose;
  with 'AnyEvent::Pump::Role::From';
  sub consume { shift @in }
  sub push_read { $_[1]->( $_[0] ) }
  sub kill_reader { @in = ('done') }
}

{ package To;
  use Moose;
  with 'AnyEvent::Pump::Role::To';
  sub push_write { push @out, $_[1] }
}

my $pump = pump(From->new, To->new);

is_deeply \@in, [], 'in was consumed';
is_deeply \@out, [qw(t h i s i s a t e s t)], 'in copied to out';

undef $pump;

is $in[0], 'done', 'readers were killed';

done_testing;
