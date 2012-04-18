# @(#)$Id$

package HTML::Accessors;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(Class::Accessor::Fast);

use Carp;
use HTML::GenerateUtil qw(generate_tag :consts);
use HTML::Tagset;

my $ATTRS = { content_type   => q(application/xhtml+xml) };
my $INP   = { checkbox       => q(checkbox),
              hidden         => q(hidden),
              image_button   => q(image),
              password_field => q(password),
              radio_button   => q(radio),
              submit         => q(submit),
              textfield      => q(text) };
my $NUL   = q();

__PACKAGE__->mk_accessors( keys %{ $ATTRS } );

sub new {
   my ($self, @rest) = @_; my $args = _arg_list( @rest );

   return bless _hash_merge( $ATTRS, $args ), ref $self || $self;
}

sub escape_html {
   my ($self, @rest) = @_; return HTML::GenerateUtil::escape_html( @rest );
}

sub is_xml {
   return $_[ 0 ]->content_type =~ m{ / (.*) xml \z }mx ? 1 : 0;
}

sub popup_menu {
   my ($self, @rest) = @_; my $options; $rest[ 0 ] ||= $NUL;

   my $args    = _arg_list( @rest );
   my $classes = $args->{classes} || {};   delete $args->{classes};
   my $def     = $args->{default} || $NUL; delete $args->{default};
   my $labels  = $args->{labels } || {};   delete $args->{labels };
   my $values  = $args->{values } || [];   delete $args->{values };

   for my $val (grep { defined } @{ $values }) {
      my $opt_attr = $val eq $def
                   ? { selected => $self->is_xml ? q(selected) : undef } : {};

      exists $classes->{ $val } and $opt_attr->{class} = $classes->{ $val };

      if (exists $labels->{ $val }) {
         $opt_attr->{value} = $val; $val = $labels->{ $val };
      }

      $options .= generate_tag( q(option), $opt_attr, $val, GT_ADDNEWLINE );
   }

   if ($options) { $options = "\n".$options }
   else { $options = generate_tag( q(option), undef, $NUL, GT_ADDNEWLINE ) }

   return generate_tag( q(select), $args, $options, GT_ADDNEWLINE );
}

sub radio_group {
   my ($self, @rest) = @_; my ($html, $inp); $rest[ 0 ] ||= $NUL;

   my $args        = _arg_list( @rest );
   my $cols        = $args->{columns    } || q(999999);
   my $def         = $args->{default    } || 0;
   my $labels      = $args->{labels     } || {};
   my $label_class = $args->{label_class} || q(radio_group_label);
   my $name        = $args->{name       } || q(radio);
   my $values      = $args->{values     } || [];
   my $inp_attr    = { name => $name, type => q(radio) };
   my $mode        = $self->is_xml ? GT_CLOSETAG : 0;
   my $i           = 1;

   $args->{onchange} and $inp_attr->{onchange} = $args->{onchange};

   for my $val (@{ $values }) {
      $inp_attr->{value   } = $val;
      $inp_attr->{tabindex} = $i;
      $def !~ m{ \d+ }mx and $val eq $def
         and $inp_attr->{checked } = $self->is_xml ? q(checked) : undef;
      $def =~ m{ \d+ }mx and $val == $def
         and $inp_attr->{checked } = $self->is_xml ? q(checked) : undef;
      $html .= generate_tag( q(input), $inp_attr, undef, $mode );
      (exists $labels->{ $val } and not defined $labels->{ $val })
         or $html .= generate_tag( q(label),
                                   { class => $label_class },
                                   ($labels->{ $val } || $val),
                                   GT_ADDNEWLINE );
      $cols and $i % $cols == 0
         and $html .= generate_tag( q(br), undef, undef, $mode );
      delete $inp_attr->{checked};
      $i++;
   }

   return $html || $NUL;
}

sub scrolling_list {
   my ($self, @rest) = @_; my $args = _arg_list( @rest );

   $args->{multiple} = q(multiple);
   return $self->popup_menu( $args );
}

sub AUTOLOAD { ## no critic
   my ($self, @rest) = @_;

   my $args = {}; my $mode = GT_ADDNEWLINE; my $val = $rest[ 0 ];

  (my $elem = lc $HTML::Accessors::AUTOLOAD) =~ s{ .* :: }{}mx;

   if ($rest[ 0 ] and ref $rest[ 0 ] eq q(HASH)) {
      $args = { %{ $rest[ 0 ] } }; $val = $rest[ 1 ];
   }

   if (exists $INP->{ $elem }) {
      $args->{type} = $INP->{ $elem };
      defined $args->{default} and $args->{value} = delete $args->{default};
      defined $args->{value  } or  $args->{value} = $NUL;
      $elem = q(input);
   }

   unless ($HTML::Tagset::isKnown{ $elem }) { ## no critic
      carp "Unknown element $elem"; return;
   }

   $val ||= defined $args->{default} ? delete $args->{default} : $NUL;

   if ($HTML::Tagset::emptyElement{ $elem }) { ## no critic
      $val = undef; $mode = $self->is_xml ? GT_CLOSETAG : 0;
   }

   return generate_tag( $elem, $args, $val, $mode );
}

sub DESTROY {}

# Private subroutines

