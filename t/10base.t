# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use File::Spec::Functions;
use FindBin qw( $Bin );
use lib catdir( $Bin, updir, q(lib) );

use English qw( -no_match_vars );
use Module::Build;
use Test::More;

BEGIN {
   my $current = eval { Module::Build->current };

   $current and $current->notes->{stop_tests}
            and plan skip_all => $current->notes->{stop_tests};
}

use HTML::Accessors;

my $hacc  = HTML::Accessors->new();

ok( (not defined $hacc->DESTROY), 'Call DESTROY' );

ok( (not defined $hacc->not_likely), 'Unknown element' );

like $hacc->a(), qr{ <a .* > .* </a> }mx, 'Anchor';

like $hacc->span( { class => 'test' }, 'content' ),
   qr{ <span \s+ class="test">content</span> }mx, 'Span';

is $hacc->textfield( { default => q(default value), name => q(my_field) } ),
   '<input value="default value" name="my_field" type="text" />', 'Textfield';

my $args = { default => 1, name => q(my_field), values => [ 1, 2 ] };

like $hacc->popup_menu( $args ),
   qr{ \A <select \s+ name="my_field"> \s+
          <option \s+ selected="selected">1</option> \s+
          <option \s+ >2</option> \s+ </select> }mx, 'Popup menu';

$args = { columns => 2,
          default => 1,
          labels  => { 1 => q(Button One),
                       2 => q(Button Two),
                       3 => q(Button Three),
                       4 => q(Button Four), },
          name    => q(my_field),
          values  => [ 1, 2, 3, 4 ] };

like $hacc->radio_group( $args ),
   qr{ \A <input \s+ checked="checked" \s+ tabindex="1"
          \s+ value="1" \s+ name="my_field" \s+ type="radio" \s+
          /><label \s+ class="radio_group_label"> Button \s+
          One</label> }mx, 'Radio group';

$hacc = HTML::Accessors->new( content_type => q(text/html) );

is $hacc->textfield( { default => q(default value), name => q(my_field) } ),
   '<input value="default value" name="my_field" type="text">',
   'Textfield - HTML';

like $hacc->radio_group( $args ),
   qr{ \A <input \s+ checked \s+ tabindex="1"
          \s+ value="1" \s+ name="my_field" \s+ type="radio"
          ><label \s+ class="radio_group_label"> Button \s+
          One</label> }mx, 'Radio group - HTML';

$args = { default => 1, name => q(my_field), values => [ 1, 2 ] };

like $hacc->popup_menu( $args ),
   qr{ \A <select \s+ name="my_field"> \s+
          <option \s+ selected>1</option> \s+
          <option \s+ >2</option> \s+ </select> }mx, 'Popup menu - HTML';

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
