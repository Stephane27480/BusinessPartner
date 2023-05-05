#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  vatFromSiren.pm
#
#        USAGE:  ./vatFromSiren.pm  
#
#  DESCRIPTION:  Get the VAT number of the SIREN
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  05/05/2023 17:33:36
#     REVISION:  ---
#===============================================================================
package vatFromSiren {
use Modern::Perl ;
use Moose;
use Carp;
=pod
=head1 Class vatFromSiren.pm
	This class finds the VAT number based on SIREN
	Input can be a single entry or a file
=head2 Attributes	
	none

=cut
=pod
=head1 Method vatDetermination
	This method is requiring a SIREN number as input parameter
=cut
sub vatDetermination{
	my $self = shift ;
	my $siren = shift ;
	# get the vat number
	my $modulo = ((12 + ( 3 * ( $siren% 97))) %97 );
	if ( length( $modulo ) ne 2){ $modulo = 0 . $modulo; }
		my $vat = "FR$modulo$siren" ;
	return $vat
}

=pod
=head1 
	This method is finding the VAT number for a given file
	The input parameter is first the path then the filename 
=cut
sub vatFromFile {
	my $self = shift;
	my $rep = shift;
	my $filename = shift;
	chomp ($rep);
	chomp($filename);
	chdir $rep;

	open(OUT, ">>", 'siren_vat.csv')|| die "Impossible d'ouvrir le fichier de sortie";

	open(IN,"< $filename")|| die "Impossible d'ouvrir le fichier $filename";
   	 while (my $text=<IN>) {
    		chomp($text);
		my @list= split (/,/,$text);
		if ($list[0] ne "siren"){
			my $vat = $self->vatDetermination( $list[0]);		
			# save the vat and SIREN
			print OUT "$list[0]\t$vat\n";
		}
	}
	close IN ;
	close OUT;
	print "done\n ";
	}
1;	
	}	
