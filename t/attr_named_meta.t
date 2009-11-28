#!/usr/bin/perl -w

use strict;
use warnings;
use Mouse::Meta::Class ();
use Test::More skip_all => 'TODO'; #
use MouseX::Adopt::Class::Accessor::Fast;

{
  package TestPackage;
  use base 'Class::Accessor::Fast';
  __PACKAGE__->mk_accessors(qw/ meta /);
}

my $i = TestPackage->new( meta => 66 );

is $i->meta, 66, 'meta accessor read value from constructor';
$i->meta(9);
is $i->meta, 9, 'meta accessor read set value';

my $meta = Mouse::Meta::get_metaclass_for('TestPackage');
$meta->make_immutable;

is $i->meta, 9, 'meta accessor read value from constructor';
$i->meta(66);
is $i->meta, 66, 'meta accessor read set value';


__END__;

