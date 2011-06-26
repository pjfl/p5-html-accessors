# @(#)$Id$

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev$ =~ /\d+/gmx );

Bob->new( {
   stop_tests => 1,
   license    => q(perl),
   module     => q(HTML::Accessors),
   home_page  => q(http://www.roxsoft.co.uk),
   requires   => {
      'perl'                  => q(5.008),
      'parent'                => q(0.221),
      'version'               => q(0.74),
      'Class::Accessor::Fast' => q(0.31),
      'HTML::GenerateUtil'    => q(1.08),
      'HTML::Tagset'          => q(3.10) },
   configure_requires => { 'Module::Build' => 0.32,
                           'version'       => 0.74, },
   build_requires     => { 'Test::More'    => 0.74, },
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# tab-width: 3
# End:
