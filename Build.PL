#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

# Stop chris from smoke testing with broken HTML::GenerateUtil
#my $cond     = q(qx(uname -a) =~ m{ canker.bingosnet.co.uk }mx);
my $requires = { 'perl'                  => q(5.008),
                 'parent'                => q(0.221),
                 'version'               => q(0.74),
                 'Class::Accessor::Fast' => q(0.31),
                 'HTML::GenerateUtil'    => q(1.08),
                 'HTML::Tagset'          => q(3.10) };
my $build    = Module::Build->new
   ( add_to_cleanup     => [ 'HTML-Accessors-*',
                             map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Test::Harness'       => q(2.64),
                             'Test::More'          => q(0.74),
                             'Test::Pod'           => q(1.14) },
     configure_requires => { 'ExtUtils::MakeMaker' => q(6.42),
                             'version'             => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/HTML/Accessors.pm),
     license            => q(perl),
     module_name        => q(HTML::Accessors),
     notes              => { cpan_testers_version => 1 },
     requires           => $requires,
     sign               => 1 );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
