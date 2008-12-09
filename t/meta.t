use strict;
use warnings;
use Test::More tests => 12;
use MooseX::Adopt::Class::Accessor::Fast;
{
  package TestPackage;
  use Moose;
  with 'MooseX::Emulate::Class::Accessor::Fast';
  __PACKAGE__->mk_accessors(qw/ normal /);
  __PACKAGE__->meta->make_immutable;
}
{
  package TestPackage::SubClass::Accessors;
  use base qw/TestPackage/;
  __PACKAGE__->mk_accessors(qw/ meta /);
}
{
  package TestPackage::SubClass::Readonly;
  use base qw/TestPackage/;
  __PACKAGE__->mk_ro_accessors(qw/ meta /);
}
{
  package TestPackage::SubClass::Writeonly;
  use base qw/TestPackage/;
  __PACKAGE__->mk_wo_accessors(qw(sekret double_sekret));
}

# This setup is a _specific_ example from Catalyst.

# CAF _will not_ replace a pre-existing symbol, but there never
# used to be a 'meta' symbol before CAF things are ported to Moose

# Therefore, 'meta' needs to be treated as a special case, as
# code which is _not_ using the symbol already should be allowed to
# say $self->meta, and get all the Moose goodness, but code which
# makes an accessor called ->meta should still work!

# 22:22 <@groditi> the difference is meta wasnt there as a method before, but MooseX::Adopt::CAF does have a meta method.
# 22:23 <@groditi> i guess i could namespace::clean it out. but it might create confusion
# 22:23  * t0m nod - I think we need a special case for this..
# 22:23 <@groditi> mst: thoughts?
# 22:23 <@mst> Moose needs to not export 'meta' if you don't want it
# 22:24 <@groditi> so namespace::clean it out or what?
# 22:25 <@mst> hmm
# 22:25 <@mst> does ->mk_accessors(qw(meta)) work if you do "use base qw(...)" instead of use Moose ?
# 22:26 <@mst> if it doesn't, then it isn't a bug in CAF
# 22:27 <@groditi> its my bug. because Adopt does use Moose because Emulate is a role
# 22:27 <@groditi> so if you isa CAF then you definitely can(meta)
# 22:27 <@t0m> I think that if the user makes an accessor called 'meta', we need to remove the Moose package symbol, and 
#              immutable the class so the the accessor / constructor doesn't touch meta..
# 22:27 <@t0m> and generate a warning.
# 22:28 <@t0m> which is ugly as, but kinda works.
# 22:29 <@groditi> ok ok. i'll do has_method
# 22:29 <@t0m> as you want users who aren't shitting on the moose symbol to be able to call $self->meta as they 'Moosify'
# 22:29 <@groditi> this sucks though because Emulate counts on meta being there
# 22:30 <@groditi> ok well this requires major major changes so delayed until i finish finals

# Suggested fix - something less hacky than:
#Index: lib/MooseX/Emulate/Class/Accessor/Fast.pm
#===================================================================
#--- lib/MooseX/Emulate/Class/Accessor/Fast.pm   (revision 7035)
#+++ lib/MooseX/Emulate/Class/Accessor/Fast.pm   (working copy)
#@@ -93,14 +93,15 @@
# 
# sub mk_accessors{
#   my $self = shift;
#-  my $meta = $self->meta;
#+  my $meta = $self->Moose::Object::meta;
#+  $meta->make_mutable if $meta->is_immutable;
#   for my $attr_name (@_){
#     my $reader = $self->accessor_name_for($attr_name);
#     my $writer = $self->mutator_name_for( $attr_name);
# 
#     #dont overwrite existing methods
#     if($reader eq $writer){
#-      my %opts = ( $self->can($reader) ? () : (accessor => $reader) );
#+      my %opts = ( $self->can($reader) && $reader ne 'meta' ? () : (accessor => $reader) );
#       my $attr = $meta->add_attribute($attr_name, %opts);
#       if($attr_name eq $reader){
#         my $alias = "_${attr_name}_accessor";
#@@ -115,6 +116,7 @@
#       $meta->add_attribute($attr_name, @opts);
#     }
#   }
#+  $meta->make_immutable;
# }

{
  my $i = TestPackage::SubClass::Accessors->new({ normal => 42, meta => 66 });

  # 1,2
  is $i->normal, 42, 'normal accessor read value from constructor';
  $i->normal(2);
  is $i->normal, 2, 'normal accessor read set value';

  TODO: {
    local $TODO = 'meta method needs special case';

    # 3,4
    is $i->meta, 66, 'meta accessor read value from constructor';
    $i->meta(9);
    is $i->meta, 9, 'meta accessor read set value';
  }
}
{
  my $i = TestPackage::SubClass::Readonly->new({ normal => 42, meta => 66 });

  # 5,6
  is $i->normal, 42, 'normal accessor read value from constructor';
  $i->{normal} = 2;
  is $i->normal, 2, 'normal accessor read set value';

  TODO: {
    local $TODO = 'meta method needs special case';
    
    # 7,8
    is $i->meta, 66, 'meta accessor read value from constructor';
    $i->{meta} = 9;
    is $i->meta, 9, 'meta accessor read set value';
  }
}
{
  my $i = TestPackage::SubClass::Writeonly->new({ normal => 42, meta => 66 });

  # 9,10
  is $i->normal, 42, 'normal accessor read value from constructor';
  $i->normal(2);
  is $i->normal, 2, 'normal accessor read set value';

  TODO: {
    local $TODO = 'meta method needs special case';

    # 11,12
    is $i->{meta}, 66, 'meta accessor read value from constructor';
    $i->meta(9);
    is $i->{meta}, 9, 'meta accessor read set value';
  }
}
