package insee;
 use strict;
 use warnings;
 use WWW::Curl::Easy;

sub get_token {
my ($user, $consKey, $secKey) = @_ ;
my $url = "https://api.insee.fr/token";
my $curl = WWW::Curl::Easy->new;
my $param= "grant_type=client_credentials&validity_period=604800";

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
#        print "*"x 20;
        my ( $responseNew ) = $response_body =~ /{"access_token":"(\S*)","scope/ ;
#        print "\n $responseNew \n";
	} else {
        # Error code, type of error, error message
        print("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}
}

sub revoke_token {
my ($user, $consKey, $secKey,$token) = @_ ;
my $url = "https://api.insee.fr/revoke";
my $curl = WWW::Curl::Easy->new;
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
        print("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}
}
1;
