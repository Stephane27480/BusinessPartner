 use strict;
 use FindBin;
 use lib "$FindBin::Bin/../lib";
 use warnings;
 use Moose;
 use vies;
 use Test::More tests => 5;

 # Test instanciation
 my $vat = "FR21432673838" ;

my $class = vies->new( vat => $vat  );
ok $class, "Class Instanciée";

my $cc_check = $class->check_country( );
ok $cc_check, "Member State : $cc_check\n";
$class->main( );
my $vat_check = $class->check_vat( );
ok $vat_check, "VAT : $vat_check\n";
ok $class->{errorCode}, "Error Code: $class->{errorCode}\n";
my $param = 'name';	
my $name = $class->get_info( $param  ); 
ok $name, "Name : $name \n";
$param = '';
my $infoRef = $class->get_info( );
foreach my $h (keys %$infoRef) {
	print "$h \t $infoRef->{$h}\n";
}

done_testing();


