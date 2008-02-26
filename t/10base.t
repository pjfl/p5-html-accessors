#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use lib qq($Bin/../lib);
use Test::More tests => 2;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

BEGIN { use_ok q(HTML::Accessors) }

my $ref = HTML::Accessors->new();

ok( $ref->a() =~ m{ <a .* > .* </a> }mx, q(anchor) );
