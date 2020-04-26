#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  myapp.pl
#
#        USAGE:  ./myapp.pl  
#
#  DESCRIPTION: Application to get the SIRET(s) addresses 
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  0.10
#      CREATED:  18/12/2019 09:32:48
#     REVISION:  001-
#===============================================================================
use Modern::Perl '2018';
use Mojolicious::Lite ;
use lib 'lib';
use Model::Users;
use Model::UserInsee;
use appSiren ;
use appVies ;
use appSOS ;


#Helper to lazy initialize and store model object
helper users => sub {state $users = Model::Users->new};
helper userInsee => sub {state $userInsee = Model::UserInsee->new};
app->secrets(['Codilog SIREN']);
get '/siren' => sub {
	my $c = shift ;
	
	my $user = $c->req->url->to_abs->username;
	my $pass = $c->req->url->to_abs->password;
	#query parameters
	my $params ;
	my $siren = $c->param('siren');	
	if ($siren) {
		$params ="/siret?q=siren:$siren ";
	} elsif ( $c->param('siret') ) {	
		my $siret = $c->param('siret');
		$params = "/siret?q=siret:$siret ";
	} elsif ( $c->param('name' ) ) {
			my $name = $c->param('name');
			$params = "/siret?q=denominationUniteLegale:$name ";
	}
	# searching by department (first 2 car of cp)
	# if lenght = 5 then search department
	if ( $c->param('cp')){
		my $cp = $c->param('cp') ;
		my $length_cp = 5 - length( $cp) ;
		$cp .= '?' x $length_cp ;
		$params .= "AND codePostalEtablissement:$cp ";
	}	

	# Check password
    if ($c->users->check($user, $pass)) {
		$c->session(user => $user );
		my @Insee = $c->userInsee->check($user);
		my $class = appSiren->new(
								user	=>	$Insee[0],
                               	consKey	=>	$Insee[1],
                               	secKey	=>	$Insee[2],
 							    param	=>	$params
							);
		my $data = $class->main( );
		$c->render(json => $data ); 					
	} else {# Failed
			my $InseeSOS = appSOS->new( desc 	=> 	"Not authorized :Wrong username or password",
										msg		=> 	"PERL INSEE 401 }",
										install	=>	"CDLG",
										syst	=>	"SCP",
										prod	=>	"X"
										) ;
		
		$c->res->code(401);
		$c->res->message( 'Not Authorised');
  		$c->render(text => '$c->res->message : Wrong username or password.');
	}
};#siren

get '/vies' => sub {
	my $c = shift;
	my $user = $c->req->url->to_abs->username;
	my $pass = $c->req->url->to_abs->password;
	#query parameters
	my $vat = $c->param('vat');	
	# Check password
    if ($c->users->check($user, $pass)) {
		$c->session(user => $user );
		my $vies = appVies->new( vat => $vat );
		my $datvies = $vies->main( );
		if (defined $datvies) {
			$c->render(json => $datvies );
		} else {
			if ($vies->{errorCode} < 17 ) {
				$c->res->code(400);
			} elsif ( $vies->{errorCode} < 257 ) {
				$c->res->code( 503 );
			} else {
				$c->res->code( 500) ;
			}
			# call the SOS  apps
			my $viesSOS = appSOS->new( 	desc 	=> 	"$vies->{errorText}",
										msg		=> 	"PERL VIES $vies->{errorCode}",
										install	=>	"CDLG",
										syst	=>	"SCP",
										prod	=>	"X"
										) ;
			$c->res->message(" $vies->{errorCode} : $vies->{errorText} ") ;
			$c->render( text => $c->res->message );
		}
	} else {
			my $vies1SOS = appSOS->new( desc 	=> 	"Not Authorized",
										msg		=> 	"PERL VIES 401}",
										install	=>	"CDLG",
										syst	=>	"SCP",
										prod	=>	"X"
										) ;
		$c->res->code(401);
		$c->res->message( 'Not Authorised');
		$c->render(text => $c->res->message );
	}
}; #vies	
get '/sos' => sub {
	my $c = shift;
	#get query parameters
	my $desc 	= $c->param('desc');
	my $msg		= $c->param('msg');
	my $install = $c->param('install');
	my $syst 	= $c->param('syst');
	my $prod 	= $c->param('prod');
	if ( ! defined $prod ) { 
		$prod = ' ';
	}
	# call the apps
	my $sos = appSOS->new( 	desc 	=> 	$desc,
							msg		=> 	$msg,
							install	=>	$install,
							syst	=>	$syst,
							prod	=>	$prod
						) ;
	
	my $return = $sos->main( ) ;
	$c->res->code( $return->code);
	if ($return->code == 200 ) {
		$c->res->message( 'Card Added');
		$c->render( json => $return->body );
	}else{
		$c->res->message( 'Card Not Added');
		$c->render( text => $c->res->message );
	}
		
};#sos		


app->start;
