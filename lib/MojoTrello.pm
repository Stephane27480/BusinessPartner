#
#===============================================================================
#
#         FILE:  MojoTrello.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  24/04/2020 10:16:36
#     REVISION:  ---
#===============================================================================
package MojoTrello;
use Modern::Perl '2018';
use Moose;
use FindBin;
use lib "$FindBin::Bin/./";
use Mojolicious;
use Mojo::Util qw(dumper);
use Mojo::JSON qw(decode_json);
use RestPath;

#Attributes
has 'paths',	is => 'rw', isa => 'RestPath';
has 'version',	is => 'ro', isa => 'Str', default => '1';
has 'server', 	is => 'ro', isa => 'Str', default => 'https://api.trello.com';
has 'token', 	is => 'ro', isa => 'Str';
has 'key',		is => 'ro',	isa => 'Str';

#Methods
sub main {
my $self 		= shift;
my $action 		= shift;
my $object 		= shift;
my $arguments 	= shift;
my @the_rest 	= shift;
	$self->getPaths( $action, $object  );
	
	$arguments = {} unless defined $arguments;
	$arguments->{key  } = $self->key;
	$arguments->{token} = $self->token;
	my @path = $self->paths->actionPath( $action, $object, $arguments );
	
	my $url = Mojo::URL->new($self->server);
	$url->path( $path[1] );
	$url->query( $arguments );
	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->build_tx( $path[0] => $url);			 

	#do the transaction
	$ua->start($tx);
	#my $body =  $tx->result->body ;
	#	say dumper $body;
	return $tx->result;
}# main1

sub getPaths {
my $self 	= shift;
my $action 	= shift;
my $object 	= shift ;
my $pathAction = lc($action)."-$object";
if (!defined $self->paths ){
	$self->paths( RestPath->new() );
}
my %attribute = ( 	name 	=> 	$object,
					version =>	$self->version
				);
$self->paths->main( \%attribute );


} #getPaths
1;
