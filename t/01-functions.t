#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

use_ok 'MIDI::RtController::Filter::Gene';

lives_ok { MIDI::RtController::Filter::Gene::foo(666) }
    'lives through foo()';

done_testing();
