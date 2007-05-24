#!perl
use strict;
use Test::More tests => 32;

#1
require_ok("MooseX::Adopt::Class::Accessor::Fast");

my $class = "Testing::Class::Accessor::Fast";

{
  no strict 'refs';
  @{"${class}::ISA"} = ('Class::Accessor::Fast');
  *{"${class}::car"} = sub { shift->_car_accessor(@_); };
  *{"${class}::mar"} = sub { return "Overloaded"; };

  $class->mk_accessors(qw( foo bar yar car mar ));
  $class->mk_ro_accessors(qw(static unchanged));
  $class->mk_wo_accessors(qw(sekret double_sekret));
  $class->follow_best_practice;
  $class->mk_accessors(qw( best));
}

my %attrs = map{$_->name => $_} $class->meta->compute_all_applicable_attributes;

#2
is(keys %attrs, 10, 'Correct number of attributes');

#3-12
ok(exists $attrs{$_}, "Attribute ${_} created")
  for qw( foo bar yar car mar static unchanged sekret double_sekret best );

#13-21
ok($class->can("_${_}_accessor"), "Attribute ${_} created")
  for qw( foo bar yar car mar static unchanged sekret double_sekret );

#22-24
is( $attrs{$_}->accessor, $_, "Accessor ${_} created" )
  for qw( foo bar yar);

#25,26
ok( !$attrs{$_}->has_accessor, "Accessor ${_} not created" )
  for qw( car mar);

#27,28
is( $attrs{$_}->reader, $_, "Reader ${_} created")
  for qw( static unchanged );

#29,30
is( $attrs{$_}->writer, $_, "Writer ${_} created")
  for qw(sekret double_sekret);

#31,32
is( $attrs{'best'}->reader, 'get_best', "Reader get_best created");
is( $attrs{'best'}->writer, 'set_best', "Writer set_best created");
