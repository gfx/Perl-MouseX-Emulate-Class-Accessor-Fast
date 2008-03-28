#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'MooseX-Emulate-Class-Accessor-Fast';
abstract 'Emnulate Class::Accessor::Fast using attributes';
all_from 'lib/MooseX/Emulate/Class/Accessor/Fast.pm';

# Specific dependencies
requires 'Moose';

build_requires 'Test::More' => 0;

WriteAll;
