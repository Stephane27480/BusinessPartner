package formatInseeSiret {
use Modern::Perl ;
 use Carp;
 use Moose;
 use POSIX qw(strftime);
 use Data::Dumper;
 use FindBin;
 use lib "$FindBin::Bin/./";

 # Attributes
 has 'data' => (is => 'ro', isa => 'Str', required => 1, writer => '_set_data');
 has 'header' =>( is => 'ro', isa => 'Str', writer => '_set_header');
 has 'body'=>( is => 'ro', isa => 'Str', writer => '_set_body');

### other methods ###
sub get_etablissement {
	my ($self, $formatRef, $regex) = @_ ;
	my $result = "\"etablissements\":[{";
	my $body = $self->data ;
	my @etablissement = split( /{"siren":/, $body);
	shift(@etablissement);
	my $descr ;
	my @valeurs ;my $siret; ; my  $address ;
	foreach (@etablissement) {
		if (m/$regex/){
			my $data = $_ ;
			$descr = "siret";
			$result =  $self->getset_value( $result, $data , $descr, ','  );
			$result =~ s/\"siret\":/\"{siret\":/;	
			$descr = "etablissementSiege";
			$result =  $self->getset_bool( $result, $data , $descr, ','  );
			$descr = "adresseEtablissement";
			$address =  $self->getset_value( $result, $data , $descr, '},' ); 		 	
			$address =~ s/"\w+":null,//g ;
			$address =~ s/"\w+":null}/}/g;
			# delete null object
			$address =~ s/"\w+":\{\},//g;
			$address =~ s/,}/}/g;
			$result =  $address ;
		}	
	}
	$result =~ s/,$/]/;
	$self->_set_body($result) ;
}


sub get_vat {
	my ($self, $siren) = @_ ;
	my $modulo = (12 + ( 3 * ( $siren % 97)) %97) ;
	my $vat = "FR$modulo$siren" ;
	return $vat ;
		}

sub get_header {
	my ( $self  ) = @_ ;
	my $data = $self->data ;
	my $siren = $self->get_value( $data, 'siren', ',' );
	my $result = '{"header":{';
	$result = $self->add_to_return( $result , 'siren' , $siren , ',');
	# Get the VAT	
	if ( $siren =~ /\"(\d{9})\"/) {
		$siren = $1 ;
		my $vat = $self->get_vat( $siren ) ;
		if (defined $vat ) {
			$result = $self->add_to_return( $result , 'vat' , $vat , ',');
		}
	}
	# check if personn company or not
	my $descr = 'categorieJuridiqueUniteLegale'; 
	my $value = $self->get_value( $data , $descr, ',' );
	$result = $self->add_to_return( $result , $descr, $value , ',');
	
	if ($value ne '1000') {
		# company
		$descr = "denominationUniteLegale";  
		$result =  $self->getset_value( $result, $data , $descr, ',', 'name' );
		$descr = "denominationUsuelle1UniteLegale";  
		$result =  $self->getset_value( $result, $data , $descr, ',', 'name2' );
		$descr = "denominationUsuelle2UniteLegale";  
		$result =  $self->getset_value( $result, $data , $descr, ',', 'name3' );
		$descr = "denominationUsuelle3UniteLegale";  
		$result =  $self->getset_value( $result, $data , $descr, ',', 'name4' );

	} else {
		# personal company
		$descr = "nomUniteLegale";  
		$result =  $self->getset_value( $result, $data , $descr, ',', 'name' );
		$descr = "nomUsageUniteLegale";  
		$result =  $self->getset_value( $result, $data , $descr, ',', 'name2' );
	}
	# Get the company category
	$descr = "categorieEntreprise";  
	$result =  $self->getset_value( $result, $data , $descr);
	$result .= "}";
	$self->_set_header( $result );
	}

sub add_to_return {
	my ($self,  $result, $descr, $value, $end ) = @_ ;
	# this is just a macro to concatenate the data
		$result .= "\"$descr\":$value$end";
	return $result ;
}

sub get_value {
	my ( $self, $data, $descr, $end ) = @_;
	my $value ;
	# faire un test sur $end si commence par } 
	if ($end =~ /^\}/) {
		if ($data =~ /\"$descr\":(\{\".+?\}),\"/ ) { 
			 $value = $1 ;}
	} elsif ($data =~ /\"$descr\":(\".+?\")$end/ ) { 
		 $value = $1 ;}
	return $value ;
}

sub getset_value {
	my ( $self, $result, $data, $descr, $end, $otherdescr ) = @_;
	if ( !defined $end) { $end = '' ;}

	my $value = $self->get_value( $data , $descr, $end );
	if ( defined $value ) {
		if (defined $otherdescr ) { $descr = $otherdescr; }
		$result = $self->add_to_return( $result , $descr, $value , $end );
	}
	return $result ;
}

sub getset_bool {
	my ( $self, $result, $data, $descr, $end ) = @_;
	if ( !defined $end) { $end = '' ;}

	my $value = $self->get_bool( $data , $descr, $end );
	if ( defined $value ) {
		$result = $self->add_to_return( $result , $descr, $value , $end );
	}
	return $result ;
}	


sub get_bool {
	my ( $self, $data, $descr, $end ) = @_;
	my $value ;
	# faire un test sur $end si commence par } 
	if ($end =~ /^\}/) {
		if ($data =~ /\"$descr\":(\{.+?\}),/ ) { 
			 $value = $1 ;}
	} elsif ($data =~ /\"$descr\":(.+?)$end/ ) { 
		 $value = $1 ;}
	return $value ;
}
1;
}
