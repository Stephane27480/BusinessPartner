use Test::More tests => 1;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use warnings;
use Moose;
use Data::Dumper;
use appSOS;

my $install ="1234";
my $msg = '_CDLG_BP 011';
my $desc = "Le code TRI inexistant pas dans la table /cdlg/bp_categ";
my $syst = 'RE1CLNT100';
my $prod = ' ';

my $request = appSOS->new(
	install => 	$install,
	syst	=>	$syst,
	msg		=> 	$msg,
	desc	=>	$desc,
	prod	=>	$prod,
);
# Add a new card...
my $response = $request->main( );
#print "header :";
#print Dumper($response->headers);
#print "code: ";
#print Dumper($response->code);
#print "body :";
#print Dumper($response->body);
print "Message :";
print Dumper($response->message);
is( $response->code, '200', 'Card added' );
done_testing( );