sub _arg_list {
   return $_[ 0 ] ? ref $_[ 0 ] eq q(HASH) ? { %{ $_[ 0 ] } } : { @_ } : {};
}

sub _hash_merge {
   return { %{ $_[ 0 ] }, %{ $_[ 1 ] || {} } };
}

1;

__END__

=pod

=head1 Name

HTML::Accessors - Generate HTML elements

=head1 Version

0.7.$Rev$

=head1 Synopsis

   use HTML::Accessors;

   my $my_obj = HTML::Accessors->new();

   # Create an anchor element
   $anchor = $my_obj->a( { href => 'http://...' }, 'This is a link' );

=head1 Description

Uses L<HTML::GenerateUtil> to create an autoload method for each of
the elements defined by L<HTML::Tagset>. The API was loosely taken
from L<CGI>. Using the L<CGI> module is undesirable in a L<Catalyst>
application (run from the development server) due go greediness issues
over STDIN.

The returned tags are either XHTML 1.1 or HTML 4.01 compliant.

=head1 Configuration and Environment

The constructor defines accessors and mutators for one attribute:

=over 3

=item B<content_type>

Defaults to I<application/xhtml+xml> which causes the generated tags
to conform to the XHTML standard. Setting it to I<text/html> will
generate HTML compatible tags instead

=back

=head1 Subroutines/Methods

=head2 new

   my $my_obj = HTML::Accessors->new( content_type => q(application/xhtml+xml) );

Uses L</_arg_list> to process the passed options

=head2 escape_html

   my $escaped_html = $my_obj->escape_html( $unescaped_html );

Expose the method L<escape_html|HTML::GenerateUtil/FUNCTIONS>

=head2 is_xml

   my $bool = $my_obj->is_xml;

Returns true if the returned tags will be XHTML. Matches the string I<.xml>
at the end of the I<content_type>

=head2 popup_menu

   my $html = $my_obj->popup_menu( default => $value, labels => {}, values => [] );

Returns the C<< <select> >> element. The first option passed to
C<popup_menu> is either a hash ref or a list of key/value pairs. The keys are:

=over 3

=item B<classes>

A hash ref keyed by the I<values> attribute. It lets you to set the I<class>
attribute of each C<< <option> >> element

=item B<default>

Determines which of the values will be selected by default

=item B<labels>

Display these labels in place of the values (but return the value
of the selected label). This is a hash ref with a key for each
element in the C<values> array

=item B<values>

The key references an array ref whose values are used as the list of
options returned in the body of the C<< <select> >> element

=back

The rest of the keys and values are passed as attributes to the
C<< <select> >> element. For example:

   $ref = { default => 1, name => q(my_field), values => [ 1, 2 ] };
   $my_obj->popup_menu( $ref );

would return:

   <select name="my_field">
      <option selected="selected">1</option>
      <option>2</option>
   </select>

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

=item B<label_class>

Class of the labels generated for each button

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
   $my_obj->radio_group( $ref );

would return:

   <label>
      <input checked="checked" tabindex="1" value="1" name="my_field" type="radio" />Button One
   </label>
   <label>
      <input tabindex="2" value="2" name="my_field" type="radio" />Button Two
   </label>
   <br />
   <label>
      <input tabindex="3" value="3" name="my_field" type="radio" />Button Three
   </label>
   <label>
      <input tabindex="4" value="4" name="my_field" type="radio" />Button Four
   </label>
   <br />

=head2 scrolling_list

Calls C<popup_menu> with the C<multiple> argument set to
C<multiple>. This has the effect of allowing multiple selections to
be returned from the popup menu

=head2 AUTOLOAD

Uses L<HTML::Tagset> to check if the requested method is a known HTML
element. If it is C<AUTOLOAD> uses L<HTML::GenerateUtil> to create the tag

If the first option is a hash ref then the keys and values are copied
and passed to C<HTML::GenerateUtil::generate_tag> which uses them to
set the attributes on the created element. The next option is treated
as the element's body text and overrides the C<default> attribute which
is passed and deleted from the options hash

If the requested element exists in the hard coded list of input
elements, then the element is set to C<input> and the mapped value
used as the type attribute in the call to C<generate_tag>. For example;

   $my_obj->textfield( { default => q(default value), name => q(my_field) } );

would return

   <input value="default value" name="my_field" type="text" />

The list of input elements contains; button, checkbox, hidden,
image_button, password_field, radio_button, submit, and textfield

Carp and return C<undef> if the element does not exist in
L<isKnown|HTML::Tagset/isKnown>

=head2 DESTROY

Implement the C<DESTROY> method so that the C<AUTOLOAD> method doesn't get
called instead

=head2 _arg_list

Returns a hash ref containing the passed parameter list. Enables
methods to be called with either a list or a hash ref as it's input
parameters. Makes copies as it goes so that you can change the contents
without altering the parameters if they were passed by reference

=head2 _hash_merge

Simplistic merging of two hashes

=head1 Diagnostics

L<Carp|Carp/carp> is called to issue a warning about undefined elements

=head1 Dependencies

=over 4

=item L<Class::Accessor::Fast>

=item L<HTML::GenerateUtil>

=item L<HTML::Tagset>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 License and Copyright

Copyright (c) 2012 Peter Flanigan. All rights reserved.

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
