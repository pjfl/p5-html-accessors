<div>
    <a href="https://travis-ci.org/pjfl/p5-html-accessors"><img src="https://travis-ci.org/pjfl/p5-html-accessors.svg?branch=master" alt="Travis CI Badge"></a>
    <a href="http://badge.fury.io/pl/HTML-Accessors"><img src="https://badge.fury.io/pl/HTML-Accessors.svg" alt="CPAN Badge"></a>
    <a href="http://cpants.cpanauthors.org/dist/HTML-Accessors"><img src="http://cpants.cpanauthors.org/dist/HTML-Accessors.png" alt="Kwalitee Badge"></a>
</div>

# Name

HTML::Accessors - Generate HTML elements

# Version

Describes version v0.12.$Rev: 3 $ of [HTML::Accessors](https://metacpan.org/pod/HTML::Accessors)

# Synopsis

    use HTML::Accessors;

    my $hacc = HTML::Accessors->new();

    # Create an anchor element
    $anchor = $hacc->a( { href => 'http://...' }, 'This is a link' );

# Description

Uses [HTML::GenerateUtil](https://metacpan.org/pod/HTML::GenerateUtil) to create an autoload method for each of
the elements defined by [HTML::Tagset](https://metacpan.org/pod/HTML::Tagset). The API was loosely taken
from [CGI](https://metacpan.org/pod/CGI). Using the [CGI](https://metacpan.org/pod/CGI) module is undesirable in a [Catalyst](https://metacpan.org/pod/Catalyst)
application (run from the development server) due go greediness issues
over STDIN.

The returned tags are either XHTML 1.1 or HTML 5 compliant.

# Configuration and Environment

The constructor defines accessors and mutators for one attribute:

- `content_type`

    Defaults to _application/xhtml+xml_ which causes the generated tags
    to conform to the XHTML standard. Setting it to _text/html_ will
    generate HTML compatible tags instead

# Subroutines/Methods

## new

    my $hacc = HTML::Accessors->new( content_type => 'application/xhtml+xml' );

Uses `_hashify` to process the passed options

## content\_type

    $content_type = $hacc->content_type( $new_type );

Accessor / mutator for the `content_type` attribute

## escape\_html

    my $escaped_html = $hacc->escape_html( $unescaped_html );

Expose the method [escape\_html](https://metacpan.org/pod/HTML::GenerateUtil#FUNCTIONS)

## is\_xml

    my $bool = $hacc->is_xml;

Returns true if the returned tags will be XHTML. Matches the string _.xml_
at the end of the _content\_type_

## popup\_menu

    my $html = $hacc->popup_menu( default => $value, labels => {}, values => [] );

Returns the `<select>` element. The first option passed to
`popup_menu` is either a hash ref or a list of key/value pairs. The keys are:

- `classes`

    A hash ref keyed by the _values_ attribute. It lets you to set the _class_
    attribute of each `<option>` element

- `default`

    Determines which of the values will be selected by default

- `labels`

    Display these labels in place of the values (but return the value
    of the selected label). This is a hash ref with a key for each
    element in the `values` array

- `values`

    The key references an array ref whose values are used as the list of
    options returned in the body of the `<select>` element

The rest of the keys and values are passed as attributes to the
`<select>` element. For example:

    $ref = { default => 1, name => 'my_field', values => [ 1, 2 ] };
    $hacc->popup_menu( $ref );

would return:

    <select name="my_field">
       <option selected="selected">1</option>
       <option>2</option>
    </select>

## radio\_group

Generates a list of radio input buttons with labels. Break elements can
be inserted to create rows of a given number of columns when
displayed. The first option passed to `radio_group` is either a hash
ref or a list of key/value pairs. The keys are:

- `columns`

    Integer number of columns to display the generated buttons in. If
    zero then a list of radio buttons without breaks is generated

- `default`

    Determines which of the radio box will be selected by default

- `label_class`

    Class of the labels generated for each button

- `labels`

    Display these labels next to each button. This is a hash ref with a
    key for each element in the `values` array

- `name`

    The form name of the generated buttons

- `onchange`

    An optional JavaScript reference. The JavaScript will be executed each time
    a different radio button is selected

- `values`

    The key references an array ref whose values are returned by the
    radio buttons

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

## scrolling\_list

Calls `popup_menu` with the `multiple` argument set to
`multiple`. This has the effect of allowing multiple selections to
be returned from the popup menu

## AUTOLOAD

Uses [HTML::Tagset](https://metacpan.org/pod/HTML::Tagset) to check if the requested method is a known HTML
element. If it is `AUTOLOAD` uses [HTML::GenerateUtil](https://metacpan.org/pod/HTML::GenerateUtil) to create the tag

If the first option is a hash ref then the keys and values are copied
and passed to `HTML::GenerateUtil::generate_tag` which uses them to
set the attributes on the created element. The next option is treated
as the element's body text and overrides the `default` attribute which
is passed and deleted from the options hash

If the requested element exists in the hard coded list of input
elements, then the element is set to `input` and the mapped value
used as the type attribute in the call to `generate_tag`. For example;

    $hacc->textfield( { default => 'default value', name => 'my_field' } );

would return

    <input value="default value" name="my_field" type="text" />

The list of input elements contains; button, checkbox, hidden,
image\_button, password\_field, radio\_button, submit, and textfield

Carp and return `undef` if the element does not exist in list of known
[elements](https://metacpan.org/pod/HTML::Tagset#isKnown)

## DESTROY

Implement the `DESTROY` method so that the `AUTOLOAD` method doesn't get
called instead

## \_hash\_merge

Simplistic merging of two hashes

## \_hashify

Returns a hash ref containing the passed parameter list. Enables
methods to be called with either a list or a hash ref as it's input
parameters. Makes copies as it goes so that you can change the contents
without altering the parameters if they were passed by reference

# Diagnostics

[Carp](https://metacpan.org/pod/Carp#carp) is called to issue a warning about undefined elements

# Dependencies

- [Class::Accessor::Fast](https://metacpan.org/pod/Class::Accessor::Fast)
- [HTML::GenerateUtil](https://metacpan.org/pod/HTML::GenerateUtil)
- [HTML::Tagset](https://metacpan.org/pod/HTML::Tagset)

# Incompatibilities

There are no known incompatibilities in this module

# Bugs and Limitations

There are no known bugs in this module. Please report problems to
http://rt.cpan.org/NoAuth/Bugs.html?Dist=HTML-Accessors.  Patches are welcome

# Acknowledgements

Larry Wall - For the Perl programming language

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# Acknowledgements

Larry Wall - For the Perl programming language

# License and Copyright

Copyright (c) 2015 Peter Flanigan. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/pod/perlartistic).

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
