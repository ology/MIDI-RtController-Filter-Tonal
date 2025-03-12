package MIDI::RtController::Filter::Gene;

# ABSTRACT: Gene's RtController filters

use v5.36;

our $VERSION = '0.0100';

use strict;
use warnings;

=head1 NAME

MIDI::RtController::Filter::Gene - Frobnicate Universes

=head1 SYNOPSIS

  use MIDI::RtController::Filter::Gene qw(:all);
  # or
  use MIDI::RtController::Filter::Gene qw(pedal_tone etc);

=head1 DESCRIPTION

C<MIDI::RtController::Filter::Gene> is the collection of Gene's
L<MIDI::RtController> filters.

=cut

=head1 FUNCTIONS

All filter routines accept a delta-time and a MIDI event ARRAY
reference, like:

  sub pedal_tone ($dt, $event) {
    my ($event_type, $chan, $note, $value) = $event->@*;
    ...
    return $boolean;
  }

A filter also must return a boolean value. This tells
L<MIDI::RtController> to continue processing other known filters or
not.

To add a filter for L<MIDI::RtController> to use, do this:

  my $rtc = MIDI::RtController->new(...);

  $rtc->add_filter('name', \@event_types => \&filter);

Where the B<event_types> are things like C<note_on>,
C<control_change>, etc. This can also be the special type C<all>,
which tells L<MIDI::RtController> to process any event. The default is
the list: C<[note_on, note_off]>.

=head2 pedal_tone

  PEDAL, $note, $note + 7

=cut

sub _pedal_notes ($note) {
    return PEDAL, $note, $note + 7;
}
sub pedal_tone ($dt, $event) {
    my ($ev, $chan, $note, $vel) = $event->@*;
    my @notes = _pedal_notes($note);
    my $delay_time = 0;
    for my $n (@notes) {
        $delay_time += $delay;
        $rtc->delay_send($delay_time, [ $ev, $channel, $n, $vel ]);
    }
    return 0;
}

1;
__END__

=head1 SEE ALSO

L<Another::Module>

L<http://somewhere>

=cut
