#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use lib qq($Bin/../lib);
use Test::More;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

BEGIN {
   if ($ENV{AUTOMATED_TESTING}
       || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) {
      plan skip_all => q(CPAN Testing stopped);
   }

   plan tests => 7;
}

use_ok q(HTML::Accessors);

my $ref = HTML::Accessors->new();

ok( $ref->a() =~ m{ <a .* > .* </a> }mx, q(anchor) );

ok( $ref->textfield( { default => q(default value), name => q(my_field) } )
    eq '<input value="default value" name="my_field" type="text" />',
    q(textfield) );

my $args = { default => 1, name => q(my_field), values => [ 1, 2 ] };

ok ( $ref->popup_menu( $args )
     =~ m{ \A <select \s+ name="my_field"> \s+
              <option \s+ selected="selected">1</option> \s+
              <option \s+ >2</option> \s+ </select> }mx, q(popup_menu) );

$args = { columns => 2,
          default => 1,
          labels  => { 1 => q(Button One),
                       2 => q(Button Two),
                       3 => q(Button Three),
                       4 => q(Button Four), },
          name    => q(my_field),
          values  => [ 1, 2, 3, 4 ] };

ok( $ref->radio_group( $args )
    =~ m{ \A <label> \s+ <input \s+ checked="checked" \s+ tabindex="1"
          \s+ value="1" \s+ name="my_field" \s+ type="radio" \s+
          />Button \s+ One</label> }mx, q(radio_group) );

$ref = HTML::Accessors->new( content_type => q(text/html) );

ok( $ref->textfield( { default => q(default value), name => q(my_field) } )
    eq '<input value="default value" name="my_field" type="text">',
    q(textfield-html) );

ok( $ref->radio_group( $args )
    =~ m{ \A <label> \s+ <input \s+ checked="checked" \s+ tabindex="1"
          \s+ value="1" \s+ name="my_field" \s+ type="radio"
          >Button \s+ One</label> }mx, q(radio_group-html) );
