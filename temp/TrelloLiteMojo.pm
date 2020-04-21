#
#===============================================================================
#
#         FILE:  TrelloLite.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  21/04/2020 14:46:09
#     REVISION:  ---
#===============================================================================

use Modern::Perl '2018';
=pod
=head1 NAME
TrelloLite - Simple wrapper around the Trello web service.
=head1 SYNOPSIS
  # Get the currently open lists from a given board...
  my $trello = WWW::Trello::Lite->new(
      key   => 'invalidkey',
      token => 'invalidtoken'
  );
  my $lists = $trello->get( "boards/$id/lists" )
  # Add a new card...
  $trello->post( "cards", {name => 'New card', idList => $id} );
=head1 DESCRIPTION
L<Trello|https://www.trello.com> manages lists of I<stuff>.
L<Trello|https://www.trello.com> provides an API for remote control.
B<WWW::Trello::Lite> provides Perl scripts easy access to the API. I use it
to add cards on my to-do list.
Translating the Trello API documentation into functional calls is straight
forward.
  # Trello API documentation says:
  # GET /1/cards/[card_id]
  my $card = $trello->get( "cards/$id" );
The first word (I<GET>, I<POST>, I<PUT>, I<DELETE>) becomes the method call.
Ignore the number. That is the Trello API version number. B<WWW::Trello::Lite>
handles that for you automatically.
The rest of the API URL slides into the first parameter of the method.
Some API calls, such as this one, also accept B<Arguments>. Pass the arguments
as a hash reference in the second parameter. The argument name is a key. And
the argument value is the value.
  # Trello API documentation says:
  # GET /1/cards/[card_id]
  my $card = $trello->get( "cards/$id", {attachments => 'true'} );
=cut

use FindBin;
use lib "$FindBin::Bin/./";
use Moose;
use Mojolicious;
use Mojo::Util qw(dumper);
use Mojo::JSON qw(decode_json);
use Mojolicious::Plugin::REST;
use Mojolicious::Controller::REST;
use Mojo::Parameters;

#Attributes
has 'key',		is => 'ro',	isa	=>	'Str';
has	'token',	is => 'ro',	isa =>	'Str';
has 'server',   is => 'ro', isa =>	'Str', default => 'https://api.trello.com/';
our $VERSION = '1.00';



=head1 METHODS & ATTRIBUTES
=head3 get / delete / post / put
The method name corresponds with the first word in the Trello API
documentation. It tells Trello what you are trying to do. Each method expects
two parameters:
=over
=item 1. URL
The URL (minus the server name) for the API call. You can also leave off the
version number. Begin with the item such as I<boards> or I<cards>.
=item 2. arguments
An optional hash reference of arguments for the API call. The class
automatically adds your development key and token. It is not necessary to
include them in the arguments.
=cut
around qw/get delete put post/ => sub {
	my ($action, $self, $object, $arguments, @the_rest) = @_;
	#set the route
	$self->startup( $object );
	# Query parameters
	my $params = Mojo::Parameters->new( $arguments ) ;
	#user Agent
	my $ua = Mojo::URL->New( $self->server => { 
			Authorization => "key $self->key, token $self->token"
		})->query($params);
	;
	

	

	return $self->$action( "$api/$url", $arguments, @the_rest );
};

sub startup {
	my $self = shift;
	my $object = shift;
	$self->plugin( 'REST' => { version => '1' } );
	 my $r->rest_routes( name => $object );
}
1;


