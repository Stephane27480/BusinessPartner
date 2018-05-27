package BusinessPartnerFR ;

sub verification {
	my ($ref1, $ref2, $ref3) = @_;
	my $llongueur = ${$ref1};
	my $ltitre = ${$ref2};
	my $lnum = ${$ref3};

	@verif1 = split(//,reverse($lnum));

# traitement des numeros pairs
	for ($i= 1 ; $i < scalar(@verif1) ; $i += 2 ) {
		$verif1[$i] = $verif1[$i] * 2;
		if ($verif1[$i] > 9){ $verif1[$i] -= 9;}
		}

#Cacul de la somme
	foreach $verif1 (@verif1) {
		$total += $verif1 ;}

# verification
	if ( $total % 10 == 0) {
		print "\n Le $ltitre est correct \n" ;}
		else { print "\n Le $ltitre est incorrect \n" ; exit;}
}

sub generer {
	
#$prefichier = sbl::prefichier ;
 
	open my($out), '>', "$prefichier $titre.txt";							
	
	for ($i=0; $i< scalar(@verif); $i +=2){
		for ($t=i+2; $t< scalar(@verif); $t +=2){
			if ($verif[$t] != $verif[$i]){
				$temp = $verif[$t];
				$verif[$t] = $verif[$i] ;
				$verif[$i] = $temp ;
				
				$num = "";
			    foreach $verif (@verif) { 
				$num = $num . $verif ;
				}
				&check(\$num,\$out) ;
				
				for ($j=1; $j< scalar(@verif); $j +=2){
					for ($s=$j+2; $s< scalar(@verif); $s +=2){
						if ($verif[$j] != $verif[$s]){
							$temp2 = $verif[$s];
							$verif[$s] = $verif[$j];
							$verif[$j] = $temp2 ;
							$num = "";
							foreach $verif (@verif) { 
								$num = $num . $verif ;
								}
							&check(\$num,\$out) ;}
							}	
				}
			}
		}	
	}
	
	
close $out;
}

sub check {
	my ($sref1, $sref2) = @_;
	my $code = ${$sref1};
	my $out = ${$sref2};



if (length($code) == 9){
	@verif2 = split(//,reverse($code));}
else {
	$SIREN = substr $code, 0, 9;
	@verif2 = split(//,reverse($SIREN));
}
# traitement des numeros pairs
	for ($k= 1 ; $k < scalar(@verif2) ; $k += 2 ) {
		$verif2[$k] = $verif2[$k] * 2;
		if ($verif2[$k] > 9){ $verif2[$k] -= 9;}
		}
$total1 = 0;
#Cacul de la somme
	foreach $verif2 (@verif2) {	$total1 += $verif2 ;}
# verification
	if ( $total1 % 10 == 0) { print $out "$code\n" ; }
	}

1;
