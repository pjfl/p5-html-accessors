#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

# Stop chris from smoke testing
my $cond = q($ENV{PERL5LIB} =~ m{ home/cpan/perl58[123] }mx);
my $requires = { 'perl'                  => q(5.008),
                 'version'               => q(0.74),
                 'Class::Accessor::Fast' => q(0.31),
                 'HTML::GenerateUtil'    => q(1.08),
                 'HTML::Tagset'          => q(3.10),
                 'NEXT'                  => q(0.60),
                 'Readonly'              => q(1.03) };
my $build = Module::Build->new
   ( build_requires     => { 'Test::More' => q(0.74) },
     configure_requires => { 'version' => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/HTML/Accessors.pm),
     license            => q(perl),
     module_name        => q(HTML::Accessors),
     notes              => { cpan_testers_version => 1,
                             cpan_testers_cond    => $cond },
     requires           => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
