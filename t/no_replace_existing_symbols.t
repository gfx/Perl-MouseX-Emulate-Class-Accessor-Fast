{
  package SomeClass;
  #use base qw/Class::Accessor::Fast/;
  use Moose;
  with 'MooseX::Emulate::Class::Accessor::Fast';
  
  sub anaccessor { 'wibble' }

  #sub new { bless {}, 'SomeClass' }
}
{
  package SubClass;
  use base qw/SomeClass/;

  sub anotherone { 'flibble' }
  __PACKAGE__->mk_accessors(qw/ anaccessor anotherone /);
}

use Test::More tests => 6;

# 1, 2
my $someclass = SomeClass->new;
is $someclass->anaccessor, 'wibble';
$someclass->anaccessor('fnord');
is $someclass->anaccessor, 'wibble';

# 3-6
my $subclass = SubClass->new;
is $subclass->anaccessor, 'wibble';
$subclass->anaccessor('fnord');
is $subclass->anaccessor, 'wibble';
is $subclass->anotherone, 'flibble';
$subclass->anotherone('fnord');
is $subclass->anotherone, 'flibble';
