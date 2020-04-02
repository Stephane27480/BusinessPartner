package InseeSiret {
 use Modern::Perl ;
 use Carp;
 use Moose;
 use POSIX qw(strftime);
 use FindBin;
 use lib "$FindBin::Bin/./";
 use ExInseeCurl;
 use Mojolicious;
 use Mojo::Util qw(dumper);
 use Mojo::JSON qw(decode_json);
=pod

=head1 Class InseeSiret.pm
	This class connect to the SIREN API
	Gets the response for a SIREN number

=head2 Attributes:

=over 5

=item user defines the user for the connection

=item consKey defined by the API 

=item secKey secret key of the account 

=item date 

=back
 
=cut

 # Attributes
 has 'user' , is => 'ro', isa => 'Str';
 has 'consKey', is => 'ro', isa => 'Str';
 has 'secKey', is => 'ro', isa => 'Str';
 has 'token', is => 'ro', isa => 'Str', writer => '_set_token';
 has 'date', is=> 'ro', isa => 'Str', default => strftime( "%F", localtime);

 #Methods
 
=pod 

=head1 Method get_token
	This method get the token to identify the session

=cut

sub get_token {
	my $self = shift ;
	my $url = Mojo::URL->new("https://api.insee.fr/token")
                    ->userinfo( join ':', $self->consKey, $self->secKey );				 
	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->build_tx( POST=> $url);			 
	$tx->req->body('grant_type=client_credentials&validity_period=604800',);

	#do the transaction
	$ua->start($tx);

	# Looking at the results...
		# judge result and next action based on $response_code
		if ( $tx->result->code == 200 ){
        	my $respData = decode_json( $tx->result->body );
			$self->_set_token($respData->{"access_token"} );
			} else {	
				print "$tx->result->code \n";
				ExInseeCurl->throw({ 
					code => "$tx->result->code",
					method => 'revoke_token',
				} );							
			}
		}
=pod

=head1 revoke_token
	This method is revoquing the token 

=cut

sub revoke_token {
	my $self = shift ;
	my $url = Mojo::URL->new("https://api.insee.fr/revoke")
                    ->userinfo( join ':', $self->consKey, $self->secKey );				 
	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->build_tx( POST=> $url);			 
	$tx->req->body("token={ $self->{token} }",);

	#do the transaction
	$ua->start($tx);

	# Looking at the results...
		# judge result and next action based on $response_code
		if ( $tx->result->code != 200 ){
	
			print $tx->result->code . "\n";
			ExInseeCurl->throw({ 
				code => $tx->result->code,
				method => 'get_Token'
				} );							
			}
	}

=pod

=head1 Method response
	This method provides the response from the API
	to get the details of all the etablissements

=head2 Attributes

=over 3

=item C<$siren> defines the SIREN for which the search processed 

=item C<$date> defines the period for which the search is processsed

=back

=cut

sub response {
	my $self = shift;
	my $siren = shift ;
	my $date = $self->date ;
	#Create the parameters
	#Take only the siret that have never been closed
	my $params = "/siret?q=siren:$siren AND -periode(etatAdministratifEtablissement:F)&date=$date&nombre=1000";
	my $uri = "https://api.insee.fr/entreprises/sirene/V3" . $params;
	my $url = Mojo::URL->new("$uri");
	
	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->build_tx( GET => $url);			 

	# create the header
	$tx->req->headers->accept('application/json');
	$tx->req->headers->authorization("Bearer $self->{token}");

	#do the transaction
	$ua->start($tx);

		if ( $tx->result->code == 200 ){
				my $respData =  $tx->result->body ;
				# say dumper( $respData );
				return $respData ;
			} else {
				#	say $tx->res->to_string;
				print  $tx->result->code . "\n";
				ExInseeCurl->throw({ 
					code => $tx->result->code,
					method => 'getSiret'
				} );							
			} 
	}

1;
}
