#
#===============================================================================
#
#         FILE:  RestPath.t
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  23/04/2020 10:45:04
#     REVISION:  ---
#===============================================================================

use Modern::Perl '2018';
use Test::More tests =>7;                      # last test to print
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use warnings;
use Moose;
use RestPath ; 

my $restpath = RestPath->new( );
ok $restpath, "classe instanciée\n";
my %attribute = ( 'name' => 'account',
                'prefix' => 'api',
                'version' => 'v1');
 $restpath->main( \%attribute );
my $pathRef = $restpath->paths ;
							
ok  $pathRef, "retour existe $pathRef\n";
ok @{$pathRef->{create_account}}, "@{$pathRef->{create_account}}\n";
my @retour =  @{$pathRef->{create_account}};
is( $retour[0], 'POST', "$retour[0]");
my @retour2 =  @{$pathRef->{read_account}};
is( $retour2[1], '/api/v1/accounts/:accountId', "$retour[1]");

my %query = ( desc => 'test' ,
			  name => ' encore un',
			  account => '123456'
		  );

my @path = $restpath->actionPath( 'delete', 'account', \%query);
is( $path[0], 'DELETE', 'Action HTTP');
is( $path[1], '/api/v1/accounts/123456','Path');

done_testing();
