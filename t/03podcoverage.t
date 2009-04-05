# @(#)$Id: 03podcoverage.t 288 2008-11-25 01:03:57Z pjf $

use strict;
use warnings;
use File::Spec::Functions;
use FindBin ();
use lib catfile( $FindBin::Bin, updir, q(lib) );
use Test::More;

BEGIN {
   if (!-e catfile( $FindBin::Bin, updir, q(MANIFEST.SKIP) )) {
      plan skip_all => 'POD coverage test only for developers';
   }
}

eval "use Test::Pod::Coverage 1.04";

plan skip_all => 'Test::Pod::Coverage 1.04 required' if ($@);

all_pod_coverage_ok();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
