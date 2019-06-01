package InseeCurl ;
=pod
=encoding UTF-8
=cut
#
#===============================================================================
#
#         FILE:  InseeCurl.pm
#
#  DESCRIPTION: This class handles the exceptions to the Insee API call 
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  30/05/2019 21:48:53
#     REVISION:  ---
#===============================================================================
use Moose;
with 'Throwable';
has code => (is => 'ro');
has method => (is => 'ro');
1;

