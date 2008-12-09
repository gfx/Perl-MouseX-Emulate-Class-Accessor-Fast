package MooseX::Emulate::Class::Accessor::Fast;

use Moose::Role;

our $VERSION = '0.00500';

=head1 NAME

MooseX::Emulate::Class::Accessor::Fast -
  Emulate Class::Accessor::Fast behavior using Moose attributes

=head1 SYNOPSYS

    package MyClass;
    use Moose;

    with 'MooseX::Emulate::Class::Accessor::Fast';


    #fields with readers and writers
    __PACKAGE__->mk_accessors(qw/field1 field2/);
    #fields with readers only
    __PACKAGE__->mk_accessors(qw/field3 field4/);
    #fields with writers only
    __PACKAGE__->mk_accessors(qw/field5 field6/);


=head1 DESCRIPTION

This module attempts to emulate the behavior of L<Class::Accessor::Fast> as
accurately as possible using the Moose attribute system. The public API of
C<Class::Accessor::Fast> is wholly supported, but the private methods are not.
If you are only using the public methods (as you should) migration should be a
matter of switching your C<use base> line to a C<with> line.

While I have attempted to emulate the behavior of Class::Accessor::Fast as closely
as possible bugs may still be lurking in edge-cases.

=head1 BEHAVIOR

Simple documentation is provided here for your convenience, but for more thorough
documentation please see L<Class::Accessor::Fast> and L<Class::Accessor>.

=head2 A note about introspection

Please note that, at this time, the C<is> flag attribute is not being set. To
determine the C<reader> and C<writer> methods using introspection in later versions
of L<Class::MOP> ( > 0.38) please use the C<get_read_method> and C<get_write_method>
methods in L<Class::MOP::Attribute>. Example

    # with Class::MOP <= 0.38
    my $attr = $self->meta->find_attribute_by_name($field_name);
    my $reader_method = $attr->reader || $attr->accessor;
    my $writer_method = $attr->writer || $attr->accessor;

    # with Class::MOP > 0.38
    my $attr = $self->meta->find_attribute_by_name($field_name);
    my $reader_method = $attr->get_read_method;
    my $writer_method = $attr->get_write_method;

=head1 METHODS

=head2 BUILD $self %args

Change the default Moose class building to emulate the behavior of C::A::F and
store arguments in the instance hashref.

=cut

sub BUILD {
  my $self = shift;
  my %args;
  if (scalar @_ == 1 && defined $_[0] && ref($_[0]) eq 'HASH') {
    %args = %{$_[0]};
  } elsif( scalar(@_) ) {
    %args = @_;
  }
  my @extra = grep { !exists($self->{$_}) } keys %args;
  @{$self}{@extra} = @args{@extra};
  return $self;
}

=head2 mk_accessors @field_names

Create read-write accessors. An attribute named C<$field_name> will be created.
The name of the c<reader> and C<writer> methods will be determined by the return
value of C<accessor_name_for> and C<mutator_name_for>, which by default return the
name passed unchanged. If the accessor and mutator names are equal the C<accessor>
attribute will be passes to Moose, otherwise the C<reader> and C<writer> attributes
will be passed. Please see L<Class::MOP::Attribute> for more information.

=cut

sub mk_accessors{
  my $self = shift;
  my $meta = $self->meta;
  for my $attr_name (@_){
    my $reader = $self->accessor_name_for($attr_name);
    my $writer = $self->mutator_name_for( $attr_name);

    #dont overwrite existing methods
    if($reader eq $writer){
      my %opts = ( $self->can($reader) ? () : (accessor => $reader) );
      my $attr = $meta->add_attribute($attr_name, %opts);
      if($attr_name eq $reader){
        my $alias = "_${attr_name}_accessor";
        next if $self->can($alias);
        my @alias_method = $opts{accessor} ? ( $alias => $self->can($reader) )
          : ( $attr->process_accessors(accessor => $alias, 0 ) );
        $meta->add_method(@alias_method);
      }
    } else {
      my @opts = ( $self->can($writer) ? () : (writer => $writer) );
      push(@opts, (reader => $reader)) unless $self->can($reader);
      $meta->add_attribute($attr_name, @opts);
    }
  }
}

=head2 mk_ro_accessors @field_names

Create read-only accessors.

=cut

