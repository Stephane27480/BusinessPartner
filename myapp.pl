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
#     REVISION:  ---
#===============================================================================
use Modern::Perl '2018';
use Mojolicious::Lite ;
use lib 'lib';
use Model::Users;
use Model::UserInsee;
use appSiren ;
use appVies ;

#Helper to lazy initialize and store model object
helper users => sub {state $users = Model::Users->new};
helper userInsee => sub {state $userInsee = Model::UserInsee->new};
app->secrets(['Codilog SIREN']);
get '/siren' => sub {
	my $c = shift ;
	
	my $user = $c->req->url->to_abs->username;
	my $pass = $c->req->url->to_abs->password;
	#query parameters
	my $siren = $c->param('siren');	
	# Check password
    if ($c->users->check($user, $pass)) {
		$c->session(user => $user );
		my @Insee = $c->userInsee->check($user);
		my $class = appSiren->new(
								user	=>	$Insee[0],
                               	consKey	=>	$Insee[1],
                               	secKey	=>	$Insee[2],
 								siren	=>	$siren
							);
		my $data = $class->main( );
		$c->render(json => $data ); 					
	} else {# Failed
		$c->res->code(401);
		$c->res->message( 'Not Authorised');
  		$c->render(text => '$c->res->message : Wrong username or password.');
	}
};

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
			$c->res->message(" $vies->{errorCode} : $vies->{errorText} ") ;
			$c->render( text => $c->res->message );
		}
	} else {
		$c->res->code(401);
		$c->res->message( 'Not Authorised');
		$c->render(text => $c->res->message );
	};

};

app->start;
