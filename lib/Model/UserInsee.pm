#
#===============================================================================
#
#         FILE:  UserInsee.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  18/12/2019 11:49:11
#     REVISION:  ---
#===============================================================================
package Model::UserInsee;
use Modern::Perl '2018';

#use Mojo::Util 'secure_compare';

my $USERS = {
  sbl      => ("INSEE27480","7z6CyvFaIzyH1WC4NX06zUIg3j8a","N2FYCzsyOl3qZJwvf_WeWiMIKzga"),
  marcus    => ( 'user','consKey', 'secKey'),
  sebastian =>  ( 'user','consKey', 'secKey')
};

sub new { bless {}, shift }

sub check {
  my ($self, $user) = @_;

  # Success
	if (defined $USERS->{$user} ) {
		my @insee = $USERS->{$user} ;
		return @insee;
	} else{
  		# Fail
  		return undef;
	}
}

1;

