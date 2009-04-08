#! /usr/bin/perl -w

# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name 'MooseX-Emulate-Class-Accessor-Fast';
all_from 'lib/MooseX/Emulate/Class/Accessor/Fast.pm';

# Specific dependencies
requires 'Moose' => '0.74';
requires 'namespace::clean' => 0;
build_requires 'Test::More' => 0;

WriteAll;
