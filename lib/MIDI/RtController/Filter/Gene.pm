package MIDI::RtController::Filter::Gene;

# ABSTRACT: Gene's RtController filters

use v5.36;

our $VERSION = '0.0100';

use strict;
use warnings;

=head1 NAME

MIDI::RtController::Filter::Gene - Frobnicate Universes

=head1 SYNOPSIS

  use MIDI::RtController::Filter::Gene ();

  $foo = MIDI::RtController::Filter::Gene::foo();

=head1 DESCRIPTION

C<MIDI::RtController::Filter::Gene> is the collection of Gene's
L<MIDI::RtController> filters.

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
