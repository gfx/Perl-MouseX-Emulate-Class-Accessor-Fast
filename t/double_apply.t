#!perl
use strict;
use warnings;
use Test::More tests => 5;
use Test::Exception;

# 1
use_ok('MooseX::Adopt::Class::Accessor::Fast');
{
  package My::Package;
  use base qw/Class::Accessor::Fast/;
  for (0..1) {
    __PACKAGE__->mk_accessors(qw( foo ));
    __PACKAGE__->mk_ro_accessors(qw( bar ));
    __PACKAGE__->mk_wo_accessors(qw( baz ));
  }
}

my $i = bless { bar => 'bar' }, 'My::Package';

# 2
lives_ok {
  $i->foo('foo');
  $i->baz('baz');

  # 3-5
  is($i->foo, 'foo');
  is($i->bar, 'bar');
  is($i->{baz}, 'baz');
} 'No exception';

