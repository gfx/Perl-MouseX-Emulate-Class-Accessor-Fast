#!perl
use strict;
use lib 't/lib';
use Test::More tests => 6;

#1,2
require_ok("MooseX::Adopt::Class::Accessor::Fast");
use_ok('TestAdoptCAF');

#3-6
ok(TestAdoptCAF->can('meta'), 'Adopt seems to work');
ok(TestAdoptCAF->meta->find_attribute_by_name($_), "attribute $_ created")
  for qw(foo bar baz);
