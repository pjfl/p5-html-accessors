package HTML::Accessors;

use 5.01;
use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.13.%d', q$Rev: 3 $ =~ /\d+/gmx );

use Carp;
use HTML::GenerateUtil qw( generate_tag :consts );
use HTML::Tagset;
use Scalar::Util       qw( blessed );

my $INP = { checkbox       => 'checkbox',
            hidden         => 'hidden',
            image_button   => 'image',
            password_field => 'password',
            radio_button   => 'radio',
            submit         => 'submit',
            textfield      => 'text' };
my $NUL = q();

# Private functions
my $_hash_merge = sub {
   return { %{ $_[ 0 ] }, %{ $_[ 1 ] || {} } };
};

my $_hashify = sub {
   return $_[ 0 ] ? ref $_[ 0 ] eq 'HASH' ? { %{ $_[ 0 ] } } : { @_ } : {};
};

# Public methods
sub new {
   my ($self, @args) = @_; my $class = blessed $self || $self;

   my $attr = { content_type => 'application/xhtml+xml' };

   return bless $_hash_merge->( $attr, $_hashify->( @args ) ), $class;
}

sub content_type {
   return $_[ 0 ]->{content_type};
}

sub escape_html {
   my ($self, @args) = @_; return HTML::GenerateUtil::escape_html( @args );
}

sub is_xml {
   return $_[ 0 ]->content_type =~ m{ / (.*) xml \z }mx ? 1 : 0;
}

sub popup_menu {
   my ($self, @args) = @_; my $options;

   my $args    = $_hashify->( @args );
   my $classes = delete $args->{classes} || {};
   my $def     = delete $args->{default} || $NUL;
   my $labels  = delete $args->{labels } || {};
   my $values  = delete $args->{values } || [];

   for my $val (grep { defined } @{ $values }) {
      my $opt_attr = $val eq $def ? { selected => $self->is_xml
                                                ? 'selected' : undef } : {};

      exists $classes->{ $val } and $opt_attr->{class} = $classes->{ $val };

      if (exists $labels->{ $val }) {
         $opt_attr->{value} = $val; $val = $labels->{ $val };
      }

      $options .= generate_tag( 'option', $opt_attr, $val, GT_ADDNEWLINE );
   }

   if ($options) { $options = "\n".$options }
   else { $options = generate_tag( 'option', undef, $NUL, GT_ADDNEWLINE ) }

   return generate_tag( 'select', $args, $options, GT_ADDNEWLINE );
}

sub radio_group {
   my ($self, @args) = @_;

   my $args        = $_hashify->( @args );
   my $cols        = $args->{columns    } || '999999';
   my $def         = $args->{default    } || 0;
   my $labels      = $args->{labels     } || {};
   my $label_class = $args->{label_class} || 'radio_group_label';
   my $name        = $args->{name       } || 'radio';
   my $values      = $args->{values     } || [];
   my $inp_attr    = { name => $name, type => 'radio' };
   my $mode        = $self->is_xml ? GT_CLOSETAG : 0;
   my $html        = $NUL;
   my $i           = 1;

   $args->{onchange} and $inp_attr->{onchange} = $args->{onchange};

   for my $val (grep { defined } @{ $values }) {
      $inp_attr->{value   } = $val;
      $inp_attr->{tabindex} = $i;
      $val =~ m{ \d+ }mx and $def =~ m{ \d+ }mx  and $val == $def
         and $inp_attr->{checked } = $self->is_xml ? 'checked' : undef;
     ($val !~ m{ \d+ }mx or  $def !~ m{ \d+ }mx) and $val eq $def
         and $inp_attr->{checked } = $self->is_xml ? 'checked' : undef;
      $html .= generate_tag( 'input', $inp_attr, undef, $mode );
     (exists $labels->{ $val } and not defined $labels->{ $val })
         or  $html .= generate_tag( 'label',
                                    { class => $label_class },
                                    ($labels->{ $val } || $val),
                                    GT_ADDNEWLINE );
      $i % $cols == 0 and $html .= generate_tag( 'br', undef, undef, $mode );
      delete $inp_attr->{checked};
      $i++;
   }

   return $html;
}

sub scrolling_list {
   my ($self, @args) = @_; my $args = $_hashify->( @args );

   $args->{multiple} = 'multiple';
   return $self->popup_menu( $args );
}

sub AUTOLOAD { ## no critic
   my ($self, @args) = @_; my $args = {};

   my $mode = GT_ADDNEWLINE; my $val = $args[ 0 ];

  (my $elem = lc $HTML::Accessors::AUTOLOAD) =~ s{ .* :: }{}mx;

   if ($val and ref $val eq 'HASH') { $args = { %{ $val } }; $val = $args[ 1 ] }

   if (exists $INP->{ $elem }) {
      $args->{type} = $INP->{ $elem };
      defined $args->{default} and $args->{value} = delete $args->{default};
      defined $args->{value  } or  $args->{value} = $NUL;
      $elem = 'input';
   }

   unless ($HTML::Tagset::isKnown{ $elem }) { ## no critic
      carp "Unknown element $elem"; return;
   }

   $val //= delete $args->{default} // $NUL;

   if ($HTML::Tagset::emptyElement{ $elem }) { ## no critic
      $val = undef; $mode = $self->is_xml ? GT_CLOSETAG : 0;
   }

   return generate_tag( $elem, $args, $val, $mode );
}

