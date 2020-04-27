#
#===============================================================================
#
#         FILE:  vies.pm
#
#  DESCRIPTION:  Service for European VAT (VIES)
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  19/12/2019 10:24:53
#     REVISION:  ---
#===============================================================================
package vies ;
use Modern::Perl '2018';
use Moose;
use FindBin;
use lib "$FindBin::Bin/./";
use Business::Tax::VAT::Validation;
use appSOS; 

=pod

=head1 Package Vies 
	This package use the Business::TAX::VAT::Validation
	it calls the vies services and provides an easy way 
	to get the results.

=cut


 # Attributes
has 'vat' , is => 'rw', isa => 'Str', required => 1;
has 'vies' , is => 'rw',  
			 builder => '_build_vies',
			predicate => 'has_vies';			
has 'errorCode', is => 'rw';
has 'errorText', is => 'rw';
=pod

=head1 Method _buid_vies 
	This Method creates the object to call the VIES service

=cut			

sub _build_vies {
	return Business::Tax::VAT::Validation->new();
}


=pod

=head1 Method main
	This method returns the vat number if correct
	and returns undef if not

=cut

sub main {
	my $self = shift ;
	my $vat_check;
	my $ms_check = $self->check_country( );
	if ($ms_check == 1){
		$vat_check = $self->check_vat( );
		print " vat check : $vat_check\n";
		if ( $vat_check ==1 ){
			return $self->vat;
		}	
	} else {
		my $viesSOS = appSOS->new( 	desc 	=> 	"$self->{errorText}",
									msg		=> 	"PERL VIES $self->{errorCode}",
									install	=>	"CDLG",
									syst	=>	"SCP",
									prod	=>	"X"
									) ;

		return undef ;
	}
}

=pod

=head1 Method check_country
	This method checks if the country is a member state

=cut


sub check_country {
	my $self = shift ;
	my $ret_val;
	my $cc = substr($self->vat, 0,2);
	my  @ms=$self->vies->member_states;
	my $MS = join(" ", @ms);
  	if ($MS =~ m/$cc/ ) {
 		$ret_val = 1  ;}
 	 else{
    	$ret_val = 0 ;
	}
	return $ret_val;
}

=pod

=head1 check_vat
	This method check if the VAT ID is valid
	returns 1 if ok
	returns 0 if not

=cut

sub check_vat {
	my $self = shift ;
	my $ret_val;
	 if ($self->vies->check($self->vat) == -1){
		 print "passe\n";
		$ret_val = 1; }
	elsif ( $self->vies->get_last_error_code( ) < 17 ){
		$self->errorCode( $self->vies->get_last_error_code( ) ) ;
		$self->errorText( $self->vies->get_last_error( ) );
		$ret_val = 0 ; }
	else {
		$self->errorCode( $self->vies->get_last_error_code( ) ) ;
		$self->errorText( $self->vies->get_last_error( ) );
		$ret_val = 0; #$self->local_check( );
		}
	return $ret_val ;		
}

=pod

=head1 local_check
	This method checks locally the VAT format

=cut

sub local_check {
	my $self = shift;
	# returns 1 if valid 0 if invalid
  	my $ret_value = $self->vies->local_check($self->vat);
}	

=pod

=head1 Method get_info
	Cette méthode contien un paramètre
	soit name ou address et retourne la valeur 

=cut

sub get_info {
	my ($self, $param ) = @_ ;
	my $value = $self->vies->informations( $param );
	return $value ;
}
1;
