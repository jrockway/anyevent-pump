use MooseX::Declare;

role AnyEvent::Pump::Role::From {
    requires 'push_read';
    requires 'consume';
    requires 'kill_reader';
}
