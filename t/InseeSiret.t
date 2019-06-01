 use strict;
 use FindBin;
 use lib "$FindBin::Bin/../lib";
 use warnings;
 use InseeSiret ;
use Test::More tests => 6;
use Moose;

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
my $siren = '432673838';
my $sirets = $class->getSiret( $siren );
ok $sirets, "Siret devrait être rempli";
print $sirets ;
# test date

done_testing();


