package formatInseeSiret {
use Modern::Perl ;
 use Carp;
 use Moose;
 use POSIX qw(strftime);
 use Data::Dumper;
 use FindBin;
 use lib "$FindBin::Bin/./";

=pod 

=head1 formatInseeSiret

 This class is the utility to format the response from the API

=over 4

=item * Attribute data represents the response from InseeSiret

=item * Attribute header is the text we put in the object Header

=item * Attribute body is the list of SIRET

=back

=cut

 # Attributes
 has 'data' => (is => 'ro', isa => 'Str', required => 1, writer => '_set_data');
 has 'header' =>( is => 'ro', isa => 'Str', writer => '_set_header');
 has 'body'=>( is => 'ro', isa => 'Str', writer => '_set_body');

### other methods ###
=pod

=head1 Method get_etablissement
	This method get the list of Etablissement
	It formats the result

=head2 Attributes :

=over 3

=item  $regex 
	Allows to only get the active etablissement

=back

=cut
 
sub get_etablissement {
	my ($self, $regex) = @_ ;
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

=pod

=head1 Method get_header
		This method provide the information for the SIREN

=head2 Attributes :		
	None

=cut

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

=pod

=head1 Method add_to_return
	This method is adding "$descr":$value$end" to the result

=head2 Attributes

=over 4 

=item $result the variable that contains the value returned	

=item $descr is the label of the json

=item $value is the value found for the label

=item $end is the mark at the end "," "}"...

=back

=cut	

sub add_to_return {
	my ($self,  $result, $descr, $value, $end ) = @_ ;
	# this is just a macro to concatenate the data
		$result .= "\"$descr\":$value$end";
	return $result ;
	}

=pod

=head1 Method get_value	
	This method get the value from where the label is $descr
	from the data ($data) when $descr is between "
	and value also
	$end describe the end of the regex

=head2 Attributes :

=over 4

=item $data is the whole data where the value is searched from

=item $descr is the label of the value we are searching

=item $end represents the end of the regex 	

=back

=cut
	
sub get_value {
	my ( $self, $data, $descr, $end ) = @_;
	my $value ;
	# faire un test sur $end si commence par } 
		if ($end =~ /^\}/) {
			if ($data =~ /\"$descr\":(\{\".+?\}),\"/ ) { 
				 $value = $1 ;}
		} elsif ($data =~ /\"$descr\":(\".+?\")$end/ ) { 
		 $value = $1 ;
	 	}
	return $value ;
	}

	

=pod

=head1 Method getset_value	
	This method call the get_value method
	and call the add_to_return method 
	it replaces the original label with another description if needed
	for the result

=head2 Attributes :

=over 4

=item C<$data> is the whole data where the value is searched from

=item C<$descr> is the label of the value we are searching

=item C<$end> represents the end of the regex 	

=item C<$otherdescr> represents an alertative description for the result

=back

=cut

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

	
=pod

=head1 Method getset_bool
	This method call the get_bool method
	and call the add_to_return method 
	it replaces the original label with another description if needed
	for the result

=head2 Attributes :

=over 4

=item C<$data> is the whole data where the value is searched from

=item C<$descr> is the label of the value we are searching

=item C<$end> represents the end of the regex 	

=item C<$otherdescr> represents an alertative description for the result

=back

=cut

sub getset_bool {
	my ( $self, $result, $data, $descr, $end ) = @_;
	if ( !defined $end) { $end = '' ;}

	my $value = $self->get_bool( $data , $descr, $end );
	if ( defined $value ) {
		$result = $self->add_to_return( $result , $descr, $value , $end );
	}
	return $result ;
}	


=pod

=head1 Method get_bool	
	This method get a boolean value from where the label is $descr
	from the data ($data) when $descr is between "
	and value also
	$end describe the end of the regex

=head2 Attributes :

=over 4

=item $data is the whole data where the value is searched from

=item $descr is the label of the value we are searching

=item $end represents the end of the regex 	

=back

=cut

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
