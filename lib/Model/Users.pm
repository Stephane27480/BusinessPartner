#
#===============================================================================
#
#         FILE:  Users.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  18/12/2019 11:42:13
#     REVISION:  ---
#===============================================================================

package Model::Users;

use Modern::Perl '2018';
use Mojo::Util 'secure_compare';

# we should interrogate a DB Here
my $USERS = {
  sbl      => '27480',
  marcus    => 'lulz',
  sebastian => 'secr3t'
};

sub new { bless {}, shift }

sub check {
  my ($self, $user, $pass) = @_;

  # Success
  return 1 if $USERS->{$user} && secure_compare $USERS->{$user}, $pass;

  # Fail
  return undef;
}

1;


