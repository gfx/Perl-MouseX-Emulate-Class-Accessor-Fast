package MouseX::Emulate::Class::Accessor::Fast::Meta::Accessor;

use Mouse;

# It can be PP or XS
extends( Mouse::Util::MOUSE_XS ? 'Mouse::Meta::Method::Accessor::XS' : 'Mouse::Meta::Method::Accessor' );

sub _generate_accessor {
    my($method_class, $attr, $class, $type) = @_;

    my $accessor = $method_class->SUPER::_generate_accessor($attr, $class, defined $type ? $type : ());

    return $accessor if defined $type;

    return sub {
        my $self = shift;
        $accessor->($self, $_[0]) if scalar(@_) == 1;
        $accessor->($self, [@_]) if scalar(@_) > 1;
        $accessor->($self);
    };
}

sub _generate_writer {
    my($method_class, @args) = @_;

    my $writer = $method_class->SUPER::_generate_writer(@args);
    return sub {
        my $self = shift;
        $writer->($self, $_[0]) if scalar(@_) == 1;
        $writer->($self, [@_]) if scalar(@_) > 1;
    };
}

no Mouse;
1;