sub DESTROY {}

1;

__END__

=pod

=encoding utf8

=begin html

<a href="https://travis-ci.org/pjfl/p5-html-accessors"><img src="https://travis-ci.org/pjfl/p5-html-accessors.svg?branch=master" alt="Travis CI Badge"></a>
<a href="http://badge.fury.io/pl/HTML-Accessors"><img src="https://badge.fury.io/pl/HTML-Accessors.svg" alt="CPAN Badge"></a>
<a href="http://cpants.cpanauthors.org/dist/HTML-Accessors"><img src="http://cpants.cpanauthors.org/dist/HTML-Accessors.png" alt="Kwalitee Badge"></a>

=end html

=head1 Name

HTML::Accessors - Generate HTML elements

=head1 Version

Describes version v0.13.$Rev: 3 $ of L<HTML::Accessors>

=head1 Synopsis

   use HTML::Accessors;

   my $hacc = HTML::Accessors->new();

   # Create an anchor element
   $anchor = $hacc->a( { href => 'http://...' }, 'This is a link' );

=head1 Description

Uses L<HTML::GenerateUtil> to create an autoload method for each of
the elements defined by L<HTML::Tagset>. The API was loosely taken
from L<CGI>. Using the L<CGI> module is undesirable in a L<Catalyst>
application (run from the development server) due go greediness issues
over STDIN.

The returned tags are either XHTML 1.1 or HTML 5 compliant.

=head1 Configuration and Environment

The constructor defines accessors and mutators for one attribute:

=over 3

=item C<content_type>

Defaults to I<application/xhtml+xml> which causes the generated tags
to conform to the XHTML standard. Setting it to I<text/html> will
generate HTML compatible tags instead

=back

=head1 Subroutines/Methods

=head2 new

   my $hacc = HTML::Accessors->new( content_type => 'application/xhtml+xml' );

Uses C<_hashify> to process the passed options

=head2 content_type

   $content_type = $hacc->content_type( $new_type );

Accessor / mutator for the C<content_type> attribute

=head2 escape_html

   my $escaped_html = $hacc->escape_html( $unescaped_html );

Expose the method L<escape_html|HTML::GenerateUtil/FUNCTIONS>

=head2 is_xml

   my $bool = $hacc->is_xml;

Returns true if the returned tags will be XHTML. Matches the string I<.xml>
at the end of the I<content_type>

=head2 popup_menu

   my $html = $hacc->popup_menu( default => $value, labels => {}, values => [] );

Returns the C<< <select> >> element. The first option passed to
C<popup_menu> is either a hash ref or a list of key/value pairs. The keys are:

=over 3

=item C<classes>

A hash ref keyed by the I<values> attribute. It lets you to set the I<class>
attribute of each C<< <option> >> element

=item C<default>

Determines which of the values will be selected by default

=item C<labels>

Display these labels in place of the values (but return the value
of the selected label). This is a hash ref with a key for each
element in the C<values> array

=item C<values>

The key references an array ref whose values are used as the list of
options returned in the body of the C<< <select> >> element

=back

The rest of the keys and values are passed as attributes to the
C<< <select> >> element. For example:

   $ref = { default => 1, name => 'my_field', values => [ 1, 2 ] };
   $hacc->popup_menu( $ref );

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

=item C<columns>

Integer number of columns to display the generated buttons in. If
zero then a list of radio buttons without breaks is generated

=item C<default>

Determines which of the radio box will be selected by default

=item C<label_class>

Class of the labels generated for each button

=item C<labels>

Display these labels next to each button. This is a hash ref with a
key for each element in the C<values> array

=item C<name>

The form name of the generated buttons

=item C<onchange>

An optional JavaScript reference. The JavaScript will be executed each time
a different radio button is selected

=item C<values>

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
   $hacc->radio_group( $ref );

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

   $hacc->textfield( { default => 'default value', name => 'my_field' } );

would return

   <input value="default value" name="my_field" type="text" />

The list of input elements contains; button, checkbox, hidden,
image_button, password_field, radio_button, submit, and textfield

Carp and return C<undef> if the element does not exist in list of known
L<elements|HTML::Tagset/isKnown>

=head2 DESTROY

Implement the C<DESTROY> method so that the C<AUTOLOAD> method doesn't get
called instead

=head2 _hash_merge

Simplistic merging of two hashes

=head2 _hashify

Returns a hash ref containing the passed parameter list. Enables
methods to be called with either a list or a hash ref as it's input
parameters. Makes copies as it goes so that you can change the contents
without altering the parameters if they were passed by reference

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

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=HTML-Accessors.  Patches are welcome

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 License and Copyright

Copyright (c) 2015 Peter Flanigan. All rights reserved.

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
