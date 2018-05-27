#!/usr/bin/perl
=pod
Ce programme effectue une verification des codes SIREN et SIRET et permet de generer une liste
Si le champs est vide alors le controle n'est pas effectue
format d'entree |client|SIRET|SIREN|
=cut
use sbl ;
my %h_result ;
my @line ;
my @verif1;
my @valeurs ;
print "Repertoire de travail: ";
#my $rep =  "/home/stephane/lang/perl.lang/raw" ;
my $rep = <STDIN>;
chomp ($rep);
print "Nom de fichier :";
$filename =  <STDIN>;
chomp($filename);

chdir $rep;

$prefichier = sbl::prefichier ;

open(IN,"< $filename")|| die "Impossible d'ouvrir le fichier";
#open my($out), '>', "$prefichier SIRENSIRET.csv";
	while ($text=<IN>) {
	 chomp($text);
		@list= split (/\t/,$text);
		$fonction[0] = $list[1];
		$fonction[1] = $list[2]; 	
		if (($list[2] =~ /^\d/ )) { 
			$titre = "SIRET";
			&verification(\@fonction);}
		$fonction[1] = $list[3]; 	
		if (($list[3] =~ /^\d/ )){
			$titre = "SIREN";
			&verification(\@fonction);}
	} 
	close IN;
#	close $out;

open my($out1), '>', "$prefichier RESULT.csv";
	while ( ($clefs, $res) = each %h_result){
	$res =~ s/;;/;/g ;
	$res =~ s/^;//;	
	print $out1 "$clefs;$res\n";
	}
close $out1;
print "Travail termine" ;



sub verification {
	my ($ref1) = @_;
	my @REF = @{$ref1};
	$NUM = $REF[1];
	@verif  = split(//,$NUM);
$longueur = length($NUM);
if ($longueur eq 14 || $longueur eq 9) {
	if (($longueur eq 14 && $titre eq "SIRET" ) || ($longueur eq 9 && $titre eq "SIREN" ))  {
		# traitement des numeros pairs
		for ($i= 1 ; $i < scalar(@verif1) ; $i += 2 ) {
			$verif1[$i] = $verif1[$i] * 2;
			if ($verif1[$i] > 9){ $verif1[$i] -= 9;}
			}
		my $total ;
#Cacul de la somme
		foreach $verif1 (@verif1) {
			$total += $verif1 ;}

# verification 
		if ( $total % 10 != 0) {
#			print $out "$REF[0];$titre;$REF[1];Le $titre est incorrect \n" ;
			$valeurs[0] = $REF[0] ; 
			$valeurs[1] = $titre ;
			$valeurs[2] = $REF[1] ;
			$valeurs[3] = "Le $titre est incorrect"; 
			&result(\@valeurs); } 
		elsif ( $total % 10 == 0) {
#			print $out "$REF[0];$titre;$REF[1];Le $titre est correct \n" ;
			$valeurs[0] = $REF[0] ; 
			$valeurs[1] = $titre ;
			$valeurs[2] = $REF[1] ;
			$valeurs[3] = "Le $titre est correct"; 
			&result(\@valeurs); } 
	}	 

	}else { if ($longueur == 14 || $longueur == 9){
#		print $out "$REF[0];$titre;$REF[1];Le $titre n'est pas dans le bon champs \n";
			$valeurs[0] = $REF[0] ; 
			$valeurs[1] = $titre ;
			$valeurs[2] = $REF[1] ;
			$valeurs[3] = "Le $titre n'est pas dans le bon champs"; 
			&result(\@valeurs);  

		} else { 
#		print $out "$REF[0];$titre;$REF[1];Le nombre de chiffre doit etre de 14 ou 9 \n" ;
			$valeurs[0] = $REF[0] ; 
			$valeurs[1] = $titre ;
			$valeurs[2] = $REF[1] ;
			$valeurs[3] = "Le nombre de chiffre doit etre de 14 ou 9"; 
			&result(\@valeurs); } 
		}
}

sub result {
	my ($ref2) = @_ ;
	my @ls_line = @{$ref2};
	my @tmp_valeur ;
	my $lv_valeur ;
	if (exists($h_result{"$ls_line[0]"})) {
		if ($ls_line[1] eq "SIRET" ) {
			$lv_valeur = $h_result{$ls_line[0]};
			@tmp_valeur = split(";",$lv_valeur) ;
			$tmp_valeur[1] = $ls_line[2];
			$tmp_valeur[3] = $ls_line[3];
			$lv_valeur = join(";",@tmp_valeur);
			$h_result{"$ls_line[0]"} = $lv_valeur ;
		}else{

			$lv_valeur = $h_result{$ls_line[0]};
			@tmp_valeur = split(";",$lv_valeur) ;
			$tmp_valeur[2] = $ls_line[2];
			$tmp_valeur[4] = $ls_line[3];
			$modulo =  ((12 + ( 3 * ( $ls_line[2] % 97))) % 97) ;
			$tmp_valeur[5] = "FR$modulo$ls_line[2]"   ;
			$lv_valeur = join(";",@tmp_valeur);
			$h_result{"$ls_line[0]"} = $lv_valeur ;
		}
	}else{
		if ($ls_line[1] eq "SIRET" ) {
			@tmp_valeur = split(";",$lv_valeur) ;
			$tmp_valeur[1] = $ls_line[2];
			$tmp_valeur[3] = $ls_line[3];
			$lv_valeur = join(";",@tmp_valeur);
			$h_result{"$ls_line[0]"} = $lv_valeur ;
		}else{
			@tmp_valeur = split(";",$lv_valeur) ;
			$tmp_valeur[2] = $ls_line[2];
			$tmp_valeur[4] = $ls_line[3];
			$modulo =  ((12 + ( 3 * ( $ls_line[2] % 97))) % 97) ;
			$tmp_valeur[5] = "FR$modulo$ls_line[2]"   ;
			$lv_valeur = join(";",@tmp_valeur);
			$h_result{"$ls_line[0]"} = $lv_valeur ;
		 }
	}
}
