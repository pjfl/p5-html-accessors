# @(#)$Ident: 10base.t 2013-08-15 18:56 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.9.%d', q$Rev: 1 $ =~ /\d+/gmx );
use File::Spec::Functions   qw( catdir updir );
use FindBin                 qw( $Bin );
use lib                 catdir( $Bin, updir, 'lib' );

use Module::Build;
use Test::More;

my $notes = {};

BEGIN {
   my $builder = eval { Module::Build->current };
      $builder and $notes = $builder->notes;
}

use English qw( -no_match_vars );

use_ok 'HTML::Accessors';

my $hacc = HTML::Accessors->new();

ok( (not defined $hacc->DESTROY), 'Call DESTROY' );

ok( (not defined $hacc->not_likely), 'Unknown element' );

like $hacc->a(), qr{ <a .* > .* </a> }msx, 'XHTML - anchor';

like $hacc->span( { class => 'test' }, 'content' ),
   qr{ <span \s+ class="test">content</span> }msx, 'XHTML - span';

my $field = $hacc->textfield( { default => q(default value),
                                name    => q(my_field) } );

like $field, qr{ \A <input (.*)? type="text" (.*)? /> \z }msx,
   'XHTML - textfield';

like $field, qr{ value="default \s+ value" }msx,
   'XHTML - textfield - default value';

like $field, qr{ name="my_field" }msx, 'XHTML - textfield - field name';

my $args = { default => 1, name => q(my_field), values => [ 1, 2 ] };

like $hacc->popup_menu( $args ),
   qr{ \A <select \s+ name="my_field"> \s+
          <option \s+ selected="selected">1</option> \s+
          <option \s+ >2</option> \s+ </select> }msx, 'XHTML - popup menu';

$args = { columns => 2,
          default => 1,
          labels  => { 1 => q(Button One),
                       2 => q(Button Two),
                       3 => q(Button Three),
                       4 => q(Button Four), },
          name    => q(my_field),
          values  => [ 1, 2, 3, 4 ] };

$field = $hacc->radio_group( $args );

like $field, qr{ \A <input (.*)? type="radio" }msx, 'XHTML - radio group';

like $field, qr{ name="my_field"  }msx, 'XHTML - radio group - field name';

like $field, qr{ <label \s+ class="radio_group_label"> Button \s+ One }msx,
   'XHTML - radio group - label';

$hacc = HTML::Accessors->new( content_type => q(text/html) );

$field = $hacc->textfield( { default => q(default value),
                             name    => q(my_field) } );

like $field, qr{ \A <input (.*)? type="text" (.*)? > \z }msx,
   'HTML - textfield';

like $field, qr{ value="default \s+ value" }msx,
   'HTML - textfield - default value';

like $field, qr{ name="my_field" }msx,
   'HTML - textfield - field name';

$field = $hacc->radio_group( $args );

like $field, qr{ \A <input (.*)? type="radio" }msx, 'HTML - radio group';

like $field, qr{ name="my_field"  }msx, 'HTML - radio group - field name';

like $field, qr{ <label \s+ class="radio_group_label"> Button \s+ One }msx,
   'HTML - radio group - label';

$args = { default => 1, name => q(my_field), values => [ 1, 2 ] };

like $hacc->popup_menu( $args ),
   qr{ \A <select \s+ name="my_field"> \s+
          <option \s+ selected>1</option> \s+
          <option \s+ >2</option> \s+ </select> }msx, 'HTML - popup menu';

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
