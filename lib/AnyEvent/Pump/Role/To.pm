use MooseX::Declare;

role AnyEvent::Pump::Role::To {
    requires 'push_write';
}
