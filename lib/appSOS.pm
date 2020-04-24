#
#===============================================================================
#
#         FILE:  appSOS.pm
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Stéphane Bailleul (SBL), sbl27480@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  18/04/2020 19:07:21
#     REVISION:  ---
#===============================================================================
package appSOS;
use Modern::Perl '2018';
use Moose;
use FindBin;
use lib "$FindBin::Bin/./";
use MojoTrello;

#Attributes
has 'key',		is	=>	'ro',	isa =>	'Str',	writer => '_set_key';
has 'token',	is	=>	'ro',	isa =>	'Str',	writer => '_set_token';
has 'idList',	is	=>	'ro',	isa =>	'Str',	writer => '_set_idList';
has 'desc', 	is	=>	'rw',	isa =>	'Str';
has 'msg',		is	=>	'ro',	isa	=>	'Str';
has 'install',	is	=>	'ro',	isa =>	'Str';	
has 'syst',		is	=>	'ro',	isa	=>	'Str';
has	'prod',		is	=>	'ro',	isa	=>	'Str';
has 'trello',	is	=>	'rw',	builder => '_build_trello',	predicate => 'has_trello';

sub set_attr {
	my $self = shift;
	$self->_set_token( '7c686ea6eff77afafd421ddea559fe39274dc5457756968b1a6b091cdc23068f');
	$self->_set_key( 'ee74875bff8a130455d5363683c99245' );
	# list Support
	$self->_set_idList( '5e9b35335c2852369f0a6cff');
}

sub main {
	my $self = shift ;
	my $name = $self->install . $self->syst . $self->msg ;
	my $response  = $self->addCard( $name );
	return $response ;
}

sub addCard {
	my $self = shift;
	my $name = $self->getName( );
	my %args = ( 'name' => $self->desc, 'idList' => $self->idList, 'desc' => $name  );
	$self->addLabel( \%args );
	return $self->trello->main( "create","card", \%args );
		#{name => $self->desc, idList => $self->idList, desc => $name  } );
   
}

sub _build_trello {
	my $self = shift;
	$self->set_attr( );
	return MojoTrello->new(
			key		=>	$self->key,
			token	=>	$self->token
		);
}	
sub getName {
	my $self = shift;
	my $title = $self->desc ;
	my $name = "** $title **\x0A\x0A---" ;
	if ( $self->install ) { $name .= "\x0A- Install: " . $self->install ;}
	if ( $self->syst ) { $name .= "\x0A- Syst: " . $self->syst ;}
	if ( $self->msg ) { $name .= "\x0A- Message : " . $self->msg ;}
	if ( $self->prod ) { $name .= "\x0A- Production : " . $self->prod ;}
	return $name ;
}

sub addLabel {
	my $self = shift;
	my $argsRef = shift;
	my $idLabels ;
=pod
=head1	
labels":[
{"id":"5e1751fa1dff2f7f45495480","idBoard":"5e174e70b5a95355e20a3530","name":"ABAP","color":"blue"},
{"id":"5e17521696d634410fe567bf","idBoard":"5e174e70b5a95355e20a3530","name":"UI5","color":"pink"},
{"id":"5e174e70af988c41f2f4c56e","idBoard":"5e174e70b5a95355e20a3530","name":"organisation","color":"purple"},
{"id":"5e17520ca9a3f9790ef500e2","idBoard":"5e174e70b5a95355e20a3530","name":"PERL","color":"lime"},
{"id":"5e17521f8fa5887dbb7784e6","idBoard":"5e174e70b5a95355e20a3530","name":"DB","color":"black"},
{"id":"5e174e70af988c41f2f4c568","idBoard":"5e174e70b5a95355e20a3530","name":"XSODATA / XSJS","color":"orange"},
{"id":"5e174e70af988c41f2f4c56c","idBoard":"5e174e70b5a95355e20a3530","name":"","color":"blue"},
{"id":"5e174e70af988c41f2f4c569","idBoard":"5e174e70b5a95355e20a3530","name":"","color":"green"},
{"id":"5e174e70af988c41f2f4c567","idBoard":"5e174e70b5a95355e20a3530","name":"","color":"red"},
{"id":"5e174e70af988c41f2f4c566","idBoard":"5e174e70b5a95355e20a3530","name":"","color":"yellow"},
{"id":"5e1752047fb1915d41afa156","idBoard":"5e174e70b5a95355e20a3530","name":"DOCKER","color":"sky"}
]
=cut

	if ( $self->msg =~ m/^_CDLG_BP/) { $idLabels = "5e1751fa1dff2f7f45495480" ; } #ABAP 
	elsif  ( $self->msg =~ m/^PERL/) { $idLabels = "5e17520ca9a3f9790ef500e2" ;} #Perl 
	else { $idLabels = "INIT"; }
				
	if ( $idLabels ne "INIT" ){
		$self->addArg($argsRef,'idLabels', $idLabels) ; 
	}
}

sub addArg {
	my ($self, $argsRef, $key, $value) = @_ ;
	$argsRef->{ $key } = $value ; 
	
}	
1;
