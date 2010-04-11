use inc::Module::Install;
use strict;

name 'AnyEvent-Pump';
all_from 'lib/AnyEvent/Pump.pm';

requires 'Sub::Exporter';
requires 'Guard';
requires 'Scalar::Util';

test_requires 'AnyEvent'; # not required to run the module
test_requires 'Test::More';

WriteAll;
