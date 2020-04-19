use Test::More tests => 1;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use warnings;
use Moose;
use appSOS;

my $install ="1234";
my $msg = '/CDLG/BP 001';
my $desc = 'Test pour SOS';
my $syst = 'RE1CLNT100';
my $prod = '';

my $request = appSOS->new(
	install => 	$install,
	syst	=>	$syst,
	msg		=> 	$msg,
	desc	=>	$desc,
	prod	=>	$prod,
);
# Add a new card...
my $response = $request->main( );
is( $response, '200', 'Card added' );
