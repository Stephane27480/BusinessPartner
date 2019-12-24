 use strict;
 use FindBin;
 use lib "$FindBin::Bin/../lib";
 use warnings;
 use Moose;
 use formatInseeSiret;
 use Mojo::Util qw(dumper);
 use Test::More tests => 3;

 # Test instanciation
 my $data ;
open IN,  "./../temp/response.txt";
	while (my $line = <IN>){
		$data .= $line;
	}
close IN;

my $class = formatInseeSiret->new( data => $data );
ok $class, "Class Instanciée";

my $data2 = $class->main( );
open OUT, '>', "./../temp/json.txt";
print OUT   $data2  ;
close OUT;
ok $data2, "JSON received"; 

my $siren = $class->siren;
ok $siren, "SIREN : $siren";

done_testing();


