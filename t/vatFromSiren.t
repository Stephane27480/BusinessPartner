use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use warnings;
use vatFromSiren ;
use Test::More tests => 1;
use Moose;
use Mojo::Util qw(dumper);

my $class = vatFromSiren->new( );

#test vat determination
my $siren = '432673838';
my $vat = $class->vatDetermination( $siren );
is $vat, 'FR21432673838', "vat shall be FR21432673838";

