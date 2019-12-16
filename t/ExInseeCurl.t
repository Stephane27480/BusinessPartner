 use strict;
 use FindBin;
 use lib "$FindBin::Bin/../lib";
 use warnings;
 use ExInseeCurl ;
use Test::More tests => 1;
use Moose;
use Try::Tiny ;

 # Test instanciation 

 my $exClass = try {ExInseeCurl->throw({
             code => '200',
             method => 'TestInstanciation'}) }
 			catch { if( blessed($_) and $_->isa('ExInseeCurl')){
				my $code = $_->code ;
				print "Error $code \n";
				ok $code, "Code: $code";
			}};


done_testing();


