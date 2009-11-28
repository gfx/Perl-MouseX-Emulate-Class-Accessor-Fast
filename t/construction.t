#!perl
use strict;
use Test::More tests => 9;

#1
require_ok("MouseX::Emulate::Class::Accessor::Fast");

{
  package MyClass;
  use Mouse;
  with 'MouseX::Emulate::Class::Accessor::Fast';
}

{
  package MyClass::MouseChild;
  use Mouse;
  extends 'MyClass';
}

{
  package MyClass::ImmutableMouseChild;
  use Mouse;
  extends 'MyClass';
  __PACKAGE__->meta->make_immutable(allow_mutable_ancestors => 1);
}

{
  package MyClass::TraditionalChild;
  use base qw(MyClass);
}

{
  package MyImmutableClass;
  use Mouse;
  with 'MouseX::Emulate::Class::Accessor::Fast';
  __PACKAGE__->meta->make_immutable;
}

{
  package MyImmutableClass::MouseChild;
  use Mouse;
  extends 'MyImmutableClass';
}

{
  package MyImmutableClass::ImmutableMouseChild;
  use Mouse;
  extends 'MyImmutableClass';
  __PACKAGE__->meta->make_immutable;
}

{
  package MyImmutableClass::TraditionalChild;
  use base qw(MyImmutableClass);
}

# 2-9
foreach my $class (qw/
                      MyClass 
                      MyImmutableClass 
                      MyClass::MouseChild 
                      MyClass::ImmutableMouseChild  
                      MyClass::TraditionalChild 
                      MyImmutableClass::MouseChild 
                      MyImmutableClass::ImmutableMouseChild 
                      MyImmutableClass::TraditionalChild
                                                           /) {
    my $instance = $class->new(foo => 'bar');
    is($instance->{foo}, 'bar', $class . " has CAF construction behavior");
}

