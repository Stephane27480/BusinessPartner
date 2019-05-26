package Insee;
use Modern::Perl ;
 use Carp;
 use WWW::Curl::Easy;
 use Moose;
 use POSIX qw(strftime);
 use Data::Dumper;

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
my $self = shift ;
my $url = "https://api.insee.fr/revoke";
my $curl = WWW::Curl::Easy->new;
my $token = $self->token ;
my $user = $self->user;
my $consKey = $self->consKey;
my $secKey = $self->secKey;
my $param= "token={$token}";

$curl->setopt(CURLOPT_HEADER,1);
$curl->setopt(CURLOPT_URL, $url);
$curl->setopt(CURLOPT_CUSTOMREQUEST, "POST");
$curl->setopt(CURLOPT_POSTFIELDS, $param );

$curl->setopt(CURLOPT_USERNAME, $consKey );
$curl->setopt(CURLOPT_PASSWORD, $secKey );
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
my $date = $self->date ;
my $query = "siren:$siren&date=$date";
# &periode(etatAdministratifEtablissement:A)
my $url = "https://api.insee.fr/entreprises/sirene/V3/siret?q=";
$url .= $query ;
say $url ;
my $curl = WWW::Curl::Easy->new;
my $token = $self->token;
my @headers = ("Accept: application/json","Authorization: Bearer $token");

#curl -X GET --header 'Accept: application/json' --header 'Authorization: Bearer 64825907-8076-3ef2-a66d-87cf0fc3dd3d' 'https://api.insee.fr/entreprises/sirene/V3/siret?q=siren%3A432673838%20AND%20etatAdministratifUniteLegale%20%3AA&date=2019-05-21'
$curl->setopt(CURLOPT_HEADER,1);
$curl->setopt(CURLOPT_URL, $url);
$curl->setopt(CURLOPT_CUSTOMREQUEST, "GET");
$curl->setopt(CURLOPT_HTTPGET, 1 );
$curl->setopt(CURLOPT_HTTPHEADER, \@headers);
# A filehandle, reference to a scalar or reference to a typeglob can be used here.
my $response_body;
$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
# Starts the actual request
my $retcode = $curl->perform;
# Looking at the results...
if ($retcode == 0) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        # judge result and next action based on $response_code
        if ( $response_code = 200 ){
			my @valid = $self->format_body( $response_body );
			return @valid ;
		}
		#TODO  implement exception
	} else {
        # Error code, type of error, error message
        carp("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}
}
sub format_body {
	my $self = shift;
	my $body = shift ;
	my $regex = '\"periodesEtablissement\":\[\{\"dateFin\":null,\"dateDebut\":\"\d{4}-\d{2}-\d{2}\",\"etatAdministratifEtablissement\":\"A\"';
	my @valid ;
	my @etablissement = split( /{"siren":/, $body);
	shift(@etablissement);
	foreach (@etablissement) {
		if (m/$regex/){
			my $data = $_ ;
			my  $data_reg = '(\"siret\":\"\d{14}\")';
			my $siret = $self->get_data( $data , $data_reg );
			$data_reg = '(^\"\d{9}\")'; 
			my $siren = '"siren":' . $self->get_data( $data , $data_reg );
			$data_reg = '(\"denominationUniteLegale\":\".*\"),\"sigleUniteLegale\"'; 
			my $name = $self->get_data( $data , $data_reg );
			$data_reg = '(\"adresseEtablissement\":\{\".*\}),\"adresse2Etablissement\"'; 
			my $address = $self->get_data( $data , $data_reg );
			my $value = "$siret , $siren , $address";
			push( @valid ,$value );
		}	
	}
	return @valid ;
}
sub get_data {
	my $self = shift ;
	my $data = shift ;
	my $regex = shift ;
	if ( $data =~ /$regex/ ){
		return  $1; 
	}
}
1;
