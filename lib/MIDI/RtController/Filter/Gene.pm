package MIDI::RtController::Filter::Gene;

# ABSTRACT: Frobnicate Universes

our $VERSION = '0.0100';

use strict;
use warnings;

=head1 NAME

MIDI::RtController::Filter::Gene - Frobnicate Universes

=head1 SYNOPSIS

  use MIDI::RtController::Filter::Gene ();

  $foo = MIDI::RtController::Filter::Gene::foo();

=head1 DESCRIPTION

C<MIDI::RtController::Filter::Gene> frobnicates universes.

=cut

=head1 FUNCTIONS

=head2 foo

  $foo = MIDI::RtController::Filter::Gene::foo();

Foo!

=cut

sub foo {
    my (%args) = @_;
    my $foo ||= 'bar';
    return $foo;
}

1;
__END__

=head1 SEE ALSO

L<Another::Module>

L<http://somewhere>

=cut
