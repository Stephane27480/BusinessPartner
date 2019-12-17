 use strict;
 use FindBin;
 use lib "$FindBin::Bin/../lib";
 use warnings;
 use Moose;
 use formatInseeSiret;
 use Test::More tests => 4;

 # Test instanciation
 my $data ;
open IN,  "./../temp/response.txt";
	while (my $line = <IN>){
		$data .= $line;
	}
close IN;

my $class = formatInseeSiret->new( data => $data );
ok $class, "Class Instanciée";

my $siren = $class->get_value( $data, 'siren', ',' );
ok $siren, "SIREN : $siren\n";

$class->get_header( );
my $header = $class->header;
ok $header, "Header : $header\n";

my $regex = '\"periodesEtablissement\":\[\{\"dateFin\":null,\"dateDebut\":\"\d{4}-\d{2}-\d{2}\",\"etatAdministratifEtablissement\":\"A\"';
 $class->get_etablissement( $regex );
my $body = $class->body ;
ok $body, "BODY : $body \n";


done_testing();


