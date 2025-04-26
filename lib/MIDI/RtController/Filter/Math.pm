package MIDI::RtController::Filter::Math;

# ABSTRACT: Math based RtController filters

use v5.36;

use strictures 2;
use Moo;
use Types::Standard qw(Num);
use Types::Common::Numeric qw(PositiveInt PositiveNum);
use namespace::clean;

extends 'MIDI::RtController::Filter';

=head1 SYNOPSIS

  use curry;
  use MIDI::RtController ();
  use MIDI::RtController::Filter::Math ();

  my $rtc = MIDI::RtController->new(
    input  => 'keyboard',
    output => 'usb',
  );

  my $filter = MIDI::RtController::Filter::Math->new(rtc => $rtc);

  $filter->control(1); # CC#01 = mod-wheel
  $filter->channel(0);

  $rtc->add_filter('stair_step', note_on => $filter->curry::stair_step);

  $rtc->run;

=head1 DESCRIPTION

C<MIDI::RtController::Filter::Math> is the collection of Math based
L<MIDI::RtController> filters.

=cut

=head1 ATTRIBUTES

=head2 delay

  $delay = $filter->delay;
  $filter->delay($number);

The current delay time.

Default: C<0.1> seconds

=cut

has delay => (
    is      => 'rw',
    isa     => PositiveNum,
    default => sub { 0.1 },
);

=head2 feedback

  $feedback = $filter->feedback;
  $filter->feedback($number);

The amount of feedback.

Default: C<3>

=cut

has feedback => (
    is      => 'rw',
    isa     => PositiveInt,
    default => sub { 1 },
);

=head2 up

  $up = $filter->up;
  $filter->up($number);

The upward movement steps.

Default: C<2>

=cut

has up => (
    is      => 'rw',
    isa     => Num,
    default => sub { 2 },
);

=head2 down

  $down = $filter->down;
  $filter->down($number);

The downward movement steps.

Default: C<-1>

=cut

has down => (
    is      => 'rw',
    isa     => Num,
    default => sub { -1 },
);

=head1 METHODS

All filter methods must accept the object, a MIDI device name, a
delta-time, and a MIDI event ARRAY reference, like:

  sub stair_step ($self, $device, $delta, $event) {
    my ($event_type, $chan, $note, $value) = $event->@*;
    ...
    return $boolean;
  }

A filter also must return a boolean value. This tells
L<MIDI::RtController> to continue processing other known filters or
not.

=head2 stair_step

Notes are played from the event note, in up-down, stair-step fashion.

If B<trigger> or B<value> is set, the filter checks those against the
MIDI event C<note> or C<value>, respectively, to see if the filter
should be applied.

=cut

sub _stair_step_notes ($self, $note) {
    my @notes;
    my $factor;
    my $current = $note;
    for my $i (1 .. $self->feedback) {
        if ($i % 2 == 0) {
            $factor = ($i - 1) * $self->down;
        }
        else {
            $factor = $i * $self->up;
        }
        $current += $factor;
        push @notes, $current;
    }
    return @notes;
}

sub stair_step ($self, $device, $dt, $event) {
    my ($ev, $chan, $note, $val) = $event->@*;
    return 0 if defined $self->trigger && $note != $self->trigger;
    return 0 if defined $self->value && $val != $self->value;

    my @notes = $self->_stair_step_notes($note);
    my $delay_time = 0;
    for my $n (@notes) {
        $delay_time += $self->delay;
        $self->rtc->delay_send($delay_time, [ $ev, $self->channel, $n, $val ]);
    }
    return 0;
}

1;
__END__

=head1 SEE ALSO

The eg/*.pl program(s) in this distribution

L<MIDI::RtController::Filter>

L<MIDI::RtController::Filter::Tonal>

L<MIDI::RtController::Filter::Drums>

L<MIDI::RtController::Filter::CC>

L<Moo>

L<Types::MIDI>

L<Types::Standard>

=cut
