#!perl -T
use strict;
use warnings;
use Test::More;

plan tests => 1;

use_ok 'XML::C14N' or print "Bail out!\n";

diag "Testing XML::C14N $XML::C14N::VERSION, Perl $], $^X";
