package HTML::Accessors;

# @(#)$Id$

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use HTML::GenerateUtil qw(generate_tag :consts);
use HTML::Tagset;
use NEXT;
use Readonly;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $INP => { button         => q(button),
                      checkbox       => q(checkbox),
                      hidden         => q(hidden),
                      image_button   => q(image),
                      password_field => q(password),
                      radio_button   => q(radio),
                      submit         => q(submit),
                      textfield      => q(text) };
Readonly my $NUL => q();

sub escape_html {
   my ($me, @rest) = @_; return HTML::GenerateUtil::escape_html( @rest );
}

sub popup_menu {
   my ($me, @rest) = @_;
   my ($args, $def, $labels, $opt_attr, $options, $val, $values);

   $rest[0] ||= $NUL;
   $args      = ref $rest[0] eq q(HASH) ? { %{ $rest[0] } } : { @rest };
   $def       = $args->{default} || $NUL; delete $args->{default};
   $labels    = $args->{labels}  || {};   delete $args->{labels};
   $values    = $args->{values}  || [];   delete $args->{values};

   for $val (@{ $values }) {
      $opt_attr = $val eq $def ? { selected => q(selected) } : {};

      if (exists $labels->{ $val }) {
         $opt_attr->{value} = $val;
         $val = $labels->{ $val };
      }

      $options .= generate_tag( q(option), $opt_attr, $val, GT_ADDNEWLINE );
   }

   if ($options) { $options = "\n".$options }
   else { $options = generate_tag( q(option), undef, $NUL, GT_ADDNEWLINE ) }

   return generate_tag( q(select), $args, $options, GT_ADDNEWLINE );
}

sub radio_group {
   my ($me, @rest) = @_;
   my ($args, $cols, $def, $html, $i, $inp, $inp_attr);
   my ($labels, $name, $val, $values);

   $rest[0] ||= $NUL;
   $args      = ref $rest[0] eq q(HASH) ? { %{ $rest[0] } } : { @rest };
   $cols      = $args->{columns} || q(999999);
   $def       = $args->{default} || 0;
   $labels    = $args->{labels}  || {};
   $name      = $args->{name}    || q(radio);
   $values    = $args->{values}  || [];
   $inp_attr  = { name => $name, type => q(radio) };
   $i         = 1;

   $inp_attr->{onchange} = $args->{onchange} if ($args->{onchange});

   for $val (@{ $values }) {
      $inp_attr->{value   } = $val;
      $inp_attr->{tabindex} = $i;
      $inp_attr->{checked } = q(checked)
         if ($def !~ m{ \d+ }mx && $val eq $def);
      $inp_attr->{checked } = q(checked)
         if ($def =~ m{ \d+ }mx && $val == $def);
      $inp   = generate_tag( q(input), $inp_attr, undef, GT_CLOSETAG );
      $inp  .= $labels->{ $val } || $val;
      $html .= generate_tag( q(label), undef, "\n".$inp, GT_ADDNEWLINE );

      if ($cols && $i % $cols == 0) {
         $html .= generate_tag( q(br), undef, undef, GT_CLOSETAG );
      }

      delete $inp_attr->{checked};
      $i++;
   }

   return $html || $NUL;
}

sub scrolling_list {
   my ($me, $args) = @_;

   $args->{multiple} = q(multiple);

   return $me->popup_menu( $args );
}

## no critic
sub AUTOLOAD {
## critic
   my ($me, @rest) = @_; my ($args, $elem, $mode, $val);

   ($elem = $HTML::Accessors::AUTOLOAD) =~ s{ .* :: }{}mx;
   $mode  = GT_ADDNEWLINE;

   if ($rest[0] && ref $rest[0] eq q(HASH)) {
      $args = { %{ $rest[0] } }; $val = $rest[1];
   }
   else { $args = {}; $val = $rest[0] }

   if (exists $INP->{ $elem }) {
      $args->{type}    = $INP->{ $elem };
      $args->{value}   = delete $args->{default} if (defined $args->{default});
      $args->{value} ||= $NUL;
      $elem            = q(input);
   }

## no critic
   unless ($HTML::Tagset::isKnown{ $elem }) {
## critic
      _carp( 'Unknown element '.$elem );
      return $me->NEXT::AUTOLOAD( @rest );
   }

   $val ||= defined $args->{default} ? delete $args->{default} : $NUL;

## no critic
   if ($HTML::Tagset::emptyElement{ $elem }) {
## critic
      ($val, $mode) = (undef, GT_CLOSETAG);
   }

   return generate_tag( $elem, $args, $val, $mode );
}

sub DESTROY {
   my ($me, @rest) = @_; return $me->NEXT::DESTROY( @rest );
}

# Private methods

sub _carp { require Carp; goto &Carp::carp }

sub _croak { require Carp; goto &Carp::croak }

