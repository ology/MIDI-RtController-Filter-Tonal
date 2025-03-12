package MIDI::RtController::Filter::Gene;

# ABSTRACT: Gene's RtController filters

use v5.36;

our $VERSION = '0.0100';

use Moo;
use strictures 2;
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::RtController ();
  use MIDI::RtController::Filter::Gene ();

  my $rtc = MIDI::RtController->new; # * input/output required

  my $filter = MIDI::RtController::Filter::Gene->new(rtc => $rtc);

  $rtc->add_filter('foo', note_on => $filter->can('foo'));

  $rtc->run;

=head1 DESCRIPTION

C<MIDI::RtController::Filter::Gene> is the collection of Gene's
L<MIDI::RtController> filters.

=cut

=head1 ATTRIBUTES

=head2 rtc

  $rtc = $filter->rtc;

The required L<MIDI::RtController> instance provided in the
constructor.

=cut

has rtc => (
    is  => 'ro',
    isa => sub { die 'Invalid rtc' unless ref($_[0]) eq 'MIDI::RtController' },
    required => 1,
);

=head2 pedal

  $pedal = $filter->pedal;
  $filter->pedal($note);

The B<note> used by the pedal-tone filter.

=cut

has pedal => (
    is  => 'rw',
    isa => sub { die 'Invalid pedal' unless $_[0] =~ /^\d+$/ },
    default => sub { 55 },
);

=head2 channel

  $channel = $filter->channel;
  $filter->channel($number);

The current MIDI channel (0-15, drums=9).

=cut

has channel => (
    is  => 'rw',
    isa => sub { die 'Invalid channel' unless $_[0] =~ /^\d+$/ && $_[0] < 16 },
    default => sub { 0 },
);

=head2 delay

  $delay = $filter->delay;
  $filter->delay($number);

The current delay time in seconds.

=cut

has delay => (
    is  => 'rw',
    isa => sub { die 'Invalid delay' unless $_[0] =~ /^[\d.]+$/ },
    default => sub { 0 },
);

=head1 METHODS

All filter methods must accept the object, a delta-time, and a MIDI
event ARRAY reference, like:

  sub pedal_tone ($self, $dt, $event) {
    my ($event_type, $chan, $note, $value) = $event->@*;
    ...
    return $boolean;
  }

A filter also must return a boolean value. This tells
L<MIDI::RtController> to continue processing other known filters or
not.

=head2 pedal_tone

  PEDAL, $note, $note + 7

Where C<PEDAL> is a constant (C<55>) for G below middle-C.

=cut

sub _pedal_notes ($self, $note) {
    return $self->pedal, $note, $note + 7;
}
sub pedal_tone ($self, $dt, $event) {
    my ($ev, $chan, $note, $vel) = $event->@*;
    my @notes = $self->_pedal_notes($note);
    my $delay_time = 0;
    for my $n (@notes) {
        $delay_time += $self->delay;
        $self->rtc->delay_send($delay_time, [ $ev, $self->channel, $n, $vel ]);
    }
    return 0;
}

1;
__END__

=head1 SEE ALSO

L<Moo>

=cut
