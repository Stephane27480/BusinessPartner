#!/usr/bin/perl
=pod
Ce programme verifie les numéros de TVA intracommunautaire
il faut intégrer le numéro de fournisseur et de TVA 
separation par tabulation
=cut
use Business::Tax::VAT::Validation;
#If your system is located behind a proxy :
#$hvatn=Business::Tax::VAT::Validation->new(-proxy => ['http', 'http://example.com:8001/']);

use sbl ;
my %h_result ;
#get the member state for VAT 
$vatEUR=Business::Tax::VAT::Validation->new();
 @ms=$vatEUR->member_states;
$MS = join(" ", @ms);	
print "Repertoire de travail: ";
#my $rep =  "/home/stephane/lang/perl.lang/raw" ;
my $rep = <STDIN>;
chomp ($rep);
print "Nom de fichier :";
$filename =  <STDIN>;
chomp($filename);

chdir $rep;

$prefichier = sbl::prefichier ;

open(IN,"< $filename")|| die "Impossible d'ouvrir le fichier $filename";
	while ($text=<IN>) {
	 chomp($text);
	@list= split (/\t/,$text);
		my $hvatn=Business::Tax::VAT::Validation->new();
		if ($hvatn->check($list[1])){
			 $name = $hvatn->informations('name');
			 $address = $hvatn->informations('address');
			 $h_result{"$clef"} = "$list[0]\tOK\t$name\t$address" ;
		}
		 		
 		else { 
			$err_vat = $hvatn->get_last_error_code() ;
			if ($err_vat =~ m/^1$|^2$|^3$/){
#				print "1\t$text\t$err_vat\n";
				$h_result{"$list[1]"} = "$list[0]\tInvalid Code - $err_vat" ;}
			else{ 	$connect{"$list[1]"} = $list[0] ;
#				print "1\t$text\t$err_vat\n";
				foreach $clef (keys %connect) {
					my $hvatn=Business::Tax::VAT::Validation->new();
					if ($hvatn->check($clef)){
						 $name = $hvatn->informations('name');
						$address = $hvatn->informations('address');
						$vendor = $h_result{"$clef"};
						$h_result{"$clef"} = "$vendor\tOK\t$name\t$address" ;
						delete $connect{$clef};
						$count = (keys(%connect));
#						print "2\t$clef\tok\t$count\n";
						}
		 		
 					else { 
						$err_vat = $hvatn->get_last_error_code() ;
						if ($err_vat =~ m/^1$|^2$|^3$/){
							$vendor = $h_result{"$clef"};
							$h_result{"$clef;"} = "$vendor\tInvalid Code - $err_vat" ;
							delete $connect{$clef};
							$count = (keys(%connect));
#							print "2\t$clef\t$err_vat\t$count\n";
						}
						else{
							$count = (keys(%connect));
#							print "2\t$clef\t$err_vat\t$count\n";
						 }
					}
				}
			}
		}
	} 
	close IN;
	while (keys(%connect) ne 0){
		foreach $clef (keys %connect) {
			my $hvatn=Business::Tax::VAT::Validation->new();
			if ($hvatn->check($clef)){
				$name = $hvatn->informations('name');
				$address = $hvatn->informations('address');
				$vendor = $h_result{"$clef"};
				$h_result{"$clef"} = "$vendor\tOK\t$name\t$address" ;
				delete $connect{$clef};
#				print "3\t$clef\tok\n";
			}
			else { 
				$err_vat = $hvatn->get_last_error_code() ;
				if ($err_vat =~ m/^1$|^2$|^3$/){
					$vendor = $h_result{"$clef"};
					$h_result{"$clef;"} = "$vendor\tInvalid Code - $err_vat" ;
					delete $connect{$clef};
					$count = (keys(%connect));
#					print "3\t$clef\t$err_vat\t$count\n";
				}	
				else{
					$count = (keys(%connect));
#					print "3\t$clef\t$err_vat\t$count\n";

				}
			}
		}
	
	}

open my($out1), '>', "$prefichier vatcheck.txt";
	while ( ($clefs, $res) = each %h_result){
	print $out1 "$clefs\t$res\n";
	}
close $out1;
print "Travail termine" ;



