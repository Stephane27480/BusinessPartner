use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use warnings;
use InseeSiret ;
use Test::More tests => 8;
use Moose;
use Mojo::Util qw(dumper);
 # Test instanciation 
my $user = "INSEE27480";
my $consKey = "7z6CyvFaIzyH1WC4NX06zUIg3j8a";
my $secKey = "N2FYCzsyOl3qZJwvf_WeWiMIKzga";

my $class = InseeSiret->new( user => $user,
						consKey => $consKey,
						secKey => $secKey );
my $ruser = $class->user;
is  $ruser, $user, "User shall be $user";
my $rconsKey =  $class->consKey; 
is $rconsKey, $consKey, "consKey shall be true";
my $rsecKey =  $class->secKey;
is $rsecKey, $secKey, "secKey shall be true";
my $rdate =  $class->date;  
ok $rdate , "date: $rdate";

# test get token
my $token = $class->get_token ;
ok $token, "Token: $token";

# test get the siret from SIREN
#my $siren = '432673838';
my $siren = '552081317';
my $params ="/siret?q=siren:$siren ";

my $data = $class->response(  $params );
#my $data = $dataRef ;
ok $data, "la réponse devrait être remplie";
#print "$data\n" ;
# write in a file
open my($out), '>', "./../temp/response.txt";
	print $out  $data ;
close $out;

# test get the siret 
my $siret = '43267383800053';
 $params ="/siret?q=siret:$siret ";
 $data = $class->response(  $params );
#my $data = $dataRef ;
ok $data, "la réponse devrait être remplie";
#print "$data\n" ;
# write in a file
open my($etab), '>', "./../temp/response_siret.txt";
	print $etab  $data ;
close $etab;

# test get the siret from adress 
my $name = 'codilog';
my $cp = '80???';
 $params = "/siret?q=denominationUniteLegale:$name AND codePostalEtablissement:$cp ";
 $data = $class->response(  $params );
#my $data = $dataRef ;
ok $data, "la réponse devrait être remplie";
#print "$data\n" ;
# write in a file
open my ($adress), '>', "./../temp/response_name.txt";
	print $adress  $data ;
close $adress;

# test get the siret from name
$name = 'coquart';
#my $cp = '80???';
 $params = "/siret?q=denominationUniteLegale:$name ";
 $data = $class->response(  $params );
#my $data = $dataRef ;
ok $data, "la réponse devrait être remplie";
#print "$data\n" ;
# write in a file
open my ($nameonly), '>', "./../temp/response_nameionly.txt";
	print $nameonly  $data ;
close $nameonly;

