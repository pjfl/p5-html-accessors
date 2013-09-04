# @(#)$Ident: 10test_script.t 2013-09-04 21:15 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev: 1 $ =~ /\d+/gmx );
use File::Spec::Functions   qw( catdir updir );
use FindBin                 qw( $Bin );
use lib                 catdir( $Bin, updir, 'lib' );

use Module::Build;
use Test::More;

my $notes = {}; my $perl_ver;

BEGIN {
   my $builder = eval { Module::Build->current };
      $builder and $notes = $builder->notes;
      $perl_ver = $notes->{min_perl_version} || 5.008;
}

use Test::Requires "${perl_ver}";
use English qw( -no_match_vars );

use_ok 'HTML::Accessors';

my $hacc = HTML::Accessors->new();

isa_ok $hacc, 'HTML::Accessors';

$hacc = $hacc->new();

isa_ok $hacc, 'HTML::Accessors';

is $hacc->escape_html( '&<>"' ), '&amp;&lt;&gt;&quot;', 'Escape html';

ok( (not defined $hacc->DESTROY), 'Call DESTROY' );

ok( (not defined $hacc->not_likely), 'Unknown element' );

like $hacc->a(), qr{ <a .* > .* </a> }msx, 'XHTML - anchor';

like $hacc->a( 'Content' ), qr{ Content }mx, 'XHTML - anchor with content';

like $hacc->span( { class => 'test' }, 'content' ),
   qr{ <span \s+ class="test">content</span> }msx, 'XHTML - span';

my $field = $hacc->textfield();

like $field, qr{ \A <input (.*)? value="" (.*)? /> \z }mx, 'Default textfield';

$field = $hacc->textfield( {
   default => 'default value', name => 'my_field' } );

like $field, qr{ \A <input (.*)? type="text" (.*)? /> \z }msx,
   'XHTML - textfield';

like $field, qr{ value="default \s+ value" }msx,
   'XHTML - textfield - default value';

like $field, qr{ name="my_field" }msx, 'XHTML - textfield - field name';

my $x = $hacc->popup_menu();

like $hacc->popup_menu(), qr{ select }mx, 'Default popup menu';

my $args = { default => 1, labels => { 1 => 'a', 2 => 'b', },
             name => 'my_field', values => [ 1, 2 ] };

like $hacc->popup_menu( $args ),
   qr{ \A <select \s+ name="my_field"> \s+
          <option \s+ (.*)? selected="selected" (.*)? >a</option> \s+
          <option \s+ value="2">b</option> \s+ </select> }msx,
   'XHTML - popup menu';

like $hacc->scrolling_list(), qr{ select \s+ multiple }mx, 'Scrolling list';

is $hacc->radio_group(), q(), 'Default radio group';

$args = { columns     => 2,
          default     => 1,
          label_class => 'whatever',
          labels      => { 1 => 'Button One',
                           2 => 'Button Two',
                           3 => 'Button Three',
                           4 => 'Button Four',
                           x => 'Non numeric value',
                           y => undef, },
          name        => 'my_field',
          values      => [ 1, 2, 3, 4, 'x', 'y', 'z', '' ] };

$field = $hacc->radio_group( $args );

like $field, qr{ \A <input (.*)? type="radio" }msx, 'XHTML - radio group';

like $field, qr{ name="my_field"  }msx, 'XHTML - radio group - field name';

like $field, qr{ <label \s+ class="whatever"> Button \s+ One }msx,
   'XHTML - radio group - label';

$args->{default} = 'x';

$field = $hacc->radio_group( $args );

like $field, qr { checked }mx, 'XHTML - radio group - string default';

$args->{default} = '1'; delete $args->{label_class};

$hacc = HTML::Accessors->new( content_type => 'text/html' );

$field = $hacc->textfield( { default => 'default value',
                             name    => 'my_field' } );

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

$args->{default} = 'x';

$field = $hacc->radio_group( $args );

like $field, qr { checked }mx, 'HTML - radio group - string default';

$args = { classes => {}, default => 1, name => 'my_field', values => [ 1, 2 ] };

like $hacc->popup_menu( $args ),
   qr{ \A <select \s+ name="my_field"> \s+
          <option \s+ selected>1</option> \s+
          <option \s+ >2</option> \s+ </select> }msx, 'HTML - popup menu';

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
