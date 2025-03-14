#!/usr/bin/env perl

# PERL_FUTURE_DEBUG=1 perl eg/tester.pl

use v5.36;

use curry;
use Future::IO::Impl::IOAsync;
use MIDI::RtController ();
use MIDI::RtController::Filter::Gene ();
use MIDI::RtController::Filter::Math ();

my $input_name  = shift || 'tempopad'; # midi controller device
my $output_name = shift || 'fluid';    # fluidsynth

my $rtc = MIDI::RtController->new(
    input  => $input_name,
    output => $output_name,
);

my $rtfg = MIDI::RtController::Filter::Gene->new(rtc => $rtc);
my $rtfm = MIDI::RtController::Filter::Math->new(rtc => $rtc);

$rtfm->delay(0.2);
$rtfm->feedback(4);

# add_filters('pedal', $rtfg->curry::pedal_tone, 0);
add_filters('stair', $rtfm->curry::stair_step, 0);

$rtc->run;

sub add_filters ($name, $coderef, $types) {
    $types ||= [qw(note_on note_off)];
    $rtc->add_filter($name, $types, $coderef);
}
