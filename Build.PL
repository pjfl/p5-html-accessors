# @(#)$Ident: Build.PL 2013-05-16 20:52 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.8.%d', q$Rev: 1 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(HTML::Accessors),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'               => 5.01,
      'parent'             => 0.224,
      'Class::Accessor'    => 0.34,
      'HTML::GenerateUtil' => 1.10,
      'HTML::Tagset'       => 3.20, },
   recommends          => {
      'App::cpanminus' => 1.6005, },
   configure_requires  => {
      'version'        => 0.88,
      'Module::Build'  => 0.4004, },
   build_requires      => {
      'version'        => 0.88,
      'Module::Build'  => 0.4004, },
} )->create_build_script; # Goal!

# Local Variables:
# eval: (load-project-state "html-accessors")
# mode: perl
# tab-title: Accessors
# tab-width: 3
# End:
