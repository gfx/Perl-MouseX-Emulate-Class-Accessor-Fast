#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'MooseX-Emulate-Class-Accessor-Fast';
abstract 'Emulate Class::Accessor::Fast using attributes';
all_from 'lib/MooseX/Emulate/Class/Accessor/Fast.pm';

# Specific dependencies
requires 'Moose' => '0.31';
requires 'namespace::clean' => 0;
build_requires 'Test::More' => 0;

WriteAll;
