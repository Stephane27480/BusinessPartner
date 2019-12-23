#
#===============================================================================
#
#         FILE:  myApp.pm
#
#  DESCRIPTION:  Class to do the actual work
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  18/12/2019 16:47:47
#     REVISION:  ---
#===============================================================================
package myApp;
use Modern::Perl '2018';
 use Moose;
use FindBin;
use lib "$FindBin::Bin/./";
use InseeSiret ;
use formatInseeSiret;
use XML::XML2JSON;

# Attributes
has 'user' , is => 'ro', isa => 'Str';
has 'consKey', is => 'ro', isa => 'Str';
has 'secKey', is => 'ro', isa => 'Str';
has 'siren', is => 'ro', isa => 'Str';
has 'format', is => 'ro', isa => 'Str';

sub main {
	my $self = shift;
	my $classInsee = InseeSiret->new( user => $self->user,
    	        	             consKey => $self->consKey,
        		    	         secKey => $self->secKey );
	my $insee = $classInsee->response($self->siren );
	my $classFormat = formatInseeSiret->new( data => $insee );						 

	 my $data = $classFormat->main( ); 
	 if ($self->format = 'xml') {
		 my $conv = XML::XML2JSON->new( );
		 $data = $conv->jsonxml( $data );
	 }
	return $data ;
	}

1;
