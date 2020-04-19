use Test::More tests => 3;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use warnings;
use Moose;
use TrelloLite;

#BEGIN { use_ok( 'WWW::Trello::Lite' ); }
#require_ok( 'WWW::Trello::Lite' );
my $key = 'ee74875bff8a130455d5363683c99245';
my $token = '7c686ea6eff77afafd421ddea559fe39274dc5457756968b1a6b091cdc23068f';
my $desc = "**test** --- Prendre la douche --- generated --- card";
my $request = TrelloLite->new(
	key   => $key, 
	token => $token
);
my $response = $request->get( 'lists/invalidlist' );
is( $response->failed, '1', 'Verified connection to Trello' );
is( $response->response->content, "invalid id", 'Reported invalid board' );
# Add a new card...
my $id = '5e9b35335c2852369f0a6cff';
$response = $request->post( "cards", {name => 'Problème Flora', idList => $id, desc => $desc  } );
is( $response->code, '200', 'Card added' );