1;

__END__

=pod

=head1 Name

HTML::Accessors - Generate HTML elements

=head1 Version

0.1.$Rev$

=head1 Synopsis

   use HTML::Accessors;

   my $htag = HTML::Accessors->new();

   # Create an anchor element
   $anchor = $htag->a( { href => 'http://...' }, 'This is a link' );

=head1 Description

Uses L<HTML::GenerateUtil> to create an autoload method for each of
the elements defined by L<HTML::Tagset>. The API was loosely taken
from L<CGI>. Using the L<CGI> module is undesirable in a L<Catalyst>
application (run from the development server) due go greediness issues
over STDIN.

The returned tags are XHTML 1.1 compliant.

=head1 Subroutines/Methods

=head2 new

The constructor is inherited from L<Class::Accessor::Fast> and takes
no options

=head2 escape_html

Expose C<HTML::GenerateUtil::escape_html>

=head2 popup_menu

Returns the C<E<lt>selectE<gt>> element. The first option passed to
C<popup_menu> is either a hash ref or a list of key/value pairs. The keys are:

=over 3

=item B<default>
   Determines which of the values will be selected by default

=item B<labels>
   Display these labels in place of the values (but return the value
   of the selected label). This is a hash ref with a key for each
   element in the C<values> array

=item B<values>
   The key references an array ref whose values are used as the list of
   options returned in the body of the C<E<lt>selectE<gt>> element.

=back

The rest of the keys and values are passed as attributes to the
C<E<lt>selectE<gt>> element. For example:

   $ref = { default => 1, name => q(my_field), values => [ 1, 2 ] };
   $htag->popup_menu( $ref );

would return

   E<lt>select name="my_field"E<gt>
      E<lt>option selected="selected"E<gt>1E<lt>/optionE<gt>
      E<lt>optionE<gt>2E<lt>/optionE<gt>
   E<lt>/selectE<gt>

=head2 radio_group

Generates a list of radio input buttons with labels. Break elements can
be inserted to create rows of a given number of columns when
displayed. The first option passed to C<radio_group> is either a hash
ref or a list of key/value pairs. The keys are:

=over 3

=item B<columns>
   Integer number of columns to display the generated buttons in. If
   zero then a list of radio buttons without breaks is generated

=item B<default>
   Determines which of the radio box will be selected by default

=item B<labels>
   Display these labels next to each button. This is a hash ref with a
   key for each element in the C<values> array

=item B<name>
   The form name of the generated buttons

=item B<onchange>
   An optional Javascript reference. The JS will be executed each time
   a different radio button is selected

=item B<values>
   The key references an array ref whose values are returned by the
   radio buttons

=back

For example:

   $ref = { columns => 2,
            default => 1,
            labels  => { 1 => q(Button One),
                         2 => q(Button Two),
                         3 => q(Button Three),
                         4 => q(Button Four), },
            name    => q(my_field),
            values  => [ 1, 2, 3, 4 ] };
   $htag->radio_group( $ref );

=head2 scrolling_list

Calls C<popup_menu> with the C<multiple> argument set to
C<multiple>. This has the effect of allowing multiple selections to
be returned from the popup menu

=head2 AUTOLOAD

Uses L<HTML::Tagset> to check if the requested method is a known HTML
element. If it is C<AUTOLOAD> uses L<HTML::GenerateUtil> to create the tag.

If the first option is a hash ref then the keys and values are copied
and passed to C<HTML::GenerateUtil::generate_tag> which uses them to
set the attributes on the created element. The next option is treated
as the element's body text and overrides the C<default> attribute which
is passed and deleted from the options hash.

If the requested element exists in the hard coded list of input
elements, then the element is set to C<input> and the mapped value
used as the type atrribute in the call to C<generate_tag>. For example;

   $htag->textfield( { name => q(my_field) }, q(Some default text));

would return

   E<lt>input type="text" name="my_field"E<gt>Some default textE<lt>/inputE<gt>

The list of input elements contains; button, checkbox, hidden,
image_button, password_field, radio_button, submit, and textfield

=head2 DESTROY

Implement the C<DESTROY> method so that the C<AUTOLOAD> method doesn't get
called instead. Redispatchs the call upstream.

=head2 _carp

Call C<Carp::carp>. Don't load L<Carp> if we don't have to

=head2 _croak

Call C<Carp::croak>. Don't load L<Carp> if we don't have to

=head1 Configuration and Environment

None

=head1 Diagnostics

C<Carp::carp> is called to issue a warning about undefined elements

=head1 Dependencies

=over 4

=item L<Class::Accessor::Fast>

=item L<HTML::GenerateUtil>

=item L<HTML::Tagset>

=item L<NEXT>

=item L<Readonly>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module.

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome.

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2008 Peter Flanigan. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
