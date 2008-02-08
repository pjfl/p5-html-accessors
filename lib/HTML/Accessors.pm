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
   $def       = defined $args->{default} ? $args->{default} : 0;
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

   $val = delete $args->{default} if (defined $args->{default});

## no critic
   if ($HTML::Tagset::emptyElement{ $elem }) {
## critic
      ($val, $mode) = (undef, GT_CLOSETAG);
   }
   else { $val ||= $NUL }

   return generate_tag( $elem, $args, $val, $mode );
}

sub DESTROY { my ($me, @rest) = @_; return $me->NEXT::DESTROY( @rest ) }

# Private methods

sub _carp { require Carp; goto &Carp::carp }

sub _croak { require Carp; goto &Carp::croak }

1;

__END__

=pod

=head1 Name

HTML::Accessors - Generate HTML elements

=head1 Version

0.1.$Revision$

=head1 Synopsis

   use HTML::Accessors;

   my $htag = HTML::Accessors->new( );

   # Create an anchor element
   $anchor = $htag->a( { href => 'http://...' }, 'This is a link' );

=head1 Description

=head1 Configuration and Environment

=head2 new

=head1 Subroutines/Methods

=head2 AUTOLOAD

=head1 Diagnostics

None

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

Copyright (c) 2007 RoxSoft Limited. All rights reserved.

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
