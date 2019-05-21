package Insee;
 use strict;
 use Carp;
 use warnings;
 use WWW::Curl::Easy;
 use Moose;
 use POSIX qw(strftime);

 # Attributes
 has 'user' , is => 'ro', isa => 'Str';
 has 'consKey', is => 'ro', isa => 'Str';
 has 'secKey', is => 'ro', isa => 'Str';
 has 'token', is => 'ro', isa => 'Str', writer => '_set_token';
 has 'date', is=> 'ro', isa => 'Str', default => strftime( "%F", localtime);
sub get_token {
my  $self = shift ;
my $url = "https://api.insee.fr/token";
my $curl = WWW::Curl::Easy->new;
my $param= "grant_type=client_credentials&validity_period=604800";

$curl->setopt(CURLOPT_HEADER,1);
$curl->setopt(CURLOPT_URL, $url);
$curl->setopt(CURLOPT_CUSTOMREQUEST, "POST");
$curl->setopt(CURLOPT_POSTFIELDS, $param );

$curl->setopt(CURLOPT_USERNAME, $self->consKey );
$curl->setopt(CURLOPT_PASSWORD, $self->secKey );
# A filehandle, reference to a scalar or reference to a typeglob can be used here.
my $response_body;
$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
# Starts the actual request
my $retcode = $curl->perform;

# Looking at the results...
if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        # judge result and next action based on $response_code
#        print("Received response: $response_body\n");
#        print "*"x 20;
        my ( $responseNew ) = $response_body =~ /{"access_token":"(\S*)","scope/ ;
#        print "\n $responseNew \n";
		$self->_set_token( $responseNew);
	} else {
        # Error code, type of error, error message
        print("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}
}

sub revoke_token {
my ($self, $user, $consKey, $secKey,$token) = @_ ;
my $url = "https://api.insee.fr/revoke";
my $curl = WWW::Curl::Easy->new;
my $param= "token={$self->token}";

$curl->setopt(CURLOPT_HEADER,1);
$curl->setopt(CURLOPT_URL, $url);
$curl->setopt(CURLOPT_CUSTOMREQUEST, "POST");
$curl->setopt(CURLOPT_POSTFIELDS, $param );

$curl->setopt(CURLOPT_USERNAME, $self->consKey );
$curl->setopt(CURLOPT_PASSWORD, $self->secKey );
# A filehandle, reference to a scalar or reference to a typeglob can be used here.
my $response_body;
$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
# Starts the actual request
my $retcode = $curl->perform;

# Looking at the results...
if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        # judge result and next action based on $response_code
#        print("Received response: $response_body\n");
	} else {
        # Error code, type of error, error message
        carp("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}
}

sub getSiret{
my $self = shift;
my $siren = shift ;
my $query = "siren:$siren AND etatAdministratifUniteLegale:A &date=$self->date";
my $url = "https://api.insee.fr/entreprises/sirene/V3/siret?q=";
$url .= $query ;
my $curl = WWW::Curl::Easy->new;
my $param= "Accept: application/json&Authorization: Bearer $self->token";
#curl -X GET --header 'Accept: application/json' --header 'Authorization: Bearer 64825907-8076-3ef2-a66d-87cf0fc3dd3d' 'https://api.insee.fr/entreprises/sirene/V3/siret?q=siren%3A432673838%20AND%20etatAdministratifUniteLegale%20%3AA&date=2019-05-21'
$curl->setopt(CURLOPT_HEADER,1);
$curl->setopt(CURLOPT_URL, $url);
$curl->setopt(CURLOPT_CUSTOMREQUEST, "GET");
$curl->setopt(CURLOPT_HTTPGET, $param );

# A filehandle, reference to a scalar or reference to a typeglob can be used here.
my $response_body;
$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
# Starts the actual request
my $retcode = $curl->perform;
# Looking at the results...
if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        # judge result and next action based on $response_code
#        print("Received response: $response_body\n");
		return $response_code ;        
	} else {
        # Error code, type of error, error message
        carp("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}
}
sub get_date {
	my $self = shift;
	#	 print " $self->date";
	return $self->date ;
}
1;
