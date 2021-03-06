#
#===============================================================================
#
#         FILE:  appVies.pm
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
package appVies;
use Modern::Perl '2018';
 use Moose;
use FindBin;
use lib "$FindBin::Bin/./";
use vies;
use Mojo::JSON qw(decode_json encode_json);

# Attributes
has 'vat' , is => 'rw', isa => 'Str';
has 'errorCode', is => 'rw', isa => 'Str';
has 'errorText', is => 'rw', isa => 'Str';

sub main {
	my $self = shift;
 	my $class = vies->new( vat => $self->vat );
	if (defined $class->main( ) && defined $class->get_info('name')){
 
	my $infoRef = $class->get_info( );
 	$infoRef->{"vat"} = $self->vat;
	my $data = encode_json( $infoRef );	
	return $data ;
  			
  }
	$self->errorCode( $class->{errorCode});
	$self->errorText( $class->{errorText});
   my %info;
   $info{"vat"} = $self->vat;
   $info{"errorCode"} = $self->errorCode;
   $info{"errorText"} = $self->errorText ;
   my $data = encode_json( \%info );
	return $data;
}

1;
