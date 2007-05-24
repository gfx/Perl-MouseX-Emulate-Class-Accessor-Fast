package MooseX::Adopt::Class::Accessor::Fast;

our $VERSION = 0.0001;

$INC{'Class/Accessor/Fast.pm'} = __FILE__;

package Class::Accessor::Fast;

use base qw/MooseX::Emulate::Class::Accessor::Fast/;

1;

=head1 NAME

MooseX::Adopt::Class::Accessor::Fast -
  Hijack Class::Accessor::Fast in %INC;

=head1 SYNOPSYS

    use MooseX::Adopt::Class::Accessor::Fast;
    use CAF::Using::Module;
    #that's it! JustWorks

=head1 DESCRIPTION

This module attempts to hijack L<Class::Accessor::Fast> in %INC and replace it
with L<MooseX::Emulate::Class::Accessor::Fast>. Make sure it is loaded before the
classes you have that use <Class::Accessor::Fast>. It is meant as a tool to help
you migrate your project from L<Class::Accessor::Fast>, to
 L<MooseX::Emulate::Class::Accessor::Fast> and ultimately, to L<Moose>.

=head1 SEE ALSO

L<Moose>, L<Class::Accessor::Fast>, L<MooseX::Emulate::Class::Accessor::Fast>

=head1 AUTHOR

Matt S Trout

With Contributions from:
Guillermo Roditi (groditi) <groditi@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

