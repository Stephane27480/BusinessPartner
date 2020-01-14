 use strict;
 use FindBin;
 use lib "$FindBin::Bin/../lib";
 use warnings;
 use Moose;
 use appVies;
 use Test::More tests => 2;

 # Test instanciation
 my $vat = "FR21432673838" ;

my $class = appVies->new( vat => $vat  );
ok $class, "Class Instanciée";

my $data = $class->main( );
ok $data, "Member State : $data\n";

#foreach my $h (keys %$infoRef) {
#	print "$h \t $infoRef->{$h}\n";
#}

done_testing();


