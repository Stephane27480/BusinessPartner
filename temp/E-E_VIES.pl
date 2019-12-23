#!/usr/bin/perl
use Business::Tax::VAT::Validation;
my $hvatn=Business::Tax::VAT::Validation->new();
#If your system is located behind a proxy :
#$hvatn=Business::Tax::VAT::Validation->new(-proxy => ['http', 'http://example.com:8001/']);

# Check number
$VAT = "FR21432673838";
#$VAT = "FR4532261790" ;
$cc = substr($VAT, 0,2);
 @ms=$hvatn->member_states;
$MS = join(" ", @ms);	
if ($MS =~ m/$cc/ ) {
	print "Match";}
else{
	print "Match pas : country:$cc\t list:$MS\n";}
 if ($hvatn->check($VAT)){
       print "OK\n";
	 $name = $hvatn->informations('name');
	$address = $hvatn->informations('address');
	print "$name\n";
	print "$address\n"
 }
 else {       print $hvatn->get_last_error; }

#%re=$hvatn->regular_expressions;
#	while (( $clef, $valeur) = each %re) {
#		print "$clef\t$valeur\n";}

#local check 
# returns 1 if valid 0 if invalid
$ok=$hvatn->local_check($VAT);
print "local check : $ok \n";

