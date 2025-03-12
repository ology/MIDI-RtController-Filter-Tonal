package MIDI::RtController::Filter::Gene;

# ABSTRACT: Gene's RtController filters

use v5.36;

our $VERSION = '0.0100';

use Moo;
use strictures 2;
use List::SomeUtils qw(first_index);
use Music::Scales qw(get_scale_MIDI get_scale_notes);
use Music::Chord::Note ();
use Music::Note ();
use Music::ToRoman ();
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::RtController ();
  use MIDI::RtController::Filter::Gene ();

  my $rtc = MIDI::RtController->new; # * input/output required

  my $rtf = MIDI::RtController::Filter::Gene->new(rtc => $rtc);

  $rtc->add_filter('foo', note_on => $rtf->can('foo'));

  $rtc->run;

=head1 DESCRIPTION

C<MIDI::RtController::Filter::Gene> is the collection of Gene's
L<MIDI::RtController> filters.

=cut

=head1 ATTRIBUTES

=head2 rtc

  $rtc = $rtf->rtc;

The required L<MIDI::RtController> instance provided in the
constructor.

=cut

has rtc => (
    is  => 'ro',
    isa => sub { die 'Invalid rtc' unless ref($_[0]) eq 'MIDI::RtController' },
    required => 1,
);

=head2 pedal

  $pedal = $rtf->pedal;
  $rtf->pedal($note);

The B<note> used by the pedal-tone filter.

Default: C<55>

Which is the MIDI-number for G below middle-C.

=cut

has pedal => (
    is  => 'rw',
    isa => sub { die 'Invalid pedal' unless $_[0] =~ /^\d+$/ },
    default => sub { 55 },
);

=head2 channel

  $channel = $rtf->channel;
  $rtf->channel($number);

The current MIDI channel (0-15, drums=9).

Default: C<0>

=cut

has channel => (
    is  => 'rw',
    isa => sub { die 'Invalid channel' unless $_[0] =~ /^\d+$/ && $_[0] < 16 },
    default => sub { 0 },
);

=head2 delay

  $delay = $rtf->delay;
  $rtf->delay($number);

The current delay time.

Default: C<0.1> seconds

=cut

has delay => (
    is  => 'rw',
    isa => sub { die 'Invalid delay' unless $_[0] =~ /^[\d.]+$/ },
    default => sub { 0.1 },
);

=head2 velocity

  $velocity = $rtf->velocity;
  $rtf->velocity($number);

The velocity (or volume) change increment (0-127).

Default: C<10>

=cut

has velocity => (
    is  => 'rw',
    isa => sub { die 'Invalid velocity' unless $_[0] =~ /^\d+$/ },
    default => sub { 10 },
);

=head2 feedback

  $feedback = $rtf->feedback;
  $rtf->feedback($number);

The feedback (0-127).

Default: C<1>

=cut

has feedback => (
    is  => 'rw',
    isa => sub { die 'Invalid feedback' unless $_[0] =~ /^\d+$/ },
    default => sub { 1 },
);

=head2 offset

  $offset = $rtf->offset;
  $rtf->offset($number);

The note offset number.

Default: C<-12>

=cut

has offset => (
    is  => 'rw',
    isa => sub { die 'Invalid offset' unless $_[0] =~ /^[\d-]+$/ },
    default => sub { -12 },
);

=head2 key

  $key = $rtf->key;
  $rtf->key($number);

The MIDI number of the musical key.

=cut

has key => (
    is  => 'rw',
    isa => sub { die 'Invalid key' unless $_[0] =~ /^[A-G][#b]?$/ },
    default => sub { 'C' },
);

=head2 scale

  $scale = $rtf->scale;
  $rtf->scale($name);

The name of the musical scale.

=cut

has scale => (
    is  => 'rw',
    isa => sub { die 'Invalid scale' unless $_[0] =~ /^\w+$/ },
    default => sub { 'major' },
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

  pedal, $note, $note + 7

Where the B<pedal> is the object attribute.

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

=head2 chord_tone

Play a diatonic chord based on the given event note, B<key> and
B<scale> attributes.

=cut

sub _chord_notes ($self, $note) {
    my $mn = Music::Note->new($note, 'midinum');
    my $base = uc($mn->format('isobase'));
    my @scale = get_scale_notes($self->key, $self->scale);
    my $index = first_index { $_ eq $base } @scale;
    return $note if $index == -1;
    my $mtr = Music::ToRoman->new(scale_note => $base);
    my @chords = $mtr->get_scale_chords;
    my $chord = $scale[$index] . $chords[$index];
    my $cn = Music::Chord::Note->new;
    my @notes = $cn->chord_with_octave($chord, $mn->octave);
    @notes = map { Music::Note->new($_, 'ISO')->format('midinum') } @notes;
    return @notes;
}
sub chord_tone ($self, $dt, $event) {
    my ($ev, $chan, $note, $vel) = $event->@*;
    my @notes = $self->_chord_notes($note);
    $self->rtc->send_it([ $ev, $self->channel, $_, $vel ]) for @notes;
    return 0;
}

=head2 delay_tone

Play a delayed note, or series of notes, based on the given event note
and B<delay> attribute.

=cut

sub _delay_notes ($self, $note) {
    return ($note) x $self->feedback;
}
sub delay_tone ($self, $dt, $event) {
    my ($ev, $chan, $note, $vel) = $event->@*;
    my @notes = $self->_delay_notes($note);
    my $delay_time = 0;
    for my $n (@notes) {
        $delay_time += $self->delay;
        $self->rtc->delay_send($delay_time, [ $ev, $self->channel, $n, $vel ]);
        $vel -= $self->velocity;
    }
    return 0;
}

=head2 offset_tone

Play a note and an offset note.

=cut

sub _offset_notes ($self, $note) {
    my @notes = ($note);
    push @notes, $note + $self->offset if $self->offset;
    return @notes;
}
sub offset_tone ($self, $dt, $event) {
    my ($ev, $chan, $note, $vel) = $event->@*;
    my @notes = $self->_offset_notes($note);
    $self->rtc->send_it([ $ev, $self->channel, $_, $vel ]) for @notes;
    return 0;
}

1;
__END__

=head1 SEE ALSO

L<Moo>

=cut