sub mk_ro_accessors{
  my $self = shift;
  my $meta = $self->meta;
  for my $attr_name (@_){
    my $reader = $self->accessor_name_for($attr_name);
    my @opts = ($self->can($reader) ? () : (reader => $reader) );
    my $attr = $meta->add_attribute($attr_name, @opts);
    if($reader eq $attr_name && $reader eq $self->mutator_name_for($attr_name)){
      $meta->add_method("_${attr_name}_accessor" => $attr->get_read_method_ref)
        unless $self->can("_${attr_name}_accessor");
    }
  }
}

=head2 mk_ro_accessors @field_names

Create write-only accessors.

=cut

#this is retarded.. but we need it for compatibility or whatever.
sub mk_wo_accessors{
  my $self = shift;
  my $meta = $self->meta;
  for my $attr_name (@_){
    my $writer = $self->mutator_name_for($attr_name);
    my @opts = ($self->can($writer) ? () : (writer => $writer) );
    my $attr = $meta->add_attribute($attr_name, @opts);
    if($writer eq $attr_name && $writer eq $self->accessor_name_for($attr_name)){
      $meta->add_method("_${attr_name}_accessor" => $attr->get_write_method_ref)
        unless $self->can("_${attr_name}_accessor");
    }
  }
}

=head2 follow_best_practices

Preface readers with 'get_' and writers with 'set_'.
See original L<Class::Accessor> documentation for more information.

=cut

sub follow_best_practice{
  my $self = shift;
  my $meta = $self->meta;

  $meta->remove_method('mutator_name_for');
  $meta->remove_method('accessor_name_for');
  $meta->add_method('mutator_name_for',  sub{ return "set_".$_[1] });
  $meta->add_method('accessor_name_for', sub{ return "get_".$_[1] });
}

=head2 mutator_name_for

=head2 accessor_name_for

See original L<Class::Accessor> documentation for more information.

=cut

sub mutator_name_for{  return $_[1] }
sub accessor_name_for{ return $_[1] }

=head2 set

See original L<Class::Accessor> documentation for more information.

=cut

sub set{
  my $self = shift;
  my $k = shift;
  confess "Wrong number of arguments received" unless scalar @_;

  #my $writer = $self->mutator_name_for( $k );
  confess "No such attribute  '$k'"
    unless ( my $attr = $self->meta->find_attribute_by_name($k) );
  my $writer = $attr->writer || $attr->accessor;
  $self->$writer(@_ > 1 ? [@_] : @_);
}

=head2 get

See original L<Class::Accessor> documentation for more information.

=cut

sub get{
  my $self = shift;
  confess "Wrong number of arguments received" unless scalar @_;

  my @values;
  #while( my $attr = $self->meta->find_attribute_by_name( shift(@_) ){
  for( @_ ){
    confess "No such attribute  '$_'"
      unless ( my $attr = $self->meta->find_attribute_by_name($_) );
    my $reader = $attr->reader || $attr->accessor;
    @_ > 1 ? push(@values, $self->$reader) : return $self->$reader;
  }

  return @values;
}

sub make_accessor {
  my($class, $field) = @_;
  my $meta = $class->meta;
  my $attr = $meta->find_attribute_by_name($field) || $meta->add_attribute($field); 
  my $reader = $attr->get_read_method_ref;
  my $writer = $attr->get_write_method_ref;
  return sub {
    my $self = shift;
    return $reader->($self) unless @_;
    return $writer->($self,(@_ > 1 ? [@_] : @_));
  }
}


sub make_ro_accessor {
  my($class, $field) = @_;
  my $meta = $class->meta;
  my $attr = $meta->find_attribute_by_name($field) || $meta->add_attribute($field); 
  return $attr->get_read_method_ref;
}


sub make_wo_accessor {
  my($class, $field) = @_;
  my $meta = $class->meta;
  my $attr = $meta->find_attribute_by_name($field) || $meta->add_attribute($field); 
  return $attr->get_write_method_ref;
}


1;

=head2 meta

See L<Moose::Meta::Class>.

=cut

=head1 SEE ALSO

L<Moose>, L<Moose::Meta::Attribute>, L<Class::Accessor>, L<Class::Accessor::Fast>,
L<Class::MOP::Attribute>, L<MooseX::Adopt::Class::Accessor::Fast>

=head1 AUTHORS

Guillermo Roditi (groditi) E<lt>groditi@cpan.orgE<gt>

With contributions from:

=over 4

=item Tomas Doran E<lt>bobtfish@bobtfish.netE<gt>

=back

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
