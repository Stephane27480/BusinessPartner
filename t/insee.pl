 use strict;
 use FindBin;
 use lib "$FindBin::Bin/../lib";
 use warnings;
 use Insee ;
use Test::More tests => 6;
use Moose;

 # Test instanciation 
my $user = "INSEE27480";
my $consKey = "7z6CyvFaIzyH1WC4NX06zUIg3j8a";
my $secKey = "N2FYCzsyOl3qZJwvf_WeWiMIKzga";

my $class = Insee->new( user => $user,
						consKey => $consKey,
						secKey => $secKey );
$user = $class->user;
ok $user, "User shall be $user";
ok  $class->consKey, "consKey shall be true";
ok  $class->secKey, "secKey shall be true";
ok  $class->date, "date: $class->date";

# test get token
my $token = $class->get_token ;
ok $class->token, "Token: $class->token";

# test get the siret from SIREN
#my $siren = '432673838';
#my $sirets = $class->getSiret( $siren );
#ok $sirets, "Siret devrait être rempli";

# test date
my $date = $class->get_date;
ok $date, "Date : $date";

done_testing();


