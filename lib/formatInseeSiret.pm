package formatInseeSiret {
use Modern::Perl ;
 use Carp;
 use Moose;
 use POSIX qw(strftime);
 use Mojo::Util qw(dumper);
 use Mojo::JSON qw(decode_json encode_json);
 use FindBin;
 use lib "$FindBin::Bin/./";
 use vies;
 use Data::Dumper;
=pod 

=head1 formatInseeSiret

 This class is the utility to format the response from the API

=over 2

=item * Attribute data represents the response from InseeSiret

=item * Attribute siren represents the SIREN number

=back

=cut

 # Attributes
 has 'data' => (is => 'ro', isa => 'Str', required => 1, writer => '_set_data');
 has 'siren' => (is => 'ro', isa => 'Str', writer => '_set_siren');
### other methods ###
=pod

=head1 Method get_etablissement
	This method get the list of Etablissement
	It formats the result

=cut
 
sub get_etablissement {
	my ($self, $etabRef) = @_ ;
	my %etab;
	# get the siret
	my $descr = "siret";
	$etab{$descr} = $etabRef->{$descr};
	# get the status for header quaters
	$descr = "etablissementSiege";
	$etab{$descr} = $etabRef->{$descr};
	# Get the Address
	$descr = "adresseEtablissement"; 
	# Get Unite Legale
	my $ulRef = $etabRef->{uniteLegale};
	
	# get the category of the company 1000=> personal
	my $categ = $ulRef->{categorieJuridiqueUniteLegale}; 
		if ($categ ne '1000') {
			# company
			$etabRef->{$descr}{name} = $ulRef->{denominationUniteLegale};
			
		} else {
			# personal company
			$etabRef->{$descr}{name} = $ulRef->{nomUniteLegale};
		}
	$etabRef->{$descr}{libellePaysEtranger} = $etabRef->{$descr}{libellePaysEtrangerEtablissement} ;
	$etabRef->{$descr}{distributionSpeciale} = $etabRef->{$descr}{distributionSpecialeEtablissement} ;
	$etabRef->{$descr}{libelleCommuneEtranger} = $etabRef->{$descr}{libelleCommuneEtrangerEtablissement} ;
	delete $etabRef->{$descr}->{libellePaysEtrangerEtablissement};
	delete $etabRef->{$descr}->{distributionSpecialeEtablissement} ;
	delete $etabRef->{$descr}->{libelleCommuneEtrangerEtablissement} ;
	$etab{$descr} = $etabRef->{$descr};
	# Get the data from the periodes etablissement
	 $descr = "periodesEtablissement";
	my $periodesRef = $etabRef->{$descr};
	foreach my $periode (@$periodesRef) {

		if (!defined $periode->{"dateFin"}) {
			$descr = "activitePrincipaleEtablissement";
			$etab{activitePrincipale} = $periode->{$descr}; 
		}
	}
	

	return \%etab;
	}

sub get_vat {
	my ($self, $siren) = @_ ;
	my $modulo = ((12 + ( 3 * ( $siren % 97))) %97) ;
	if ( length( $modulo ) ne 2){ $modulo = 0 . $modulo; }
	my $vat = "FR$modulo$siren" ;
	my $vies = vies->new( vat => $vat );
	$vat = $vies->main( );
	return $vat ;
		}

=pod

=head1 Method get_header
		This method provide the information for the SIREN
		Company name VAT SIREN Category
=head2 Attributes :		
	None

=cut

sub get_header {
	my ( $self, $etabRef  ) = @_ ;
	my $siren = $etabRef->{siren};
	my %header ;
	$self->_set_siren( $siren );
	 $header{siren} = $siren ;
	my $descr;
	# Get the VAT	
			my $vat = $self->get_vat( $siren ) ;
			if (defined $vat ) {
			 $header{vat} = $vat; 
			}	
			
	# check if personn company or not
	# Get Unite Legale
	my $ulRef = $etabRef->{uniteLegale};
	# get the category of the company 1000=> personal
	my $categ = $ulRef->{categorieJuridiqueUniteLegale}; 
		$header{"categorieJuridique"} = $categ;	
		if ($categ ne '1000') {
			# company
			$descr = "denominationUniteLegale";  
			$header{name} = $ulRef->{$descr};
			$descr = "denominationUsuelle1UniteLegale";  
			$header{name2} = $ulRef->{$descr};
			$descr = "denominationUsuelle2UniteLegale";  
			$header{name3} = $ulRef->{$descr};
			$descr = "denominationUsuelle3UniteLegale";  
			$header{name4} = $ulRef->{$descr};

		} else {
			# personal company
			$descr = "nomUniteLegale";  
			$header{name} = $ulRef->{$descr};
			$descr = "nomUsageUniteLegale";  
			$header{name2} = $ulRef->{$descr};
		}
	# Get the company category
	$descr = "categorieEntreprise";  
	$header{$descr} = $ulRef->{$descr};
	$descr = "activitePrincipaleUniteLegale";
	$header{activitePrincipale} = $ulRef->{$descr};

	return %header;
	}

=head1 Method main
	This method calls the get_header method
	and get_etablissement method then builds 
	the JSON data

=cut	

sub main {
	my $self = shift;
	my %header;
	my @body;
	my $dataRef = decode_json( $self->data  ); 
	# Get the data from the etablissements 
	my $etabRef = $dataRef->{etablissements};	
	foreach my $etab (@$etabRef) {
		if (!defined $self->siren) {
			%header = $self->get_header( $etab ); 
		}
			push (@body, $self->get_etablissement( $etab ));
	}

	$header{etablissements} = \@body;	 
	
	my $dataJSON = encode_json(\%header);
	return $dataJSON ;

	}
	1;
}
